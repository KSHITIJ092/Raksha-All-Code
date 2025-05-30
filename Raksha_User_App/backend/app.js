const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const fs = require('fs');
const multer = require('multer');
const path = require('path');
const authRoutes = require('./routes/auth');
const personalInfoRoutes = require('./routes/personalInfo');
const {security} = require('./controllers/security');
const app = express();


  
// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(express.json());

// Routes
app.use('/api', authRoutes); // For authentication routes
app.use('/api/personalinfo', personalInfoRoutes); // For personal info routes

app.post('/security/:name',security)

app.post('/upload', (req, res) => {
    
    if (!req.file) {
      return res.status(400).send('No file uploaded.');
    }
    res.status(200).send({
      message: 'File uploaded successfully!',
      filePath: req.file.path,
    });
  });
  
// Export the app
module.exports = app;