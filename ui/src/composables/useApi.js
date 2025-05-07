import { ref } from 'vue';

/**
 * Composable for API-related utilities and state
 * @returns {Object} API utilities and state
 */
export function useApi() {
  const API_URL = import.meta.env.VITE_API_URL || "http://localhost:3000";
  
  // Common notification state (could be integrated with a toast system)
  const notification = ref({ show: false, message: '', type: 'info' });
  
  // Show a notification message
  const notify = (message, type = 'info') => {
    notification.value = { show: true, message, type };
    setTimeout(() => {
      notification.value.show = false;
    }, 3000);
  };
  
  // Common success handler for API operations
  const handleSuccess = (message) => {
    notify(message, 'success');
  };
  
  // Common error handler for API operations
  const handleError = (error) => {
    notify(error.message || 'An error occurred', 'error');
    console.error(error);
  };
  
  // Generate a full resource URL
  const getResourceUrl = (endpoint) => {
    return `${API_URL}/${endpoint}`;
  };
  
  return {
    API_URL,
    notification,
    notify,
    handleSuccess,
    handleError,
    getResourceUrl
  };
}