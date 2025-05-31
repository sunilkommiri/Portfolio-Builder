// backend/src/config/db.js
const { Pool } = require('pg');
require('dotenv').config(); // To load environment variables from .env file

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_DATABASE,
  password: process.env.DB_PASSWORD,
  port: parseInt(process.env.DB_PORT || '5432', 10),
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false, // Basic SSL for production if needed
});

pool.on('connect', () => {
  console.log('Connected to the PostgreSQL database!');
});

pool.on('error', (err) => {
  console.error('Unexpected error on idle client', err);
  process.exit(-1);
});

// Test the connection (optional, but good for startup)
async function testDbConnection() {
  try {
    const client = await pool.connect();
    console.log(`Successfully connected to PostgreSQL DB: ${client.database} on host ${client.host}`);
    client.release();
  } catch (error) {
    console.error('Failed to connect to the database:', error);
    // Potentially exit or retry logic here for critical DB connection
  }
}

module.exports = {
  query: (text, params) => pool.query(text, params),
  pool, // Export pool if you need direct access for transactions etc.
  testDbConnection,
};
