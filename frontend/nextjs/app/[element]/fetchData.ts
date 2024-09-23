export async function fetchData(element: string) {
  try {
    const res = await fetch(`https://api.tianheg.org/${element}`);
    if (!res.ok) {
      throw new Error(`HTTP error! status: ${res.status}`);
    }
    const data = await res.json();
    console.log('Fetched data:', data);
    return data.data;
  } catch (error) {
    console.error('Error fetching data:', error);
    throw error;
  }
}
