const express = require('express');
const router = express.Router();
const db = require('../db');

// Get all tickets with filters
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

    // Filter by user_id (either created or assigned - Legacy/General)
    if (user_id) {
      params.push(user_id);
      query += ` AND (t.created_by = $${params.length} OR t.assigned_to = $${params.length})`;
    }

    // Filter specifically by created_by
    if (created_by) {
      params.push(created_by);
      query += ` AND t.created_by = $${params.length}`;
    }

    // Filter specifically by assigned_to
    if (assigned_to) {
      params.push(assigned_to);
      query += ` AND t.assigned_to = $${params.length}`;
    }

    if (status) {
      params.push(status);
      query += ` AND t.status = $${params.length}`;
    }

    query += ' ORDER BY t.created_at DESC';
    const result = await db.query(query, params);
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Get ticket detail
router.get('/:id', async (req, res) => {
  try {
    const result = await db.query(
      `SELECT t.*, u.name as created_by_name, a.name as assigned_to_name
       FROM tickets t
       LEFT JOIN users u ON t.created_by = u.id
       LEFT JOIN users a ON t.assigned_to = a.id
       WHERE t.id = $1`,
      [req.params.id]
    );
    if (result.rows.length === 0) return res.status(404).json({ message: 'Tiket tidak ditemukan' });
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Create ticket
router.post('/', async (req, res) => {
  const { title, description, priority, category, created_by, attachments } = req.body;
  const io = req.app.get('socketio');
  try {
    const result = await db.query(
      'INSERT INTO tickets (title, description, priority, category, created_by, attachments) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *',
      [title, description, priority, category, created_by, attachments || []]
    );

    // Fetch with created_by_name
    const newTicketResult = await db.query(
      `SELECT t.*, u.name as created_by_name
       FROM tickets t
       LEFT JOIN users u ON t.created_by = u.id
       WHERE t.id = $1`,
      [result.rows[0].id]
    );

    const newTicket = newTicketResult.rows[0];

    // Emit real-time event
    if (io) {
        io.emit('ticket_created', newTicket);
        io.emit('stats_updated');
    }

    res.status(201).json(newTicket);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Update status and assign
router.put('/:id/status', async (req, res) => {
  const { status, assigned_to } = req.body;
  const io = req.app.get('socketio');
  try {
    const result = await db.query(
      'UPDATE tickets SET status = COALESCE($1, status), assigned_to = COALESCE($2, assigned_to) WHERE id = $3 RETURNING *',
      [status, assigned_to, req.params.id]
    );

    const updatedTicket = result.rows[0];

    // Emit real-time event
    if (io) {
        io.emit('ticket_updated', updatedTicket);
        io.emit('stats_updated');
    }

    res.json(updatedTicket);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Unassign ticket
router.put('/:id/unassign', async (req, res) => {
  const io = req.app.get('socketio');
  try {
    const result = await db.query(
      "UPDATE tickets SET assigned_to = NULL, status = 'open' WHERE id = $1 RETURNING *",
      [req.params.id]
    );

    if (io) {
        io.emit('ticket_updated', result.rows[0]);
        io.emit('stats_updated');
    }

    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Get comments
router.get('/:id/comments', async (req, res) => {
  try {
    const result = await db.query(
      `SELECT c.*, u.name as user_name, u.role as user_role
       FROM comments c
       JOIN users u ON c.user_id = u.id
       WHERE c.ticket_id = $1
       ORDER BY c.created_at ASC`,
      [req.params.id]
    );
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Add comment
router.post('/:id/comments', async (req, res) => {
  const { user_id, content } = req.body;
  const io = req.app.get('socketio');
  try {
    const result = await db.query(
      'INSERT INTO comments (ticket_id, user_id, content) VALUES ($1, $2, $3) RETURNING *',
      [req.params.id, user_id, content]
    );

    // Fetch comment with user info for response
    const commentWithUser = await db.query(
      `SELECT c.*, u.name as user_name, u.role as user_role
       FROM comments c
       JOIN users u ON c.user_id = u.id
       WHERE c.id = $1`,
      [result.rows[0].id]
    );

    const newComment = commentWithUser.rows[0];

    if (io) {
        io.emit('comment_added', { ticketId: req.params.id, comment: newComment });
    }

    res.status(201).json(newComment);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
