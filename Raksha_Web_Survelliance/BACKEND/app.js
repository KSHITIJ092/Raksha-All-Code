const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const path = require('path');
const cors = require('cors');
const fs = require('fs');
const { log } = require('console');
const app = express();
const server = http.createServer(app);

// CORS configuration
app.use(cors({
  origin: 'http://localhost:5173', // Update to your frontend URL for production
  methods: ['GET', 'POST'],
  credentials: true
}));

// Socket.IO server with CORS settings
const io = new Server(server, {
  cors: {
    origin: "*", // For production, update this to the frontend URL
  }
});

app.set('view engine', 'ejs');
app.use(express.static(path.join(__dirname, 'public')));

app.get('/capture', (req, res) => {
  res.render('capture');
});
app.get('/capture2', (req, res) => {
  res.render('capture2');
});
app.get('/display', (req, res) => {
  res.render('display');
});

io.on('connection', (socket) => {
  console.log('A user connected:', socket.id);

  // Relay video stream data from specific cameras
  socket.on('video-stream', ({ cameraId, data }) => {
    // Send the data only to viewers of the specific camera
    socket.broadcast.emit(`display-stream-${cameraId}`, data);
  });

  // Log data received on the 'image-capture' event
  socket.on('image-capture', async ({ cameraId, dataImg }) => {
    try {
      console.log(`Received image from camera ${cameraId}`);
      console.log(dataImg)

      // Convert ArrayBuffer to Buffer (binary format)
      const buffer = Buffer.from(dataImg);

      // Send the binary buffer to Flask
      const response = await axios.post(FLASK_SERVER_URL, buffer, {
        headers: {
          'Content-Type': 'application/octet-stream', // Specify raw binary content
        },
      });
      io.emit(`receive-alerts-${cameraId}`, response.data);
      console.log('Response from Flask:', response.data);
    } catch (error) {
      console.error('Error sending image to Flask:', error.message);
    }
  });
  socket.on('userDetails', (data) => {
    console.log('Received user details:', data);
    // Process the data and broadcast the alert
    io.emit('alert-userDetails', data);
  });
  socket.on('update-status', (data) => {
    console.log('Received user details:', data);
    // Process the data and broadcast the alert
    io.emit('alert-update', data);
  });


  socket.on('sendacknowledgment', (data) => {
    // console.log('Received user details:', data);
    // Process the data and broadcast the alert
    io.emit('acknowledgment', data);
  });
  socket.on('sendImage', (data) => {
    const { image, name } = data;

    // Convert the image from Base64 string to Buffer
    const buffer = Buffer.from(image, 'base64');  // Assuming the image is sent in base64 format

    // Broadcast the image to other clients in base64 format
    socket.broadcast.emit('receiveImage', { image, name });
  });

  socket.on('disconnect', () => {
    console.log('User disconnected:', socket.id);
  });
});

const PORT = 3000;
server.listen(PORT, () => {
  console.log(`Server running at http://192.168.93.176:${PORT}`);
});
