<script setup>
import { onMounted, computed } from "vue";
import DataForm from "@/components/DataForm.vue";
import DataTable from "@/components/DataTable.vue";
import { useCrud } from "@/composables/useCrud";
import { useApi } from "@/composables/useApi";

// Get API utilities
const { getResourceUrl, handleSuccess, handleError } = useApi();

// Define form fields and table columns
const fields = [
  { name: "name", label: "Name", type: "text", required: true, desc: "Enter the name of the item." },
  { name: "review", label: "Review", type: "textarea", required: true, desc: "Write your review here." },
];

const columns = [
  { label: "Name", key: "name" },
  { label: "Review", key: "review" },
];

// Use the CRUD composable with Watch-specific configuration
const {
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
  fetchItems,
  handlePageChange,
  submitForm,
  deleteItem,
  cancelForm,
  handleFormUpdate
} = useCrud({
  resourceUrl: getResourceUrl('watch'),
  initialItem: { id: null, name: "", review: "" },
  onSuccess: handleSuccess,
  onError: handleError,
  resourceName: 'watch item',
  initialPageSize: 10000  // Custom page size for Watch view
});

// Action buttons for table rows
const tableActions = [
  {
    label: "Edit",
    class: "btn-info text-info-content",
    icon: `<svg xmlns='http://www.w3.org/2000/svg' class='w-4 h-4 mr-1' fill='none' viewBox='0 0 24 24' stroke='currentColor'><path stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M15.232 5.232l3.536 3.536M9 13h3l8-8a2.828 2.828 0 00-4-4l-8 8v3z' /></svg>`,
    onClick: (item) => { currentItem.value = item; showEditForm.value = true; },
  },
  {
    label: "Delete",
    class: "btn-error text-error-content",
    icon: `<svg xmlns='http://www.w3.org/2000/svg' class='w-4 h-4 mr-1' fill='none' viewBox='0 0 24 24' stroke='currentColor'><path stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M6 18L18 6M6 6l12 12' /></svg>`,
    onClick: (item) => deleteItem(item.id),
  },
];

// Fetch items on component mount
onMounted(fetchItems);
</script>
<template>
  <div class="card bg-base-100">
    <div class="card-body">
      <h1 class="card-title text-2xl mb-6 text-primary">Watch Management</h1>
      <div v-if="loading && !showAddForm && !showEditForm" class="flex justify-center my-8">
        <span class="loading loading-spinner loading-lg text-primary"></span>
      </div>
      <div class="mb-6" v-if="!showAddForm && !showEditForm">
        <button class="btn btn-primary text-primary-content" @click="showAddForm = true">
          Add New Watch
        </button>
      </div>
      <div class="card bg-base-200 border border-base-300" v-if="showAddForm || showEditForm">
        <div class="card-body">
          <h3 class="card-title text-secondary">
            {{ isEditMode ? 'Edit Watch' : 'Add New Watch' }}
          </h3>
          <DataForm
            :fields="fields"
            :modelValue="formModel"
            @update:modelValue="handleFormUpdate"
            :onSubmit="submitForm"
            :submitLabel="isEditMode ? 'Update Watch' : 'Save Watch'"
            cancelLabel="Cancel"
            :loading="loading"
            :error="error"
            @cancel="cancelForm"
          />
        </div>
      </div>
      <DataTable
        v-if="!loading && items.length && !showAddForm && !showEditForm"
        :columns="columns"
        :items="items"
        :actions="tableActions"
        emptyText="No watch items found. Add some watch items!"
        :page="page"
        :pageSize="pageSize"
        :total="total"
        @update:page="handlePageChange"
      />
      <div v-if="!loading && !items.length && !showAddForm && !showEditForm" class="alert alert-info text-info-content">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="stroke-current shrink-0 w-6 h-6"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
        <span>No watch items found. Add some watch items!</span>
      </div>
    </div>
  </div>
</template>