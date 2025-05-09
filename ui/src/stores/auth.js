import { defineStore } from "pinia";
import { ref } from "vue";

const API_URL = import.meta.env.VITE_API_URL || "http://localhost:3000";

export const useAuthStore = defineStore("auth", () => {
  const user = ref(null);
  const token = ref(localStorage.getItem("token") || null);
  const loading = ref(false);
  const error = ref(null);

  // Initialize user from token if exists
  if (token.value) {
    try {
      // Try to parse the user from the token
      const base64Url = token.value.split(".")[1];
      const base64 = base64Url.replace(/-/g, "+").replace(/_/g, "/");
      const payload = JSON.parse(window.atob(base64));
      user.value = { email: payload.email };
    } catch (err) {
      // Invalid token format
      token.value = null;
      localStorage.removeItem("token");
    }
  }

  // Request a magic link
  const requestMagicLink = async (email) => {
    loading.value = true;
    error.value = null;

    try {
      const response = await fetch(`${API_URL}/auth/magic-link`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          email,
        }),
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.message || "Failed to send magic link");
      }

      const data = await response.json();
      return data;
    } catch (err) {
      error.value = err.message || "Failed to send magic link";
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
      if (typeof magicToken !== "string") {
        throw new Error("Invalid token format");
      }

      const response = await fetch(`${API_URL}/auth/verify`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          token: magicToken,
        }),
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.message || "Failed to verify magic link");
      }

      const data = await response.json();

      // Store token and user info
      token.value = data.token;
      user.value = data.user;

      // Save token to localStorage
      localStorage.setItem("token", token.value);

      return data;
    } catch (err) {
      error.value = err.message || "Failed to verify magic link";
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
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${token.value}`,
          },
        });

        if (!response.ok) {
          console.error("Logout failed on server:", await response.text());
        }
      }
    } catch (err) {
      console.error("Error during logout:", err);
    } finally {
      // Always clear local state regardless of server response
      user.value = null;
      token.value = null;
      localStorage.removeItem("token");
    }
  };

  // Check if user is authenticated
  const isAuthenticated = () => {
    if (!token.value) return false;

    try {
      const base64Url = token.value.split(".")[1];
      const base64 = base64Url.replace(/-/g, "+").replace(/_/g, "/");
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
    loading,
    error,
    requestMagicLink,
    verifyMagicLink,
    logout,
    isAuthenticated,
  };
});
