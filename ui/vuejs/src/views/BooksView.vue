<script setup>
import { ref, onMounted } from 'vue';
// fetch data
const data = ref([]);

onMounted(async () => {
  const response = await fetch('https://jsonplaceholder.typicode.com/posts');
  data.value = await response.json();
});

</script>

<template>
  <div>
    <h1>Books</h1>

    <ul>
      <li v-for="item in data" :key="item.id">
        {{ item.title }}
      </li>
    </ul>
  </div>
</template>
