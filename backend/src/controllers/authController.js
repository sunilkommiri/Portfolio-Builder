// backend/src/controllers/authController.js
const db = require('../config/db'); // Your db query function
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

exports.registerUser = async (req, res, next) => {
  const { name, email, password } = req.body;

  // Basic validation (in a real app, use a library like Joi or express-validator)
  if (!name || !email || !password) {
    return res.status(400).json({ message: 'Please provide name, email, and password.' });
  }

  try {
    // Check if user already exists
    const userExists = await db.query('SELECT * FROM users WHERE email = $1', [email]);
    if (userExists.rows.length > 0) {
      return res.status(409).json({ message: 'User with this email already exists.' });
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Insert new user (assuming you have a 'users' table)
    // Example users table: id (SERIAL PRIMARY KEY), name (VARCHAR), email (VARCHAR UNIQUE), password_hash (VARCHAR), created_at (TIMESTAMP)
    const newUser = await db.query(
      'INSERT INTO users (name, email, password_hash) VALUES ($1, $2, $3) RETURNING id, name, email, created_at',
      [name, email, hashedPassword]
    );

    // Create portfolio entry (assuming a 'portfolios' table linked to users)
    // Example portfolios table: id (SERIAL PRIMARY KEY), user_id (INT REFERENCES users(id)), bio (TEXT), etc.
    // await db.query('INSERT INTO portfolios (user_id) VALUES ($1)', [newUser.rows[0].id]);


    // Generate JWT
    const token = jwt.sign(
        { userId: newUser.rows[0].id, email: newUser.rows[0].email },
        process.env.JWT_SECRET,
        { expiresIn: process.env.JWT_EXPIRES_IN }
    );

    res.status(201).json({
      message: 'User registered successfully!',
      user: newUser.rows[0],
      token
    });
  } catch (error) {
    next(error); // Pass error to global error handler
  }
};

exports.loginUser = async (req, res, next) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: 'Please provide email and password.' });
  }

  try {
    const result = await db.query('SELECT * FROM users WHERE email = $1', [email]);
    if (result.rows.length === 0) {
      return res.status(401).json({ message: 'Invalid credentials (user not found).' });
    }

    const user = result.rows[0];
    const isMatch = await bcrypt.compare(password, user.password_hash);

    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid credentials (password incorrect).' });
    }

    const token = jwt.sign(
      { userId: user.id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN }
    );

    // Omit password_hash from the response
    const { password_hash, ...userWithoutPassword } = user;

    res.status(200).json({
      message: 'Login successful!',
      user: userWithoutPassword,
      token
    });
  } catch (error) {
    next(error);
  }
};

// exports.getCurrentUser = async (req, res, next) => {
//   // req.user is attached by verifyToken middleware
//   try {
//     const result = await db.query('SELECT id, name, email, created_at FROM users WHERE id = $1', [req.user.userId]);
//     if (result.rows.length === 0) {
//       return res.status(404).json({ message: 'User not found.' });
//     }
//     res.status(200).json(result.rows[0]);
//   } catch (error) {
//     next(error);
//   }
// };
