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
const formModel = reactive({ id: null, name: "", url: "" });
const isEditMode = computed(() => showEditForm.value);

const page = ref(1);
const pageSize = ref(10);
const total = ref(0);

const fields = [
  { name: "name", label: "Name", type: "text", required: true, desc: "Enter the name of the music." },
  { name: "url", label: "URL", type: "url", required: false, placeholder: "https://", desc: "Optional: Link to the music." },
];

const columns = [
  { label: "Name", key: "name" },
  { label: "URL", key: "url" },
];

watch([showAddForm, showEditForm, currentItem], ([add, edit, item]) => {
  error.value = null;
  if (add) {
    Object.assign(formModel, { id: null, name: "", url: "" });
  } else if (edit && item) {
    Object.assign(formModel, { ...item });
  } else if (!add && !edit) {
    Object.assign(formModel, { id: null, name: "", url: "" });
  }
});

const fetchItems = async () => {
  loading.value = true;
  error.value = null;
  try {
    const response = await fetch(`${API_URL}/music?page=${page.value}&limit=${pageSize.value}`);
    if (!response.ok) throw new Error("Failed to fetch music");
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
    const requestOptions = {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(formModel),
    };
    const response = await fetch(`${API_URL}/music`, requestOptions);
    if (!response.ok) throw new Error("Failed to create music");
    Object.assign(formModel, { id: null, name: "", url: "" });
    showAddForm.value = false;
    fetchItems();
  } catch (err) {
    error.value = err.message;
  }
};

const updateItem = async () => {
  try {
    const { id, ...updateData } = formModel;
    if (!id) throw new Error("Cannot update music without ID.");

    const requestOptions = {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(updateData),
    };
    const response = await fetch(`${API_URL}/music/${id}`, requestOptions);
    if (!response.ok) throw new Error("Failed to update music");
    showEditForm.value = false;
    currentItem.value = null;
    fetchItems();
  } catch (err) {
    error.value = err.message;
  }
};

const deleteItem = async (id) => {
  if (!confirm("Are you sure you want to delete this music?")) return;
  try {
    const requestOptions = { method: "DELETE" };
    const response = await fetch(`${API_URL}/music/${id}`, requestOptions);
    if (!response.ok) throw new Error("Failed to delete music");
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
      <h1 class="card-title text-2xl mb-6 text-primary">Music Management</h1>
      <div v-if="loading" class="flex justify-center my-8">
        <span class="loading loading-spinner loading-lg text-primary"></span>
      </div>
      <div class="mb-6" v-if="!showAddForm && !showEditForm">
        <button class="btn btn-primary text-primary-content" @click="showAddForm = true">
          Add New Music
        </button>
      </div>
      <div class="card bg-base-200 border border-base-300" v-if="showAddForm || showEditForm">
        <div class="card-body">
          <h3 class="card-title text-secondary">
            {{ isEditMode ? 'Edit Music' : 'Add New Music' }}
          </h3>
          <DataForm
            :fields="fields"
            :modelValue="formModel"
            @update:modelValue="handleFormUpdate"
            :onSubmit="submitForm"
            :submitLabel="isEditMode ? 'Update Music' : 'Save Music'"
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
        emptyText="No music found. Add some music!"
        :page="page"
        :pageSize="pageSize"
        :total="total"
        @update:page="handlePageChange"
      >
        <template #url="{ item }">
          <a v-if="item.url" :href="item.url" target="_blank" rel="noopener noreferrer" class="link link-primary">{{ item.url }}</a>
          <span v-else class="text-base-content/50">-</span>
        </template>
      </DataTable>
      <div v-if="!loading && !items.length && !showAddForm && !showEditForm" class="alert alert-info text-info-content">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="stroke-current shrink-0 w-6 h-6"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
        <span>No music found. Add some music!</span>
      </div>
    </div>
  </div>
</template>