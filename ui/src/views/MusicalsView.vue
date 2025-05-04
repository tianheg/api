<script setup>
import { onMounted, reactive, ref, computed, watch } from "vue";
import DataForm from "@/components/DataForm.vue";
import DataTable from "@/components/DataTable.vue";

const API_URL = import.meta.env.VITE_API_URL || "http://localhost:3000";
const musicals = ref([]);
const loading = ref(false);
const error = ref(null);
const showAddForm = ref(false);
const showEditForm = ref(false);
const currentMusical = ref(null);
const formModel = reactive({ name: "", review: "" });
const isEditMode = computed(() => showEditForm.value);

const musicalFields = [
  { name: "name", label: "Name", type: "text", required: true, desc: "Enter the name of the musical." },
  { name: "review", label: "Review", type: "textarea", required: true, desc: "Write your review here." },
];

const musicalColumns = [
  { label: "Name", key: "name" },
  { label: "Review", key: "review" },
];

watch([showAddForm, showEditForm, currentMusical], ([add, edit, item]) => {
  if (add) {
    Object.assign(formModel, { name: "", review: "" });
  } else if (edit && item) {
    Object.assign(formModel, item);
  }
});

const fetchMusicals = async () => {
  loading.value = true;
  error.value = null;
  try {
    const response = await fetch(`${API_URL}/musicals`);
    if (!response.ok) throw new Error("Failed to fetch musicals");
    const data = await response.json();
    musicals.value = data.data || [];
  } catch (err) {
    error.value = err.message;
  } finally {
    loading.value = false;
  }
};

const submitForm = async () => {
  if (isEditMode.value) {
    await updateMusicalUnified();
  } else {
    await createMusicalUnified();
  }
};

const createMusicalUnified = async () => {
  try {
    const requestOptions = {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(formModel),
    };
    const response = await fetch(`${API_URL}/musicals`, requestOptions);
    if (!response.ok) throw new Error("Failed to create musical");
    Object.assign(formModel, { name: "", review: "" });
    showAddForm.value = false;
    fetchMusicals();
  } catch (err) {
    error.value = err.message;
  }
};

const updateMusicalUnified = async () => {
  try {
    const requestOptions = {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(formModel),
    };
    const response = await fetch(`${API_URL}/musicals/${currentMusical.value.id}`, requestOptions);
    if (!response.ok) throw new Error("Failed to update musical");
    showEditForm.value = false;
    currentMusical.value = null;
    fetchMusicals();
  } catch (err) {
    error.value = err.message;
  }
};

const deleteMusical = async (id) => {
  if (!confirm("Are you sure you want to delete this musical?")) return;
  try {
    const requestOptions = { method: "DELETE" };
    const response = await fetch(`${API_URL}/musicals/${id}`, requestOptions);
    if (!response.ok) throw new Error("Failed to delete musical");
    fetchMusicals();
  } catch (err) {
    error.value = err.message;
  }
};

const cancelForm = () => {
  showAddForm.value = false;
  showEditForm.value = false;
  currentMusical.value = null;
};

const tableActions = [
  {
    label: "Edit",
    class: "btn-info text-info-content",
    icon: `<svg xmlns='http://www.w3.org/2000/svg' class='w-4 h-4 mr-1' fill='none' viewBox='0 0 24 24' stroke='currentColor'><path stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M15.232 5.232l3.536 3.536M9 13h3l8-8a2.828 2.828 0 00-4-4l-8 8v3z' /></svg>`,
    onClick: (item) => { currentMusical.value = item; showEditForm.value = true; },
  },
  {
    label: "Delete",
    class: "btn-error text-error-content",
    icon: `<svg xmlns='http://www.w3.org/2000/svg' class='w-4 h-4 mr-1' fill='none' viewBox='0 0 24 24' stroke='currentColor'><path stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M6 18L18 6M6 6l12 12' /></svg>`,
    onClick: (item) => deleteMusical(item.id),
  },
];

onMounted(fetchMusicals);
</script>
<template>
  <div class="card bg-base-100">
    <div class="card-body">
      <h1 class="card-title text-2xl mb-6 text-primary">Musicals Management</h1>
      <div v-if="error" class="alert alert-error mb-4 text-error-content">
        <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
        <span>{{ error }}</span>
      </div>
      <div v-if="loading" class="flex justify-center my-8">
        <span class="loading loading-spinner loading-lg text-primary"></span>
      </div>
      <div class="mb-6" v-if="!showAddForm && !showEditForm">
        <button class="btn btn-primary text-primary-content" @click="showAddForm = true">
          Add New Musical
        </button>
      </div>
      <div class="card bg-base-200 border border-base-300" v-if="showAddForm || showEditForm">
        <div class="card-body">
          <h3 class="card-title text-secondary">
            {{ isEditMode ? 'Edit Musical' : 'Add New Musical' }}
          </h3>
          <DataForm
            :fields="musicalFields"
            v-model="formModel"
            :onSubmit="submitForm"
            :submitLabel="isEditMode ? 'Update Musical' : 'Save Musical'"
            cancelLabel="Cancel"
            :loading="loading"
            :error="error"
            @cancel="cancelForm"
          />
        </div>
      </div>
      <DataTable
        v-if="!loading && musicals.length && !showAddForm && !showEditForm"
        :columns="musicalColumns"
        :items="musicals"
        :actions="tableActions"
        emptyText="No musicals found. Add some musicals!"
      />
      <div v-if="!loading && !musicals.length && !showAddForm && !showEditForm" class="alert alert-info text-info-content">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="stroke-current shrink-0 w-6 h-6"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
        <span>No musicals found. Add some musicals!</span>
      </div>
    </div>
  </div>
</template>