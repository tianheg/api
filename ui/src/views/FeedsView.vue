<script setup>
import { onMounted, reactive, ref } from "vue";

// Base API URL
const API_URL = import.meta.env.VITE_API_URL || "http://localhost:3000";

// Feed data and state management
const feeds = ref([]);
const loading = ref(false);
const error = ref(null);

// Form states
const showAddForm = ref(false);
const showEditForm = ref(false);
const currentFeed = ref(null);

// Form models
const newFeed = reactive({
  title: "",
  url: "",
  description: "",
  rss: "",
});

const editedFeed = reactive({
  id: null,
  title: "",
  url: "",
  description: "",
  rss: "",
});

// Fetch all feeds
const fetchFeeds = async () => {
  loading.value = true;
  error.value = null;
  try {
    const response = await fetch(`${API_URL}/feeds`);
    if (!response.ok) throw new Error("Failed to fetch feeds");
    const data = await response.json();
    feeds.value = data.data || [];
    console.log("Feeds:", feeds.value);
  } catch (err) {
    console.error("Error fetching feeds:", err);
    error.value = err.message;
  } finally {
    loading.value = false;
  }
};

// Create a new feed
const createFeed = async () => {
  try {
    const requestOptions = {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(newFeed),
    };

    const response = await fetch(`${API_URL}/feeds`, requestOptions);

    if (!response.ok) throw new Error("Failed to create feed");

    Object.assign(newFeed, { title: "", url: "", description: "", rss: "" });
    showAddForm.value = false;
    fetchFeeds();
  } catch (err) {
    console.error("Error creating feed:", err);
    error.value = err.message;
  }
};

// Start editing a feed
const startEdit = (feed) => {
  editedFeed.id = feed.id;
  editedFeed.title = feed.title;
  editedFeed.url = feed.url;
  editedFeed.description = feed.description;
  editedFeed.rss = feed.rss;
  showEditForm.value = true;
  currentFeed.value = feed;
};

// Update a feed
const updateFeed = async () => {
  try {
    const requestOptions = {
      method: "PUT",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        title: editedFeed.title,
        url: editedFeed.url,
        description: editedFeed.description,
        rss: editedFeed.rss,
      }),
    };

    const response = await fetch(`${API_URL}/feeds/${editedFeed.id}`, requestOptions);

    if (!response.ok) throw new Error("Failed to update feed");

    showEditForm.value = false;
    currentFeed.value = null;
    fetchFeeds();
  } catch (err) {
    console.error("Error updating feed:", err);
    error.value = err.message;
  }
};

// Delete a feed
const deleteFeed = async (id) => {
  if (!confirm("Are you sure you want to delete this feed?")) return;

  try {
    const requestOptions = {
      method: "DELETE",
    };

    const response = await fetch(`${API_URL}/feeds/${id}`, requestOptions);

    if (!response.ok) throw new Error("Failed to delete feed");

    fetchFeeds();
  } catch (err) {
    console.error("Error deleting feed:", err);
    error.value = err.message;
  }
};

// Cancel form
const cancelForm = () => {
  showAddForm.value = false;
  showEditForm.value = false;
  currentFeed.value = null;
};

// Load feeds when component is mounted
onMounted(fetchFeeds);
</script>

