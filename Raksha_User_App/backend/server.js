require('dotenv').config();  // Load .env variables
const http = require('http');
const app = require('./app');
const connectDB = require('./config/db');

// Connect to MongoDB
connectDB();

// Create the server
const server = http.createServer(app);

// Define the PORT and start the server
const PORT = process.env.PORT || 5000;  // Use PORT from .env if available
server.listen(PORT, () => {

  console.log(`Server running on http://192.168.93.176:${PORT}`);
});
