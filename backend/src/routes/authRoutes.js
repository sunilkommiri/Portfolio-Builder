// backend/src/routes/authRoutes.js
const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
// const { validateRegistration, validateLogin } = require('../middleware/validators'); // Example validator middleware

// POST /api/auth/register
router.post('/register', /* validateRegistration, */ authController.registerUser);

// POST /api/auth/login
router.post('/login', /* validateLogin, */ authController.loginUser);

// GET /api/auth/me (Example protected route to get current user info)
// router.get('/me', authMiddleware.verifyToken, authController.getCurrentUser);

module.exports = router;
