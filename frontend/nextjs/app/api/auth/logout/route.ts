import { NextRequest, NextResponse } from 'next/server';

export async function POST(request: NextRequest) {
  // Example: Clearing a session token cookie
  const response = NextResponse.json({ message: 'Signed out successfully' });
  response.cookies.set('auth_session', '', {
    path: '/',
    expires: new Date(0),
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'strict',
  });

  // Add any additional server-side sign-out logic here

  return response;
}
