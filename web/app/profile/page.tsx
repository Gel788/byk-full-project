'use client';

import { useState, useEffect } from 'react';
import { motion, useScroll, useTransform } from 'framer-motion';
import { 
  User, 
  MapPin, 
  Phone, 
  Mail, 
  Clock, 
  Star, 
  Heart, 
  Settings, 
  LogOut, 
  Edit3,
  Calendar,
  Package,
  CreditCard,
  Shield,
  Bell,
  HelpCircle,
  Crown,
  TrendingUp,
  Award,
  Zap,
  ChevronRight,
  Plus,
  Trash2,
  Eye
} from 'lucide-react';
import { useRouter } from 'next/navigation';

interface UserProfile {
  id: string;
  name: string;
  email: string;
  phone: string;
  address: string;
  avatar: string;
  joinDate: string;
  totalOrders: number;
  totalSpent: number;
  favoriteRestaurants: string[];
  loyaltyPoints: number;
  tier: 'bronze' | 'silver' | 'gold' | 'platinum';
}

const mockUser: UserProfile = {
  id: '1',
  name: 'Александр Петров',
  email: 'alex.petrov@email.com',
  phone: '+7 (999) 123-45-67',
  address: 'ул. Тверская, 15, кв. 42',
  avatar: '/images/avatar.jpg',
  joinDate: '2024-01-15',
  totalOrders: 47,
  totalSpent: 125000,
  favoriteRestaurants: ['THE БЫК - Тверская', 'MOSCA - Арбат'],
  loyaltyPoints: 2840,
  tier: 'gold'
};

const tierInfo = {
  bronze: { name: 'Бронза', color: '#CD7F32', gradient: 'from-amber-600 to-orange-500', icon: '🥉' },
  silver: { name: 'Серебро', color: '#C0C0C0', gradient: 'from-gray-400 to-gray-600', icon: '🥈' },
  gold: { name: 'Золото', color: '#FFD700', gradient: 'from-yellow-500 to-orange-500', icon: '🥇' },
  platinum: { name: 'Платина', color: '#E5E4E2', gradient: 'from-purple-500 to-pink-500', icon: '👑' }
};

