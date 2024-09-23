'use client';

import { useEffect, useState } from 'react';
import { fetchData } from './fetchData';
import ItemList from './ItemList';

export default function Page({ params }: { params: { element: string } }) {
  const [items, setItems] = useState<any[] | undefined>(undefined);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function loadData() {
      try {
        const data = await fetchData(params.element);
        setItems(data);
      } catch (err) {
        setError('Failed to fetch data. Please try again later.');
        console.error(err);
      }
    }
    loadData();
  }, [params.element]);

  if (error) {
    return <div>Error: {error}</div>;
  }

  return <ItemList items={items} element={params.element} />;
}
