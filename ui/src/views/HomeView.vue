<script setup>
import { ref, onMounted } from "vue";

const API_URL = import.meta.env.VITE_API_URL || "http://localhost:3000";
const randomSentence = ref("");
const loading = ref(true);
const error = ref(null);

async function fetchRandomSentence() {
  loading.value = true;
  error.value = null;
  try {
    // Fetch all sentences (limit 1000 for safety)
    const response = await fetch(`${API_URL}/sentences?page=1&limit=1000`);
    if (!response.ok) throw new Error("Failed to fetch sentences");
    const data = await response.json();
    const items = data.data || [];
    if (items.length) {
      const idx = Math.floor(Math.random() * items.length);
      randomSentence.value = items[idx].content;
    } else {
      randomSentence.value = "No sentences found. Add some in the Sentences section!";
    }
  } catch (err) {
    error.value = err.message;
    randomSentence.value = "Failed to load sentence.";
  } finally {
    loading.value = false;
  }
}

onMounted(fetchRandomSentence);
</script>

<template>
  <div class="container mx-auto px-4 py-8 bg-base-200">
    <h1 class="text-4xl font-bold text-center text-primary mb-8">
      Love life, love me
    </h1>
    <p class="py-6 text-center text-lg text-base-content">
      {{ loading ? "Loading..." : randomSentence }}
    </p>
  </div>
</template>