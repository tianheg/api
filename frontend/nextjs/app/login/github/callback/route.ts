import { github, lucia } from "@/lib/auth";
import { db } from "@/lib/db";
import { cookies } from "next/headers";
import { OAuth2RequestError } from "arctic";
import { generateId } from "lucia";

import type { DatabaseUser } from "@/lib/db";

export async function GET(request: Request): Promise<Response> {
	const url = new URL(request.url);
	const code = url.searchParams.get("code");
	const state = url.searchParams.get("state");
	const storedState = cookies().get("github_oauth_state")?.value ?? null;
	if (!code || !state || !storedState || state !== storedState) {
		console.error("State mismatch or missing parameters");
		return new Response(null, {
			status: 400
		});
	}

	try {
		const tokens = await github.validateAuthorizationCode(code);
		const githubUserResponse = await fetch("https://api.github.com/user", {
			headers: {
				Authorization: `Bearer ${tokens.accessToken}`
			}
		});
		const githubUser: GitHubUser = await githubUserResponse.json();
		console.log("GitHub User:", githubUser);

		const existingUserResult = await db.execute({
			sql: "SELECT * FROM user WHERE github_id = ?",
			args: [githubUser.id]
		});
		const existingUser = existingUserResult.rows[0] as unknown as DatabaseUser | undefined;

		if (existingUser) {
			console.log("Existing user found:", existingUser);
			const session = await lucia.createSession(existingUser.id, {});
			const sessionCookie = lucia.createSessionCookie(session.id);
				cookies().set(sessionCookie.name, sessionCookie.value, sessionCookie.attributes);
			return new Response(null, {
				status: 302,
				headers: {
					Location: "/"
				}
			});
		}

		const userId = generateId(15);
		await db.execute({
			sql: "INSERT INTO user (id, github_id, username) VALUES (?, ?, ?)",
			args: [userId, githubUser.id, githubUser.login]
		});
		console.log("New user inserted:", { userId, githubId: githubUser.id, username: githubUser.login });

		const session = await lucia.createSession(userId, {});
		const sessionCookie = lucia.createSessionCookie(session.id);
		cookies().set(sessionCookie.name, sessionCookie.value, sessionCookie.attributes);
		return new Response(null, {
			status: 302,
			headers: {
				Location: "/"
			}
		});
	} catch (e) {
		console.error("Error during GitHub OAuth callback:", e);
		if (e instanceof OAuth2RequestError && e.message === "bad_verification_code") {
			// invalid code
			return new Response(null, {
				status: 400
			});
		}
		return new Response(null, {
			status: 500
		});
	}
}

interface GitHubUser {
	id: string;
	login: string;
}