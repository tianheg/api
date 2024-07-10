import { List } from "antd";
import Link from "next/link";
import BookList from "./books/page";

interface Book {
  id: number;
  name: string;
  url: string;
}

async function getData() {
  const res = await fetch("http://localhost:3000/books");
  if (!res.ok) {
    throw new Error(" Failed to fetch data");
  }
  return res.json();
}

export default async function Home() {
  const books = await getData();

  return (
    <main className="flex min-h-screen flex-col items-center justify-between p-24">
      <h1>Home</h1>

      <List>
        <Link href="/books">Books</Link>
        <BookList books={books} />
      </List>
    </main>
  );
}
