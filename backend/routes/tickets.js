const express = require('express');
const router = express.Router();
const db = require('../db');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Konfigurasi Multer
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const dir = './uploads';
    if (!fs.existsSync(dir)) fs.mkdirSync(dir);
    cb(null, dir);
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  }
});
const upload = multer({ storage });

// Create ticket (Handle JSON and Multipart)
router.post('/', upload.array('attachments'), async (req, res) => {
  console.log('>>> Request Create Ticket Masuk');

  try {
    const { title, description, priority, category, created_by } = req.body;

    if (!title || !created_by) {
      return res.status(400).json({ message: 'Data tidak lengkap' });
    }

    const filePaths = req.files ? req.files.map(f => `/uploads/${f.filename}`) : [];

    const result = await db.query(
      'INSERT INTO tickets (title, description, priority, category, created_by, attachments, status) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *',
      [title, description, priority || 'medium', category || 'Lainnya', created_by, filePaths, 'open']
    );

    const newTicketId = result.rows[0].id;

    const fullTicket = await db.query(
      'SELECT t.*, u.name as created_by_name FROM tickets t LEFT JOIN users u ON t.created_by = u.id WHERE t.id = $1',
      [newTicketId]
    );

    const newTicket = fullTicket.rows[0];

    // NOTIFIKASI UNTUK HELPDESK & ADMIN
    try {
        const staffs = await db.query("SELECT id FROM users WHERE role IN ('admin', 'helpdesk')");
        for (const staff of staffs.rows) {
          await db.query(
            'INSERT INTO notifications (recipient_user_id, title, message, ticket_id, type) VALUES ($1, $2, $3, $4, $5)',
            [staff.id, 'Tiket Baru Masuk', `${newTicket.created_by_name} membuat tiket: ${title}`, newTicketId, 'new_ticket']
          );
        }
    } catch (notifErr) {
        console.error('Gagal membuat notifikasi:', notifErr.message);
    }

    const io = req.app.get('socketio');
    if (io) {
      console.log('>>> Emitting socket events...');
      io.emit('ticket_created', newTicket);
      io.emit('new_notification', { type: 'new_ticket', ticketId: newTicketId }); // PENTING: Untuk real-time refresh
      io.emit('stats_updated');
    }

    res.status(201).json(newTicket);
  } catch (err) {
    console.error('!!! DATABASE ERROR:', err.message);
    res.status(500).json({ message: 'Gagal membuat tiket: ' + err.message });
  }
});

