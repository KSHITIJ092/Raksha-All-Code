const mongoose = require('mongoose');
const PersonalInfo = require('./models/personalInfoSchema');

// MongoDB connection URL
const dbURI = 'mongodb://localhost:27017/women_safety_app'; // Replace 'women_safety_app' with the actual database name if different

// Connect to MongoDB and insert dummy data
mongoose.connect(dbURI, { useNewUrlParser: true, useUnifiedTopology: true })
  .then(() => {
    console.log('MongoDB connected');

    return PersonalInfo.insertMany([
      {
        name: "Ashitosh Sabale",
        mobileNo: "9876543210",
        gender: "Male",
        selectedState: "Maharashtra",
        pinCode: "411001",
        address: "123 Main Street, Pune",
        aadharNo: "123456789012",
        securityPin: "1234",
        emergencyContacts: [
          { name: "Ram Shekade", phone: "9876543211" },
          { name: "Shyam Rao", phone: "9876543212" },
        ],
      },
      {
        name: "Priya Desai",
        mobileNo: "9876501234",
        gender: "Female",
        selectedState: "Gujarat",
        pinCode: "380001",
        address: "456 Second Avenue, Ahmedabad",
        aadharNo: "234567890123",
        securityPin: "5678",
        emergencyContacts: [
          { name: "Ravi Kumar", phone: "9876501235" },
          { name: "Anjali Mehta", phone: "9876501236" },
        ],
      },
    ]);
  })
  .then((result) => {
    console.log('Dummy data inserted:', result);
    mongoose.disconnect();
  })
  .catch((error) => {
    console.error('Error inserting dummy data:', error);
    mongoose.disconnect();
  });
