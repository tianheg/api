<script setup>
import { useAuthStore } from "@/stores/auth";
import { computed } from "vue";
import { RouterLink, RouterView } from "vue-router";
import { useRouter } from "vue-router";

const authStore = useAuthStore();
const isAuthenticated = computed(() => authStore.isAuthenticated());
const user = computed(() => authStore.user);
const logout = authStore.logout;
const router = useRouter();
const logoutAndRedirect = () => {
  logout();
  router.push("/login");
};
</script>

<template>
  <div class="min-h-screen bg-base-200 text-base-content font-serif flex flex-col">
    <header class="bg-base-300 shadow-lg">
      <div class="container mx-auto px-4">
        <div class="navbar">
          <!-- Brand Section -->
          <div class="navbar-start">
            <RouterLink to="/" class="btn btn-ghost normal-case px-2">
              <h1 class="text-4xl font-bold text-primary">Lifebook</h1>
            </RouterLink>
          </div>

          <!-- Desktop Navigation -->
          <div class="navbar-center hidden lg:flex">
            <nav class="flex items-center gap-4">
              <RouterLink 
                to="/" 
                class="btn btn-ghost text-lg text-base-content"
                active-class="btn-primary text-primary-content"
              >
                Home
              </RouterLink>

              <template v-if="isAuthenticated">
                <RouterLink 
                  to="/books" 
                  class="btn btn-ghost text-lg text-base-content"
                  active-class="btn-primary text-primary-content"
                >
                  Books
                </RouterLink>

                <div class="dropdown dropdown-hover">
                  <label tabindex="0" class="btn btn-ghost text-lg text-base-content">
                    Others
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 ml-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                    </svg>
                  </label>
                  <ul tabindex="0" class="dropdown-content z-[1] menu p-2 shadow bg-base-300 rounded-box w-52 text-base-content">
                    <li><RouterLink to="/feeds">Feeds</RouterLink></li>
                    <li><RouterLink to="/watch">Watch</RouterLink></li>
                    <li><RouterLink to="/music">Music</RouterLink></li>
                    <li><RouterLink to="/musicals">Musicals</RouterLink></li>
                    <li><RouterLink to="/sentences">Sentences</RouterLink></li>
                  </ul>
                </div>
              </template>
            </nav>
          </div>

          <!-- Mobile Menu -->
          <div class="navbar-end lg:hidden">
            <div class="dropdown dropdown-end">
              <label tabindex="0" class="btn btn-ghost text-base-content">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
                </svg>
              </label>
              <ul tabindex="0" class="dropdown-content z-[1] menu p-2 shadow bg-base-300 rounded-box w-52 mt-4 text-base-content">
                <li><RouterLink to="/">Home</RouterLink></li>
                <template v-if="isAuthenticated">
                  <li><RouterLink to="/books">Books</RouterLink></li>
                  <li class="menu-title"><span class="text-base-content/70">Others</span></li>
                  <li><RouterLink to="/feeds">Feeds</RouterLink></li>
                  <li><RouterLink to="/watch">Watch</RouterLink></li>
                  <li><RouterLink to="/music">Music</RouterLink></li>
                  <li><RouterLink to="/musicals">Musicals</RouterLink></li>
                  <li><RouterLink to="/sentences">Sentences</RouterLink></li>
                </template>
              </ul>
            </div>
          </div>

          <!-- Auth Section -->
          <div class="navbar-end hidden lg:flex">
            <template v-if="isAuthenticated">
              <div class="dropdown dropdown-end">
                <label tabindex="0" class="btn btn-ghost">
                  <div class="flex items-center gap-2">
                    <span class="truncate max-w-[120px] text-base-content">{{ user?.email }}</span>
                  </div>
                </label>
                <ul tabindex="0" class="dropdown-content z-[1] menu p-2 shadow bg-base-300 rounded-box w-52 text-base-content">
                  <li><button @click="logoutAndRedirect" class="text-error">Logout</button></li>
                </ul>
              </div>
            </template>
            <template v-else>
              <RouterLink to="/login" class="btn btn-primary text-primary-content text-lg">Login</RouterLink>
            </template>
          </div>
        </div>
      </div>
    </header>

    <main class="container mx-auto px-4 py-8 flex-1">
      <div class="bg-base-100 rounded-box shadow-lg p-6 border border-base-300">
        <RouterView />
      </div>
    </main>
  </div>
</template>
