/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: "selector",
  content: ["./index.html", "./src/**/*.tsx"],
  theme: {
    extend: {
      fontFamily: {
        sans: ["Inter"],
      },
      fontSize: {
        "2xs": ["0.7rem", "0.85rem"],
        "3xs": ["0.6rem", "0.75rem"],
      },
    },
  },
  plugins: [require("@tailwindcss/forms")],
};
