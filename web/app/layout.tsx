import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'
import { CartProvider } from '../lib/contexts/CartContext'
import { RestaurantProvider } from '../lib/contexts/RestaurantContext'
import Navigation from '../components/Navigation'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'БЫК - Премиум доставка еды',
  description: 'Заказывайте еду из лучших ресторанов: THE БЫК, THE ПИВО, MOSCA',
  keywords: 'доставка еды, рестораны, стейки, пиво, итальянская кухня',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="ru">
      <body className={inter.className}>
        <RestaurantProvider>
          <CartProvider>
            <div className="min-h-screen bg-gradient-to-br from-black via-gray-900 to-black">
              <Navigation />
              {children}
            </div>
          </CartProvider>
        </RestaurantProvider>
      </body>
    </html>
  )
} 