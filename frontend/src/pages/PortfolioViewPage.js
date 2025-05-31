// src/pages/PortfolioViewPage.js
import React, { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';

function PortfolioViewPage() {
  const { userId } = useParams();
  const [portfolioData, setPortfolioData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    // Fetch portfolio data for the given userId from your backend API
    const fetchPortfolio = async () => {
      setLoading(true);
      setError('');
      try {
        // const response = await fetch(`/api/portfolio/${userId}`);
        // if (!response.ok) throw new Error('Portfolio not found or error fetching data');
        // const data = await response.json();
        // setPortfolioData(data);

        // Mock data for now:
        if (userId === "my-user-id" || userId === "another-user") {
          setPortfolioData({
            name: userId === "my-user-id" ? "My Awesome Profile" : "Jane Doe's Portfolio",
            bio: "A passionate developer creating amazing web applications.",
            skills: ["React", "Node.js", "JavaScript", "Tailwind CSS", "PostgreSQL"],
            projects: [{id: 1, title: "Cool Project Alpha", description: "Did something amazing."}],
            // ... more sections
          });
        } else {
            throw new Error('Portfolio not found (mock)');
        }
      } catch (err) {
        setError(err.message);
        setPortfolioData(null);
      }
      setLoading(false);
    };

    if (userId) {
      fetchPortfolio();
    }
  }, [userId]);

  if (loading) return <p className="text-center text-gray-700 dark:text-gray-300">Loading portfolio...</p>;
  if (error) return <p className="text-center text-red-500 dark:text-red-400">Error: {error}</p>;
  if (!portfolioData) return <p className="text-center text-gray-700 dark:text-gray-300">Portfolio not available.</p>;

  return (
    <div className="p-6 bg-white dark:bg-gray-800 shadow-xl rounded-lg">
      <h1 className="text-3xl font-bold text-gray-900 dark:text-white mb-2">{portfolioData.name}</h1>
      <p className="text-gray-700 dark:text-gray-300 mb-6">{portfolioData.bio}</p>

      <section className="mb-6">
        <h2 className="text-2xl font-semibold text-gray-800 dark:text-white mb-3">Skills</h2>
        <div className="flex flex-wrap gap-2">
          {portfolioData.skills?.map(skill => (
            <span key={skill} className="bg-indigo-100 dark:bg-indigo-700 text-indigo-700 dark:text-indigo-200 px-3 py-1 rounded-full text-sm font-medium">{skill}</span>
          ))}
        </div>
      </section>

      {/* Add sections for Experience, Education, Projects etc. */}
      <section>
        <h2 className="text-2xl font-semibold text-gray-800 dark:text-white mb-3">Projects</h2>
        {portfolioData.projects?.map(project => (
          <div key={project.id} className="mb-4 p-4 border border-gray-200 dark:border-gray-700 rounded-md">
            <h3 className="text-xl font-medium text-gray-900 dark:text-white">{project.title}</h3>
            <p className="text-gray-600 dark:text-gray-400">{project.description}</p>
          </div>
        ))}
      </section>
    </div>
  );
}
export default PortfolioViewPage;
