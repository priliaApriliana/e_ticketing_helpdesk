const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../db');

// Register
router.post('/register', async (req, res) => {
  const { name, email, password } = req.body;
  try {
    const hashedPassword = await bcrypt.hash(password, 10);
    const result = await db.query(
      'INSERT INTO users (name, email, password) VALUES ($1, $2, $3) RETURNING id, name, email, role',
      [name, email, hashedPassword]
    );
    res.status(201).json({ message: 'Registrasi berhasil', user: result.rows[0] });
  } catch (err) {
    if (err.code === '23505') {
      return res.status(400).json({ message: 'Email sudah terdaftar' });
    }
    res.status(500).json({ message: 'Terjadi kesalahan server' });
  }
});

// Login
router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  try {
    const result = await db.query('SELECT * FROM users WHERE email = $1', [email]);
    if (result.rows.length === 0) {
      return res.status(400).json({ message: 'Email atau password salah' });
    }

    const user = result.rows[0];
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: 'Email atau password salah' });
    }

    const token = jwt.sign({ id: user.id, role: user.role }, process.env.JWT_SECRET, { expiresIn: '7d' });
    delete user.password;
    res.json({ token, user });
  } catch (err) {
    res.status(500).json({ message: 'Terjadi kesalahan server' });
  }
});

// Reset Password (Endpoint Baru untuk sinkronisasi dengan Flutter)
router.post('/reset-password', async (req, res) => {
  const { email, new_password } = req.body;
  try {
    const hashedPassword = await bcrypt.hash(new_password, 10);
    const result = await db.query(
      'UPDATE users SET password = $1 WHERE email = $2 RETURNING id',
      [hashedPassword, email]
    );
    if (result.rows.length === 0) return res.status(404).json({ message: 'User tidak ditemukan' });
    res.json({ message: 'Password berhasil direset' });
  } catch (err) {
    res.status(500).json({ message: 'Gagal reset password' });
  }
});

// Change Password
router.post('/change-password', async (req, res) => {
  const { old_password, new_password } = req.body;
  // Note: Dalam real app, ambil user_id dari JWT middleware
  // Untuk demo, kita asumsikan middleware sudah ada atau kirim email di body
  res.json({ message: 'Fitur ganti password berhasil diakses' });
});

module.exports = router;
