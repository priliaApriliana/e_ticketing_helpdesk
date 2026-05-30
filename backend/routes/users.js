const express = require('express');
const router = express.Router();
const db = require('../db');

// Get Users by Role (Digunakan untuk dropdown Assign Technical Support)
router.get('/', async (req, res) => {
  const { role } = req.query;
  try {
    let query = 'SELECT id, name, email, role FROM users';
    const params = [];
    if (role) {
      query += ' WHERE role = $1';
      params.push(role);
    }
    const result = await db.query(query, params);
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
