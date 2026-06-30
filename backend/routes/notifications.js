const express = require('express');
const router = express.Router();
const db = require('../db');

// Get notifications for current user
router.get('/', async (req, res) => {
  const { user_id } = req.query;
  try {
    // Gunakan casting ::text untuk keamanan perbandingan tipe data
    const result = await db.query(
      'SELECT * FROM notifications WHERE recipient_user_id::text = $1::text ORDER BY created_at DESC',
      [user_id]
    );
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Create notification
router.post('/', async (req, res) => {
  const { recipient_user_id, title, message, ticket_id, type } = req.body;
  try {
    const result = await db.query(
      'INSERT INTO notifications (recipient_user_id, title, message, ticket_id, type) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      [recipient_user_id, title, message, ticket_id, type]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Mark notification as read
router.put('/:id/read', async (req, res) => {
  try {
    await db.query('UPDATE notifications SET is_read = TRUE WHERE id = $1', [req.params.id]);
    res.json({ message: 'Notifikasi ditandai sudah dibaca' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Mark all notifications as read for a user
router.put('/read-all', async (req, res) => {
  const { user_id } = req.body;
  try {
    await db.query('UPDATE notifications SET is_read = TRUE WHERE recipient_user_id::text = $1::text', [user_id]);
    res.json({ message: 'Semua notifikasi ditandai sudah dibaca' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
