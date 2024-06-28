"use client";
import React, { useState, useEffect } from "react";
import { Input, List, Pagination, Modal, Spin } from "antd";
import { PlusOutlined } from "@ant-design/icons";
import BookForm from "./bookform";

interface Book {
  id: number;
  name: string;
  url: string;
}

async function getData() {
  const res = await fetch("http://localhost:3000/books");
  if (!res.ok) {
    throw new Error("Failed to fetch data");
  }
  return res.json();
}

const BookList = () => {
  const [books, setBooks] = useState<Book[]>([]);
  const [loading, setLoading] = useState(true);
  const [currentPage, setCurrentPage] = useState(1);
  const [pageSize, setPageSize] = useState(20);
  const [editingBook, setEditingBook] = useState<Book | null>(null);
  const [editing, setEditing] = useState(false);
  const [showAddBookForm, setShowAddBookForm] = useState(false);
  const handleAddBook = () => {
    setShowAddBookForm(true);
  };
  const saveBookData = async (bookData) => {
    try {
      const res = await fetch("http://localhost:3000/books", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(bookData),
      });
      if (!res.ok) {
        throw new Error("Failed to add book");
      }
      const newBook = await res.json();
      setBooks((prevBooks) => [...prevBooks, newBook]);
      setShowAddBookForm(false); // Close the form/modal on success
    } catch (error) {
      console.error(error);
    }
  };

  useEffect(() => {
    const fetchBooks = async () => {
      try {
        const data = await getData();
        setBooks(data.data);
        setLoading(false);
      } catch (error) {
        console.error(error);
        setLoading(false);
      }
    };
    fetchBooks();
  }, []);

  const currentBooks = books.slice(
    (currentPage - 1) * pageSize,
    currentPage * pageSize,
  );
  const handlePageChange = (page, pageSize) => {
    setCurrentPage(page);
    setPageSize(pageSize);
  };
  const handleEdit = (book: Book) => {
    setEditingBook(book);
    setEditing(true);
  };

  const handleSave = async () => {
    if (!editingBook) return;
    try {
      const res = await fetch(`http://localhost:3000/books/${editingBook.id}`, {
        method: "PUT",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(editingBook),
      });
      if (!res.ok) {
        throw new Error("Failed to update book");
      }
      setBooks((prevBooks) =>
        prevBooks.map((b) => (b.id === editingBook.id ? editingBook : b)),
      );
      setEditingBook(null);
      setEditing(false);
    } catch (error) {
      console.error(error);
    }
  };

  const handleCancel = () => {
    setEditingBook(null);
    setEditing(false);
  };

  return (
    <main className="flex min-h-screen flex-col items-center justify-between p-24">
      <h1>Books</h1>
      <button onClick={handleAddBook} className="add-book-button">
        <PlusOutlined />
      </button>
      <Modal open={showAddBookForm} onCancel={() => setShowAddBookForm(false)} okText="Save">
        <BookForm
          onSave={saveBookData}
          onCancel={() => setShowAddBookForm(false)}
        />
      </Modal>

      {loading ? (
        <Spin size="large" fullscreen />
      ) : (
        <List
          bordered
          pagination={{
            current: currentPage,
            pageSize,
            total: books.length,
            responsive: true,
            showSizeChanger: true,
            size: "small",
            onChange: handlePageChange,
          }}
          dataSource={books}
          renderItem={(book: Book) => (
            <List.Item key={book.id} onClick={() => handleEdit(book)}>
              {editing && editingBook?.id === book.id ? (
                <Modal
                  title="Edit Book"
                  open={editing && editingBook?.id === book.id}
                  onOk={handleSave}
                  onCancel={(e) => {
                    e.stopPropagation(); // Prevent event bubbling
                    handleCancel();
                  }}
                >
                  <Input
                    value={editingBook.name}
                    onChange={(e) =>
                      setEditingBook({ ...editingBook, name: e.target.value })
                    }
                  />
                </Modal>
              ) : (
                book.name
              )}
            </List.Item>
          )}
        />
      )}
    </main>
  );
};

export default BookList;
