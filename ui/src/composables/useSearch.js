import { ref, computed } from 'vue';
import { useApi } from './useApi';

/**
 * Composable for global search across all resources
 * @returns {Object} Search utilities and state
 */
export function useSearch() {
  const { getResourceUrl } = useApi();
  const searchQuery = ref('');
  const isSearching = ref(false);
  const searchResults = ref([]);

  const resources = [
    { name: 'Feeds', endpoint: 'feeds', displayField: 'title' },
    { name: 'Watch', endpoint: 'watch', displayField: 'title' },
    { name: 'Music', endpoint: 'music', displayField: 'name' },
    { name: 'Musicals', endpoint: 'musicals', displayField: 'title' },
    { name: 'Sentences', endpoint: 'sentences', displayField: 'content' },
  ];

  const performSearch = async (query) => {
    if (!query.trim()) {
      searchResults.value = [];
      return;
    }

    isSearching.value = true;
    searchResults.value = [];

    try {
      const results = [];

      // Search each resource
      for (const resource of resources) {
        try {
          const response = await fetch(getResourceUrl(resource.endpoint));
          const data = await response.json();

          // Filter results based on query
          const filtered = data.data
            .filter(item => {
              const displayValue = item[resource.displayField];
              if (!displayValue) return false;
              return displayValue
                .toString()
                .toLowerCase()
                .includes(query.toLowerCase());
            })
            .map(item => ({
              ...item,
              resourceType: resource.name,
              resourceEndpoint: resource.endpoint,
              displayValue: item[resource.displayField],
            }));

          results.push(...filtered);
        } catch (error) {
          console.error(`Error searching ${resource.name}:`, error);
        }
      }

      searchResults.value = results;
    } finally {
      isSearching.value = false;
    }
  };

  const clearSearch = () => {
    searchQuery.value = '';
    searchResults.value = [];
  };

  const totalResults = computed(() => searchResults.value.length);

  return {
    searchQuery,
    searchResults,
    isSearching,
    totalResults,
    performSearch,
    clearSearch,
  };
}
