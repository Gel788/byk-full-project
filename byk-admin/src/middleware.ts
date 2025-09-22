import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export function middleware(request: NextRequest) {
  // Проверяем, если пользователь идет на главную страницу
  if (request.nextUrl.pathname === '/') {
    // В реальном приложении здесь будет проверка токена из cookies или headers
    // Для демонстрации просто пропускаем
    return NextResponse.next()
  }

  // Пропускаем все остальные запросы
  return NextResponse.next()
}

export const config = {
  matcher: [
    /*
     * Match all request paths except for the ones starting with:
     * - api (API routes)
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     */
    '/((?!api|_next/static|_next/image|favicon.ico).*)',
  ],
}
