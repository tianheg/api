import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
	title: "Lifebook",
	description: "Record things in my life"
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
	return (
		<html lang="zh">
			<body className="bg-base-100">{children}</body>
		</html>
	);
}