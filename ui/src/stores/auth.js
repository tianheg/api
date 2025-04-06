import { defineStore } from 'pinia';
import { ref } from 'vue';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000';

export const useAuthStore = defineStore('auth', () => {
  const user = ref(null);
  const token = ref(localStorage.getItem('token') || null);
  const csrfToken = ref(localStorage.getItem('csrfToken') || null);
  const loading = ref(false);
  const error = ref(null);

  // Initialize user from token if exists
  if (token.value) {
    try {
      // Try to parse the user from the token
      const base64Url = token.value.split('.')[1];
      const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
      const payload = JSON.parse(window.atob(base64));
      user.value = { email: payload.email };
    } catch (err) {
      // Invalid token format
      token.value = null;
      csrfToken.value = null;
      localStorage.removeItem('token');
      localStorage.removeItem('csrfToken');
    }
  }

  // Fetch a CSRF token
  const fetchCsrfToken = async () => {
    try {
      const response = await fetch(`${API_URL}/csrf/token`);
      if (!response.ok) {
        throw new Error('Failed to fetch CSRF token');
      }
      const data = await response.json();
      csrfToken.value = data.csrfToken;
      localStorage.setItem('csrfToken', csrfToken.value);
      return csrfToken.value;
    } catch (err) {
      error.value = err.message;
      throw err;
    }
  };

  // Request a magic link
  const requestMagicLink = async (email) => {
    loading.value = true;
    error.value = null;
    
    try {
      // Ensure we have a CSRF token
      if (!csrfToken.value) {
        await fetchCsrfToken();
      }

      const response = await fetch(`${API_URL}/auth/magic-link`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken.value
        },
        body: JSON.stringify({ 
          email,
          csrfToken: csrfToken.value
        })
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.message || 'Failed to send magic link');
      }

      const data = await response.json();
      return data;
    } catch (err) {
      error.value = err.message || 'Failed to send magic link';
      throw err;
    } finally {
      loading.value = false;
    }
  };

  // Verify magic link token
  const verifyMagicLink = async (magicToken) => {
    loading.value = true;
    error.value = null;
    
    try {
      // Make sure token is a string
      if (typeof magicToken !== 'string') {
        throw new Error('Invalid token format');
      }

      // Ensure we have a CSRF token
      if (!csrfToken.value) {
        await fetchCsrfToken();
      }
      
      const response = await fetch(`${API_URL}/auth/verify`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken.value
        },
        body: JSON.stringify({ 
          token: magicToken,
          csrfToken: csrfToken.value
        })
      });
      
      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.message || 'Failed to verify magic link');
      }
      
      const data = await response.json();
      
      // Store token and user info
      token.value = data.token;
      user.value = data.user;
      
      // Also store the new CSRF token that came with the response
      if (data.csrfToken) {
        csrfToken.value = data.csrfToken;
        localStorage.setItem('csrfToken', csrfToken.value);
      }
      
      // Save token to localStorage
      localStorage.setItem('token', token.value);
      
      return data;
    } catch (err) {
      error.value = err.message || 'Failed to verify magic link';
      throw err;
    } finally {
      loading.value = false;
    }
  };

  // Logout user
  const logout = async () => {
    try {
      if (token.value) {
        // Call the backend logout API if we have a token
        const response = await fetch(`${API_URL}/auth/logout`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token.value}`,
            'X-CSRF-Token': csrfToken.value
          },
          body: JSON.stringify({ 
            csrfToken: csrfToken.value
          })
        });
        
        if (!response.ok) {
          console.error('Logout failed on server:', await response.text());
        }
      }
    } catch (err) {
      console.error('Error during logout:', err);
    } finally {
      // Always clear local state regardless of server response
      user.value = null;
      token.value = null;
      csrfToken.value = null;
      localStorage.removeItem('token');
      localStorage.removeItem('csrfToken');
    }
  };

  // Check if user is authenticated
  const isAuthenticated = () => {
    if (!token.value) return false;

    try {
      const base64Url = token.value.split('.')[1];
      const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
      const payload = JSON.parse(window.atob(base64));

      // Check if the token is expired
      const currentTime = Math.floor(Date.now() / 1000);
      if (payload.exp && payload.exp < currentTime) {
        // Token is expired, clear it
        logout();
        return false;
      }

      return true;
    } catch (err) {
      // Invalid token format
      logout();
      return false;
    }
  };

  return {
    user,
    token,
    csrfToken,
    loading,
    error,
    fetchCsrfToken,
    requestMagicLink,
    verifyMagicLink,
    logout,
    isAuthenticated
  };
});
