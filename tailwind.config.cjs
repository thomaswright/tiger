/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./index.html", "./src/**/*.res.mjs"],
  theme: {
    extend: {
      fontSize: {
        "2xs": ["0.6rem", "0.75rem"],
      },
    },
  },
  plugins: [],
};
