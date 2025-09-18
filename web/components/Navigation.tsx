'use client';

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import Link from 'next/link';
import { useRouter, usePathname } from 'next/navigation';
import { 
  Menu, 
  X, 
  ShoppingCart, 
  User, 
  Search, 
  Phone, 
  Mail,
  Crown,
  Sparkles
} from 'lucide-react';

export default function Navigation() {
  const [isOpen, setIsOpen] = useState(false);
  const [isScrolled, setIsScrolled] = useState(false);
  const router = useRouter();
  const pathname = usePathname();

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 20);
    };

    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  const handleNavClick = () => {
    setIsOpen(false);
  };

  const navItems = [
    { href: '/', label: 'Главная' },
    { href: '/restaurants', label: 'Рестораны' },
    { href: '/menu', label: 'Меню' },
    { href: '/news', label: 'Новости' },
  ];

  return (
    <>
      {/* Премиальная навигация */}
      <motion.nav
        initial={{ y: -100 }}
        animate={{ y: 0 }}
        className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${
          isScrolled 
            ? 'glass-effect border-b border-[#d4af37]/20' 
            : 'bg-transparent'
        }`}
      >
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16 sm:h-20">
            {/* Логотип */}
            <Link href="/" className="flex items-center space-x-3 group">
              <motion.div
                whileHover={{ scale: 1.1, rotate: 5 }}
                className="relative"
              >
                <div className="w-10 h-10 sm:w-12 sm:h-12 bg-gradient-to-r from-[#d4af37] to-[#f4d03f] rounded-full flex items-center justify-center shadow-lg">
                  <Crown className="w-6 h-6 sm:w-7 sm:h-7 text-[#1a1a1a]" />
                </div>
                <motion.div
                  animate={{ rotate: 360 }}
                  transition={{ duration: 3, repeat: Infinity, ease: "linear" }}
                  className="absolute -top-1 -right-1 w-4 h-4 sm:w-5 sm:h-5"
                >
                  <Sparkles className="w-full h-full text-[#ff6b35]" />
                </motion.div>
              </motion.div>
              <div className="hidden sm:block">
                <h1 className="text-xl sm:text-2xl font-bold text-white group-hover:text-[#d4af37] transition-colors">
                  БЫК
                </h1>
                <p className="text-[#d4af37] text-xs font-medium">ХОЛДИНГ</p>
              </div>
            </Link>

            {/* Десктопная навигация */}
            <div className="hidden lg:flex items-center space-x-8">
              {navItems.map((item) => (
                <Link
                  key={item.href}
                  href={item.href}
                  className={`relative text-white/80 hover:text-[#d4af37] font-medium transition-colors duration-300 ${
                    pathname === item.href ? 'text-[#d4af37]' : ''
                  }`}
                >
                  {item.label}
                  {pathname === item.href && (
                    <motion.div
                      layoutId="activeTab"
                      className="absolute -bottom-1 left-0 right-0 h-0.5 bg-gradient-to-r from-[#d4af37] to-[#f4d03f]"
                    />
                  )}
                </Link>
              ))}
            </div>

            {/* Правая часть */}
            <div className="flex items-center space-x-4">
              {/* Поиск */}
              <motion.button
                whileHover={{ scale: 1.1 }}
                whileTap={{ scale: 0.9 }}
                className="hidden sm:flex items-center justify-center w-10 h-10 bg-[#d4af37]/10 border border-[#d4af37]/30 rounded-full text-[#d4af37] hover:bg-[#d4af37]/20 transition-all duration-300"
              >
                <Search className="w-5 h-5" />
              </motion.button>

              {/* Корзина */}
              <Link href="/cart">
                <motion.button
                  whileHover={{ scale: 1.1 }}
                  whileTap={{ scale: 0.9 }}
                  className="relative flex items-center justify-center w-10 h-10 bg-gradient-to-r from-[#d4af37] to-[#f4d03f] rounded-full text-[#1a1a1a] shadow-lg hover:shadow-[#d4af37]/25 transition-all duration-300"
                >
                  <ShoppingCart className="w-5 h-5" />
                </motion.button>
              </Link>

              {/* Профиль */}
              <Link href="/profile">
                <motion.button
                  whileHover={{ scale: 1.1 }}
                  whileTap={{ scale: 0.9 }}
                  className="hidden sm:flex items-center justify-center w-10 h-10 bg-[#d4af37]/10 border border-[#d4af37]/30 rounded-full text-[#d4af37] hover:bg-[#d4af37]/20 transition-all duration-300"
                >
                  <User className="w-5 h-5" />
                </motion.button>
              </Link>

              {/* Мобильное меню */}
              <motion.button
                whileHover={{ scale: 1.1 }}
                whileTap={{ scale: 0.9 }}
                onClick={() => setIsOpen(!isOpen)}
                className="lg:hidden flex items-center justify-center w-10 h-10 bg-[#d4af37]/10 border border-[#d4af37]/30 rounded-full text-[#d4af37] hover:bg-[#d4af37]/20 transition-all duration-300"
              >
                {isOpen ? <X className="w-5 h-5" /> : <Menu className="w-5 h-5" />}
              </motion.button>
            </div>
          </div>
        </div>
      </motion.nav>

      {/* Мобильное меню */}
      <AnimatePresence>
        {isOpen && (
          <motion.div
            initial={{ opacity: 0, x: '100%' }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: '100%' }}
            className="fixed top-0 right-0 h-full w-80 bg-[#1a1a1a]/95 backdrop-blur-xl border-l border-[#d4af37]/20 z-50 lg:hidden"
          >
            <div className="p-6 h-full flex flex-col">
              {/* Заголовок */}
              <div className="flex items-center justify-between mb-8">
                <div className="flex items-center space-x-3">
                  <div className="w-10 h-10 bg-gradient-to-r from-[#d4af37] to-[#f4d03f] rounded-full flex items-center justify-center">
                    <Crown className="w-6 h-6 text-[#1a1a1a]" />
                  </div>
                  <div>
                    <h2 className="text-xl font-bold text-white">БЫК</h2>
                    <p className="text-[#d4af37] text-sm font-medium">ХОЛДИНГ</p>
                  </div>
                </div>
                <motion.button
                  whileHover={{ scale: 1.1 }}
                  whileTap={{ scale: 0.9 }}
                  onClick={() => setIsOpen(false)}
                  className="w-8 h-8 bg-[#d4af37]/10 border border-[#d4af37]/30 rounded-full flex items-center justify-center text-[#d4af37]"
                >
                  <X className="w-4 h-4" />
                </motion.button>
              </div>

              {/* Навигация */}
              <nav className="flex-1">
                <div className="space-y-2">
                  {navItems.map((item) => (
                    <Link
                      key={item.href}
                      href={item.href}
                      onClick={handleNavClick}
                      className={`block px-4 py-3 rounded-2xl font-medium transition-all duration-300 ${
                        pathname === item.href
                          ? 'bg-gradient-to-r from-[#d4af37] to-[#f4d03f] text-[#1a1a1a]'
                          : 'text-white/80 hover:text-[#d4af37] hover:bg-[#d4af37]/10'
                      }`}
                    >
                      {item.label}
                    </Link>
                  ))}
                </div>

                {/* Дополнительные ссылки */}
                <div className="mt-8 pt-8 border-t border-[#d4af37]/20">
                  <div className="space-y-2">
                    <Link
                      href="/cart"
                      onClick={handleNavClick}
                      className="block px-4 py-3 text-white/80 hover:text-[#d4af37] hover:bg-[#d4af37]/10 rounded-2xl transition-all duration-300"
                    >
                      Корзина
                    </Link>
                    <Link
                      href="/profile"
                      onClick={handleNavClick}
                      className="block px-4 py-3 text-white/80 hover:text-[#d4af37] hover:bg-[#d4af37]/10 rounded-2xl transition-all duration-300"
                    >
                      Профиль
                    </Link>
                  </div>
                </div>
              </nav>

              {/* Контакты */}
              <div className="pt-8 border-t border-[#d4af37]/20">
                <div className="space-y-3">
                  <div className="flex items-center space-x-3 text-white/60">
                    <Phone className="w-4 h-4 text-[#d4af37]" />
                    <span className="text-sm">+7 (495) 123-45-67</span>
                  </div>
                  <div className="flex items-center space-x-3 text-white/60">
                    <Mail className="w-4 h-4 text-[#d4af37]" />
                    <span className="text-sm">info@byk-holding.ru</span>
                  </div>
                </div>
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Оверлей */}
      <AnimatePresence>
        {isOpen && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={() => setIsOpen(false)}
            className="fixed inset-0 bg-black/50 z-40 lg:hidden"
          />
        )}
      </AnimatePresence>
    </>
  );
} 