const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Import Routes
const authRoutes = require('./routes/auth');
const ticketRoutes = require('./routes/tickets');
const notificationRoutes = require('./routes/notifications');
const dashboardRoutes = require('./routes/dashboard');
const userRoutes = require('./routes/users');

// Register Routes
app.use('/api/auth', authRoutes);
app.use('/api/tickets', ticketRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/dashboard', dashboardRoutes);
app.use('/api/users', userRoutes);

// Root check
app.get('/', (req, res) => {
  res.send('E-Ticketing Helpdesk API is running...');
});

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
