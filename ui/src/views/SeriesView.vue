<script setup>
import { onMounted, reactive, ref } from "vue";
import { csrfService } from "@/csrf";

// Base API URL
const API_URL = import.meta.env.VITE_API_URL || "http://localhost:3000";

// Series data and state management
const series = ref([]);
const loading = ref(false);
const error = ref(null);

// Form states
const showAddForm = ref(false);
const showEditForm = ref(false);
const currentSeries = ref(null);

// Form models
const newSeries = reactive({
  name: "",
  review: "",
  date: new Date().toISOString().split('T')[0] // Initialize with today's date
});

const editedSeries = reactive({
  id: null,
  name: "",
  review: "",
  date: ""
});

// Fetch all series
const fetchSeries = async () => {
  loading.value = true;
  error.value = null;
  try {
    const response = await fetch(`${API_URL}/series`);
    if (!response.ok) throw new Error("Failed to fetch series");
    const data = await response.json();
    series.value = data.data || []; // Use the data array from the response
    console.log("Series:", series.value);
  } catch (err) {
    console.error("Error fetching series:", err);
    error.value = err.message;
  } finally {
    loading.value = false;
  }
};

// Create a new series
const createSeries = async () => {
  try {
    // Prepare request with CSRF token
    const requestOptions = await csrfService.addTokenToRequest({
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(newSeries),
    });

    const response = await fetch(`${API_URL}/series`, requestOptions);

    if (!response.ok) throw new Error("Failed to create series");

    // Reset form and refresh series
    Object.assign(newSeries, { name: "", review: "", date: new Date().toISOString().split('T')[0] });
    showAddForm.value = false;
    fetchSeries();
  } catch (err) {
    console.error("Error creating series:", err);
    error.value = err.message;
  }
};

// Start editing a series
const startEdit = (item) => {
  editedSeries.id = item.id;
  editedSeries.name = item.name;
  editedSeries.review = item.review;
  editedSeries.date = item.date;
  showEditForm.value = true;
  currentSeries.value = item;
};

// Update a series
const updateSeries = async () => {
  try {
    // Prepare request with CSRF token
    const requestOptions = await csrfService.addTokenToRequest({
      method: "PUT",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        name: editedSeries.name,
        review: editedSeries.review,
        date: editedSeries.date
      }),
    });

    const response = await fetch(`${API_URL}/series/${editedSeries.id}`, requestOptions);

    if (!response.ok) throw new Error("Failed to update series");

    // Reset form and refresh series
    showEditForm.value = false;
    currentSeries.value = null;
    fetchSeries();
  } catch (err) {
    console.error("Error updating series:", err);
    error.value = err.message;
  }
};

// Delete a series
const deleteSeries = async (id) => {
  if (!confirm("Are you sure you want to delete this series?")) return;

  try {
    // Prepare request with CSRF token
    const requestOptions = await csrfService.addTokenToRequest({
      method: "DELETE",
    });

    const response = await fetch(`${API_URL}/series/${id}`, requestOptions);

    if (!response.ok) throw new Error("Failed to delete series");

    // Refresh series after delete
    fetchSeries();
  } catch (err) {
    console.error("Error deleting series:", err);
    error.value = err.message;
  }
};

// Cancel form
const cancelForm = () => {
  showAddForm.value = false;
  showEditForm.value = false;
  currentSeries.value = null;
};

// Load series when component is mounted
onMounted(fetchSeries);
</script>

<template>
  <div class="card bg-base-100 shadow-xl">
    <div class="card-body">
      <h1 class="card-title text-2xl mb-6">Series Management</h1>
      
      <!-- Error display -->
      <div v-if="error" class="alert alert-error mb-4">
        <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
        <span>{{ error }}</span>
      </div>

      <!-- Loading indicator -->
      <div v-if="loading" class="flex justify-center my-8">
        <span class="loading loading-spinner loading-lg"></span>
      </div>
      
      <!-- Add Series Button -->
      <div class="mb-6" v-if="!showAddForm && !showEditForm">
        <button class="btn btn-primary" @click="showAddForm = true">
          Add New Series
        </button>
      </div>

      <!-- Add Series Form -->
      <div class="card bg-base-200" v-if="showAddForm">
        <div class="card-body">
          <h3 class="card-title">Add New Series</h3>
          <form @submit.prevent="createSeries">
            <div class="form-control mb-4">
              <label class="label" for="name">
                <span class="label-text">Name</span>
              </label>
              <input 
                type="text" 
                id="name" 
                v-model="newSeries.name"
                required
                class="input input-bordered"
              />
            </div>
            
            <div class="form-control mb-4">
              <label class="label" for="review">
                <span class="label-text">Review</span>
              </label>
              <textarea 
                id="review" 
                v-model="newSeries.review"
                required
                class="textarea textarea-bordered"
                rows="3"
              ></textarea>
            </div>
            
            <div class="form-control mb-4">
              <label class="label" for="date">
                <span class="label-text">Date</span>
              </label>
              <input 
                type="date" 
                id="date" 
                v-model="newSeries.date"
                required
                class="input input-bordered"
              />
            </div>
            
            <div class="flex justify-end gap-2 mt-4">
              <button type="button" class="btn" @click="cancelForm">Cancel</button>
              <button type="submit" class="btn btn-primary">Save Series</button>
            </div>
          </form>
        </div>
      </div>
      
      <!-- Edit Series Form -->
      <div class="card bg-base-200" v-if="showEditForm">
        <div class="card-body">
          <h3 class="card-title">Edit Series</h3>
          <form @submit.prevent="updateSeries">
            <div class="form-control mb-4">
              <label class="label" for="editName">
                <span class="label-text">Name</span>
              </label>
              <input 
                type="text" 
                id="editName" 
                v-model="editedSeries.name"
                required
                class="input input-bordered"
              />
            </div>
            
            <div class="form-control mb-4">
              <label class="label" for="editReview">
                <span class="label-text">Review</span>
              </label>
              <textarea 
                id="editReview" 
                v-model="editedSeries.review"
                required
                class="textarea textarea-bordered"
                rows="3"
              ></textarea>
            </div>
            
            <div class="form-control mb-4">
              <label class="label" for="editDate">
                <span class="label-text">Date</span>
              </label>
              <input 
                type="date" 
                id="editDate" 
                v-model="editedSeries.date"
                required
                class="input input-bordered"
              />
            </div>
            
            <div class="flex justify-end gap-2 mt-4">
              <button type="button" class="btn" @click="cancelForm">Cancel</button>
              <button type="submit" class="btn btn-primary">Update Series</button>
            </div>
          </form>
        </div>
      </div>

      <!-- Series Table -->
      <div class="overflow-x-auto" v-if="!loading && series.length && !showAddForm && !showEditForm">
        <table class="table table-zebra">
          <thead>
            <tr>
              <th>Name</th>
              <th>Review</th>
              <th>Date</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in series" :key="item.id">
              <td>{{ item.name }}</td>
              <td>{{ item.review }}</td>
              <td>{{ new Date(item.date).toLocaleDateString() }}</td>
              <td>
                <div class="flex gap-2">
                  <button class="btn btn-sm btn-info" @click="startEdit(item)">Edit</button>
                  <button class="btn btn-sm btn-error" @click="deleteSeries(item.id)">Delete</button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      
      <!-- No series message -->
      <div v-if="!loading && !series.length && !showAddForm && !showEditForm" class="alert alert-info">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="stroke-current shrink-0 w-6 h-6"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
        <span>No series found. Add some series!</span>
      </div>
    </div>
  </div>
</template>