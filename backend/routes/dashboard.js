const express = require('express');
const router = express.Router();
const db = require('../db');

// GET /api/dashboard/metrics
router.get('/metrics', async (req, res) => {
  const { user_id } = req.query;
  try {
    let query = 'SELECT status, COUNT(*) FROM tickets';
    const params = [];

    if (user_id) {
      query += ' WHERE created_by = $1 OR assigned_to = $1';
      params.push(user_id);
    }

    query += ' GROUP BY status';
    const result = await db.query(query, params);

    const stats = {
      total: 0,
      open: 0,
      in_progress: 0,
      resolved: 0,
      closed: 0
    };

    result.rows.forEach(row => {
      const count = parseInt(row.count);
      stats[row.status] = count;
      stats.total += count;
    });

    res.json(stats);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
