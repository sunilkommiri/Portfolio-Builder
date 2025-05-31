// src/components/Footer.js
import React from 'react';

function Footer() {
  return (
    <footer className="bg-gray-800 dark:bg-gray-950 text-white text-center p-4 mt-auto">
      <p>&copy; {new Date().getFullYear()} PortfolioPro. All rights reserved.</p>
      <p className="text-xs">Powered by React & Node.js</p>
    </footer>
  );
}

export default Footer;
