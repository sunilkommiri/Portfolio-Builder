// backend/src/server.js
const app = require('./app');
const { testDbConnection } = require('./config/db'); // Import the test function

const PORT = process.env.PORT || 3001;

async function startServer() {
  try {
    // Test database connection on startup
    await testDbConnection();

    // Start the Express server
    app.listen(PORT, () => {
      console.log(`Server is running on port ${PORT}`);
      console.log(`API available at http://localhost:${PORT}`);
      if(process.env.NODE_ENV === 'development') {
        console.log(`CORS enabled for: ${process.env.CORS_ORIGIN}`);
      }
    });
  } catch (error) {
    console.error('Failed to start the server:', error);
    process.exit(1); // Exit if server can't start (e.g., DB connection failed critically)
  }
}

startServer();