<template>
  <div class="card bg-base-100 shadow-xl">
    <div class="card-body">
      <h1 class="card-title text-2xl mb-6">Feeds Management</h1>
      
      <!-- Error display -->
      <div v-if="error" class="alert alert-error mb-4">
        <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
        <span>{{ error }}</span>
      </div>

      <!-- Loading indicator -->
      <div v-if="loading" class="flex justify-center my-8">
        <span class="loading loading-spinner loading-lg"></span>
      </div>
      
      <!-- Add Feed Button -->
      <div class="mb-6" v-if="!showAddForm && !showEditForm">
        <button class="btn btn-primary" @click="showAddForm = true">
          Add New Feed
        </button>
      </div>

      <!-- Add Feed Form -->
      <div class="card bg-base-200" v-if="showAddForm">
        <div class="card-body">
          <h3 class="card-title">Add New Feed</h3>
          <form @submit.prevent="createFeed">
            <div class="form-control mb-4">
              <label class="label" for="title">
                <span class="label-text">Title</span>
              </label>
              <input 
                type="text" 
                id="title" 
                v-model="newFeed.title"
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
                v-model="newFeed.url"
                required
                class="input input-bordered"
                placeholder="https://"
              />
            </div>

            <div class="form-control mb-4">
              <label class="label" for="description">
                <span class="label-text">Description</span>
              </label>
              <textarea
                id="description"
                v-model="newFeed.description"
                class="textarea textarea-bordered"
                placeholder="Feed description"
              ></textarea>
            </div>

            <div class="form-control mb-4">
              <label class="label" for="rss">
                <span class="label-text">RSS URL</span>
              </label>
              <input
                type="url"
                id="rss"
                v-model="newFeed.rss"
                required
                class="input input-bordered"
                placeholder="https://"
              />
            </div>
            
            <div class="flex justify-end gap-2 mt-4">
              <button type="button" class="btn" @click="cancelForm">Cancel</button>
              <button type="submit" class="btn btn-primary">Save Feed</button>
            </div>
          </form>
        </div>
      </div>
      
      <!-- Edit Feed Form -->
      <div class="card bg-base-200" v-if="showEditForm">
        <div class="card-body">
          <h3 class="card-title">Edit Feed</h3>
          <form @submit.prevent="updateFeed">
            <div class="form-control mb-4">
              <label class="label" for="editTitle">
                <span class="label-text">Title</span>
              </label>
              <input 
                type="text" 
                id="editTitle" 
                v-model="editedFeed.title"
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
                v-model="editedFeed.url"
                required
                class="input input-bordered"
                placeholder="https://"
              />
            </div>

            <div class="form-control mb-4">
              <label class="label" for="editDescription">
                <span class="label-text">Description</span>
              </label>
              <textarea
                id="editDescription"
                v-model="editedFeed.description"
                class="textarea textarea-bordered"
                placeholder="Feed description"
              ></textarea>
            </div>

            <div class="form-control mb-4">
              <label class="label" for="editRss">
                <span class="label-text">RSS URL</span>
              </label>
              <input
                type="url"
                id="editRss"
                v-model="editedFeed.rss"
                required
                class="input input-bordered"
                placeholder="https://"
              />
            </div>
            
            <div class="flex justify-end gap-2 mt-4">
              <button type="button" class="btn" @click="cancelForm">Cancel</button>
              <button type="submit" class="btn btn-primary">Update Feed</button>
            </div>
          </form>
        </div>
      </div>

      <!-- Feeds Table -->
      <div class="overflow-x-auto" v-if="!loading && feeds.length && !showAddForm && !showEditForm">
        <table class="table table-zebra">
          <thead>
            <tr>
              <th>Title</th>
              <th>URL</th>
              <th>Description</th>
              <th>RSS URL</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="feed in feeds" :key="feed.id">
              <td>{{ feed.title }}</td>
              <td>
                <a :href="feed.url" target="_blank" rel="noopener noreferrer" class="link link-primary">{{ feed.url }}</a>
              </td>
              <td>{{ feed.description }}</td>
              <td>
                <a :href="feed.rss" target="_blank" rel="noopener noreferrer" class="link link-primary">{{ feed.rss }}</a>
              </td>
              <td>
                <div class="flex gap-2">
                  <button class="btn btn-sm btn-info" @click="startEdit(feed)">Edit</button>
                  <button class="btn btn-sm btn-error" @click="deleteFeed(feed.id)">Delete</button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      
      <!-- No feeds message -->
      <div v-if="!loading && !feeds.length && !showAddForm && !showEditForm" class="alert alert-info">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="stroke-current shrink-0 w-6 h-6"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
        <span>No feeds found. Add some feeds!</span>
      </div>
    </div>
  </div>
</template>
