/**
 * API Configuration
 * 
 * Configure your Django backend API endpoint here.
 * For Android emulator, use: http://10.0.2.2:8000
 * For iOS simulator, use: http://localhost:8000
 * For physical device, use your computer's IP address: http://YOUR_IP:8000
 */

// Development API base URL
const API_BASE_URL = __DEV__
  ? 'http://localhost:8000' // Change to your backend URL
  : 'https://api.flashbricks.com'; // Production URL

export const API_ENDPOINTS = {
  BASE_URL: API_BASE_URL,
  HEALTH: `${API_BASE_URL}/api/health/`,
  // Add more endpoints here as you create them
};

export default API_ENDPOINTS;

