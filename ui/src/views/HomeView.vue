<script setup>
import { useAuthStore } from '@/stores/auth';
import { computed } from 'vue';

const authStore = useAuthStore();
const isAuthenticated = computed(() => authStore.isAuthenticated);
const user = computed(() => authStore.user);
</script>

<template>
  <div class="prose max-w-full">
    <h1 class="text-3xl font-bold mb-6">Welcome to Lifebook</h1>
    
    <template v-if="isAuthenticated">
      <div class="alert alert-success mb-6">
        <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
        <span>You are logged in as <strong>{{ user?.email }}</strong></span>
      </div>
      
      <p>Use the navigation menu to access your books, movies, music, and more.</p>
      
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 mt-8">
        <RouterLink to="/books" class="card bg-base-100 shadow-md hover:shadow-lg transition-shadow">
          <div class="card-body">
            <h2 class="card-title">Books</h2>
            <p>Manage your book collection</p>
          </div>
        </RouterLink>
        
        <RouterLink to="/movies" class="card bg-base-100 shadow-md hover:shadow-lg transition-shadow">
          <div class="card-body">
            <h2 class="card-title">Movies</h2>
            <p>Track movies you've watched</p>
          </div>
        </RouterLink>
        
        <RouterLink to="/series" class="card bg-base-100 shadow-md hover:shadow-lg transition-shadow">
          <div class="card-body">
            <h2 class="card-title">Series</h2>
            <p>Keep up with your favorite series</p>
          </div>
        </RouterLink>
      </div>
    </template>
    
    <template v-else>
      <p>
        Lifebook helps you manage your personal collections of books, movies, music, and more.
      </p>
      <p>Please log in to access your collections.</p>
      
      <div class="card bg-base-100 shadow-xl my-8 max-w-md mx-auto">
        <div class="card-body">
          <h2 class="card-title">Get Started</h2>
          <p>Log in with a secure magic link sent to your email.</p>
          <div class="card-actions justify-end mt-4">
            <RouterLink to="/login" class="btn btn-primary">Login Now</RouterLink>
          </div>
        </div>
      </div>
    </template>
  </div>
</template>
