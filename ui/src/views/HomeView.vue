<script setup>
import { useAuthStore } from "@/stores/auth";
import { computed } from "vue";

const authStore = useAuthStore();
const isAuthenticated = computed(() => authStore.isAuthenticated());
</script>

<template>
  <div class="container mx-auto px-4 py-8 bg-base-200">
    <h1 class="text-4xl font-bold text-center text-primary mb-8">Love life, love me</h1>
    <p class="py-6 text-center text-lg text-base-content">
      "The person who has lived the most is not the one with the most years but the one with the richest
      experiences."
      <br>― Jean-Jacques Rousseau
    </p>

    <template v-if="isAuthenticated">
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <RouterLink to="/books"
          class="card bg-base-100 shadow-lg hover:shadow-xl transition-shadow duration-300 border border-base-300">
          <div class="card-body items-center text-center">
            <h2 class="card-title text-xl mb-2 text-primary">Books</h2>
            <p class="text-base-content">Manage your book collection</p>
          </div>
        </RouterLink>

        <RouterLink to="/movies"
          class="card bg-base-100 shadow-lg hover:shadow-xl transition-shadow duration-300 border border-base-300">
          <div class="card-body items-center text-center">
            <h2 class="card-title text-xl mb-2 text-primary">Movies</h2>
            <p class="text-base-content">Track movies you've watched</p>
          </div>
        </RouterLink>

        <RouterLink to="/series"
          class="card bg-base-100 shadow-lg hover:shadow-xl transition-shadow duration-300 border border-base-300">
          <div class="card-body items-center text-center">
            <h2 class="card-title text-xl mb-2 text-primary">Series</h2>
            <p class="text-base-content">Keep up with your favorite series</p>
          </div>
        </RouterLink>
      </div>
    </template>

    <template v-else>
      <div class="max-w-md mx-auto">
        <div class="text-center space-y-4 mb-10">
          <h2 class="text-2xl font-semibold text-primary">My Personal Archive</h2>
          <p class="text-base-content">
            Organize my books, movies, and series in one place
          </p>
        </div>
      </div>
    </template>
  </div>
</template>