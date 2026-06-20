const express = require('express');
const router = express.Router();
const db = require('../db');

// Get all users with optional role filter
router.get('/', async (req, res) => {
  const { role } = req.query;
  try {
    let query = 'SELECT id, name, email, role, created_at FROM users';
    const params = [];
    if (role) {
      query += ' WHERE role = $1';
      params.push(role);
    }
    query += ' ORDER BY created_at DESC';
    const result = await db.query(query, params);
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Update user role
router.put('/:id/role', async (req, res) => {
  const { role } = req.body;
  const { id } = req.params;
  try {
    const result = await db.query(
      'UPDATE users SET role = $1 WHERE id = $2 RETURNING id, name, email, role',
      [role, id]
    );
    if (result.rows.length === 0) return res.status(404).json({ message: 'User tidak ditemukan' });
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Delete user (Non-aktifkan)
router.delete('/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const result = await db.query('DELETE FROM users WHERE id = $1 RETURNING id', [id]);
    if (result.rows.length === 0) return res.status(404).json({ message: 'User tidak ditemukan' });
    res.json({ message: 'User berhasil dihapus', id: result.rows[0].id });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
