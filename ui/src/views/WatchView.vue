<script setup>
import { onMounted, reactive, ref, computed, watch } from "vue";
import DataForm from "@/components/DataForm.vue";
import DataTable from "@/components/DataTable.vue";

const API_URL = import.meta.env.VITE_API_URL || "http://localhost:3000";
const watchList = ref([]);
const loading = ref(false);
const error = ref(null);
const showAddForm = ref(false);
const showEditForm = ref(false);
const currentWatch = ref(null);
const formModel = reactive({ name: "", review: "" });
const isEditMode = computed(() => showEditForm.value);

const page = ref(1);
const pageSize = ref(10);
const total = ref(0);

const watchFields = [
  { name: "name", label: "Name", type: "text", required: true, desc: "Enter the name of the item." },
  { name: "review", label: "Review", type: "textarea", required: true, desc: "Write your review here." },
];

const watchColumns = [
  { label: "Name", key: "name" },
  { label: "Review", key: "review" },
];

watch([showAddForm, showEditForm, currentWatch], ([add, edit, item]) => {
  if (add) {
    Object.assign(formModel, { name: "", review: "" });
  } else if (edit && item) {
    Object.assign(formModel, item);
  }
});

const fetchWatch = async () => {
  loading.value = true;
  error.value = null;
  try {
    const response = await fetch(`${API_URL}/watch?page=${page.value}&limit=${pageSize.value}`);
    if (!response.ok) throw new Error("Failed to fetch watch items");
    const data = await response.json();
    watchList.value = data.data || [];
    total.value = data.total || 0;
  } catch (err) {
    error.value = err.message;
  } finally {
    loading.value = false;
  }
};

function handlePageChange(newPage) {
  page.value = newPage;
  fetchWatch();
}

const submitForm = async () => {
  if (isEditMode.value) {
    await updateWatchUnified();
  } else {
    await createWatchUnified();
  }
};

const createWatchUnified = async () => {
  try {
    const requestOptions = {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(formModel),
    };
    const response = await fetch(`${API_URL}/watch`, requestOptions);
    if (!response.ok) throw new Error("Failed to create watch item");
    Object.assign(formModel, { name: "", review: "" });
    showAddForm.value = false;
    fetchWatch();
  } catch (err) {
    error.value = err.message;
  }
};

const updateWatchUnified = async () => {
  try {
    const requestOptions = {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(formModel),
    };
    const response = await fetch(`${API_URL}/watch/${currentWatch.value.id}`, requestOptions);
    if (!response.ok) throw new Error("Failed to update watch item");
    showEditForm.value = false;
    currentWatch.value = null;
    fetchWatch();
  } catch (err) {
    error.value = err.message;
  }
};

const deleteWatch = async (id) => {
  if (!confirm("Are you sure you want to delete this watch item?")) return;
  try {
    const requestOptions = { method: "DELETE" };
    const response = await fetch(`${API_URL}/watch/${id}`, requestOptions);
    if (!response.ok) throw new Error("Failed to delete watch item");
    fetchWatch();
  } catch (err) {
    error.value = err.message;
  }
};

const cancelForm = () => {
  showAddForm.value = false;
  showEditForm.value = false;
  currentWatch.value = null;
};

const tableActions = [
  {
    label: "Edit",
    class: "btn-info text-info-content",
    icon: `<svg xmlns='http://www.w3.org/2000/svg' class='w-4 h-4 mr-1' fill='none' viewBox='0 0 24 24' stroke='currentColor'><path stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M15.232 5.232l3.536 3.536M9 13h3l8-8a2.828 2.828 0 00-4-4l-8 8v3z' /></svg>`,
    onClick: (item) => { currentWatch.value = item; showEditForm.value = true; },
  },
  {
    label: "Delete",
    class: "btn-error text-error-content",
    icon: `<svg xmlns='http://www.w3.org/2000/svg' class='w-4 h-4 mr-1' fill='none' viewBox='0 0 24 24' stroke='currentColor'><path stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M6 18L18 6M6 6l12 12' /></svg>`,
    onClick: (item) => deleteWatch(item.id),
  },
];

onMounted(fetchWatch);
</script>
<template>
  <div class="card bg-base-100">
    <div class="card-body">
      <h1 class="card-title text-2xl mb-6 text-primary">Watch Management</h1>
      <div v-if="error" class="alert alert-error mb-4 text-error-content">
        <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
        <span>{{ error }}</span>
      </div>
      <div v-if="loading" class="flex justify-center my-8">
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
            :fields="watchFields"
            v-model="formModel"
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
        v-if="!loading && watchList.length && !showAddForm && !showEditForm"
        :columns="watchColumns"
        :items="watchList"
        :actions="tableActions"
        emptyText="No watch items found. Add some watch items!"
        :page="page"
        :pageSize="pageSize"
        :total="total"
        @update:page="handlePageChange"
      />
      <div v-if="!loading && !watchList.length && !showAddForm && !showEditForm" class="alert alert-info text-info-content">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="stroke-current shrink-0 w-6 h-6"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
        <span>No watch items found. Add some watch items!</span>
      </div>
    </div>
  </div>
</template>