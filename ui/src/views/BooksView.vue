<script setup>
import { onMounted, reactive, ref } from "vue";

// Base API URL
const API_URL = import.meta.env.VITE_API_URL || "http://localhost:3000";

// Book data and state management
const books = ref([]);
const loading = ref(false);
const error = ref(null);

// Form states
const showAddForm = ref(false);
const showEditForm = ref(false);
const currentBook = ref(null);

// Form models
const newBook = reactive({
  name: "",
  url: "",
});

const editedBook = reactive({
  id: null,
  name: "",
  url: "",
});

// Fetch all books
const fetchBooks = async () => {
  loading.value = true;
  error.value = null;
  try {
    const response = await fetch(`${API_URL}/books`);
    if (!response.ok) throw new Error("Failed to fetch books");
    const data = await response.json();
    books.value = data.data || []; // Use the data array from the response
    console.log("Books:", books.value);
  } catch (err) {
    console.error("Error fetching books:", err);
    error.value = err.message;
  } finally {
    loading.value = false;
  }
};

// Create a new book
const createBook = async () => {
  try {
    const requestOptions = {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(newBook),
    };

    const response = await fetch(`${API_URL}/books`, requestOptions);

    if (!response.ok) throw new Error("Failed to create book");

    // Reset form and refresh books
    Object.assign(newBook, { name: "", url: "" });
    showAddForm.value = false;
    fetchBooks();
  } catch (err) {
    console.error("Error creating book:", err);
    error.value = err.message;
  }
};

// Start editing a book
const startEdit = (book) => {
  editedBook.id = book.id;
  editedBook.name = book.name;
  editedBook.url = book.url;
  showEditForm.value = true;
  currentBook.value = book;
};

// Update a book
const updateBook = async () => {
  try {
    const requestOptions = {
      method: "PUT",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        name: editedBook.name,
        url: editedBook.url,
      }),
    };

    const response = await fetch(
      `${API_URL}/books/${editedBook.id}`,
      requestOptions,
    );

    if (!response.ok) throw new Error("Failed to update book");

    // Reset form and refresh books
    showEditForm.value = false;
    currentBook.value = null;
    fetchBooks();
  } catch (err) {
    console.error("Error updating book:", err);
    error.value = err.message;
  }
};

// Delete a book
const deleteBook = async (id) => {
  if (!confirm("Are you sure you want to delete this book?")) return;

  try {
    const requestOptions = {
      method: "DELETE",
    };

    const response = await fetch(`${API_URL}/books/${id}`, requestOptions);

    if (!response.ok) throw new Error("Failed to delete book");

    // Refresh books after delete
    fetchBooks();
  } catch (err) {
    console.error("Error deleting book:", err);
    error.value = err.message;
  }
};

// Cancel form
const cancelForm = () => {
  showAddForm.value = false;
  showEditForm.value = false;
  currentBook.value = null;
};

// Load books when component is mounted
onMounted(fetchBooks);
</script>

<template>
  <div class="card bg-base-100 shadow-xl">
    <div class="card-body">
      <h1 class="card-title text-2xl mb-6">Books Management</h1>
      
      <!-- Error display -->
      <div v-if="error" class="alert alert-error mb-4">
        <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
        <span>{{ error }}</span>
      </div>

      <!-- Loading indicator -->
      <div v-if="loading" class="flex justify-center my-8">
        <span class="loading loading-spinner loading-lg"></span>
      </div>
      
      <!-- Add Book Button -->
      <div class="mb-6" v-if="!showAddForm && !showEditForm">
        <button class="btn btn-primary" @click="showAddForm = true">
          Add New Book
        </button>
      </div>

      <!-- Add Book Form -->
      <div class="card bg-base-200" v-if="showAddForm">
        <div class="card-body">
          <h3 class="card-title">Add New Book</h3>
          <form @submit.prevent="createBook">
            <div class="form-control mb-4">
              <label class="label" for="name">
                <span class="label-text">Name</span>
              </label>
              <input 
                type="text" 
                id="name" 
                v-model="newBook.name"
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
                v-model="newBook.url"
                required
                class="input input-bordered"
                placeholder="https://"
              />
            </div>
            
            <div class="flex justify-end gap-2 mt-4">
              <button type="button" class="btn" @click="cancelForm">Cancel</button>
              <button type="submit" class="btn btn-primary">Save Book</button>
            </div>
          </form>
        </div>
      </div>
      
      <!-- Edit Book Form -->
      <div class="card bg-base-200" v-if="showEditForm">
        <div class="card-body">
          <h3 class="card-title">Edit Book</h3>
          <form @submit.prevent="updateBook">
            <div class="form-control mb-4">
              <label class="label" for="editName">
                <span class="label-text">Name</span>
              </label>
              <input 
                type="text" 
                id="editName" 
                v-model="editedBook.name"
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
                v-model="editedBook.url"
                required
                class="input input-bordered"
                placeholder="https://"
              />
            </div>
            
            <div class="flex justify-end gap-2 mt-4">
              <button type="button" class="btn" @click="cancelForm">Cancel</button>
              <button type="submit" class="btn btn-primary">Update Book</button>
            </div>
          </form>
        </div>
      </div>

      <!-- Books Table -->
      <div class="overflow-x-auto" v-if="!loading && books.length && !showAddForm && !showEditForm">
        <table class="table table-zebra">
          <thead>
            <tr>
              <th>Name</th>
              <th>URL</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="book in books" :key="book.id">
              <td>{{ book.name }}</td>
              <td>
                <a :href="book.url" target="_blank" rel="noopener noreferrer" class="link link-primary">{{ book.url }}</a>
              </td>
              <td>
                <div class="flex gap-2">
                  <button class="btn btn-sm btn-info" @click="startEdit(book)">Edit</button>
                  <button class="btn btn-sm btn-error" @click="deleteBook(book.id)">Delete</button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      
      <!-- No books message -->
      <div v-if="!loading && !books.length && !showAddForm && !showEditForm" class="alert alert-info">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="stroke-current shrink-0 w-6 h-6"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
        <span>No books found. Add some books!</span>
      </div>
    </div>
  </div>
</template>
