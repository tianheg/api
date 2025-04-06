<script setup>
import { RouterLink, RouterView } from "vue-router";
import { useAuthStore } from "@/stores/auth";
import { computed } from "vue";
import { useRouter } from 'vue-router';

const authStore = useAuthStore();
const isAuthenticated = computed(() => authStore.isAuthenticated());
const user = computed(() => authStore.user);
const logout = authStore.logout;
const router = useRouter();
const logoutAndRedirect = () => {
  logout();
  router.push('/login');
};

</script>

<template>
  <div class="min-h-screen bg-base-200">
    <header class="bg-base-100 shadow-lg p-4">
      <div class="container mx-auto text-center">
        <h1 class="text-4xl font-extrabold text-primary mb-2">Lifebook</h1>
        <h2 class="text-xl text-secondary mb-4">
          -- My books, feeds, movies, music, musicals, series, and sentences --
        </h2>

        <nav class="navbar bg-base-100 justify-center space-x-4">
          <RouterLink class="btn btn-primary" to="/">Home</RouterLink>
          
          <!-- Show navigation only if authenticated -->
          <template v-if="isAuthenticated">
            <RouterLink class="btn btn-primary" to="/books">Books</RouterLink>
            <div class="dropdown dropdown-hover">
              <label tabindex="0" class="btn btn-primary">Others</label>
              <ul tabindex="0" class="dropdown-content z-[1] menu p-2 shadow bg-base-100 rounded-box w-52">
                <li><RouterLink to="/feeds">Feeds</RouterLink></li>
                <li><RouterLink to="/movies">Movies</RouterLink></li>
                <li><RouterLink to="/music">Music</RouterLink></li>
                <li><RouterLink to="/musicals">Musicals</RouterLink></li>
                <li><RouterLink to="/series">Series</RouterLink></li>
                <li><RouterLink to="/sentences">Sentences</RouterLink></li>
              </ul>
            </div>
          </template>

          <!-- Auth buttons -->
          <div class="ml-auto">
            <template v-if="isAuthenticated">
              <div class="dropdown dropdown-end">
                <label tabindex="0" class="btn">
                  {{ user?.email || 'Account' }}
                </label>
                <ul tabindex="0" class="dropdown-content z-[1] menu p-2 shadow bg-base-100 rounded-box w-52">
                  <li><button @click="logoutAndRedirect">Logout</button></li>
                </ul>
              </div>
            </template>
            <template v-else>
              <RouterLink class="btn btn-secondary" to="/login">Login</RouterLink>
            </template>
          </div>
        </nav>
      </div>
    </header>

    <main class="container mx-auto py-8 px-4 bg-white shadow-md rounded-lg">
      <RouterView />
    </main>
  </div>
</template>
