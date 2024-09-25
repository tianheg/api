import { validateRequest } from "@/lib/auth";
import { redirect } from "next/navigation";

export default async function Page() {
	const { user } = await validateRequest();
	if (user) {
		return redirect("/");
	}
	return (
		<div className="hero min-h-screen bg-base-200">
			<div className="hero-content text-center">
				<div className="max-w-md">
					<h1 className="text-5xl font-bold mb-8">Login</h1>
					<a href="/login/github" className="btn btn-primary">
						<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-github"><path d="M15 22v-4a4.8 4.8 0 0 0-1-3.5c3 0 6-2 6-5.5.08-1.25-.27-2.48-1-3.5.28-1.15.28-2.35 0-3.5 0 0-1 0-3 1.5-2.64-.5-5.36-.5-8 0C6 2 5 2 5 2c-.3 2.3 0 4.55.08 6.45a11.8 11.8 0 0 0 2.67 4.05c-.34.3-.68.58-1 1-3.3.3-6.6.6-9 0-.4-.4-.74-.8-1-1.2 0 0-1 0-3-1.5C6 10 6 10 5 12c0 3.5 3 5.5 6 5.5-.39.49-.68 1.03-.8 1.6-3 1-6 1.5-9 1.5-.1 0-.2 0-.3-.03"/><path d="M9 9h6v6"/></svg>
						Login with GitHub
					</a>
				</div>
			</div>
		</div>
	);
}