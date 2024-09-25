import { lucia, validateRequest } from "@/lib/auth";
import { redirect } from "next/navigation";
import { cookies } from "next/headers";
import Link from "next/link";

export default async function Page() {
	const { user } = await validateRequest();
	if (!user) {
		return redirect("/login");
	}
	return (
		<div className="min-h-screen relative">
			<form action={logout} className="absolute top-4 right-4">
				<button type="submit" className="btn btn-error btn-sm">
					Logout
				</button>
			</form>
			<div className="hero min-h-screen">
				<div className="hero-content text-center">
					<div className="max-w-md">
						<h1 className="text-5xl font-bold mb-4">Hi, {user.username}!</h1>
						<p className="text-lg">Your user ID is {user.id}.</p>						
						<div className="mt-8">
							<h2 className="text-3xl font-bold mb-4">精神食粮</h2>
							<div className="grid grid-cols-1 md:grid-cols-2 gap-4">
								<Link href="/books" className="btn btn-primary">Books</Link>
								<Link href="/movies" className="btn btn-primary">Movies</Link>
								<Link href="/feeds" className="btn btn-primary">Feeds</Link>
								<Link href="/music" className="btn btn-primary">Music</Link>
								<Link href="/musicals" className="btn btn-primary">Musicals</Link>
								<Link href="/series" className="btn btn-primary">Series</Link>
								<Link href="/words" className="btn btn-primary">Words</Link>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	);
}


async function logout(): Promise<ActionResult> {
	"use server";
	const { session } = await validateRequest();
	if (!session) {
		return {
			error: "Unauthorized"
		};
	}

	await lucia.invalidateSession(session.id);

	const sessionCookie = lucia.createBlankSessionCookie();
	cookies().set(sessionCookie.name, sessionCookie.value, sessionCookie.attributes);
	return redirect("/login");
}

interface ActionResult {
	error: string | null;
}