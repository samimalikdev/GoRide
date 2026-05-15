const express = require('express');
const cors = require('cors');
require('dotenv').config();

const logger = require('./src/middlewares/logger');
const authRoutes = require('./src/routes/authRoutes');
const rideRoutes = require('./src/routes/rideRoutes');
const driverRoutes = require('./src/routes/driverRoutes');
const walletRoutes = require('./src/routes/walletRoutes');
const chatRoutes = require('./src/routes/chatRoutes');


const http = require('http');
const { Server } = require('socket.io');

const app = express();
app.set('trust proxy', true);

const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

const PORT = process.env.PORT || 3000;

app.set('io', io);
global.io = io; 

app.use(cors());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb', extended: true }));
app.use(logger);

const { initSocket } = require('./src/socket/socketHandler');
initSocket(io);


// Routes
app.use('/api/auth', authRoutes);
app.use('/api/drivers', driverRoutes);
app.use('/api/wallet', walletRoutes);
app.use('/api/chat', chatRoutes);
app.use('/api', rideRoutes);


app.get('/health', (req, res) => res.json({ status: 'ok', message: 'GoRide Backend is healthy!' }));
app.get('/', (req, res) => res.send('GoRide Backend API is live!'));

app.use((err, req, res, next) => {
  console.error('BACKEND ERROR:', err);
  const statusCode = err.statusCode || 500;
  const status = err.status || 'error';

  res.status(statusCode).json({
    status: status,
    message: err.message,
  });
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`Server is running on http://0.0.0.0:${PORT}`);
});

process.on('uncaughtException', (err) => console.error('UNCAUGHT EXCEPTION:', err));
