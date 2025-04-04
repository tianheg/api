<script setup>
import { onMounted, reactive, ref } from "vue";

// Base API URL
const API_URL = import.meta.env.VITE_API_URL || "http://localhost:3000";

// Music data and state management
const music = ref([]);
const loading = ref(false);
const error = ref(null);

// Form states
const showAddForm = ref(false);
const showEditForm = ref(false);
const currentMusic = ref(null);

// Form models
const newMusic = reactive({
  name: "",
  url: "",
});

const editedMusic = reactive({
  id: null,
  name: "",
  url: "",
});

// Fetch all music
const fetchMusic = async () => {
  loading.value = true;
  error.value = null;
  try {
    const response = await fetch(`${API_URL}/music`);
    if (!response.ok) throw new Error("Failed to fetch music");
    const data = await response.json();
    music.value = data.data || []; // Use the data array from the response
    console.log("Music:", music.value);
  } catch (err) {
    console.error("Error fetching music:", err);
    error.value = err.message;
  } finally {
    loading.value = false;
  }
};

// Create a new music entry
const createMusic = async () => {
  try {
    const response = await fetch(`${API_URL}/music`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(newMusic),
    });

    if (!response.ok) throw new Error("Failed to create music entry");

    // Reset form and refresh music list
    Object.assign(newMusic, { name: "", url: "" });
    showAddForm.value = false;
    fetchMusic();
  } catch (err) {
    console.error("Error creating music entry:", err);
    error.value = err.message;
  }
};

// Start editing a music entry
const startEdit = (item) => {
  editedMusic.id = item.id;
  editedMusic.name = item.name;
  editedMusic.url = item.url || "";
  showEditForm.value = true;
  currentMusic.value = item;
};

// Update a music entry
const updateMusic = async () => {
  try {
    const response = await fetch(`${API_URL}/music/${editedMusic.id}`, {
      method: "PUT",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        name: editedMusic.name,
        url: editedMusic.url,
      }),
    });

    if (!response.ok) throw new Error("Failed to update music entry");

    // Reset form and refresh music list
    showEditForm.value = false;
    currentMusic.value = null;
    fetchMusic();
  } catch (err) {
    console.error("Error updating music entry:", err);
    error.value = err.message;
  }
};

// Delete a music entry
const deleteMusic = async (id) => {
  if (!confirm("Are you sure you want to delete this music entry?")) return;

  try {
    const response = await fetch(`${API_URL}/music/${id}`, {
      method: "DELETE",
    });

    if (!response.ok) throw new Error("Failed to delete music entry");

    // Refresh music list after delete
    fetchMusic();
  } catch (err) {
    console.error("Error deleting music entry:", err);
    error.value = err.message;
  }
};

// Cancel form
const cancelForm = () => {
  showAddForm.value = false;
  showEditForm.value = false;
  currentMusic.value = null;
};

// Load music when component is mounted
onMounted(fetchMusic);
</script>

<template>
  <div class="card bg-base-100 shadow-xl">
    <div class="card-body">
      <h1 class="card-title text-2xl mb-6">Music Management</h1>
      
      <!-- Error display -->
      <div v-if="error" class="alert alert-error mb-4">
        <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
        <span>{{ error }}</span>
      </div>

      <!-- Loading indicator -->
      <div v-if="loading" class="flex justify-center my-8">
        <span class="loading loading-spinner loading-lg"></span>
      </div>
      
      <!-- Add Music Button -->
      <div class="mb-6" v-if="!showAddForm && !showEditForm">
        <button class="btn btn-primary" @click="showAddForm = true">
          Add New Music
        </button>
      </div>

      <!-- Add Music Form -->
      <div class="card bg-base-200" v-if="showAddForm">
        <div class="card-body">
          <h3 class="card-title">Add New Music</h3>
          <form @submit.prevent="createMusic">
            <div class="form-control mb-4">
              <label class="label" for="name">
                <span class="label-text">Name</span>
              </label>
              <input 
                type="text" 
                id="name" 
                v-model="newMusic.name"
                required
                class="input input-bordered"
              />
            </div>
            
            <div class="form-control mb-4">
              <label class="label" for="url">
                <span class="label-text">URL</span>
              </label>
              <input 
                type="url" 
                id="url" 
                v-model="newMusic.url"
                class="input input-bordered"
                placeholder="https://"
              />
            </div>
            
            <div class="flex justify-end gap-2 mt-4">
              <button type="button" class="btn" @click="cancelForm">Cancel</button>
              <button type="submit" class="btn btn-primary">Save Music</button>
            </div>
          </form>
        </div>
      </div>
      
      <!-- Edit Music Form -->
      <div class="card bg-base-200" v-if="showEditForm">
        <div class="card-body">
          <h3 class="card-title">Edit Music</h3>
          <form @submit.prevent="updateMusic">
            <div class="form-control mb-4">
              <label class="label" for="editName">
                <span class="label-text">Name</span>
              </label>
              <input 
                type="text" 
                id="editName" 
                v-model="editedMusic.name"
                required
                class="input input-bordered"
              />
            </div>
            
            <div class="form-control mb-4">
              <label class="label" for="editUrl">
                <span class="label-text">URL</span>
              </label>
              <input 
                type="url" 
                id="editUrl" 
                v-model="editedMusic.url"
                class="input input-bordered"
                placeholder="https://"
              />
            </div>
            
            <div class="flex justify-end gap-2 mt-4">
              <button type="button" class="btn" @click="cancelForm">Cancel</button>
              <button type="submit" class="btn btn-primary">Update Music</button>
            </div>
          </form>
        </div>
      </div>

      <!-- Music Table -->
      <div class="overflow-x-auto" v-if="!loading && music.length && !showAddForm && !showEditForm">
        <table class="table table-zebra">
          <thead>
            <tr>
              <th>Name</th>
              <th>URL</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in music" :key="item.id">
              <td>{{ item.name }}</td>
              <td>
                <a v-if="item.url" :href="item.url" target="_blank" rel="noopener noreferrer" class="link link-primary">{{ item.url }}</a>
                <span v-else>-</span>
              </td>
              <td>
                <div class="flex gap-2">
                  <button class="btn btn-sm btn-info" @click="startEdit(item)">Edit</button>
                  <button class="btn btn-sm btn-error" @click="deleteMusic(item.id)">Delete</button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      
      <!-- No music message -->
      <div v-if="!loading && !music.length && !showAddForm && !showEditForm" class="alert alert-info">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="stroke-current shrink-0 w-6 h-6"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
        <span>No music found. Add some music!</span>
      </div>
    </div>
  </div>
</template>