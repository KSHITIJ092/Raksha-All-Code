// models/personalInfoSchema.js
const mongoose = require('mongoose');

// Define the schema for Personal Information
const personalInfoSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    match: [/^[a-zA-Z\s]+$/, 'Please enter a valid name'],
  },
  mobileNo: {
    type: String,
    required: true,
    match: [/^\d{10}$/, 'Please enter a valid 10-digit mobile number'],
  },
  gender: {
    type: String,
    required: true,
    enum: ['Male', 'Female', 'Other'],
  },
  selectedState: {
    type: String,
    required: true,
  },
  pinCode: {
    type: String,
    required: true,
    match: [/^\d{6}$/, 'Please enter a valid 6-digit pin code'],
  },
  address: {
    type: String,
    required: true,
  },
  aadharNo: {
    type: String,
    required: true,
    match: [/^\d{12}$/, 'Please enter a valid 12-digit Aadhar number'],
  },
  securityPin: {
    type: String,
    required: true,
    match: [/^\d{4}$/, 'Please enter a valid 4-digit security pin'],
  },
  emergencyContacts: [
    {
      name: {
        type: String,
        required: true,
      },
      phone: {
        type: String,
        required: true,
        match: [/^\d{10}$/, 'Please enter a valid phone number'],
      },
    },
  ],
}, { timestamps: true });

// Create a model based on the schema
const PersonalInfo = mongoose.model('PersonalInfo', personalInfoSchema);

module.exports = PersonalInfo;
