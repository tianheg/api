<script setup>
import { onMounted, reactive, ref, computed, watch } from "vue";
import DataForm from "@/components/DataForm.vue";
import DataTable from "@/components/DataTable.vue";

const API_URL = import.meta.env.VITE_API_URL || "http://localhost:3000";
const items = ref([]);
const loading = ref(false);
const error = ref(null);
const showAddForm = ref(false);
const showEditForm = ref(false);
const currentItem = ref(null);
const formModel = reactive({ id: null, title: "", url: "", description: "", rss: "" });
const isEditMode = computed(() => showEditForm.value);

const page = ref(1);
const pageSize = ref(10);
const total = ref(0);

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

watch([showAddForm, showEditForm, currentItem], ([add, edit, item]) => {
  error.value = null;
  if (add) {
    Object.assign(formModel, { id: null, title: "", url: "", description: "", rss: "" });
  } else if (edit && item) {
    Object.assign(formModel, { ...item });
  } else if (!add && !edit) {
    Object.assign(formModel, { id: null, title: "", url: "", description: "", rss: "" });
  }
});

const fetchItems = async () => {
  loading.value = true;
  error.value = null;
  try {
    const response = await fetch(`${API_URL}/feeds?page=${page.value}&limit=${pageSize.value}`);
    if (!response.ok) throw new Error("Failed to fetch feeds");
    const data = await response.json();
    items.value = data.data || [];
    total.value = data.total || 0;
  } catch (err) {
    error.value = err.message;
  } finally {
    loading.value = false;
  }
};

function handlePageChange(newPage) {
  page.value = newPage;
  fetchItems();
}

const submitForm = async () => {
  if (isEditMode.value) {
    await updateItem();
  } else {
    await createItem();
  }
};

const createItem = async () => {
  try {
    const { id, ...createData } = formModel;
    const requestOptions = {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(createData),
    };
    const response = await fetch(`${API_URL}/feeds`, requestOptions);
    if (!response.ok) throw new Error("Failed to create feed");
    Object.assign(formModel, { id: null, title: "", url: "", description: "", rss: "" });
    showAddForm.value = false;
    fetchItems();
  } catch (err) {
    error.value = err.message;
  }
};

const updateItem = async () => {
  try {
    const { id, ...updateData } = formModel;
    if (!id) throw new Error("Cannot update feed without ID.");

    const requestOptions = {
      method: "PUT",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(updateData),
    };

    const response = await fetch(
      `${API_URL}/feeds/${id}`,
      requestOptions,
    );

    if (!response.ok) throw new Error("Failed to update feed");

    showEditForm.value = false;
    currentItem.value = null;
    fetchItems();
  } catch (err) {
    error.value = err.message;
  }
};

const deleteItem = async (id) => {
  if (!confirm("Are you sure you want to delete this feed?")) return;
  try {
    const requestOptions = { method: "DELETE" };
    const response = await fetch(`${API_URL}/feeds/${id}`, requestOptions);
    if (!response.ok) throw new Error("Failed to delete feed");
    fetchItems();
  } catch (err) {
    error.value = err.message;
  }
};

const cancelForm = () => {
  showAddForm.value = false;
  showEditForm.value = false;
  currentItem.value = null;
};

function handleFormUpdate(newValue) {
  Object.assign(formModel, newValue);
}

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
