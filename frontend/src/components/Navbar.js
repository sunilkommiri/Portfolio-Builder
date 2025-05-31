// src/components/Navbar.js
import React, { useContext } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { AuthContext } from '../App'; // Assuming AuthContext is in App.js

function Navbar() {
  const { isAuthenticated, logout } = useContext(AuthContext);
  const navigate = useNavigate();

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  return (
    <nav className="bg-indigo-600 dark:bg-indigo-800 text-white shadow-lg">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          <div className="flex items-center">
            <Link to="/" className="font-bold text-xl hover:text-indigo-200">
              PortfolioPro
            </Link>
          </div>
          <div className="flex items-center space-x-4">
            <Link to="/" className="hover:bg-indigo-700 dark:hover:bg-indigo-900 px-3 py-2 rounded-md text-sm font-medium">Home</Link>
            {isAuthenticated ? (
              <>
                <Link to="/dashboard" className="hover:bg-indigo-700 dark:hover:bg-indigo-900 px-3 py-2 rounded-md text-sm font-medium">Dashboard</Link>
                {/* Replace 'userId' with actual user ID from context or state */}
                <Link to="/portfolio/my-user-id" className="hover:bg-indigo-700 dark:hover:bg-indigo-900 px-3 py-2 rounded-md text-sm font-medium">My Portfolio</Link>
                <button
                  onClick={handleLogout}
                  className="bg-red-500 hover:bg-red-600 dark:bg-red-700 dark:hover:bg-red-800 px-3 py-2 rounded-md text-sm font-medium"
                >
                  Logout
                </button>
              </>
            ) : (
              <>
                <Link to="/login" className="hover:bg-indigo-700 dark:hover:bg-indigo-900 px-3 py-2 rounded-md text-sm font-medium">Login</Link>
                <Link to="/signup" className="bg-green-500 hover:bg-green-600 dark:bg-green-700 dark:hover:bg-green-800 px-3 py-2 rounded-md text-sm font-medium">Sign Up</Link>
              </>
            )}
          </div>
        </div>
      </div>
    </nav>
  );
}

export default Navbar;
