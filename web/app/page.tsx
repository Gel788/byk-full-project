'use client';

import { motion, useScroll, useTransform } from 'framer-motion';
import { useState, useEffect } from 'react';
import { ArrowRight, Star, Clock, Users, TrendingUp, Zap, Shield, Heart, ChefHat, MapPin, Phone } from 'lucide-react';
import Hero from '../components/Hero';
import RestaurantCard from '../components/RestaurantCard';
import DishCard from '../components/DishCard';
import { restaurants, dishes } from '../lib/data';

export default function HomePage() {
  const [stats, setStats] = useState({ orders: 0, customers: 0, restaurants: 0, rating: 0 });
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

  // Анимированные счетчики
  useEffect(() => {
    const animateCounters = () => {
      const targetStats = { orders: 15420, customers: 8230, restaurants: 3, rating: 4.8 };
      const duration = 2000;
      const steps = 60;
      const stepDuration = duration / steps;

      let currentStep = 0;
      const interval = setInterval(() => {
        currentStep++;
        const progress = currentStep / steps;
        const easeProgress = 1 - Math.pow(1 - progress, 3); // Ease out

        setStats({
          orders: Math.floor(targetStats.orders * easeProgress),
          customers: Math.floor(targetStats.customers * easeProgress),
          restaurants: targetStats.restaurants,
          rating: Number((targetStats.rating * easeProgress).toFixed(1))
        });

        if (currentStep >= steps) {
          clearInterval(interval);
        }
      }, stepDuration);

      return () => clearInterval(interval);
    };

    const timer = setTimeout(animateCounters, 1000);
    return () => clearTimeout(timer);
  }, []);

  // Получаем блюда для каждого ресторана
  const getDishesByRestaurant = (restaurantId: string) => {
    return dishes.filter(dish => dish.restaurantId === restaurantId);
  };

  return (
    <main className="min-h-screen bg-black relative overflow-hidden">
      {/* Интерактивный курсор эффект - только для десктопа */}
      <motion.div
        className="fixed w-6 h-6 bg-orange-500/30 rounded-full pointer-events-none z-50 mix-blend-difference hidden lg:block"
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
            className="absolute w-1 h-1 sm:w-2 sm:h-2 bg-orange-400/20 rounded-full"
            style={{
              left: `${Math.random() * 100}%`,
              top: `${Math.random() * 100}%`,
            }}
          />
        ))}
      </div>
      
      {/* Hero секция */}
      <Hero />
      
      {/* Статистика */}
      <motion.section 
        style={{ y }}
        className="relative py-12 sm:py-16 md:py-20 px-4 sm:px-6 lg:px-8 bg-gradient-to-r from-gray-900 to-black overflow-hidden"
      >
        {/* Анимированный фон статистики */}
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
        
        <div className="relative z-10 max-w-7xl mx-auto">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 1 }}
            viewport={{ once: true }}
            className="text-center mb-12 sm:mb-16"
          >
            <span className="inline-block px-3 py-2 sm:px-4 sm:py-2 bg-orange-600/20 text-orange-400 rounded-full text-xs sm:text-sm font-semibold border border-orange-600/30 mb-4">
              📊 Наши достижения
            </span>
            <h2 className="text-3xl sm:text-4xl md:text-5xl font-bold text-white mb-4 sm:mb-6">
              БЫК в цифрах
            </h2>
            <p className="text-base sm:text-lg md:text-xl text-white/70 max-w-3xl mx-auto px-4">
              Мы гордимся нашими результатами и доверием клиентов
            </p>
          </motion.div>

          <div className="grid grid-cols-2 sm:grid-cols-2 md:grid-cols-4 gap-4 sm:gap-6 md:gap-8">
            <motion.div 
              initial={{ opacity: 0, scale: 0.5 }}
              whileInView={{ opacity: 1, scale: 1 }}
              transition={{ duration: 0.5, delay: 0.1 }}
              viewport={{ once: true }}
              className="text-center group cursor-pointer"
              whileHover={{ scale: 1.05, y: -5 }}
            >
              <motion.div 
                whileHover={{ scale: 1.1, rotate: 5 }}
                className="w-16 h-16 sm:w-20 sm:h-20 bg-gradient-to-br from-orange-500 to-red-500 rounded-full flex items-center justify-center mx-auto mb-3 sm:mb-4 shadow-2xl"
              >
                <TrendingUp className="w-6 h-6 sm:w-8 sm:h-8 md:w-10 md:h-10 text-white" />
              </motion.div>
              <div className="text-2xl sm:text-3xl md:text-4xl font-bold text-white mb-1 sm:mb-2 group-hover:text-orange-400 transition-colors">
                {stats.orders.toLocaleString()}
              </div>
              <div className="text-xs sm:text-sm text-white/60">Заказов выполнено</div>
            </motion.div>

            <motion.div 
              initial={{ opacity: 0, scale: 0.5 }}
              whileInView={{ opacity: 1, scale: 1 }}
              transition={{ duration: 0.5, delay: 0.2 }}
              viewport={{ once: true }}
              className="text-center group cursor-pointer"
              whileHover={{ scale: 1.05, y: -5 }}
            >
              <motion.div 
                whileHover={{ scale: 1.1, rotate: -5 }}
                className="w-16 h-16 sm:w-20 sm:h-20 bg-gradient-to-br from-blue-500 to-purple-500 rounded-full flex items-center justify-center mx-auto mb-3 sm:mb-4 shadow-2xl"
              >
                <Users className="w-6 h-6 sm:w-8 sm:h-8 md:w-10 md:h-10 text-white" />
              </motion.div>
              <div className="text-2xl sm:text-3xl md:text-4xl font-bold text-white mb-1 sm:mb-2 group-hover:text-blue-400 transition-colors">
                {stats.customers.toLocaleString()}
              </div>
              <div className="text-xs sm:text-sm text-white/60">Довольных клиентов</div>
            </motion.div>

            <motion.div 
              initial={{ opacity: 0, scale: 0.5 }}
              whileInView={{ opacity: 1, scale: 1 }}
              transition={{ duration: 0.5, delay: 0.3 }}
              viewport={{ once: true }}
              className="text-center group cursor-pointer"
              whileHover={{ scale: 1.05, y: -5 }}
            >
              <motion.div 
                whileHover={{ scale: 1.1, rotate: 5 }}
                className="w-16 h-16 sm:w-20 sm:h-20 bg-gradient-to-br from-green-500 to-emerald-500 rounded-full flex items-center justify-center mx-auto mb-3 sm:mb-4 shadow-2xl"
              >
                <ChefHat className="w-6 h-6 sm:w-8 sm:h-8 md:w-10 md:h-10 text-white" />
              </motion.div>
              <div className="text-2xl sm:text-3xl md:text-4xl font-bold text-white mb-1 sm:mb-2 group-hover:text-green-400 transition-colors">
                {stats.restaurants}
              </div>
              <div className="text-xs sm:text-sm text-white/60">Ресторанов</div>
            </motion.div>

            <motion.div 
              initial={{ opacity: 0, scale: 0.5 }}
              whileInView={{ opacity: 1, scale: 1 }}
              transition={{ duration: 0.5, delay: 0.4 }}
              viewport={{ once: true }}
              className="text-center group cursor-pointer"
              whileHover={{ scale: 1.05, y: -5 }}
            >
              <motion.div 
                whileHover={{ scale: 1.1, rotate: -5 }}
                className="w-16 h-16 sm:w-20 sm:h-20 bg-gradient-to-br from-yellow-500 to-orange-500 rounded-full flex items-center justify-center mx-auto mb-3 sm:mb-4 shadow-2xl"
              >
                <Star className="w-6 h-6 sm:w-8 sm:h-8 md:w-10 md:h-10 text-white fill-current" />
              </motion.div>
              <div className="text-2xl sm:text-3xl md:text-4xl font-bold text-white mb-1 sm:mb-2 group-hover:text-yellow-400 transition-colors">
                {stats.rating}
              </div>
              <div className="text-xs sm:text-sm text-white/60">Средний рейтинг</div>
            </motion.div>
          </div>
        </div>
      </motion.section>

      {/* Рестораны */}
      <motion.section 
        style={{ y }}
        className="relative py-12 sm:py-16 md:py-20 px-4 sm:px-6 lg:px-8 bg-gradient-to-r from-black to-gray-900 overflow-hidden"
      >
        {/* Анимированный фон ресторанов */}
        <motion.div
          animate={{
            background: [
              "radial-gradient(circle at 80% 50%, rgba(255, 165, 0, 0.05) 0%, transparent 50%)",
              "radial-gradient(circle at 20% 50%, rgba(255, 165, 0, 0.05) 0%, transparent 50%)",
              "radial-gradient(circle at 80% 50%, rgba(255, 165, 0, 0.05) 0%, transparent 50%)"
            ]
          }}
          transition={{ duration: 8, repeat: Infinity }}
          className="absolute inset-0"
        />
        
        <div className="relative z-10 max-w-7xl mx-auto">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 1 }}
            viewport={{ once: true }}
            className="text-center mb-12 sm:mb-16"
          >
            <span className="inline-block px-3 py-2 sm:px-4 sm:py-2 bg-orange-600/20 text-orange-400 rounded-full text-xs sm:text-sm font-semibold border border-orange-600/30 mb-4">
              🏆 Наши рестораны
            </span>
            <h2 className="text-3xl sm:text-4xl md:text-5xl font-bold text-white mb-4 sm:mb-6">
              Лучшие рестораны
            </h2>
            <p className="text-base sm:text-lg md:text-xl text-white/70 max-w-3xl mx-auto px-4">
              Откройте для себя уникальные кулинарные впечатления в наших ресторанах
            </p>
          </motion.div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6 sm:gap-8 group">
            {restaurants.map((restaurant, index) => (
              <motion.div
                key={restaurant.id}
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.6, delay: index * 0.1 }}
                viewport={{ once: true }}
                whileHover={{ y: -15, scale: 1.02 }}
                className="group"
              >
                <RestaurantCard restaurant={restaurant} />
              </motion.div>
            ))}
          </div>
        </div>
      </motion.section>

      {/* Популярные блюда */}
      <motion.section 
        style={{ y }}
        className="relative py-12 sm:py-16 md:py-20 px-4 sm:px-6 lg:px-8 bg-gradient-to-r from-gray-900 to-black overflow-hidden"
      >
        {/* Анимированный фон блюд */}
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
        
        <div className="relative z-10 max-w-7xl mx-auto">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 1 }}
            viewport={{ once: true }}
            className="text-center mb-12 sm:mb-16"
          >
            <span className="inline-block px-3 py-2 sm:px-4 sm:py-2 bg-orange-600/20 text-orange-400 rounded-full text-xs sm:text-sm font-semibold border border-orange-600/30 mb-4">
              🍽️ Популярные блюда
            </span>
            <h2 className="text-3xl sm:text-4xl md:text-5xl font-bold text-white mb-4 sm:mb-6">
              Популярные блюда
            </h2>
            <p className="text-base sm:text-lg md:text-xl text-white/70 max-w-3xl mx-auto px-4">
              Попробуйте наши самые популярные и вкусные блюда
            </p>
          </motion.div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6 sm:gap-8 group">
            {dishes.slice(0, 8).map((dish, index) => (
              <motion.div
                key={dish.id}
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.6, delay: index * 0.1 }}
                viewport={{ once: true }}
                whileHover={{ y: -15, scale: 1.03 }}
                className="group"
              >
                <DishCard dish={dish} />
              </motion.div>
            ))}
          </div>
        </div>
      </motion.section>

      {/* Преимущества */}
      <motion.section 
        style={{ y }}
        className="relative py-12 sm:py-16 md:py-20 px-4 sm:px-6 lg:px-8 bg-gradient-to-r from-black to-gray-900 overflow-hidden"
      >
        {/* Анимированный фон преимуществ */}
        <motion.div
          animate={{
            background: [
              "radial-gradient(circle at 80% 50%, rgba(255, 165, 0, 0.05) 0%, transparent 50%)",
              "radial-gradient(circle at 20% 50%, rgba(255, 165, 0, 0.05) 0%, transparent 50%)",
              "radial-gradient(circle at 80% 50%, rgba(255, 165, 0, 0.05) 0%, transparent 50%)"
            ]
          }}
          transition={{ duration: 8, repeat: Infinity }}
          className="absolute inset-0"
        />
        
        <div className="relative z-10 max-w-7xl mx-auto">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 1 }}
            viewport={{ once: true }}
            className="text-center mb-12 sm:mb-16"
          >
            <span className="inline-block px-3 py-2 sm:px-4 sm:py-2 bg-orange-600/20 text-orange-400 rounded-full text-xs sm:text-sm font-semibold border border-orange-600/30 mb-4">
              ⚡ Наши преимущества
            </span>
            <h2 className="text-3xl sm:text-4xl md:text-5xl font-bold text-white mb-4 sm:mb-6">
              Почему выбирают БЫК
            </h2>
            <p className="text-base sm:text-lg md:text-xl text-white/70 max-w-3xl mx-auto px-4">
              Мы предлагаем лучший сервис и качество для наших клиентов
            </p>
          </motion.div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6 sm:gap-8">
            <motion.div 
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.1 }}
              viewport={{ once: true }}
              whileHover={{ y: -10, scale: 1.02 }}
              className="group text-center p-6 sm:p-8 bg-gradient-to-br from-gray-800/50 to-gray-900/50 rounded-3xl border border-gray-700/50 hover:border-orange-500/50 transition-all duration-500 backdrop-blur-sm"
            >
              <motion.div 
                whileHover={{ scale: 1.1, rotate: 5 }}
                className="w-16 h-16 sm:w-20 sm:h-20 bg-gradient-to-br from-orange-500 to-red-500 rounded-full flex items-center justify-center mx-auto mb-4 sm:mb-6 group-hover:scale-110 transition-transform shadow-2xl"
              >
                <Zap className="w-8 h-8 sm:w-10 sm:h-10 text-white" />
              </motion.div>
              <h3 className="text-xl sm:text-2xl font-bold text-white mb-3 sm:mb-4 group-hover:text-orange-400 transition-colors">
                Быстрая доставка
              </h3>
              <p className="text-sm sm:text-base text-white/70 leading-relaxed">
                Доставляем заказы в течение 30-45 минут по всему городу
              </p>
            </motion.div>

            <motion.div 
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.2 }}
              viewport={{ once: true }}
              whileHover={{ y: -10, scale: 1.02 }}
              className="group text-center p-6 sm:p-8 bg-gradient-to-br from-gray-800/50 to-gray-900/50 rounded-3xl border border-gray-700/50 hover:border-green-500/50 transition-all duration-500 backdrop-blur-sm"
            >
              <motion.div 
                whileHover={{ scale: 1.1, rotate: -5 }}
                className="w-16 h-16 sm:w-20 sm:h-20 bg-gradient-to-br from-green-500 to-emerald-500 rounded-full flex items-center justify-center mx-auto mb-4 sm:mb-6 group-hover:scale-110 transition-transform shadow-2xl"
              >
                <Shield className="w-8 h-8 sm:w-10 sm:h-10 text-white" />
              </motion.div>
              <h3 className="text-xl sm:text-2xl font-bold text-white mb-3 sm:mb-4 group-hover:text-green-400 transition-colors">
                Качество и безопасность
              </h3>
              <p className="text-sm sm:text-base text-white/70 leading-relaxed">
                Все блюда готовятся из свежих ингредиентов с соблюдением стандартов
              </p>
            </motion.div>

            <motion.div 
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.3 }}
              viewport={{ once: true }}
              whileHover={{ y: -10, scale: 1.02 }}
              className="group text-center p-6 sm:p-8 bg-gradient-to-br from-gray-800/50 to-gray-900/50 rounded-3xl border border-gray-700/50 hover:border-blue-500/50 transition-all duration-500 backdrop-blur-sm sm:col-span-2 lg:col-span-1"
            >
              <motion.div 
                whileHover={{ scale: 1.1, rotate: 5 }}
                className="w-16 h-16 sm:w-20 sm:h-20 bg-gradient-to-br from-blue-500 to-purple-500 rounded-full flex items-center justify-center mx-auto mb-4 sm:mb-6 group-hover:scale-110 transition-transform shadow-2xl"
              >
                <Heart className="w-8 h-8 sm:w-10 sm:h-10 text-white" />
              </motion.div>
              <h3 className="text-xl sm:text-2xl font-bold text-white mb-3 sm:mb-4 group-hover:text-blue-400 transition-colors">
                Забота о клиентах
              </h3>
              <p className="text-sm sm:text-base text-white/70 leading-relaxed">
                Наша команда всегда готова помочь и сделать ваш опыт незабываемым
              </p>
            </motion.div>
          </div>
        </div>
      </motion.section>

      {/* CTA секция */}
      <motion.section 
        style={{ y }}
        className="relative py-12 sm:py-16 md:py-20 px-4 sm:px-6 lg:px-8 bg-gradient-to-r from-gray-900 to-black overflow-hidden"
      >
        {/* Анимированный фон CTA */}
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
        
        <div className="relative z-10 max-w-4xl mx-auto text-center">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 1 }}
            viewport={{ once: true }}
            className="bg-gradient-to-br from-gray-800/50 to-gray-900/50 rounded-3xl p-8 sm:p-12 border border-gray-700/50 backdrop-blur-sm"
          >
            <h2 className="text-3xl sm:text-4xl md:text-5xl font-bold text-white mb-4 sm:mb-6">
              Готовы заказать?
            </h2>
            <p className="text-base sm:text-lg md:text-xl text-white/70 mb-8 sm:mb-10 max-w-2xl mx-auto">
              Откройте для себя мир вкусной еды с БЫК. Закажите прямо сейчас!
            </p>
            
            <div className="flex flex-col sm:flex-row gap-4 sm:gap-6 justify-center">
              <motion.button
                whileHover={{ scale: 1.05, y: -2 }}
                whileTap={{ scale: 0.95 }}
                onClick={() => window.location.href = '/restaurants'}
                className="px-8 py-4 bg-gradient-to-r from-orange-600 to-red-600 text-white font-bold rounded-xl hover:shadow-lg transition-all duration-300 text-lg"
              >
                Заказать еду
              </motion.button>
              
              <motion.button
                whileHover={{ scale: 1.05, y: -2 }}
                whileTap={{ scale: 0.95 }}
                onClick={() => window.location.href = 'tel:+74951234567'}
                className="px-8 py-4 bg-gradient-to-r from-gray-600 to-gray-700 text-white font-bold rounded-xl hover:shadow-lg transition-all duration-300 text-lg"
              >
                Позвонить нам
              </motion.button>
            </div>
          </motion.div>
        </div>
      </motion.section>
    </main>
  );
} 