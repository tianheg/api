import { ref, reactive, computed, watch } from 'vue';

/**
 * Composable for common CRUD operations
 * @param {Object} options - Configuration options
 * @param {string} options.resourceUrl - Base URL for the resource (e.g., 'http://localhost:3000/watch')
 * @param {Object} options.initialItem - Initial structure of an empty item object
 * @param {Function} options.onSuccess - Callback to execute after successful operations (optional)
 * @param {Function} options.onError - Callback to handle errors (optional)
 * @param {string} options.resourceName - Name of the resource for error messages
 * @param {number} options.initialPageSize - Initial page size for pagination (optional, defaults to 10)
 * @returns {Object} CRUD operations and state
 */
export function useCrud(options) {
  const {
    resourceUrl,
    initialItem,
    onSuccess,
    onError,
    resourceName = 'item',
    initialPageSize = 10
  } = options;

  // Reactive state
  const items = ref([]);
  const loading = ref(false);
  const error = ref(null);
  const showAddForm = ref(false);
  const showEditForm = ref(false);
  const currentItem = ref(null);
  const formModel = reactive({ ...initialItem });
  const isEditMode = computed(() => showEditForm.value);

  // Pagination
  const page = ref(1);
  const pageSize = ref(initialPageSize);
  const total = ref(0);

  // Watch for form state changes to reset the form
  watch([showAddForm, showEditForm, currentItem], ([add, edit, item]) => {
    error.value = null;
    if (add) {
      Object.assign(formModel, { ...initialItem });
    } else if (edit && item) {
      Object.assign(formModel, { ...item });
    } else if (!add && !edit) {
      Object.assign(formModel, { ...initialItem });
    }
  });

  // Fetch all items with pagination
  const fetchItems = async () => {
    loading.value = true;
    error.value = null;
    try {
      const response = await fetch(`${resourceUrl}?page=${page.value}&limit=${pageSize.value}`);
      if (!response.ok) throw new Error(`Failed to fetch ${resourceName}s`);
      const data = await response.json();
      items.value = data.data || [];
      total.value = data.total || 0;
      
      if (onSuccess) onSuccess(`${resourceName}s loaded successfully`);
    } catch (err) {
      error.value = err.message;
      if (onError) onError(err);
    } finally {
      loading.value = false;
    }
  };

  // Update page and refetch
  const handlePageChange = (newPage) => {
    page.value = newPage;
    fetchItems();
  };

  // Form submission router
  const submitForm = async () => {
    if (isEditMode.value) {
      await updateItem();
    } else {
      await createItem();
    }
  };

  // Create a new item
  const createItem = async () => {
    loading.value = true;
    error.value = null;
    try {
      const requestOptions = {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formModel),
      };
      const response = await fetch(resourceUrl, requestOptions);
      if (!response.ok) throw new Error(`Failed to create ${resourceName}`);
      
      // Reset form and refetch items
      Object.assign(formModel, { ...initialItem });
      showAddForm.value = false;
      await fetchItems();
      
      if (onSuccess) onSuccess(`${resourceName} created successfully`);
    } catch (err) {
      error.value = err.message;
      if (onError) onError(err);
    } finally {
      loading.value = false;
    }
  };

  // Update an existing item
  const updateItem = async () => {
    loading.value = true;
    error.value = null;
    try {
      const { id, ...updateData } = formModel;
      if (!id) throw new Error(`Cannot update ${resourceName} without ID.`);

      const requestOptions = {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(updateData),
      };
      const response = await fetch(`${resourceUrl}/${id}`, requestOptions);
      if (!response.ok) throw new Error(`Failed to update ${resourceName}`);
      
      // Reset form and refetch items
      showEditForm.value = false;
      currentItem.value = null;
      await fetchItems();
      
      if (onSuccess) onSuccess(`${resourceName} updated successfully`);
    } catch (err) {
      error.value = err.message;
      if (onError) onError(err);
    } finally {
      loading.value = false;
    }
  };

  // Delete an item
  const deleteItem = async (id) => {
    if (!confirm(`Are you sure you want to delete this ${resourceName}?`)) return;
    
    loading.value = true;
    error.value = null;
    try {
      const requestOptions = { method: 'DELETE' };
      const response = await fetch(`${resourceUrl}/${id}`, requestOptions);
      if (!response.ok) throw new Error(`Failed to delete ${resourceName}`);
      
      await fetchItems();
      
      if (onSuccess) onSuccess(`${resourceName} deleted successfully`);
    } catch (err) {
      error.value = err.message;
      if (onError) onError(err);
    } finally {
      loading.value = false;
    }
  };

  // Cancel form editing and reset state
  const cancelForm = () => {
    showAddForm.value = false;
    showEditForm.value = false;
    currentItem.value = null;
  };

  // Handle form updates (used with v-model)
  const handleFormUpdate = (newValue) => {
    Object.assign(formModel, newValue);
  };

  return {
    // State
    items,
    loading,
    error,
    showAddForm,
    showEditForm,
    currentItem,
    formModel,
    isEditMode,
    page,
    pageSize,
    total,
    
    // Methods
    fetchItems,
    handlePageChange,
    submitForm,
    createItem,
    updateItem,
    deleteItem,
    cancelForm,
    handleFormUpdate,
  };
}