<template>
  <div class="dropdown dropdown-end w-full max-w-xs">
    <div class="relative w-full">
      <input
        v-model="searchQuery"
        @input="handleSearch"
        @keydown.escape="clearSearch"
        type="text"
        placeholder="Search all resources..."
        class="input input-bordered input-sm w-full pr-10"
      />
      <button
        v-if="searchQuery"
        @click="clearSearch"
        class="absolute right-3 top-1/2 transform -translate-y-1/2 btn btn-ghost btn-xs"
      >
        ✕
      </button>
    </div>

    <!-- Dropdown Results -->
    <div
      v-if="searchQuery && searchResults.length > 0"
      tabindex="0"
      class="dropdown-content z-[50] w-full max-w-xs max-h-96 overflow-y-auto bg-base-100 border border-base-300 rounded-box shadow-lg"
    >
      <div class="p-2">
        <div class="text-sm text-base-content/60 px-2 py-1">
          Found {{ totalResults }} results
        </div>
        <div class="divider my-1"></div>

        <!-- Results grouped by resource type -->
        <div v-for="resource in groupedResults" :key="resource.type" class="mb-2">
          <div class="text-xs font-bold text-primary px-2 py-1">{{ resource.type }}</div>
          <div v-for="item in resource.items" :key="`${resource.type}-${item.id}`" class="mb-1">
            <RouterLink
              :to="`/${item.resourceEndpoint}`"
              @click="clearSearch"
              class="flex items-center gap-2 p-2 rounded hover:bg-base-200 text-sm text-base-content cursor-pointer"
            >
              <span class="flex-1 truncate">{{ item.displayValue }}</span>
              <span class="text-xs text-base-content/50">{{ resource.type }}</span>
            </RouterLink>
          </div>
        </div>
      </div>
    </div>

    <!-- No results message -->
    <div
      v-if="searchQuery && !isSearching && searchResults.length === 0"
      tabindex="0"
      class="dropdown-content z-[50] w-full max-w-xs bg-base-100 border border-base-300 rounded-box shadow-lg"
    >
      <div class="p-4 text-center text-sm text-base-content/60">
        No results found for "{{ searchQuery }}"
      </div>
    </div>

    <!-- Loading state -->
    <div
      v-if="isSearching"
      tabindex="0"
      class="dropdown-content z-[50] w-full max-w-xs bg-base-100 border border-base-300 rounded-box shadow-lg"
    >
      <div class="p-4 flex justify-center">
        <span class="loading loading-spinner loading-sm text-primary"></span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue';
import { useSearch } from '@/composables/useSearch';
import { RouterLink } from 'vue-router';

const { searchQuery, searchResults, isSearching, totalResults, performSearch, clearSearch } = useSearch();
const searchTimeout = ref(null);

const groupedResults = computed(() => {
  const groups = {};

  searchResults.value.forEach(item => {
    if (!groups[item.resourceType]) {
      groups[item.resourceType] = [];
    }
    groups[item.resourceType].push(item);
  });

  return Object.keys(groups).map(type => ({
    type,
    items: groups[type],
  }));
});

const handleSearch = () => {
  // Debounce search
  clearTimeout(searchTimeout.value);
  searchTimeout.value = setTimeout(() => {
    performSearch(searchQuery.value);
  }, 300);
};
</script>
