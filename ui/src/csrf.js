// filepath: /mnt/disk/MAIN/api/ui/src/services/csrf.js
import { useAuthStore } from './stores/auth';

export const csrfService = {
  async getToken() {
    const authStore = useAuthStore();
    
    // Try to use the existing token from auth store if available
    if (authStore.csrfToken) {
      return authStore.csrfToken;
    }
    
    // Otherwise fetch a new token
    return await authStore.fetchCsrfToken();
  },

  async addTokenToRequest(requestOptions = {}) {
    // Get a CSRF token
    const token = await this.getToken();
    
    // Initialize headers if they don't exist
    if (!requestOptions.headers) {
      requestOptions.headers = {};
    }
    
    // Set the CSRF token header
    requestOptions.headers['X-CSRF-Token'] = token;
    
    // If body exists and is an object, add the CSRF token
    if (requestOptions.body) {
      try {
        const bodyObj = typeof requestOptions.body === 'string' 
          ? JSON.parse(requestOptions.body) 
          : requestOptions.body;
        
        bodyObj.csrfToken = token;
        
        // Convert back to string if it was a string
        requestOptions.body = typeof requestOptions.body === 'string'
          ? JSON.stringify(bodyObj)
          : bodyObj;
      } catch (err) {
        console.error('Error adding CSRF token to request body:', err);
      }
    }
    
    return requestOptions;
  }
};