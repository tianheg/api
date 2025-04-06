<script setup>
import { onMounted, reactive, ref } from "vue";

// Base API URL
const API_URL = import.meta.env.VITE_API_URL || "http://localhost:3000";

// Movie data and state management
const movies = ref([]);
const loading = ref(false);
const error = ref(null);

// Form states
const showAddForm = ref(false);
const showEditForm = ref(false);
const currentMovie = ref(null);

// Form models
const newMovie = reactive({
  name: "",
  review: "",
  date: new Date().toISOString().substring(0, 10)
});

const editedMovie = reactive({
  id: null,
  name: "",
  review: "",
  date: ""
});

// Fetch all movies
const fetchMovies = async () => {
  loading.value = true;
  error.value = null;
  try {
    const response = await fetch(`${API_URL}/movies`);
    if (!response.ok) throw new Error("Failed to fetch movies");
    const data = await response.json();
    movies.value = data.data || [];
    console.log("Movies:", movies.value);
  } catch (err) {
    console.error("Error fetching movies:", err);
    error.value = err.message;
  } finally {
    loading.value = false;
  }
};

// Create a new movie
const createMovie = async () => {
  try {
    const requestOptions = {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(newMovie),
    };

    const response = await fetch(`${API_URL}/movies`, requestOptions);

    if (!response.ok) throw new Error("Failed to create movie");

    Object.assign(newMovie, {
      name: "",
      review: "",
      date: new Date().toISOString().substr(0, 10)
    });
    showAddForm.value = false;
    fetchMovies();
  } catch (err) {
    console.error("Error creating movie:", err);
    error.value = err.message;
  }
};

// Start editing a movie
const startEdit = (movie) => {
  editedMovie.id = movie.id;
  editedMovie.name = movie.name;
  editedMovie.review = movie.review || "";
  editedMovie.date = movie.date || new Date().toISOString().substr(0, 10);
  showEditForm.value = true;
  currentMovie.value = movie;
};

// Update a movie
const updateMovie = async () => {
  try {
    const requestOptions = {
      method: "PUT",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        name: editedMovie.name,
        review: editedMovie.review,
        date: editedMovie.date
      }),
    };

    const response = await fetch(`${API_URL}/movies/${editedMovie.id}`, requestOptions);

    if (!response.ok) throw new Error("Failed to update movie");

    showEditForm.value = false;
    currentMovie.value = null;
    fetchMovies();
  } catch (err) {
    console.error("Error updating movie:", err);
    error.value = err.message;
  }
};

// Delete a movie
const deleteMovie = async (id) => {
  if (!confirm("Are you sure you want to delete this movie?")) return;

  try {
    const requestOptions = {
      method: "DELETE",
    };

    const response = await fetch(`${API_URL}/movies/${id}`, requestOptions);

    if (!response.ok) throw new Error("Failed to delete movie");

    fetchMovies();
  } catch (err) {
    console.error("Error deleting movie:", err);
    error.value = err.message;
  }
};

// Cancel form
const cancelForm = () => {
  showAddForm.value = false;
  showEditForm.value = false;
  currentMovie.value = null;
};

// Load movies when component is mounted
onMounted(fetchMovies);
</script>

<template>
  <div class="card bg-base-100 shadow-xl">
    <div class="card-body">
      <h1 class="card-title text-2xl mb-6">Movies Management</h1>

      <!-- Error display -->
      <div v-if="error" class="alert alert-error mb-4">
        <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
            d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
        <span>{{ error }}</span>
      </div>

      <!-- Loading indicator -->
      <div v-if="loading" class="flex justify-center my-8">
        <span class="loading loading-spinner loading-lg"></span>
      </div>

      <!-- Add Movie Button -->
      <div class="mb-6" v-if="!showAddForm && !showEditForm">
        <button class="btn btn-primary" @click="showAddForm = true">
          Add New Movie
        </button>
      </div>

      <!-- Add Movie Form -->
      <div class="card bg-base-200" v-if="showAddForm">
        <div class="card-body">
          <h3 class="card-title">Add New Movie</h3>
          <form @submit.prevent="createMovie">
            <div class="form-control mb-4">
              <label class="label" for="name">
                <span class="label-text">Name</span>
              </label>
              <input type="text" id="name" v-model="newMovie.name" required class="input input-bordered" />
            </div>

            <div class="form-control mb-4">
              <label class="label" for="review">
                <span class="label-text">Review</span>
              </label>
              <textarea id="review" v-model="newMovie.review" class="textarea textarea-bordered"
                placeholder="Movie review"></textarea>
            </div>

            <div class="form-control mb-4">
              <label class="label" for="date">
                <span class="label-text">Date</span>
              </label>
              <input type="date" id="date" v-model="newMovie.date" required class="input input-bordered" />
            </div>

            <div class="flex justify-end gap-2 mt-4">
              <button type="button" class="btn" @click="cancelForm">Cancel</button>
              <button type="submit" class="btn btn-primary">Save Movie</button>
            </div>
          </form>
        </div>
      </div>

      <!-- Edit Movie Form -->
      <div class="card bg-base-200" v-if="showEditForm">
        <div class="card-body">
          <h3 class="card-title">Edit Movie</h3>
          <form @submit.prevent="updateMovie">
            <div class="form-control mb-4">
              <label class="label" for="editName">
                <span class="label-text">Name</span>
              </label>
              <input type="text" id="editName" v-model="editedMovie.name" required class="input input-bordered" />
            </div>

            <div class="form-control mb-4">
              <label class="label" for="editReview">
                <span class="label-text">Review</span>
              </label>
              <textarea id="editReview" v-model="editedMovie.review" class="textarea textarea-bordered"
                placeholder="Movie review"></textarea>
            </div>

            <div class="form-control mb-4">
              <label class="label" for="editDate">
                <span class="label-text">Date</span>
              </label>
              <input type="date" id="editDate" v-model="editedMovie.date" required class="input input-bordered" />
            </div>

            <div class="flex justify-end gap-2 mt-4">
              <button type="button" class="btn" @click="cancelForm">Cancel</button>
              <button type="submit" class="btn btn-primary">Update Movie</button>
            </div>
          </form>
        </div>
      </div>

      <!-- Movies Table -->
      <div class="overflow-x-auto" v-if="!loading && movies.length && !showAddForm && !showEditForm">
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
            <tr v-for="movie in movies" :key="movie.id">
              <td>{{ movie.name }}</td>
              <td>{{ movie.review }}</td>
              <td>{{ movie.date }}</td>
              <td>
                <div class="flex gap-2">
                  <button class="btn btn-sm btn-info" @click="startEdit(movie)">Edit</button>
                  <button class="btn btn-sm btn-error" @click="deleteMovie(movie.id)">Delete</button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- No movies message -->
      <div v-if="!loading && !movies.length && !showAddForm && !showEditForm" class="alert alert-info">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="stroke-current shrink-0 w-6 h-6">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
            d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
        </svg>
        <span>No movies found. Add some movies!</span>
      </div>
    </div>
  </div>
</template>
