<script setup>
import { onMounted, reactive, ref } from "vue";

// Base API URL
const API_URL = import.meta.env.VITE_API_URL || "http://localhost:3000";

// Sentences data and state management
const sentences = ref([]);
const loading = ref(false);
const error = ref(null);

// Form states
const showAddForm = ref(false);
const showEditForm = ref(false);
const currentSentence = ref(null);

// Form models
const newSentence = reactive({
  content: "",
});

const editedSentence = reactive({
  id: null,
  content: "",
});

// Fetch all sentences
const fetchSentences = async () => {
  loading.value = true;
  error.value = null;
  try {
    const response = await fetch(`${API_URL}/sentences`);
    if (!response.ok) throw new Error("Failed to fetch sentences");
    const data = await response.json();
    sentences.value = data.data || [];
    console.log("Sentences:", sentences.value);
  } catch (err) {
    console.error("Error fetching sentences:", err);
    error.value = err.message;
  } finally {
    loading.value = false;
  }
};

// Create a new sentence
const createSentence = async () => {
  try {
    const requestOptions = {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(newSentence),
    };

    const response = await fetch(`${API_URL}/sentences`, requestOptions);

    if (!response.ok) throw new Error("Failed to create sentence");

    Object.assign(newSentence, { content: "" });
    showAddForm.value = false;
    fetchSentences();
  } catch (err) {
    console.error("Error creating sentence:", err);
    error.value = err.message;
  }
};

// Start editing a sentence
const startEdit = (sentence) => {
  editedSentence.id = sentence.id;
  editedSentence.content = sentence.content;
  showEditForm.value = true;
  currentSentence.value = sentence;
};

// Update a sentence
const updateSentence = async () => {
  try {
    const requestOptions = {
      method: "PUT",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        sentence: editedSentence.sentence,
      }),
    };

    const response = await fetch(
      `${API_URL}/sentences/${editedSentence.id}`,
      requestOptions,
    );

    if (!response.ok) throw new Error("Failed to update sentence");

    showEditForm.value = false;
    currentSentence.value = null;
    fetchSentences();
  } catch (err) {
    console.error("Error updating sentence:", err);
    error.value = err.message;
  }
};

// Delete a sentence
const deleteSentence = async (id) => {
  if (!confirm("Are you sure you want to delete this sentence?")) return;

  try {
    const requestOptions = {
      method: "DELETE",
    };

    const response = await fetch(`${API_URL}/sentences/${id}`, requestOptions);

    if (!response.ok) throw new Error("Failed to delete sentence");

    fetchSentences();
  } catch (err) {
    console.error("Error deleting sentence:", err);
    error.value = err.message;
  }
};

// Cancel form
const cancelForm = () => {
  showAddForm.value = false;
  showEditForm.value = false;
  currentSentence.value = null;
};

// Load sentences when component is mounted
onMounted(fetchSentences);
</script>

<template>
  <div class="card bg-base-100 shadow-xl border border-base-300">
    <div class="card-body">
      <h1 class="card-title text-2xl mb-6 text-primary">Sentences Management</h1>
      
      <!-- Error display -->
      <div v-if="error" class="alert alert-error mb-4 text-error-content">
        <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
        <span>{{ error }}</span>
      </div>

      <!-- Loading indicator -->
      <div v-if="loading" class="flex justify-center my-8">
        <span class="loading loading-spinner loading-lg text-primary"></span>
      </div>
      
      <!-- Add Sentence Button -->
      <div class="mb-6" v-if="!showAddForm && !showEditForm">
        <button class="btn btn-primary text-primary-content" @click="showAddForm = true">
          Add New Sentence
        </button>
      </div>

      <!-- Add Sentence Form -->
      <div class="card bg-base-200 border border-base-300" v-if="showAddForm">
        <div class="card-body">
          <h3 class="card-title text-secondary">Add New Sentence</h3>
          <form @submit.prevent="createSentence">
            <div class="form-control mb-4">
              <label class="label" for="content">
                <span class="label-text text-base-content">Content</span>
              </label>
              <textarea 
                id="content" 
                v-model="newSentence.content"
                required
                class="textarea textarea-bordered h-24 bg-base-100 text-base-content"
              ></textarea>
            </div>
            
            <div class="flex justify-end gap-2 mt-4">
              <button type="button" class="btn btn-ghost text-base-content" @click="cancelForm">Cancel</button>
              <button type="submit" class="btn btn-primary text-primary-content">Save Sentence</button>
            </div>
          </form>
        </div>
      </div>
      
      <!-- Edit Sentence Form -->
      <div class="card bg-base-200 border border-base-300" v-if="showEditForm">
        <div class="card-body">
          <h3 class="card-title text-secondary">Edit Sentence</h3>
          <form @submit.prevent="updateSentence">
            <div class="form-control mb-4">
              <label class="label" for="editContent">
                <span class="label-text text-base-content">Content</span>
              </label>
              <textarea 
                id="editContent" 
                v-model="editedSentence.content"
                required
                class="textarea textarea-bordered h-24 bg-base-100 text-base-content"
              ></textarea>
            </div>
            
            <div class="flex justify-end gap-2 mt-4">
              <button type="button" class="btn btn-ghost text-base-content" @click="cancelForm">Cancel</button>
              <button type="submit" class="btn btn-primary text-primary-content">Update Sentence</button>
            </div>
          </form>
        </div>
      </div>

      <!-- Sentences Table -->
      <div class="overflow-x-auto" v-if="!loading && sentences.length && !showAddForm && !showEditForm">
        <table class="table table-zebra w-full">
          <thead class="bg-base-200 text-base-content">
            <tr>
              <th>Content</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody class="bg-base-100 text-base-content">
            <tr v-for="item in sentences" :key="item.id">
              <td>{{ item.content }}</td>
              <td>
                <div class="flex gap-2">
                  <button class="btn btn-sm btn-info text-info-content" @click="startEdit(item)">Edit</button>
                  <button class="btn btn-sm btn-error text-error-content" @click="deleteSentence(item.id)">Delete</button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      
      <!-- No sentences message -->
      <div v-if="!loading && !sentences.length && !showAddForm && !showEditForm" class="alert alert-info text-info-content">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="stroke-current shrink-0 w-6 h-6"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
        <span>No sentences found. Add some sentences!</span>
      </div>
    </div>
  </div>
</template>