const express = require('express');
const router = express.Router();
const { createPersonalInfo } = require('../controllers/personalInfoController');
const PersonalInfo = require('../models/personalInfoSchema');

// Route for creating personal information
router.post('/', createPersonalInfo); // This is correctly set, as '/api/personalinfo' is prefixed in app.js

// GET personal info by ID
router.get('/:name', async (req, res) => {
  const name = req.params.name;  // Grabs the user ID from the URL parameter
  try {
    const user = await PersonalInfo.findOne({name:name}); // Query database to find the user by ID
    if (user) {
      res.status(200).json(user); // Send user data back
    } else {
      res.status(404).send({ message: 'User not found' }); // Handle if user is not found
    }
  } catch (error) {
    res.status(500).send({ message: 'Server error', error: error.message }); // Handle server errors
  }
});

module.exports = router;
