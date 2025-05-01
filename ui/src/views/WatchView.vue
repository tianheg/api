<script setup>
import { onMounted, reactive, ref } from "vue";

// Base API URL
const API_URL = import.meta.env.VITE_API_URL || "http://localhost:3000";

// Watch data and state management
const watch = ref([]);
const loading = ref(false);
const error = ref(null);

// Form states
const showAddForm = ref(false);
const showEditForm = ref(false);
const currentWatch = ref(null);

// Form models
const newWatch = reactive({
  name: "",
  review: "",
});

const editedWatch = reactive({
  id: null,
  name: "",
  review: "",
});

// Fetch all watch items
const fetchWatch = async () => {
  loading.value = true;
  error.value = null;
  try {
    const response = await fetch(`${API_URL}/watch`);
    if (!response.ok) throw new Error("Failed to fetch watch items");
    const data = await response.json();
    watch.value = data.data || []; // Use the data array from the response
    console.log("Watch:", watch.value);
  } catch (err) {
    console.error("Error fetching watch items:", err);
    error.value = err.message;
  } finally {
    loading.value = false;
  }
};

// Create a new watch item
const createWatch = async () => {
  try {
    const requestOptions = {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(newWatch),
    };
    const response = await fetch(`${API_URL}/watch`, requestOptions);
    if (!response.ok) throw new Error("Failed to create watch item");
    // Reset form and refresh watch
    Object.assign(newWatch, { name: "", review: "" });
    showAddForm.value = false;
    fetchWatch();
  } catch (err) {
    console.error("Error creating watch item:", err);
    error.value = err.message;
  }
};

// Start editing a watch item
const startEdit = (item) => {
  editedWatch.id = item.id;
  editedWatch.name = item.name;
  editedWatch.review = item.review;
  showEditForm.value = true;
  currentWatch.value = item;
};

// Update a watch item
const updateWatch = async () => {
  try {
    const requestOptions = {
      method: "PUT",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        name: editedWatch.name,
        review: editedWatch.review,
      }),
    };

    const response = await fetch(
      `${API_URL}/watch/${editedWatch.id}`,
      requestOptions,
    );

    if (!response.ok) throw new Error("Failed to update watch item");

    // Reset form and refresh watch
    showEditForm.value = false;
    currentWatch.value = null;
    fetchWatch();
  } catch (err) {
    console.error("Error updating watch item:", err);
    error.value = err.message;
  }
};

// Delete a watch item
const deleteWatch = async (id) => {
  if (!confirm("Are you sure you want to delete this watch item?")) return;
  try {
    const requestOptions = {
      method: "DELETE",
    };
    const response = await fetch(`${API_URL}/watch/${id}`, requestOptions);
    if (!response.ok) throw new Error("Failed to delete watch item");
    // Refresh watch after delete
    fetchWatch();
  } catch (err) {
    console.error("Error deleting watch item:", err);
    error.value = err.message;
  }
};

// Cancel form
const cancelForm = () => {
  showAddForm.value = false;
  showEditForm.value = false;
  currentWatch.value = null;
};

// Load watch items when component is mounted
onMounted(fetchWatch);
</script>
<template>
  <div class="card bg-base-100 shadow-xl border border-base-300">
    <div class="card-body">
      <h1 class="card-title text-2xl mb-6 text-primary">Watch Management</h1>
      <!-- Error display -->
      <div v-if="error" class="alert alert-error mb-4 text-error-content">
        <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
        <span>{{ error }}</span>
      </div>
      <!-- Loading indicator -->
      <div v-if="loading" class="flex justify-center my-8">
        <span class="loading loading-spinner loading-lg text-primary"></span>
      </div>
      <!-- Add Watch Button -->
      <div class="mb-6" v-if="!showAddForm && !showEditForm">
        <button class="btn btn-primary text-primary-content" @click="showAddForm = true">
          Add New Watch
        </button>
      </div>
      <!-- Add Watch Form -->
      <div class="card bg-base-200 border border-base-300" v-if="showAddForm">
        <div class="card-body">
          <h3 class="card-title text-secondary">Add New Watch</h3>
          <form @submit.prevent="createWatch">
            <div class="form-control mb-4">
              <label class="label" for="name">
                <span class="label-text text-base-content">Name</span>
              </label>
              <input 
                type="text" 
                id="name" 
                v-model="newWatch.name"
                required
                class="input input-bordered bg-base-100 text-base-content"
              />
            </div>
            <div class="form-control mb-4">
              <label class="label" for="review">
                <span class="label-text text-base-content">Review</span>
              </label>
              <textarea 
                id="review" 
                v-model="newWatch.review"
                required
                class="textarea textarea-bordered bg-base-100 text-base-content"
                rows="3"
              ></textarea>
            </div>
            <div class="flex justify-end gap-2 mt-4">
              <button type="button" class="btn btn-ghost text-base-content" @click="cancelForm">Cancel</button>
              <button type="submit" class="btn btn-primary text-primary-content">Save Watch</button>
            </div>
          </form>
        </div>
      </div>
      <!-- Edit Watch Form -->
      <div class="card bg-base-200 border border-base-300" v-if="showEditForm">
        <div class="card-body">
          <h3 class="card-title text-secondary">Edit Watch</h3>
          <form @submit.prevent="updateWatch">
            <div class="form-control mb-4">
              <label class="label" for="editName">
                <span class="label-text text-base-content">Name</span>
              </label>
              <input 
                type="text" 
                id="editName" 
                v-model="editedWatch.name"
                required
                class="input input-bordered bg-base-100 text-base-content"
              />
            </div>
            <div class="form-control mb-4">
              <label class="label" for="editReview">
                <span class="label-text text-base-content">Review</span>
              </label>
              <textarea 
                id="editReview" 
                v-model="editedWatch.review"
                required
                class="textarea textarea-bordered bg-base-100 text-base-content"
                rows="3"
              ></textarea>
            </div>
            <div class="flex justify-end gap-2 mt-4">
              <button type="button" class="btn btn-ghost text-base-content" @click="cancelForm">Cancel</button>
              <button type="submit" class="btn btn-primary text-primary-content">Update Watch</button>
            </div>
          </form>
        </div>
      </div>
      <!-- Watch Table -->
      <div class="overflow-x-auto" v-if="!loading && watch.length && !showAddForm && !showEditForm">
        <table class="table table-zebra w-full">
          <thead class="bg-base-200 text-base-content">
            <tr>
              <th>Name</th>
              <th>Review</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody class="bg-base-100 text-base-content">
            <tr v-for="item in watch" :key="item.id">
              <td>{{ item.name }}</td>
              <td>{{ item.review }}</td>
              <td>
                <div class="flex gap-2">
                  <button class="btn btn-sm btn-info text-info-content" @click="startEdit(item)">Edit</button>
                  <button class="btn btn-sm btn-error text-error-content" @click="deleteWatch(item.id)">Delete</button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <!-- No watch items message -->
      <div v-if="!loading && !watch.length && !showAddForm && !showEditForm" class="alert alert-info text-info-content">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="stroke-current shrink-0 w-6 h-6"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
        <span>No watch items found. Add some watch items!</span>
      </div>
    </div>
  </div>
</template>