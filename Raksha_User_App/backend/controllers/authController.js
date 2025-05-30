// controllers/authController.js
const User = require('../models/user');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const PersonalInfo = require('../models/personalInfoSchema');


// Environment variables
const SECRET_KEY = process.env.JWT_SECRET || 'default_secret_key'; // Replace with a secure key

// Signup controller
const signup = async (req, res) => {
  try {
    const { username, email, password, mobile } = req.body;

    // Input validation
    if (!username || !email || !password || !mobile) {
      return res.status(400).json({ error: 'All fields are required' });
    }

    // Check if email or username already exists
    const existingUser = await User.findOne({ $or: [{ email }, { username },{mobile}] });
    if (existingUser) {
      return res.status(400).json({ error: 'Email or username already exists' });
    }

    // Hash the password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create and save the user
    const newUser = await User.create({
      username,
      email,
      mobile,
      password: hashedPassword,
    });

    // Exclude the password from the response
    const { password: _, ...userWithoutPassword } = newUser.toObject();

    res.status(201).json({
      message: 'User created successfully',
      user: userWithoutPassword,
    });
  } catch (error) {
    console.error('Error during signup:', error.message);
    res.status(500).json({ error: 'Signup failed due to a server error' });
  }
};

// Login controller
const login = async (req, res) => {
  try {
    const { mobile, password } = req.body;

    // Input validation
    if (!mobile || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    // Check if user exists
    const user = await User.findOne({ mobile });
    
    if (!user) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }
    const profileinfo= await PersonalInfo.findOne({name:user.username});
    let profile=false;
    if(profileinfo) {
      profile = true;
    }
    // // Verify password
    // const isPasswordValid = await bcrypt.compare(password, user.password);
    // if (!isPasswordValid) {
    //   return res.status(401).json({ error: 'Invalid email or password' });
    // }

    // Generate a JWT token
    const token = jwt.sign(
      { id: user._id, username: user.username },
      SECRET_KEY,
      { expiresIn: '1h' }
    );

    // Exclude the password from the response
    const { password: _, ...userWithoutPassword } = user.toObject();

    res.status(200).json({
      message: 'Login successful',
      token,
      user: userWithoutPassword,
      profile: profile
    });
  } catch (error) {
    console.error('Error during login:', error.message);
    res.status(500).json({ error: 'Login failed due to a server error' });
  }
};

module.exports = { signup, login };