// backend/src/routes/portfolioRoutes.js
const express = require('express');
const router = express.Router();
const portfolioController = require('../controllers/portfolioController');
const authMiddleware = require('../middleware/authMiddleware');

// GET /api/portfolio/:userId (Public route to view a portfolio)
router.get('/:userId', portfolioController.getPortfolioByUserId);

// PUT /api/portfolio (Protected route to update logged-in user's portfolio)
// Assumes user ID is derived from JWT token after verification
router.put('/', authMiddleware.verifyToken, portfolioController.updateUserPortfolio);

// You might have more granular routes:
// POST /api/portfolio/experience
// DELETE /api/portfolio/projects/:projectId
// etc.

module.exports = router;
