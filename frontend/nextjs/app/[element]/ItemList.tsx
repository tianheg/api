"use client";

import React from 'react';
import { useRouter } from 'next/navigation';
import { IconLogout } from "@tabler/icons-react";

interface Item {
  id: string;
  name: string;
}

interface ItemListProps {
  items: Item[] | undefined;
  element: string;
}

const ItemList: React.FC<ItemListProps> = ({ items, element }) => {
  const router = useRouter();

  const handleLogout = async () => {
    try {
      const response = await fetch('/api/auth/logout', {
        method: 'POST',
        credentials: 'include',
      });
      if (response.ok) {
        router.push('/login');
      } else {
        console.error('Logout failed:', response.statusText);
      }
    } catch (error) {
      console.error('Error during logout:', error);
    }
  };

  return (
    <div className="flex flex-col items-center justify-center min-h-screen">
      <button
        type="button"
        onClick={handleLogout}
        className="flex items-center mb-4 px-4 py-2 bg-red-500 text-white rounded absolute top-4 right-4"
      >
        <IconLogout className="mr-2" />
        Logout
      </button>

      <div className="container mx-auto p-4 max-w-[880px] text-center">
        <h1 className="text-3xl font-bold mb-4">{element} List</h1>
        {items ? (
          <ul className="menu bg-base-200 w-56 rounded-box mx-auto">
            {items.map((item) => (
              <li key={item.id}>
                <a className="hover:bg-base-300">{item.name}</a>
              </li>
            ))}
          </ul>
        ) : (
          <div className="flex justify-center items-center">
            <span className="loading loading-spinner loading-lg" />
            <p className="ml-2">Loading...</p>
          </div>
        )}
      </div>
    </div>
  );
};

export default ItemList;