export default function ProfilePage() {
  const router = useRouter();
  const [user, setUser] = useState<UserProfile>(mockUser);
  const [activeTab, setActiveTab] = useState('profile');
  const [isEditing, setIsEditing] = useState(false);
  const [mousePosition, setMousePosition] = useState({ x: 0, y: 0 });
  const { scrollYProgress } = useScroll();
  const y = useTransform(scrollYProgress, [0, 1], [0, -50]);

  // Отслеживание позиции мыши
  useEffect(() => {
    const handleMouseMove = (e: MouseEvent) => {
      setMousePosition({ x: e.clientX, y: e.clientY });
    };

    window.addEventListener('mousemove', handleMouseMove);
    return () => window.removeEventListener('mousemove', handleMouseMove);
  }, []);

  const handleLogout = () => {
    // Здесь будет логика выхода
    router.push('/');
  };

  const tabs = [
    { id: 'profile', name: 'Профиль', icon: User, color: 'from-orange-500 to-red-500' },
    { id: 'orders', name: 'Заказы', icon: Package, color: 'from-blue-500 to-purple-500' },
    { id: 'reservations', name: 'Бронирования', icon: Calendar, color: 'from-green-500 to-emerald-500' },
    { id: 'favorites', name: 'Избранное', icon: Heart, color: 'from-pink-500 to-red-500' },
    { id: 'settings', name: 'Настройки', icon: Settings, color: 'from-gray-500 to-gray-700' }
  ];

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('ru-RU').format(price);
  };

  const formatDate = (date: string) => {
    return new Intl.DateTimeFormat('ru-RU', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    }).format(new Date(date));
  };

  return (
    <main className="min-h-screen bg-black relative overflow-hidden">
      {/* Интерактивный курсор эффект */}
      <motion.div
        className="fixed w-6 h-6 bg-orange-500/30 rounded-full pointer-events-none z-50 mix-blend-difference"
        animate={{
          x: mousePosition.x - 12,
          y: mousePosition.y - 12,
        }}
        transition={{ type: "spring", stiffness: 500, damping: 28 }}
      />
      
      {/* Плавающие элементы фона */}
      <div className="fixed inset-0 pointer-events-none">
        {[...Array(15)].map((_, i) => (
          <motion.div
            key={i}
            animate={{
              y: [0, -30, 0],
              x: [0, Math.random() * 20 - 10, 0],
              opacity: [0, 0.3, 0],
            }}
            transition={{
              duration: 4 + Math.random() * 3,
              repeat: Infinity,
              delay: Math.random() * 2,
            }}
            className="absolute w-2 h-2 bg-orange-400/20 rounded-full"
            style={{
              left: `${Math.random() * 100}%`,
              top: `${Math.random() * 100}%`,
            }}
          />
        ))}
      </div>

      {/* Hero секция */}
      <section className="relative py-24 px-4 sm:px-6 lg:px-8 overflow-hidden">
        {/* Анимированный фон */}
        <div className="absolute inset-0">
          <motion.div
            animate={{
              background: [
                "radial-gradient(circle at 20% 50%, rgba(255, 165, 0, 0.05) 0%, transparent 50%)",
                "radial-gradient(circle at 80% 50%, rgba(255, 165, 0, 0.05) 0%, transparent 50%)",
                "radial-gradient(circle at 20% 50%, rgba(255, 165, 0, 0.05) 0%, transparent 50%)"
              ]
            }}
            transition={{ duration: 8, repeat: Infinity }}
            className="absolute inset-0"
          />
        </div>

        <div className="relative z-10 max-w-7xl mx-auto">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 1 }}
            className="text-center mb-12"
          >
            <span className="inline-block px-6 py-3 bg-orange-600/20 text-orange-400 rounded-full text-sm font-semibold border border-orange-600/30 backdrop-blur-sm mb-6">
              👤 Личный кабинет
            </span>
            <h1 className="text-5xl sm:text-6xl font-bold text-white mb-6">
              Добро пожаловать, <span className="bg-gradient-to-r from-white via-orange-400 to-white bg-clip-text text-transparent">{user.name}</span>
            </h1>
            <p className="text-xl text-white/70 max-w-3xl mx-auto leading-relaxed">
              Управляйте своим профилем, заказами и настройками в удобном интерфейсе
            </p>
          </motion.div>

          {/* Профиль карточка */}
          <motion.div
            initial={{ opacity: 0, y: 50 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 1, delay: 0.2 }}
            className="relative overflow-hidden rounded-3xl bg-gradient-to-br from-gray-800/50 to-gray-900/50 border border-gray-700/50 backdrop-blur-sm mb-12"
          >
            {/* Фон профиля */}
            <div className="absolute inset-0">
              <motion.div
                animate={{
                  background: [
                    `linear-gradient(135deg, ${tierInfo[user.tier].color}10, ${tierInfo[user.tier].color}20)`,
                    `linear-gradient(135deg, ${tierInfo[user.tier].color}20, ${tierInfo[user.tier].color}10)`,
                    `linear-gradient(135deg, ${tierInfo[user.tier].color}10, ${tierInfo[user.tier].color}20)`
                  ]
                }}
                transition={{ duration: 4, repeat: Infinity }}
                className="absolute inset-0"
              />
            </div>

            <div className="relative p-8">
              <div className="flex flex-col lg:flex-row items-center lg:items-start space-y-6 lg:space-y-0 lg:space-x-8">
                {/* Аватар */}
                <motion.div 
                  whileHover={{ scale: 1.05, rotate: 5 }}
                  className="relative"
                >
                  <div className={`w-32 h-32 rounded-full bg-gradient-to-br ${tierInfo[user.tier].gradient} flex items-center justify-center text-white text-4xl font-bold shadow-2xl`}>
                    {user.name.split(' ').map(n => n[0]).join('')}
                  </div>
                  <div className="absolute -bottom-2 -right-2 w-12 h-12 rounded-full bg-gradient-to-br from-yellow-500 to-orange-500 flex items-center justify-center text-2xl">
                    {tierInfo[user.tier].icon}
                  </div>
                </motion.div>

                {/* Информация пользователя */}
                <div className="flex-1 text-center lg:text-left">
                  <h2 className="text-3xl font-bold text-white mb-4">{user.name}</h2>
                  <div className="flex flex-wrap justify-center lg:justify-start gap-4 mb-6">
                    <span 
                      className="px-4 py-2 rounded-full text-sm font-semibold backdrop-blur-sm"
                      style={{
                        backgroundColor: `${tierInfo[user.tier].color}20`,
                        color: tierInfo[user.tier].color,
                        border: `1px solid ${tierInfo[user.tier].color}40`
                      }}
                    >
                      {tierInfo[user.tier].name}
                    </span>
                    <span className="px-4 py-2 rounded-full text-sm font-semibold bg-orange-500/20 text-orange-400 border border-orange-500/30 backdrop-blur-sm">
                      {user.loyaltyPoints} баллов
                    </span>
                    <span className="px-4 py-2 rounded-full text-sm font-semibold bg-blue-500/20 text-blue-400 border border-blue-500/30 backdrop-blur-sm">
                      {formatDate(user.joinDate)}
                    </span>
                  </div>
                  
                  {/* Контактная информация */}
                  <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <div className="flex items-center justify-center lg:justify-start space-x-3 text-white/70">
                      <Mail className="w-5 h-5" />
                      <span className="text-sm">{user.email}</span>
                    </div>
                    <div className="flex items-center justify-center lg:justify-start space-x-3 text-white/70">
                      <Phone className="w-5 h-5" />
                      <span className="text-sm">{user.phone}</span>
                    </div>
                    <div className="flex items-center justify-center lg:justify-start space-x-3 text-white/70">
                      <MapPin className="w-5 h-5" />
                      <span className="text-sm">{user.address}</span>
                    </div>
                  </div>
                </div>

                {/* Кнопки действий */}
                <div className="flex flex-col space-y-3">
                  <motion.button
                    whileHover={{ scale: 1.05, y: -2 }}
                    whileTap={{ scale: 0.95 }}
                    onClick={() => setIsEditing(!isEditing)}
                    className="flex items-center space-x-2 px-6 py-3 rounded-xl bg-white/10 text-white hover:bg-white/20 transition-all duration-300 backdrop-blur-sm border border-white/20"
                  >
                    <Edit3 className="w-5 h-5" />
                    <span>Редактировать</span>
                  </motion.button>
                  
                  <motion.button
                    whileHover={{ scale: 1.05, y: -2 }}
                    whileTap={{ scale: 0.95 }}
                    onClick={handleLogout}
                    className="flex items-center space-x-2 px-6 py-3 rounded-xl bg-red-500/20 text-red-400 hover:bg-red-500/30 transition-all duration-300 backdrop-blur-sm border border-red-500/30"
                  >
                    <LogOut className="w-5 h-5" />
                    <span>Выйти</span>
                  </motion.button>
                </div>
              </div>
            </div>
          </motion.div>

          {/* Статистика */}
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 1, delay: 0.4 }}
            className="grid grid-cols-1 md:grid-cols-3 gap-8 mb-12"
          >
            <motion.div 
              whileHover={{ scale: 1.05, y: -5 }}
              className="group text-center p-8 bg-gradient-to-br from-gray-800/50 to-gray-900/50 rounded-3xl border border-gray-700/50 hover:border-orange-500/50 transition-all duration-500 backdrop-blur-sm"
            >
              <motion.div 
                whileHover={{ scale: 1.1, rotate: 5 }}
                className="w-20 h-20 bg-gradient-to-br from-orange-500 to-red-500 rounded-full flex items-center justify-center mx-auto mb-6 group-hover:scale-110 transition-transform shadow-2xl"
              >
                <Package className="w-10 h-10 text-white" />
              </motion.div>
              <div className="text-4xl font-bold text-white mb-2 group-hover:text-orange-400 transition-colors">
                {user.totalOrders}
              </div>
              <div className="text-white/60">Всего заказов</div>
            </motion.div>

            <motion.div 
              whileHover={{ scale: 1.05, y: -5 }}
              className="group text-center p-8 bg-gradient-to-br from-gray-800/50 to-gray-900/50 rounded-3xl border border-gray-700/50 hover:border-green-500/50 transition-all duration-500 backdrop-blur-sm"
            >
              <motion.div 
                whileHover={{ scale: 1.1, rotate: -5 }}
                className="w-20 h-20 bg-gradient-to-br from-green-500 to-emerald-500 rounded-full flex items-center justify-center mx-auto mb-6 group-hover:scale-110 transition-transform shadow-2xl"
              >
                <CreditCard className="w-10 h-10 text-white" />
              </motion.div>
              <div className="text-4xl font-bold text-white mb-2 group-hover:text-green-400 transition-colors">
                {formatPrice(user.totalSpent)} ₽
              </div>
              <div className="text-white/60">Потрачено всего</div>
            </motion.div>

            <motion.div 
              whileHover={{ scale: 1.05, y: -5 }}
              className="group text-center p-8 bg-gradient-to-br from-gray-800/50 to-gray-900/50 rounded-3xl border border-gray-700/50 hover:border-blue-500/50 transition-all duration-500 backdrop-blur-sm"
            >
              <motion.div 
                whileHover={{ scale: 1.1, rotate: 5 }}
                className="w-20 h-20 bg-gradient-to-br from-blue-500 to-purple-500 rounded-full flex items-center justify-center mx-auto mb-6 group-hover:scale-110 transition-transform shadow-2xl"
              >
                <TrendingUp className="w-10 h-10 text-white" />
              </motion.div>
              <div className="text-4xl font-bold text-white mb-2 group-hover:text-blue-400 transition-colors">
                {user.loyaltyPoints}
              </div>
              <div className="text-white/60">Баллов лояльности</div>
            </motion.div>
          </motion.div>
        </div>
      </section>

      {/* Навигация по вкладкам */}
      <section className="relative py-12 px-4 sm:px-6 lg:px-8 overflow-hidden">
        <div className="max-w-7xl mx-auto">
          {/* Вкладки */}
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 1, delay: 0.6 }}
            className="flex flex-wrap justify-center gap-4 mb-12"
          >
            {tabs.map((tab) => {
              const Icon = tab.icon;
              return (
                <motion.button
                  key={tab.id}
                  whileHover={{ scale: 1.05, y: -2 }}
                  whileTap={{ scale: 0.95 }}
                  onClick={() => setActiveTab(tab.id)}
                  className={`flex items-center space-x-3 px-6 py-4 rounded-xl font-semibold transition-all duration-300 ${
                    activeTab === tab.id
                      ? `bg-gradient-to-r ${tab.color} text-white shadow-lg`
                      : 'text-white/70 hover:text-white bg-white/10 hover:bg-white/20 border border-white/20'
                  }`}
                >
                  <Icon className="w-5 h-5" />
                  <span>{tab.name}</span>
                </motion.button>
              );
            })}
          </motion.div>

          {/* Контент вкладок */}
          <motion.div
            key={activeTab}
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
            className="min-h-96"
          >
            {activeTab === 'profile' && (
              <div className="space-y-8">
                {/* Любимые рестораны */}
                <motion.div
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  className="bg-gradient-to-br from-gray-800/50 to-gray-900/50 rounded-3xl p-8 border border-gray-700/50 backdrop-blur-sm"
                >
                  <h3 className="text-2xl font-bold text-white mb-6 flex items-center space-x-3">
                    <Heart className="w-6 h-6 text-red-400" />
                    <span>Любимые рестораны</span>
                  </h3>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    {user.favoriteRestaurants.map((restaurant, index) => (
                      <motion.div
                        key={index}
                        whileHover={{ scale: 1.02, y: -2 }}
                        className="flex items-center justify-between p-4 rounded-2xl bg-white/5 hover:bg-white/10 transition-all duration-300 border border-white/10"
                      >
                        <div className="flex items-center space-x-3">
                          <Heart className="w-5 h-5 text-red-500 fill-current" />
                          <span className="text-white font-medium">{restaurant}</span>
                        </div>
                        <motion.button
                          whileHover={{ scale: 1.1 }}
                          whileTap={{ scale: 0.9 }}
                          className="text-white/60 hover:text-white transition-colors"
                        >
                          <Eye className="w-4 h-4" />
                        </motion.button>
                      </motion.div>
                    ))}
                  </div>
                </motion.div>
              </div>
            )}

            {activeTab === 'orders' && (
              <div className="space-y-8">
                <motion.div
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  className="bg-gradient-to-br from-gray-800/50 to-gray-900/50 rounded-3xl p-8 border border-gray-700/50 backdrop-blur-sm"
                >
                  <h3 className="text-2xl font-bold text-white mb-6 flex items-center space-x-3">
                    <Package className="w-6 h-6 text-blue-400" />
                    <span>История заказов</span>
                  </h3>
                  <div className="space-y-4">
                    {[1, 2, 3].map((order) => (
                      <motion.div
                        key={order}
                        whileHover={{ scale: 1.02, y: -2 }}
                        className="flex items-center justify-between p-6 rounded-2xl bg-white/5 hover:bg-white/10 transition-all duration-300 border border-white/10"
                      >
                        <div className="flex items-center space-x-4">
                          <div className="w-12 h-12 rounded-full bg-gradient-to-br from-blue-500 to-purple-500 flex items-center justify-center">
                            <Package className="w-6 h-6 text-white" />
                          </div>
                          <div>
                            <h4 className="text-white font-semibold">Заказ #{1000 + order}</h4>
                            <p className="text-white/60 text-sm">THE БЫК - Тверская</p>
                          </div>
                        </div>
                        <div className="text-right">
                          <p className="text-white font-semibold">{formatPrice(2500 + order * 500)} ₽</p>
                          <p className="text-green-400 text-sm">Доставлен</p>
                        </div>
                      </motion.div>
                    ))}
                  </div>
                </motion.div>
              </div>
            )}

            {activeTab === 'reservations' && (
              <div className="space-y-8">
                <motion.div
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  className="bg-gradient-to-br from-gray-800/50 to-gray-900/50 rounded-3xl p-8 border border-gray-700/50 backdrop-blur-sm"
                >
                  <h3 className="text-2xl font-bold text-white mb-6 flex items-center space-x-3">
                    <Calendar className="w-6 h-6 text-green-400" />
                    <span>Мои бронирования</span>
                  </h3>
                  <div className="space-y-4">
                    {[1, 2].map((reservation) => (
                      <motion.div
                        key={reservation}
                        whileHover={{ scale: 1.02, y: -2 }}
                        className="flex items-center justify-between p-6 rounded-2xl bg-white/5 hover:bg-white/10 transition-all duration-300 border border-white/10"
                      >
                        <div className="flex items-center space-x-4">
                          <div className="w-12 h-12 rounded-full bg-gradient-to-br from-green-500 to-emerald-500 flex items-center justify-center">
                            <Calendar className="w-6 h-6 text-white" />
                          </div>
                          <div>
                            <h4 className="text-white font-semibold">Бронирование #{2000 + reservation}</h4>
                            <p className="text-white/60 text-sm">THE БЫК - Тверская • 2 персоны</p>
                          </div>
                        </div>
                        <div className="text-right">
                          <p className="text-white font-semibold">Сегодня, 19:00</p>
                          <p className="text-green-400 text-sm">Подтверждено</p>
                        </div>
                      </motion.div>
                    ))}
                  </div>
                </motion.div>
              </div>
            )}

            {activeTab === 'favorites' && (
              <div className="space-y-8">
                <motion.div
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  className="bg-gradient-to-br from-gray-800/50 to-gray-900/50 rounded-3xl p-8 border border-gray-700/50 backdrop-blur-sm"
                >
                  <h3 className="text-2xl font-bold text-white mb-6 flex items-center space-x-3">
                    <Heart className="w-6 h-6 text-pink-400" />
                    <span>Избранное</span>
                  </h3>
                  <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    {[1, 2, 3, 4, 5, 6].map((item) => (
                      <motion.div
                        key={item}
                        whileHover={{ scale: 1.05, y: -5 }}
                        className="relative overflow-hidden rounded-2xl bg-white/5 hover:bg-white/10 transition-all duration-300 border border-white/10"
                      >
                        <div className="h-32 bg-gradient-to-br from-pink-500/20 to-red-500/20"></div>
                        <div className="p-4">
                          <h4 className="text-white font-semibold mb-2">Блюдо {item}</h4>
                          <p className="text-white/60 text-sm mb-3">Вкусное описание блюда</p>
                          <div className="flex items-center justify-between">
                            <span className="text-white font-semibold">{formatPrice(500 + item * 100)} ₽</span>
                            <motion.button
                              whileHover={{ scale: 1.1 }}
                              whileTap={{ scale: 0.9 }}
                              className="text-red-400 hover:text-red-300 transition-colors"
                            >
                              <Trash2 className="w-4 h-4" />
                            </motion.button>
                          </div>
                        </div>
                      </motion.div>
                    ))}
                  </div>
                </motion.div>
              </div>
            )}

            {activeTab === 'settings' && (
              <div className="space-y-8">
                <motion.div
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  className="bg-gradient-to-br from-gray-800/50 to-gray-900/50 rounded-3xl p-8 border border-gray-700/50 backdrop-blur-sm"
                >
                  <h3 className="text-2xl font-bold text-white mb-6 flex items-center space-x-3">
                    <Settings className="w-6 h-6 text-gray-400" />
                    <span>Настройки</span>
                  </h3>
                  <div className="space-y-6">
                    {[
                      { icon: Bell, title: 'Уведомления', description: 'Настройки push-уведомлений' },
                      { icon: Shield, title: 'Безопасность', description: 'Пароль и двухфакторная аутентификация' },
                      { icon: HelpCircle, title: 'Помощь', description: 'FAQ и поддержка' }
                    ].map((setting, index) => {
                      const Icon = setting.icon;
                      return (
                        <motion.div
                          key={index}
                          whileHover={{ scale: 1.02, y: -2 }}
                          className="flex items-center justify-between p-6 rounded-2xl bg-white/5 hover:bg-white/10 transition-all duration-300 border border-white/10 cursor-pointer"
                        >
                          <div className="flex items-center space-x-4">
                            <div className="w-12 h-12 rounded-full bg-gradient-to-br from-gray-500 to-gray-700 flex items-center justify-center">
                              <Icon className="w-6 h-6 text-white" />
                            </div>
                            <div>
                              <h4 className="text-white font-semibold">{setting.title}</h4>
                              <p className="text-white/60 text-sm">{setting.description}</p>
                            </div>
                          </div>
                          <ChevronRight className="w-5 h-5 text-white/40" />
                        </motion.div>
                      );
                    })}
                  </div>
                </motion.div>
              </div>
            )}
          </motion.div>
        </div>
      </section>
    </main>
  );
} 