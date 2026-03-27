/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,jsx}'],
  theme: {
    extend: {
      colors: {
        navy: '#161E5B',
        'ss-blue': '#1F58FB',
        'ss-blue-hover': '#1549d8',
        'ss-light': '#EEF1FA',
        'ss-border': '#DDE3F2',
        'ss-bg': '#F8F9FD',
        'ss-green': '#0F6E56',
        'ss-green-light': '#E8F5EE',
      },
      fontFamily: {
        sans: ['Montserrat', 'sans-serif'],
        serif: ['"DM Serif Display"', 'serif'],
      },
    },
  },
  plugins: [],
};