// Update status and assign
router.put('/:id/status', async (req, res) => {
  const { status, assigned_to, changed_by, changed_by_name, note } = req.body;
  const io = req.app.get('socketio');
  try {
    const currentTicketQuery = await db.query('SELECT status, created_by, title, assigned_to FROM tickets WHERE id = $1', [req.params.id]);
    if (currentTicketQuery.rows.length === 0) return res.status(404).json({ message: 'Tiket tidak ditemukan' });

    const currentTicket = currentTicketQuery.rows[0];
    const oldStatus = currentTicket.status;
    const oldAssignee = currentTicket.assigned_to;

    const result = await db.query(
      'UPDATE tickets SET status = COALESCE($1, status), assigned_to = COALESCE($2, assigned_to) WHERE id = $3 RETURNING *',
      [status, assigned_to, req.params.id]
    );

    const updatedTicket = result.rows[0];

    // NOTIFIKASI UPDATE STATUS UNTUK PEMILIK TIKET (USER)
    if (status && status !== oldStatus) {
      await db.query(
        'INSERT INTO ticket_logs (ticket_id, changed_by, changed_by_name, old_status, new_status, note) VALUES ($1, $2, $3, $4, $5, $6)',
        [req.params.id, changed_by, changed_by_name, oldStatus, status, note || 'Status diupdate']
      );

      try {
          await db.query(
            'INSERT INTO notifications (recipient_user_id, title, message, ticket_id, type) VALUES ($1, $2, $3, $4, $5)',
            [currentTicket.created_by, 'Update Status Tiket', `Tiket "${currentTicket.title}" kini berstatus: ${status}`, req.params.id, 'status_update']
          );
      } catch (notifErr) {
          console.error('Gagal membuat notifikasi update:', notifErr.message);
      }
    }

    // NOTIFIKASI PENUGASAN UNTUK TECHNICAL SUPPORT (ASSIGNEE)
    if (assigned_to && assigned_to !== oldAssignee) {
        try {
            await db.query(
              'INSERT INTO notifications (recipient_user_id, title, message, ticket_id, type) VALUES ($1, $2, $3, $4, $5)',
              [assigned_to, 'Tugas Tiket Baru', `Anda ditugaskan untuk menangani tiket: "${currentTicket.title}"`, req.params.id, 'ticket_assigned']
            );

            if (io) {
                // Emit notif spesifik untuk assignee
                io.emit('new_notification', {
                  type: 'ticket_assigned',
                  recipient_id: assigned_to,
                  ticketId: req.params.id
                });
            }
        } catch (assignNotifErr) {
            console.error('Gagal membuat notifikasi assignment:', assignNotifErr.message);
        }
    }

    if (io) {
      io.emit('ticket_updated', updatedTicket);
      io.emit('ticket_status_updated', { ticket_id: req.params.id, new_status: status || oldStatus });
      io.emit('new_notification', { type: 'status_update', ticketId: req.params.id });
      io.emit('stats_updated');
    }

    res.json(updatedTicket);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// GET route remains robust
router.get('/', async (req, res) => {
  const { user_id, created_by, assigned_to, status } = req.query;
  try {
    let query = `
      SELECT t.*, u.name as created_by_name, a.name as assigned_to_name
      FROM tickets t
      LEFT JOIN users u ON t.created_by = u.id
      LEFT JOIN users a ON t.assigned_to = a.id
      WHERE 1=1
    `;
    const params = [];
    if (user_id) { params.push(user_id); query += ` AND (t.created_by = $${params.length} OR t.assigned_to = $${params.length})`; }
    if (created_by) { params.push(created_by); query += ` AND t.created_by = $${params.length}`; }
    if (assigned_to) { params.push(assigned_to); query += ` AND t.assigned_to = $${params.length}`; }
    if (status) { params.push(status); query += ` AND t.status = $${params.length}`; }
    query += ' ORDER BY t.created_at DESC';
    const result = await db.query(query, params);
    res.json(result.rows);
  } catch (err) { res.status(500).json({ message: err.message }); }
});

router.get('/:id', async (req, res) => {
  try {
    const result = await db.query(
      `SELECT t.*, u.name as created_by_name, a.name as assigned_to_name FROM tickets t LEFT JOIN users u ON t.created_by = u.id LEFT JOIN users a ON t.assigned_to = a.id WHERE t.id = $1`,
      [req.params.id]
    );
    if (result.rows.length === 0) return res.status(404).json({ message: 'Tiket tidak ditemukan' });
    res.json(result.rows[0]);
  } catch (err) { res.status(500).json({ message: err.message }); }
});

router.get('/:id/logs', async (req, res) => {
  try {
    const result = await db.query('SELECT * FROM ticket_logs WHERE ticket_id = $1 ORDER BY created_at DESC', [req.params.id]);
    res.json({ success: true, data: result.rows });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
});

router.put('/:id/unassign', async (req, res) => {
  const io = req.app.get('socketio');
  try {
    const result = await db.query("UPDATE tickets SET assigned_to = NULL, status = 'open' WHERE id = $1 RETURNING *", [req.params.id]);
    if (io) {
      io.emit('ticket_updated', result.rows[0]);
      io.emit('new_notification');
      io.emit('stats_updated');
    }
    res.json(result.rows[0]);
  } catch (err) { res.status(500).json({ message: err.message }); }
});

router.get('/:id/comments', async (req, res) => {
  try {
    const result = await db.query(`SELECT c.*, u.name as user_name, u.role as user_role FROM comments c JOIN users u ON c.user_id = u.id WHERE c.ticket_id = $1 ORDER BY c.created_at ASC`, [req.params.id]);
    res.json(result.rows);
  } catch (err) { res.status(500).json({ message: err.message }); }
});

router.post('/:id/comments', async (req, res) => {
  const { user_id, content } = req.body;
  const io = req.app.get('socketio');
  try {
    const result = await db.query('INSERT INTO comments (ticket_id, user_id, content) VALUES ($1, $2, $3) RETURNING *', [req.params.id, user_id, content]);
    const commentWithUser = await db.query(`SELECT c.*, u.name as user_name, u.role as user_role FROM comments c JOIN users u ON c.user_id = u.id WHERE c.id = $1`, [result.rows[0].id]);
    if (io) io.emit('comment_added', { ticketId: req.params.id, comment: commentWithUser.rows[0] });
    res.status(201).json(commentWithUser.rows[0]);
  } catch (err) { res.status(500).json({ message: err.message }); }
});

module.exports = router;
