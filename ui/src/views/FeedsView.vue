<script setup>
import { onMounted } from "vue";
import DataForm from "@/components/DataForm.vue";
import DataTable from "@/components/DataTable.vue";
import { useCrud } from "@/composables/useCrud";
import { useApi } from "@/composables/useApi";

// Get API utilities
const { getResourceUrl, handleSuccess, handleError } = useApi();

// Define form fields and table columns
const fields = [
  { name: "title", label: "Title", type: "text", required: true, desc: "Enter a descriptive title for the feed." },
  { name: "url", label: "URL", type: "url", required: true, placeholder: "https://", desc: "The main website for this feed." },
  { name: "description", label: "Description", type: "textarea", required: false, desc: "Optional: Short description of the feed." },
  { name: "rss", label: "RSS URL", type: "url", required: true, placeholder: "https://", desc: "Direct link to the RSS feed." },
];

const columns = [
  { label: "Title", key: "title" },
  { label: "URL", key: "url" },
  { label: "Description", key: "description" },
  { label: "RSS URL", key: "rss" },
];

// Use the CRUD composable with Feeds-specific configuration
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
  resourceUrl: getResourceUrl('feeds'),
  initialItem: { id: null, title: "", url: "", description: "", rss: "" },
  onSuccess: handleSuccess,
  onError: handleError,
  resourceName: 'feed'
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
      <h1 class="card-title text-2xl mb-6 text-primary">Feeds Management</h1>
      <div v-if="loading" class="flex justify-center my-8">
        <span class="loading loading-spinner loading-lg text-primary"></span>
      </div>
      <div class="mb-6" v-if="!showAddForm && !showEditForm">
        <button class="btn btn-primary text-primary-content" @click="showAddForm = true">
          Add New Feed
        </button>
      </div>
      <div class="card bg-base-200 border border-base-300" v-if="showAddForm || showEditForm">
        <div class="card-body">
          <h3 class="card-title text-secondary">
            {{ isEditMode ? 'Edit Feed' : 'Add New Feed' }}
          </h3>
          <DataForm
            :fields="fields"
            :modelValue="formModel"
            @update:modelValue="handleFormUpdate"
            :onSubmit="submitForm"
            :submitLabel="isEditMode ? 'Update Feed' : 'Save Feed'"
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
        emptyText="No feeds found. Add some feeds!"
        :page="page"
        :pageSize="pageSize"
        :total="total"
        @update:page="handlePageChange"
      >
        <template #url="{ item }">
          <a :href="item.url" target="_blank" rel="noopener noreferrer" class="link link-primary">
            {{ item.url }}
          </a>
        </template>
        <template #rss="{ item }">
          <a :href="item.rss" target="_blank" rel="noopener noreferrer" class="link link-primary">{{ item.rss }}</a>
        </template>
        <template #description="{ item }">
          <span class="max-w-xs truncate" :title="item.description">{{ item.description }}</span>
        </template>
      </DataTable>
      <div v-if="!loading && !items.length && !showAddForm && !showEditForm" class="alert alert-info text-info-content">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="stroke-current shrink-0 w-6 h-6"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
        <span>No feeds found. Add some feeds!</span>
      </div>
    </div>
  </div>
</template>
