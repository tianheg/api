import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

// Define the paths that do not require authentication
const publicPaths = ['/login', '/login/github', '/login/github/callback'];

export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;

  // Allow requests to public paths
  if (publicPaths.some((path) => pathname.startsWith(path))) {
    return NextResponse.next();
  }

  // Get the session cookie
  const sessionCookie = request.cookies.get('auth_session'); // Adjust the cookie name if different

  if (!sessionCookie) {
    // Redirect to login if not authenticated
    const loginUrl = request.nextUrl.clone();
    loginUrl.pathname = '/login';
    return NextResponse.redirect(loginUrl);
  }

  // Optionally, you can verify the session token here
  // However, since Middleware runs on Edge runtime, integrating Lucia validation here is not straightforward
  // It's recommended to handle detailed session validation in server components or API routes

  return NextResponse.next();
}

export const config = {
  matcher: ['/((?!api|_next/static|favicon.ico).*)'],
};
