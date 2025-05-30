const PersonalInfo = require('../models/personalInfoSchema');

// Function to save personal info
const createPersonalInfo = async (req, res) => {
  try {
    const { name, mobileNo, gender, selectedState, pinCode, address, aadharNo, securityPin, emergencyContacts } = req.body;

    // Create a new PersonalInfo document
    const newPersonalInfo = new PersonalInfo({
      name,
      mobileNo,
      gender,
      selectedState,
      pinCode,
      address,
      aadharNo,
      securityPin,
      emergencyContacts,
    });

    console.log('Received Data:', newPersonalInfo); // Check if data is being received

    // Save the document to MongoDB
    const savedInfo = await newPersonalInfo.save();

    // Respond with the saved data
    res.status(201).json({
      message: 'Personal information saved successfully',
      data: savedInfo,
    });
  } catch (error) {
    console.error('Error saving personal info:', error);
    res.status(500).json({
      message: 'Error saving personal information',
      error: error.message,
    });
  }
};

module.exports = { createPersonalInfo };
