// src/pages/DashboardPage.js
import React from 'react';
import { Link } from 'react-router-dom';

function DashboardPage() {
  // Fetch user-specific data here
  return (
    <div className="p-6 bg-white dark:bg-gray-800 shadow-md rounded-lg">
      <h2 className="text-2xl font-semibold text-gray-900 dark:text-white mb-6">User Dashboard</h2>
      <p className="text-gray-700 dark:text-gray-300 mb-4">Welcome back! This is your personal dashboard.</p>
      <div className="space-y-4">
        <Link
            to="/edit-profile"
            className="block w-full sm:w-auto text-center bg-indigo-500 hover:bg-indigo-600 text-white font-medium py-2 px-4 rounded-md transition duration-150"
        >
            Edit Your Profile
        </Link>
        {/* Example link to view own portfolio - ensure 'my-user-id' is dynamic */}
        <Link
            to="/portfolio/my-user-id"
            className="block w-full sm:w-auto text-center bg-blue-500 hover:bg-blue-600 text-white font-medium py-2 px-4 rounded-md transition duration-150"
        >
            View My Public Portfolio
        </Link>
        {/* Add links to manage sections: projects, experience, skills, education etc. */}
      </div>
    </div>
  );
}
export default DashboardPage;
