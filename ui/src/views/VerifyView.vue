<script setup>
import { useAuthStore } from "@/stores/auth";
import { onMounted, ref } from "vue";
import { useRoute, useRouter } from "vue-router";

const route = useRoute();
const router = useRouter();
const authStore = useAuthStore();

const verifying = ref(true);
const error = ref(null);

onMounted(async () => {
  try {
    // Get token from URL and validate it
    const token = route.query.token;

    if (!token || typeof token !== "string") {
      error.value = "Invalid or missing verification token";
      verifying.value = false;
      return;
    }

    // Call the verify endpoint with the string token
    await authStore.verifyMagicLink(token);

    router.push("/");
  } catch (err) {
    console.error("Verification error:", err);
    error.value = err.message || "Failed to verify magic link";
    verifying.value = false;
  }
});
</script>

<template>
  <div class="flex justify-center items-center min-h-screen bg-base-200 p-4">
    <div class="card bg-base-100 shadow-xl w-full max-w-md border border-base-300">
      <div class="card-body items-center text-center">
        <h2 class="card-title text-2xl mb-6 justify-center text-primary">Verifying Magic Link</h2>
        
        <!-- Loading state -->
        <div v-if="verifying" class="flex flex-col items-center gap-4 py-8">
          <span class="loading loading-spinner loading-lg text-primary"></span>
          <p class="text-base-content">Verifying your login...</p>
        </div>
        
        <!-- Error state -->
        <div v-else-if="error || authStore.error" class="alert alert-error mb-4 text-error-content">
          <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          <span>{{ error || authStore.error }}</span>
        </div>
      </div>
    </div>
  </div>
</template>
