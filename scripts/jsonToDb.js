import * as dotenv from "dotenv";
dotenv.config();

import { Client } from "pg";

// Set up the PostgreSQL client with your configuration
const client = new Client({
  connectionString: process.env.POSTGRES_URL,
});

async function createTableIfNotExist(client, tableName) {
  const createTableQuery = `
    CREATE TABLE IF NOT EXISTS ${tableName} (
      id SERIAL PRIMARY KEY,
      json_data JSONB NOT NULL
    );
  `;
  await client.query(createTableQuery);
  console.log(`Table ${tableName} is ready, or already exists.`);
}

async function truncateTable(client, tableName) {
  const truncateQuery = `TRUNCATE TABLE ${tableName};`;
  await client.query(truncateQuery);
  console.log(`Truncated table ${tableName}`);
}

async function uploadJsonDataFromFile(client, relativePath, tableName) {
  try {
    const module = await import(`../${relativePath}`);
    const jsonDataFromFile = module.default;

    await createTableIfNotExist(client, tableName);
    await truncateTable(client, tableName);

    // Assuming jsonDataFromFile is an array of objects
    for (const data of jsonDataFromFile) {
      const query = {
        text: `INSERT INTO ${tableName}(json_data) VALUES(\$1)`,
        values: [JSON.stringify(data)], // Convert data to JSON string
      };
      await client.query(query);
    }

    console.log(`Data from ${relativePath} inserted successfully into ${tableName}`);
  } catch (err) {
    console.error(`Error uploading data from file ${relativePath}:`, err);
  }
}

async function uploadAllFiles(client) {
  const files = ["books.js", "feeds.js", "movies.js", "music.js", "musicals.js", "prompts.js", "series.js", "words.js"];

  for (const file of files) {
    const tableName = file.replace('.js', ''); // Remove '.js' to form the table name
    await uploadJsonDataFromFile(client, `data/${file}`, tableName);
  }
}

async function main() {
  try {
    await client.connect();
    await uploadAllFiles(client);
    console.log("Data uploaded successfully");
  } catch (err) {
    console.error("Error uploading data:", err);
  } finally {
    await client.end();
    console.log("Disconnected from the database.");
  }
}
main();
