<template>
  <div class="hero min-h-screen bg-base-100">
    <div class="hero-content flex-col lg:flex-row-reverse">
      <img src="/etienne-girardet-amxswD3KTg8-unsplash.webp" class="max-w-sm rounded-lg shadow-2xl"
        alt="Illustration" />
      <div>
        <h1 class="text-5xl font-bold">Love life, love me</h1>
        <blockquote class="py-6 italic border-l-4 border-primary pl-4 my-4">
          <p class="text-lg text-gray-600 leading-relaxed">
            "The person who has lived the most is not the one with the most years but the one with the richest
            experiences."
          </p>
          <footer class="text-sm text-gray-500 mt-2 font-medium">― Jean-Jacques Rousseau</footer>
        </blockquote>
        <button class="btn btn-primary">
          <router-link to="/books">Browse Books</router-link>
        </button>
      </div>
    </div>
  </div>
</template>
