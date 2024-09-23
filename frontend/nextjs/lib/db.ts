import { createClient } from "@libsql/client";

export const db = createClient({
	url: process.env.TURSO_DATABASE_URL || '',
	authToken: process.env.TURSO_AUTH_TOKEN || '',
});

await db.execute(`CREATE TABLE IF NOT EXISTS user (
    id TEXT NOT NULL PRIMARY KEY,
    github_id INTEGER UNIQUE,
    username TEXT NOT NULL
)`);

await db.execute(`CREATE TABLE IF NOT EXISTS session (
    id TEXT NOT NULL PRIMARY KEY,
    expires_at INTEGER NOT NULL,
    user_id TEXT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES user(id)
)`);

export interface DatabaseUser {
	id: string;
	username: string;
	github_id: number;
}