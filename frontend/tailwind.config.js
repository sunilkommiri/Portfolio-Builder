// frontend/tailwind.config.js
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{js,jsx,ts,tsx}", // Scan all JS/JSX/TS/TSX files in src
    "./public/index.html"
  ],
  darkMode: 'class', // or 'media' if you prefer OS-level dark mode detection
  theme: {
    extend: {
      // You can extend the default Tailwind theme here
      // colors: {
      //   'brand-primary': '#YOUR_COLOR',
      // },
    },
  },
  plugins: [
    // require('@tailwindcss/forms'), // If you want to use Tailwind Forms plugin
  ],
}
