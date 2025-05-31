// src/pages/SignupPage.js
import React, { useState, useContext } from 'react';
import { useNavigate } from 'react-router-dom';
import { AuthContext } from '../App';

function SignupPage() {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const { login } = useContext(AuthContext); // Assuming signup also logs in
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      // Replace with actual API call to your backend for registration
      // const response = await fetch('/api/auth/register', { /* ... */ });
      // const data = await response.json();
      // if (!response.ok) throw new Error(data.message || 'Failed to sign up');
      // login(data.token); // Assume backend returns a token on successful registration

      console.log("Mock Signup for:", name, email);
      // Simulate successful signup & login
      login("mockAuthTokenFromSignup");
      navigate('/dashboard');

    } catch (err) {
      setError(err.message);
    }
    setLoading(false);
  };

  return (
    <div className="max-w-md mx-auto mt-10 p-8 bg-white dark:bg-gray-800 rounded-lg shadow-xl">
      <h2 className="text-3xl font-bold text-center text-gray-900 dark:text-white mb-8">Sign Up</h2>
      {error && <p className="text-red-500 dark:text-red-400 text-center mb-4">{error}</p>}
      <form onSubmit={handleSubmit} className="space-y-6">
        <div>
          <label htmlFor="name" className="block text-sm font-medium text-gray-700 dark:text-gray-300">Full Name</label>
          <input type="text" id="name" value={name} onChange={(e) => setName(e.target.value)} required
                 className="mt-1 block w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm placeholder-gray-400 dark:placeholder-gray-500 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm bg-white dark:bg-gray-700 text-gray-900 dark:text-white" />
        </div>
        <div>
          <label htmlFor="email-signup" className="block text-sm font-medium text-gray-700 dark:text-gray-300">Email</label>
          <input type="email" id="email-signup" value={email} onChange={(e) => setEmail(e.target.value)} required
                 className="mt-1 block w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm placeholder-gray-400 dark:placeholder-gray-500 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm bg-white dark:bg-gray-700 text-gray-900 dark:text-white" />
        </div>
        <div>
          <label htmlFor="password-signup" className="block text-sm font-medium text-gray-700 dark:text-gray-300">Password</label>
          <input type="password" id="password-signup" value={password} onChange={(e) => setPassword(e.target.value)} required
                 className="mt-1 block w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm placeholder-gray-400 dark:placeholder-gray-500 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm bg-white dark:bg-gray-700 text-gray-900 dark:text-white" />
        </div>
        <button type="submit" disabled={loading}
                className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 disabled:opacity-50">
          {loading ? 'Signing up...' : 'Sign Up'}
        </button>
      </form>
    </div>
  );
}
export default SignupPage;
