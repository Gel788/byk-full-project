'use client';

import { motion, useScroll, useTransform } from 'framer-motion';
import { ArrowRight, Star, Clock, MapPin, Sparkles, ChefHat, Truck, Zap } from 'lucide-react';
import Link from 'next/link';
import { useState, useEffect } from 'react';

export default function Hero() {
  const [mousePosition, setMousePosition] = useState({ x: 0, y: 0 });
  const { scrollYProgress } = useScroll();
  const y = useTransform(scrollYProgress, [0, 1], [0, -100]);
  const opacity = useTransform(scrollYProgress, [0, 0.5], [1, 0]);

  useEffect(() => {
    const handleMouseMove = (e: MouseEvent) => {
      setMousePosition({ x: e.clientX, y: e.clientY });
    };

    window.addEventListener('mousemove', handleMouseMove);
    return () => window.removeEventListener('mousemove', handleMouseMove);
  }, []);

  return (
    <section className="relative min-h-screen flex items-center justify-center overflow-hidden">
      {/* Анимированный фон */}
      <div className="absolute inset-0">
        {/* Градиентный фон */}
        <div className="absolute inset-0 bg-gradient-to-br from-black via-gray-900 to-black"></div>
        
        {/* Анимированные круги */}
        <motion.div
          animate={{
            scale: [1, 1.2, 1],
            opacity: [0.3, 0.6, 0.3],
          }}
          transition={{
            duration: 8,
            repeat: Infinity,
            ease: "easeInOut"
          }}
          className="absolute top-1/4 left-1/4 w-48 h-48 sm:w-64 sm:h-64 md:w-96 md:h-96 bg-orange-500/10 rounded-full blur-3xl"
        />
        
        <motion.div
          animate={{
            scale: [1.2, 1, 1.2],
            opacity: [0.4, 0.7, 0.4],
          }}
          transition={{
            duration: 10,
            repeat: Infinity,
            ease: "easeInOut",
            delay: 2
          }}
          className="absolute bottom-1/4 right-1/4 w-40 h-40 sm:w-56 sm:h-56 md:w-80 md:h-80 bg-blue-500/10 rounded-full blur-3xl"
        />

        {/* Сетка */}
        <div className="absolute inset-0 opacity-20">
          <div className="absolute inset-0" style={{
            backgroundImage: `radial-gradient(circle at 1px 1px, rgba(255,255,255,0.1) 1px, transparent 0)`,
            backgroundSize: '30px 30px'
          }} />
        </div>

        {/* Плавающие частицы */}
        {[...Array(20)].map((_, i) => (
          <motion.div
            key={i}
            animate={{
              y: [0, -30, 0],
              x: [0, Math.random() * 20 - 10, 0],
              opacity: [0, 1, 0],
            }}
            transition={{
              duration: 3 + Math.random() * 2,
              repeat: Infinity,
              delay: Math.random() * 2,
            }}
            className="absolute w-1 h-1 bg-orange-400 rounded-full"
            style={{
              left: `${Math.random() * 100}%`,
              top: `${Math.random() * 100}%`,
            }}
          />
        ))}
      </div>

      {/* Интерактивный курсор эффект - только для десктопа */}
      <motion.div
        className="fixed w-4 h-4 bg-orange-500 rounded-full pointer-events-none z-50 mix-blend-difference hidden lg:block"
        animate={{
          x: mousePosition.x - 8,
          y: mousePosition.y - 8,
        }}
        transition={{ type: "spring", stiffness: 500, damping: 28 }}
      />

      {/* Контент */}
      <div className="relative z-10 text-center px-4 sm:px-6 lg:px-8 max-w-7xl mx-auto">
        {/* Бейдж */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.1 }}
          className="mb-6 sm:mb-8"
        >
          <span className="inline-flex items-center px-3 py-2 sm:px-4 sm:py-2 bg-orange-600/20 text-orange-400 rounded-full text-xs sm:text-sm font-semibold border border-orange-600/30 backdrop-blur-sm">
            <Sparkles className="w-3 h-3 sm:w-4 sm:h-4 mr-2" />
            Премиум доставка еды
          </span>
        </motion.div>

        {/* Главный заголовок */}
        <motion.div
          initial={{ opacity: 0, y: 50 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 1.2, delay: 0.3 }}
          className="mb-6 sm:mb-8"
        >
          <motion.h1 
            className="text-4xl sm:text-6xl md:text-8xl lg:text-9xl font-black text-white mb-4 sm:mb-6 leading-none"
            animate={{
              backgroundPosition: ['0% 50%', '100% 50%', '0% 50%'],
            }}
            transition={{
              duration: 8,
              repeat: Infinity,
              ease: "linear"
            }}
            style={{
              background: 'linear-gradient(90deg, #ffffff, #ff6b35, #ffffff, #ff6b35)',
              backgroundSize: '300% 100%',
              WebkitBackgroundClip: 'text',
              WebkitTextFillColor: 'transparent',
              backgroundClip: 'text',
            }}
          >
            БЫК
          </motion.h1>
          
          <motion.p 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 1, delay: 0.6 }}
            className="text-xl sm:text-2xl md:text-3xl lg:text-4xl text-white/90 mb-3 sm:mb-4 font-medium"
          >
            Доставка еды
          </motion.p>
          
          <motion.div
            initial={{ opacity: 0, scale: 0.8 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.8, delay: 0.8 }}
            className="flex justify-center items-center space-x-1 sm:space-x-2 mb-6 sm:mb-8"
          >
            {[...Array(5)].map((_, i) => (
              <motion.div
                key={i}
                animate={{ rotate: [0, 360] }}
                transition={{ duration: 2, delay: i * 0.1, repeat: Infinity, ease: "linear" }}
              >
                <Star className="w-4 h-4 sm:w-5 sm:h-5 md:w-6 md:h-6 text-yellow-400 fill-current" />
              </motion.div>
            ))}
          </motion.div>
        </motion.div>

        {/* Описание */}
        <motion.p
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 1, delay: 0.9 }}
          className="text-base sm:text-lg md:text-xl lg:text-2xl text-white/80 mb-8 sm:mb-12 max-w-4xl mx-auto leading-relaxed px-4"
        >
          Заказывайте еду из лучших ресторанов: <span className="text-orange-400 font-semibold">THE БЫК</span>, <span className="text-orange-400 font-semibold">THE ПИВО</span>, <span className="text-orange-400 font-semibold">MOSCA</span>. 
          Быстрая доставка по Москве с гарантией качества.
        </motion.p>

        {/* Интерактивная статистика */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 1, delay: 1.1 }}
          className="grid grid-cols-3 gap-4 sm:gap-6 md:gap-8 mb-12 sm:mb-16 max-w-2xl mx-auto"
        >
          <motion.div 
            className="text-center group cursor-pointer"
            whileHover={{ scale: 1.1, y: -5 }}
            whileTap={{ scale: 0.95 }}
          >
            <motion.div 
              className="w-12 h-12 sm:w-14 sm:h-14 md:w-16 md:h-16 bg-gradient-to-br from-yellow-500 to-orange-500 rounded-full flex items-center justify-center mx-auto mb-2 sm:mb-4 group-hover:rotate-12 transition-transform"
            >
              <Star className="w-5 h-5 sm:w-6 sm:h-6 md:w-8 md:h-8 text-white" />
            </motion.div>
            <div className="text-xl sm:text-2xl md:text-3xl font-bold text-white mb-1 sm:mb-2 group-hover:text-yellow-400 transition-colors">4.9</div>
            <span className="text-white/70 text-xs sm:text-sm">Рейтинг</span>
          </motion.div>
          
          <motion.div 
            className="text-center group cursor-pointer"
            whileHover={{ scale: 1.1, y: -5 }}
            whileTap={{ scale: 0.95 }}
          >
            <motion.div 
              className="w-12 h-12 sm:w-14 sm:h-14 md:w-16 md:h-16 bg-gradient-to-br from-green-500 to-emerald-500 rounded-full flex items-center justify-center mx-auto mb-2 sm:mb-4 group-hover:rotate-12 transition-transform"
            >
              <Clock className="w-5 h-5 sm:w-6 sm:h-6 md:w-8 md:h-8 text-white" />
            </motion.div>
            <div className="text-xl sm:text-2xl md:text-3xl font-bold text-white mb-1 sm:mb-2 group-hover:text-green-400 transition-colors">30</div>
            <span className="text-white/70 text-xs sm:text-sm">Минут</span>
          </motion.div>
          
          <motion.div 
            className="text-center group cursor-pointer"
            whileHover={{ scale: 1.1, y: -5 }}
            whileTap={{ scale: 0.95 }}
          >
            <motion.div 
              className="w-12 h-12 sm:w-14 sm:h-14 md:w-16 md:h-16 bg-gradient-to-br from-blue-500 to-purple-500 rounded-full flex items-center justify-center mx-auto mb-2 sm:mb-4 group-hover:rotate-12 transition-transform"
            >
              <MapPin className="w-5 h-5 sm:w-6 sm:h-6 md:w-8 md:h-8 text-white" />
            </motion.div>
            <div className="text-xl sm:text-2xl md:text-3xl font-bold text-white mb-1 sm:mb-2 group-hover:text-blue-400 transition-colors">3</div>
            <span className="text-white/70 text-xs sm:text-sm">Ресторана</span>
          </motion.div>
        </motion.div>

        {/* Кнопки действий */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 1, delay: 1.3 }}
          className="flex flex-col sm:flex-row gap-4 sm:gap-6 justify-center items-center mb-12 sm:mb-16"
        >
          <motion.button
            whileHover={{ scale: 1.05, y: -2 }}
            whileTap={{ scale: 0.95 }}
            className="group bg-gradient-to-r from-orange-600 to-red-600 hover:from-orange-700 hover:to-red-700 text-white font-bold py-3 sm:py-4 px-6 sm:px-8 rounded-xl sm:rounded-2xl text-base sm:text-lg transition-all duration-300 shadow-2xl hover:shadow-orange-500/25 flex items-center space-x-2 sm:space-x-3"
          >
            <span>Заказать еду</span>
            <ArrowRight className="w-4 h-4 sm:w-5 sm:h-5 group-hover:translate-x-1 transition-transform" />
          </motion.button>
          
          <motion.button
            whileHover={{ scale: 1.05, y: -2 }}
            whileTap={{ scale: 0.95 }}
            className="group border-2 border-white/30 text-white font-bold py-3 sm:py-4 px-6 sm:px-8 rounded-xl sm:rounded-2xl hover:border-white/50 transition-all duration-300 backdrop-blur-sm text-base sm:text-lg flex items-center space-x-2 sm:space-x-3"
          >
            <ChefHat className="w-4 h-4 sm:w-5 sm:h-5 group-hover:scale-110 transition-transform" />
            <span>Посмотреть меню</span>
          </motion.button>
        </motion.div>

        {/* Дополнительные преимущества */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 1, delay: 1.5 }}
          className="grid grid-cols-1 sm:grid-cols-3 gap-4 sm:gap-6 max-w-4xl mx-auto"
        >
          <motion.div 
            className="flex items-center justify-center space-x-3 p-3 sm:p-4 bg-white/5 rounded-xl backdrop-blur-sm border border-white/10"
            whileHover={{ scale: 1.02, y: -2 }}
          >
            <Truck className="w-5 h-5 sm:w-6 sm:h-6 text-orange-400" />
            <span className="text-white/80 text-sm sm:text-base">Бесплатная доставка</span>
          </motion.div>
          
          <motion.div 
            className="flex items-center justify-center space-x-3 p-3 sm:p-4 bg-white/5 rounded-xl backdrop-blur-sm border border-white/10"
            whileHover={{ scale: 1.02, y: -2 }}
          >
            <Zap className="w-5 h-5 sm:w-6 sm:h-6 text-yellow-400" />
            <span className="text-white/80 text-sm sm:text-base">Мгновенная оплата</span>
          </motion.div>
          
          <motion.div 
            className="flex items-center justify-center space-x-3 p-3 sm:p-4 bg-white/5 rounded-xl backdrop-blur-sm border border-white/10"
            whileHover={{ scale: 1.02, y: -2 }}
          >
            <Star className="w-5 h-5 sm:w-6 sm:h-6 text-green-400" />
            <span className="text-white/80 text-sm sm:text-base">Гарантия качества</span>
          </motion.div>
        </motion.div>

        {/* Индикатор прокрутки */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 1, delay: 2 }}
          className="absolute bottom-8 left-1/2 transform -translate-x-1/2"
        >
          <motion.div
            animate={{ y: [0, 10, 0] }}
            transition={{ duration: 2, repeat: Infinity }}
            className="w-6 h-10 border-2 border-white/30 rounded-full flex justify-center"
          >
            <motion.div
              animate={{ y: [0, 12, 0] }}
              transition={{ duration: 2, repeat: Infinity }}
              className="w-1 h-3 bg-white/60 rounded-full mt-2"
            />
          </motion.div>
        </motion.div>
      </div>
    </section>
  );
}