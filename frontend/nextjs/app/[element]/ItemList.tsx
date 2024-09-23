import React from 'react';

interface Item {
  // Define the structure of your item here
  id: string;
  name: string;
  // Add other properties as needed
}

interface ItemListProps {
  items: Item[] | undefined;
  element: string;
}

const ItemList: React.FC<ItemListProps> = ({ items, element }) => {
  return (
    <div className="flex flex-col items-center justify-center min-h-screen">
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
