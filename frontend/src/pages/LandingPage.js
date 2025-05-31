// src/pages/LandingPage.js
import React from 'react';
import { Link } from 'react-router-dom';

function LandingPage() {
  return (
    <div className="text-center py-10 bg-white dark:bg-gray-800 shadow-md rounded-lg">
      <h1 className="text-4xl font-bold text-gray-900 dark:text-white mb-6">Welcome to PortfolioPro!</h1>
      <p className="text-lg text-gray-700 dark:text-gray-300 mb-8">
        Craft your professional story. Build and showcase your stunning portfolio with ease.
      </p>
      <div className="space-x-4">
        <Link
          to="/signup"
          className="bg-indigo-600 hover:bg-indigo-700 text-white font-semibold py-3 px-6 rounded-lg shadow-md transition duration-150"
        >
          Get Started
        </Link>
        <Link
          to="/login"
          className="bg-gray-200 hover:bg-gray-300 text-gray-800 dark:bg-gray-700 dark:hover:bg-gray-600 dark:text-white font-semibold py-3 px-6 rounded-lg shadow-md transition duration-150"
        >
          Login
        </Link>
      </div>
    </div>
  );
}
export default LandingPage;
