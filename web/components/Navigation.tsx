'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  Home, 
  Utensils, 
  Building2, 
  Newspaper, 
  User, 
  ShoppingCart,
  Menu,
  X,
  Search,
  Bell,
  Heart,
  Phone
} from 'lucide-react';
import { useCart } from '../lib/contexts/CartContext';
import { useAuth } from '../contexts/AuthContext';

const navigation = [
  { name: 'Главная', href: '/', icon: Home },
  { name: 'Рестораны', href: '/restaurants', icon: Building2 },
  { name: 'Меню', href: '/menu', icon: Utensils },
  { name: 'Новости', href: '/news', icon: Newspaper },
];

export default function Navigation() {
  const pathname = usePathname();
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const [isScrolled, setIsScrolled] = useState(false);
  const [isSearchOpen, setIsSearchOpen] = useState(false);
  const { items } = useCart();
  const { user, logout, isAuthenticated } = useAuth();
  
  const totalItems = items.reduce((sum, item) => sum + item.quantity, 0);

  // Отслеживание скролла
  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 20);
    };

    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  // Закрытие мобильного меню при клике на ссылку
  const handleNavClick = () => {
    setIsMobileMenuOpen(false);
  };

  return (
    <>
      {/* Desktop Navigation */}
      <motion.nav 
        initial={{ y: -100 }}
        animate={{ y: 0 }}
        className={`hidden lg:flex fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${
          isScrolled 
            ? 'bg-black/95 backdrop-blur-xl border-b border-white/10 shadow-2xl' 
            : 'bg-black/80 backdrop-blur-md border-b border-white/5'
        }`}
      >
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            {/* Logo */}
            <Link href="/" className="flex items-center space-x-3 group">
              <motion.div 
                whileHover={{ scale: 1.1, rotate: 5 }}
                className="w-10 h-10 bg-gradient-to-br from-orange-500 to-red-500 rounded-xl flex items-center justify-center shadow-lg"
              >
                <span className="text-white font-black text-xl">Б</span>
              </motion.div>
              <div className="flex flex-col">
                <span className="text-white font-black text-2xl leading-none">БЫК</span>
                <span className="text-orange-400 text-xs font-medium">Доставка еды</span>
              </div>
            </Link>

            {/* Navigation Links */}
            <div className="flex items-center space-x-2">
              {navigation.map((item) => {
                const Icon = item.icon;
                const isActive = pathname === item.href;
                return (
                  <Link
                    key={item.name}
                    href={item.href}
                    className={`group relative flex items-center space-x-2 px-4 py-2 rounded-xl transition-all duration-300 ${
                      isActive
                        ? 'bg-gradient-to-r from-orange-500 to-red-500 text-white shadow-lg'
                        : 'text-white/70 hover:text-white hover:bg-white/10'
                    }`}
                  >
                    <Icon className="w-4 h-4 group-hover:scale-110 transition-transform" />
                    <span className="font-medium">{item.name}</span>
                    {isActive && (
                      <motion.div
                        layoutId="activeTab"
                        className="absolute inset-0 bg-gradient-to-r from-orange-500 to-red-500 rounded-xl -z-10"
                        initial={false}
                        transition={{ type: "spring", stiffness: 500, damping: 30 }}
                      />
                    )}
                  </Link>
                );
              })}
            </div>

            {/* Right Side */}
            <div className="flex items-center space-x-3">
              {/* Search */}
              <motion.button
                whileHover={{ scale: 1.1 }}
                whileTap={{ scale: 0.9 }}
                onClick={() => setIsSearchOpen(!isSearchOpen)}
                className="p-2 rounded-xl text-white/70 hover:text-white hover:bg-white/10 transition-all duration-300"
              >
                <Search className="w-5 h-5" />
              </motion.button>

              {/* Notifications */}
              <motion.button
                whileHover={{ scale: 1.1 }}
                whileTap={{ scale: 0.9 }}
                className="relative p-2 rounded-xl text-white/70 hover:text-white hover:bg-white/10 transition-all duration-300"
              >
                <Bell className="w-5 h-5" />
                <span className="absolute -top-1 -right-1 w-3 h-3 bg-red-500 rounded-full"></span>
              </motion.button>

              {/* Favorites */}
              <motion.button
                whileHover={{ scale: 1.1 }}
                whileTap={{ scale: 0.9 }}
                className="p-2 rounded-xl text-white/70 hover:text-white hover:bg-white/10 transition-all duration-300"
              >
                <Heart className="w-5 h-5" />
              </motion.button>

              {/* Cart */}
              <Link href="/cart">
                <motion.button
                  whileHover={{ scale: 1.1 }}
                  whileTap={{ scale: 0.9 }}
                  className="relative p-2 rounded-xl text-white/70 hover:text-white hover:bg-white/10 transition-all duration-300"
                >
                  <ShoppingCart className="w-5 h-5" />
                  {totalItems > 0 && (
                    <motion.span 
                      initial={{ scale: 0 }}
                      animate={{ scale: 1 }}
                      className="absolute -top-1 -right-1 w-5 h-5 bg-red-500 rounded-full text-xs text-white flex items-center justify-center font-bold"
                    >
                      {totalItems > 9 ? '9+' : totalItems}
                    </motion.span>
                  )}
                </motion.button>
              </Link>
              
              {/* Auth Section */}
              {isAuthenticated ? (
                <>
                  <Link href="/profile">
                    <motion.button
                      whileHover={{ scale: 1.05 }}
                      whileTap={{ scale: 0.95 }}
                      className={`flex items-center space-x-2 px-4 py-2 rounded-xl transition-all duration-300 ${
                        pathname === '/profile'
                          ? 'bg-gradient-to-r from-orange-500 to-red-500 text-white shadow-lg'
                          : 'text-white/70 hover:text-white hover:bg-white/10'
                      }`}
                    >
                      <User className="w-4 h-4" />
                      <span className="font-medium">{user?.name}</span>
                    </motion.button>
                  </Link>
                  <motion.button
                    whileHover={{ scale: 1.05 }}
                    whileTap={{ scale: 0.95 }}
                    onClick={logout}
                    className="px-4 py-2 rounded-xl text-white/70 hover:text-white hover:bg-white/10 transition-all duration-300"
                  >
                    <span className="font-medium">Выйти</span>
                  </motion.button>
                </>
              ) : (
                <div className="flex flex-col space-y-2">
                  <Link href="/register">
                    <motion.button
                      whileHover={{ scale: 1.05 }}
                      whileTap={{ scale: 0.95 }}
                      className="px-4 py-2 rounded-xl bg-gradient-to-r from-orange-500 to-red-500 text-white shadow-lg hover:from-orange-600 hover:to-red-600 transition-all duration-300"
                    >
                      <span className="font-medium">Регистрация</span>
                    </motion.button>
                  </Link>
                  <Link href="/login-phone">
                    <motion.button
                      whileHover={{ scale: 1.05 }}
                      whileTap={{ scale: 0.95 }}
                      className="flex items-center space-x-2 px-4 py-2 rounded-xl text-white/70 hover:text-white hover:bg-white/10 transition-all duration-300"
                    >
                      <Phone className="w-4 h-4" />
                      <span className="font-medium">Вход по телефону</span>
                    </motion.button>
                  </Link>
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Search Bar */}
        <AnimatePresence>
          {isSearchOpen && (
            <motion.div
              initial={{ opacity: 0, height: 0 }}
              animate={{ opacity: 1, height: 'auto' }}
              exit={{ opacity: 0, height: 0 }}
              className="border-t border-white/10 bg-black/95 backdrop-blur-xl"
            >
              <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
                <div className="relative">
                  <Search className="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-white/50" />
                  <input
                    type="text"
                    placeholder="Поиск ресторанов, блюд..."
                    className="w-full pl-12 pr-4 py-3 bg-white/10 border border-white/20 rounded-xl text-white placeholder-white/50 focus:outline-none focus:ring-2 focus:ring-orange-500 focus:border-transparent"
                    autoFocus
                  />
                </div>
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </motion.nav>

      {/* Mobile Navigation */}
      <motion.nav 
        initial={{ y: -100 }}
        animate={{ y: 0 }}
        className={`lg:hidden fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${
          isScrolled 
            ? 'bg-black/95 backdrop-blur-xl border-b border-white/10 shadow-2xl' 
            : 'bg-black/80 backdrop-blur-md border-b border-white/5'
        }`}
      >
        <div className="px-4 sm:px-6">
          <div className="flex items-center justify-between h-16">
            {/* Logo */}
            <Link href="/" className="flex items-center space-x-2 group">
              <motion.div 
                whileHover={{ scale: 1.1, rotate: 5 }}
                className="w-8 h-8 sm:w-10 sm:h-10 bg-gradient-to-br from-orange-500 to-red-500 rounded-xl flex items-center justify-center shadow-lg"
              >
                <span className="text-white font-black text-lg sm:text-xl">Б</span>
              </motion.div>
              <div className="flex flex-col">
                <span className="text-white font-black text-xl sm:text-2xl leading-none">БЫК</span>
                <span className="text-orange-400 text-xs font-medium hidden sm:block">Доставка еды</span>
              </div>
            </Link>

            {/* Right Side - Cart and Menu */}
            <div className="flex items-center space-x-2 sm:space-x-3">
              {/* Cart */}
              <Link href="/cart">
                <motion.button
                  whileHover={{ scale: 1.1 }}
                  whileTap={{ scale: 0.9 }}
                  className="relative p-2 rounded-xl text-white/70 hover:text-white hover:bg-white/10 transition-all duration-300"
                >
                  <ShoppingCart className="w-5 h-5 sm:w-6 sm:h-6" />
                  {totalItems > 0 && (
                    <motion.span 
                      initial={{ scale: 0 }}
                      animate={{ scale: 1 }}
                      className="absolute -top-1 -right-1 w-5 h-5 bg-red-500 rounded-full text-xs text-white flex items-center justify-center font-bold"
                    >
                      {totalItems > 9 ? '9+' : totalItems}
                    </motion.span>
                  )}
                </motion.button>
              </Link>

              {/* Mobile Menu Button */}
              <motion.button
                whileHover={{ scale: 1.1 }}
                whileTap={{ scale: 0.9 }}
                onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
                className="p-2 rounded-xl text-white/70 hover:text-white hover:bg-white/10 transition-all duration-300"
              >
                {isMobileMenuOpen ? (
                  <X className="w-5 h-5 sm:w-6 sm:h-6" />
                ) : (
                  <Menu className="w-5 h-5 sm:w-6 sm:h-6" />
                )}
              </motion.button>
            </div>
          </div>
        </div>

        {/* Mobile Menu */}
        <AnimatePresence>
          {isMobileMenuOpen && (
            <motion.div
              initial={{ opacity: 0, height: 0 }}
              animate={{ opacity: 1, height: 'auto' }}
              exit={{ opacity: 0, height: 0 }}
              className="border-t border-white/10 bg-black/95 backdrop-blur-xl overflow-hidden"
            >
              <div className="px-4 sm:px-6 py-4">
                {/* Search */}
                <div className="relative mb-6">
                  <Search className="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-white/50" />
                  <input
                    type="text"
                    placeholder="Поиск ресторанов, блюд..."
                    className="w-full pl-12 pr-4 py-3 bg-white/10 border border-white/20 rounded-xl text-white placeholder-white/50 focus:outline-none focus:ring-2 focus:ring-orange-500 focus:border-transparent"
                    autoFocus
                  />
                </div>

                {/* Navigation Links */}
                <div className="space-y-2 mb-6">
                  {navigation.map((item) => {
                    const Icon = item.icon;
                    const isActive = pathname === item.href;
                    return (
                      <Link
                        key={item.name}
                        href={item.href}
                        onClick={handleNavClick}
                        className={`flex items-center space-x-3 px-4 py-3 rounded-xl transition-all duration-300 ${
                          isActive
                            ? 'bg-gradient-to-r from-orange-500 to-red-500 text-white shadow-lg'
                            : 'text-white/70 hover:text-white hover:bg-white/10'
                        }`}
                      >
                        <Icon className="w-5 h-5" />
                        <span className="font-medium text-base">{item.name}</span>
                      </Link>
                    );
                  })}
                </div>

                {/* Auth Section */}
                <div className="space-y-2 mb-6">
                  {isAuthenticated ? (
                    <>
                      <Link href="/profile" onClick={handleNavClick}>
                        <div className={`flex items-center space-x-3 px-4 py-3 rounded-xl transition-all duration-300 ${
                          pathname === '/profile'
                            ? 'bg-gradient-to-r from-orange-500 to-red-500 text-white shadow-lg'
                            : 'text-white/70 hover:text-white hover:bg-white/10'
                        }`}>
                          <User className="w-5 h-5" />
                          <span className="font-medium text-base">{user?.name}</span>
                        </div>
                      </Link>
                      <button 
                        onClick={logout}
                        className="flex items-center space-x-3 px-4 py-3 rounded-xl text-white/70 hover:text-white hover:bg-white/10 transition-all duration-300 w-full"
                      >
                        <span className="font-medium text-base">Выйти</span>
                      </button>
                    </>
                  ) : (
                    <>
                      <Link href="/register" onClick={handleNavClick}>
                        <div className="flex items-center space-x-3 px-4 py-3 rounded-xl bg-gradient-to-r from-orange-500 to-red-500 text-white shadow-lg hover:from-orange-600 hover:to-red-600 transition-all duration-300">
                          <User className="w-5 h-5" />
                          <span className="font-medium text-base">Регистрация</span>
                        </div>
                      </Link>
                      <Link href="/login-phone" onClick={handleNavClick}>
                        <div className="flex items-center space-x-3 px-4 py-3 rounded-xl text-white/70 hover:text-white hover:bg-white/10 transition-all duration-300">
                          <Phone className="w-5 h-5" />
                          <span className="font-medium text-base">Вход по телефону</span>
                        </div>
                      </Link>
                    </>
                  )}
                </div>

                {/* Additional Actions */}
                <div className="space-y-2 mb-6">
                  
                  <button className="flex items-center space-x-3 px-4 py-3 rounded-xl text-white/70 hover:text-white hover:bg-white/10 transition-all duration-300 w-full">
                    <Bell className="w-5 h-5" />
                    <span className="font-medium text-base">Уведомления</span>
                    <span className="ml-auto w-3 h-3 bg-red-500 rounded-full"></span>
                  </button>
                  
                  <button className="flex items-center space-x-3 px-4 py-3 rounded-xl text-white/70 hover:text-white hover:bg-white/10 transition-all duration-300 w-full">
                    <Heart className="w-5 h-5" />
                    <span className="font-medium text-base">Избранное</span>
                  </button>
                </div>

                {/* Contact Info */}
                <div className="border-t border-white/10 pt-4">
                  <div className="text-white/50 text-sm">
                    <p className="mb-2">Телефон: +7 (999) 123-45-67</p>
                    <p>Email: info@byk.ru</p>
                  </div>
                </div>
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </motion.nav>

      {/* Overlay for mobile menu */}
      <AnimatePresence>
        {isMobileMenuOpen && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={() => setIsMobileMenuOpen(false)}
            className="lg:hidden fixed inset-0 bg-black/50 backdrop-blur-sm z-40"
          />
        )}
      </AnimatePresence>
    </>
  );
} 