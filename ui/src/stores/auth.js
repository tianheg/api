import { defineStore } from 'pinia';
import { ref } from 'vue';

export const useAuthStore = defineStore('auth', () => {
  const user = ref(null);
  const token = ref(localStorage.getItem('token') || null);
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
      localStorage.removeItem('token');
    }
  }

  // Request a magic link
  const requestMagicLink = async (email) => {
    loading.value = true;
    error.value = null;
    
    try {
      const response = await fetch('/api/auth/magic-link', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ email })
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
      
      const response = await fetch('/api/auth/verify', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ token: magicToken })
      });
      
      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.message || 'Failed to verify magic link');
      }
      
      const data = await response.json();
      
      // Store token and user info
      token.value = data.token;
      user.value = data.user;
      
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
  const logout = () => {
    user.value = null;
    token.value = null;
    localStorage.removeItem('token');
  };

  // Check if user is authenticated
  const isAuthenticated = () => !!token.value;

  return {
    user,
    token,
    loading,
    error,
    requestMagicLink,
    verifyMagicLink,
    logout,
    isAuthenticated
  };
});
