<script setup>
import { computed } from "vue";
import { RouterLink, RouterView } from "vue-router";

</script>

<template>
  <div class="min-h-screen bg-base-200 text-base-content font-sans flex flex-col">
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

              <template>
                <RouterLink 
                  to="/feeds" 
                  class="btn btn-ghost text-lg text-base-content"
                  active-class="btn-primary text-primary-content"
                >
                  Feeds
                </RouterLink>
                <RouterLink 
                  to="/watch" 
                  class="btn btn-ghost text-lg text-base-content"
                  active-class="btn-primary text-primary-content"
                >
                  Watch
                </RouterLink>
                <RouterLink 
                  to="/music" 
                  class="btn btn-ghost text-lg text-base-content"
                  active-class="btn-primary text-primary-content"
                >
                  Music
                </RouterLink>
                <RouterLink 
                  to="/musicals" 
                  class="btn btn-ghost text-lg text-base-content"
                  active-class="btn-primary text-primary-content"
                >
                  Musicals
                </RouterLink>
                <RouterLink 
                  to="/sentences" 
                  class="btn btn-ghost text-lg text-base-content"
                  active-class="btn-primary text-primary-content"
                >
                  Sentences
                </RouterLink>
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
                <template>
                  <li><RouterLink to="/feeds">Feeds</RouterLink></li>
                  <li><RouterLink to="/watch">Watch</RouterLink></li>
                  <li><RouterLink to="/music">Music</RouterLink></li>
                  <li><RouterLink to="/musicals">Musicals</RouterLink></li>
                  <li><RouterLink to="/sentences">Sentences</RouterLink></li>
                </template>
              </ul>
            </div>
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
