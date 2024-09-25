import { verifyRequestOrigin } from "lucia";
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

// Define the paths that do not require authentication
const publicPaths = ['/login', '/login/github', '/login/github/callback'];

export async function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;

  // Allow requests to public paths
  if (publicPaths.some((path) => pathname.startsWith(path))) {
    return NextResponse.next();
  }

  // Get the session cookie
  const sessionCookie = request.cookies.get('auth_session');

  if (!sessionCookie) {
    // Redirect to login if not authenticated
    const loginUrl = request.nextUrl.clone();
    loginUrl.pathname = '/login';
    return NextResponse.redirect(loginUrl);
  }

  // CSRF protection
  if (request.method === 'GET') { 
    return NextResponse.next();
  }
  const orginHeader = request.headers.get('Origin');
  const hostHeader = request.headers.get('Host');
  if (!orginHeader || !hostHeader || !verifyRequestOrigin(orginHeader, [hostHeader])) {
    return new NextResponse(null, { status: 403 });
  }

  return NextResponse.next();
}

export const config = {
  matcher: ['/((?!api|_next/static|favicon.ico).*)'],
};
