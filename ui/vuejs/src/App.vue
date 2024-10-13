<script setup>
import { RouterLink, RouterView } from 'vue-router'
</script>

<template>
  <div class="bg-gray-100 text-black min-h-screen mx-2 p-2">
    <header class="bg-white shadow-lg text-center p-2">

      <h1 class="text-3xl font-bold">Lifebook</h1>
      <h2 class="text-lg p-2">
        -- My books, feeds, movies, music, musicals, series, and words --
      </h2>

      <nav class="menu w-min mx-auto">
        <RouterLink class="px-4 py-2 rounded-md btn btn-ghost" to="/">Home</RouterLink>
        <RouterLink class="px-4 py-2 rounded-md btn btn-ghost" to="/books">Books</RouterLink>
        <div class="collapse collapse-arrow border max-w-lg mx-auto">
          <input type="checkbox" />
          <div class="collapse-title px-4 py-2 rounded-md font-bold align-middle">Others</div>
          <div class="collapse-content menu">
            <RouterLink class="px-4 py-2 rounded-md btn btn-ghost" to="/feeds">Feeds</RouterLink>
            <RouterLink class="px-4 py-2 rounded-md btn btn-ghost" to="/movies">Movies</RouterLink>
            <RouterLink class="px-4 py-2 rounded-md btn btn-ghost" to="/music">Music</RouterLink>
            <RouterLink class="px-4 py-2 rounded-md btn btn-ghost" to="/musicals">Musicals</RouterLink>
            <RouterLink class="px-4 py-2 rounded-md btn btn-ghost" to="/series">Series</RouterLink>
            <RouterLink class="px-4 py-2 rounded-md btn btn-ghost" to="/words">Words</RouterLink>
          </div>
        </div>
      </nav>
    </header>

    <RouterView class="max-w-5xl mx-auto p-4" />
  </div>
</template>
