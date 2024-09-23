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
					<h1 className="text-5xl font-bold mb-8">Sign in</h1>
					<a href="/login/github" className="btn btn-primary">
						Sign in with GitHub
					</a>
				</div>
			</div>
		</div>
	);
}