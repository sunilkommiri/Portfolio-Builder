// backend/src/controllers/portfolioController.js
const db = require('../config/db');

exports.getPortfolioByUserId = async (req, res, next) => {
  const { userId } = req.params;
  // In a real app, userId might be a username or a public ID.
  // Here, we'll assume it's the numeric user ID for simplicity.

  try {
    // This is a very simplified query. You'd likely join multiple tables
    // (users, portfolios, experiences, projects, skills, education)
    // to construct the full portfolio.
    const userQuery = 'SELECT id, name, email FROM users WHERE id = $1';
    const userResult = await db.query(userQuery, [userId]);

    if (userResult.rows.length === 0) {
      return res.status(404).json({ message: 'User not found.' });
    }

    // Example: Fetch portfolio details from a 'portfolios' table
    // Assume 'portfolios' table has user_id, bio, contact_info (JSONB), etc.
    const portfolioQuery = 'SELECT * FROM portfolios WHERE user_id = $1';
    const portfolioResult = await db.query(portfolioQuery, [userId]);

    // Combine user info and portfolio details
    const portfolioData = {
        user: userResult.rows[0],
        details: portfolioResult.rows.length > 0 ? portfolioResult.rows[0] : null,
        // You would add arrays for skills, projects, experiences, education here by querying other tables
        // skills: [{id: 1, name: 'React'}, ...],
        // projects: [{id: 1, title: 'Project X', ...}]
    };

    res.status(200).json(portfolioData);
  } catch (error) {
    next(error);
  }
};

exports.updateUserPortfolio = async (req, res, next) => {
  const loggedInUserId = req.user.userId; // From authMiddleware.verifyToken
  const { bio, skills, projects, experience, education, contact } = req.body; // Example fields

  try {
    // This is highly simplified. You'd need to handle:
    // 1. Updating the main 'portfolios' table (e.g., bio, contact).
    // 2. Managing related items in separate tables (skills, projects, etc.):
    //    - Deleting old items not present in the new request.
    //    - Updating existing items.
    //    - Adding new items.
    //    This often involves transactions for atomicity.

    // Example: Update bio in 'portfolios' table
    // (Create if not exists logic might be needed too - UPSERT)
    const updateBioQuery = 'UPDATE portfolios SET bio = $1, contact_info = $2 WHERE user_id = $3 RETURNING *';
    const portfolioResult = await db.query(updateBioQuery, [bio, JSON.stringify(contact) , loggedInUserId]);

    if (portfolioResult.rows.length === 0) {
        // If portfolio doesn't exist, create it
        const createPortfolioQuery = 'INSERT INTO portfolios (user_id, bio, contact_info) VALUES ($1, $2, $3) RETURNING *';
        const newPortfolio = await db.query(createPortfolioQuery, [loggedInUserId, bio, JSON.stringify(contact)]);
        return res.status(201).json({ message: 'Portfolio created and updated successfully.', portfolio: newPortfolio.rows[0] });
    }

    // Placeholder for updating skills, projects etc.
    // For skills (many-to-many with a join table user_skills):
    // 1. Clear existing skills for user.
    // 2. Add new skills.
    // (This needs careful transaction management)

    res.status(200).json({
      message: 'Portfolio updated successfully!',
      portfolio: portfolioResult.rows[0]
      // Include updated skills, projects etc. if you implement that part
    });
  } catch (error) {
    next(error);
  }
};
