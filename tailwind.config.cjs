/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./index.html", "./src/**/*.res.mjs", "./src/**/*.jsx"],
  theme: {
    extend: {
      fontSize: {
        "2xs": ["0.7rem", "0.85rem"],
        "3xs": ["0.6rem", "0.75rem"],
      },
    },
  },
  plugins: [require("@tailwindcss/forms")],
};
