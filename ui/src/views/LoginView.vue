<script setup>
import { useAuthStore } from "@/stores/auth";
import { ref } from "vue";

const authStore = useAuthStore();
const email = ref("");
const linkSent = ref(false);

const requestLink = async () => {
  if (!email.value) return;

  const success = await authStore.requestMagicLink(email.value);
  if (success) {
    linkSent.value = true;
  }
};
</script>

<template>
  <div class="flex justify-center items-center min-h-[70vh]">
    <div class="card bg-base-100 shadow-xl max-w-md w-full border border-base-300">
      <div class="card-body">
        <h2 class="card-title text-2xl mb-6 justify-center text-primary">Log In</h2>

        <!-- Error display -->
        <div v-if="authStore.error" class="alert alert-error mb-4 text-error-content">
          <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          <span>{{ authStore.error }}</span>
        </div>

        <!-- Success message -->
        <div v-if="linkSent" class="alert alert-success mb-4 text-success-content">
          <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          <span>Magic link sent! Check your email to log in.</span>
        </div>

        <!-- Login form -->
        <div v-if="!linkSent">
          <p class="mb-4 text-base-content">Enter your email to receive a magic link for passwordless login:</p>

          <form @submit.prevent="requestLink">
            <div class="form-control mb-4">
              <input type="email" id="email" v-model="email" required class="input input-bordered bg-base-100 text-base-content"
                placeholder="your@email.com" autocomplete="email" />
            </div>

            <div class="form-control mt-6">
              <button type="submit" class="btn btn-primary text-primary-content" :disabled="authStore.loading">
                <span v-if="authStore.loading" class="loading loading-spinner loading-xs mr-2"></span>
                Send Magic Link
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>
