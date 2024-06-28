"use client";

import type React from "react";
import { useState } from "react";
import { Button, Form, Input, Space } from "antd";

interface BookFormProps {
  onSave: (bookData: { name: string; url: string }) => void;
  onCancel: () => void;
  initialData?: { name: string; url: string };
}

const BookForm: React.FC<BookFormProps> = ({
  onSave,
  onCancel,
  initialData,
}) => {
  const [name, setName] = useState(initialData?.name || "");
  const [url, setUrl] = useState(initialData?.url || "");

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    onSave({ name, url });
  };

  return (
    <Form onFinish={handleSubmit} className="book-form">
      <h2>{initialData ? "Edit" : "Add"} Book</h2>

      <Form.Item
        label="Name"
        name="name"
        rules={[{ required: true, message: "Please enter a name" }]}
      >
        <Input />
      </Form.Item>

      <Form.Item
        label="Url"
        name="url"
        rules={[{ required: true, message: "Please enter a url" }]}
      >
        <Input />
      </Form.Item>

    </Form>
  );
};

export default BookForm;
