'use client';

import { useState } from 'react';
import { motion } from 'framer-motion';
import { ShoppingCart, User, Menu, X } from 'lucide-react';
import { useRouter } from 'next/navigation';
import { useCart } from '../lib/contexts/CartContext';
import CartView from './CartView';

export default function Header() {
  const router = useRouter();
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const [isCartOpen, setIsCartOpen] = useState(false);
  const { hasItems, items } = useCart();
  
  const cartCount = items.reduce((sum, item) => sum + item.quantity, 0);

  return (
    <>
      <header className="fixed top-0 left-0 right-0 z-50 glass-effect">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            {/* Логотип */}
            <motion.div
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.5 }}
              className="flex items-center space-x-2"
            >
              <div className="relative">
                <motion.div
                  animate={{ rotate: 360 }}
                  transition={{ duration: 2, repeat: Infinity, ease: "linear" }}
                  className="w-8 h-8 bg-gradient-to-r from-primary-500 to-accent-500 rounded-full flex items-center justify-center"
                >
                  <span className="text-white font-bold text-sm">Б</span>
                </motion.div>
              </div>
              <span className="text-xl font-bold gradient-text">БЫК</span>
            </motion.div>

            {/* Навигация для десктопа */}
            <nav className="hidden md:flex items-center space-x-8">
              <NavLink href="/restaurants">Рестораны</NavLink>
              <NavLink href="/menu">Меню</NavLink>
              <NavLink href="/news">Новости</NavLink>
              <NavLink href="/about">О нас</NavLink>
            </nav>

            {/* Правая часть */}
            <div className="flex items-center space-x-4">
              {/* Корзина */}
              <motion.button
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                onClick={() => router.push('/cart')}
                className="relative p-2 rounded-full bg-white/10 hover:bg-white/20 transition-colors"
              >
                <ShoppingCart className="w-5 h-5 text-white" />
                {cartCount > 0 && (
                  <motion.span
                    initial={{ scale: 0 }}
                    animate={{ scale: 1 }}
                    className="absolute -top-1 -right-1 w-5 h-5 bg-red-500 text-white text-xs rounded-full flex items-center justify-center font-bold"
                  >
                    {cartCount}
                  </motion.span>
                )}
              </motion.button>

              {/* Профиль */}
              <motion.button
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                onClick={() => router.push('/profile')}
                className="p-2 rounded-full bg-white/10 hover:bg-white/20 transition-colors"
              >
                <User className="w-5 h-5 text-white" />
              </motion.button>

              {/* Мобильное меню */}
              <button
                onClick={() => setIsMenuOpen(!isMenuOpen)}
                className="md:hidden p-2 rounded-full bg-white/10 hover:bg-white/20 transition-colors"
              >
                {isMenuOpen ? (
                  <X className="w-5 h-5 text-white" />
                ) : (
                  <Menu className="w-5 h-5 text-white" />
                )}
              </button>
            </div>
          </div>

          {/* Мобильное меню */}
          <motion.div
            initial={{ opacity: 0, height: 0 }}
            animate={{ 
              opacity: isMenuOpen ? 1 : 0, 
              height: isMenuOpen ? 'auto' : 0 
            }}
            transition={{ duration: 0.3 }}
            className="md:hidden overflow-hidden"
          >
            <div className="py-4 space-y-4">
              <MobileNavLink href="/restaurants">Рестораны</MobileNavLink>
              <MobileNavLink href="/menu">Меню</MobileNavLink>
              <MobileNavLink href="/news">Новости</MobileNavLink>
              <MobileNavLink href="/about">О нас</MobileNavLink>
              <MobileNavLink href="/profile">Профиль</MobileNavLink>
            </div>
          </motion.div>
        </div>
      </header>

      {/* Модальное окно корзины */}
      <CartView isOpen={isCartOpen} onClose={() => setIsCartOpen(false)} />
    </>
  );
}

function NavLink({ href, children }: { href: string; children: React.ReactNode }) {
  return (
    <motion.a
      href={href}
      whileHover={{ scale: 1.05 }}
      className="text-white/80 hover:text-white transition-colors font-medium"
    >
      {children}
    </motion.a>
  );
}

function MobileNavLink({ href, children }: { href: string; children: React.ReactNode }) {
  return (
    <a
      href={href}
      className="block text-white/80 hover:text-white transition-colors font-medium py-2"
    >
      {children}
    </a>
  );
} 