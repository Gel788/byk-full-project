'use client';

import { motion, useScroll, useTransform } from 'framer-motion';
import { ArrowRight, Star, Clock, MapPin, Sparkles, ChefHat, Truck, Zap, Crown } from 'lucide-react';
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
    <section className="relative min-h-screen flex items-center justify-center overflow-hidden bg-gradient-to-br from-[#1a1a1a] via-[#2a2a2a] to-[#1a1a1a]">
      {/* Премиальный фон */}
      <div className="absolute inset-0">
        {/* Золотые частицы */}
        {[...Array(30)].map((_, i) => (
          <motion.div
            key={i}
            animate={{
              y: [0, -100, 0],
              x: [0, Math.random() * 50 - 25, 0],
              opacity: [0, 1, 0],
              scale: [0, 1, 0],
            }}
            transition={{
              duration: 4 + Math.random() * 3,
              repeat: Infinity,
              delay: Math.random() * 2,
            }}
            className="absolute w-1 h-1 bg-gradient-to-r from-[#d4af37] to-[#f4d03f] rounded-full"
            style={{
              left: `${Math.random() * 100}%`,
              top: `${Math.random() * 100}%`,
            }}
          />
        ))}

        {/* Анимированные круги */}
        <motion.div
          animate={{
            scale: [1, 1.3, 1],
            opacity: [0.1, 0.3, 0.1],
            rotate: [0, 360],
          }}
          transition={{
            duration: 20,
            repeat: Infinity,
            ease: "linear"
          }}
          className="absolute top-1/4 left-1/4 w-96 h-96 bg-gradient-to-r from-[#d4af37]/20 to-[#f4d03f]/20 rounded-full blur-3xl"
        />
        
        <motion.div
          animate={{
            scale: [1.2, 1, 1.2],
            opacity: [0.2, 0.4, 0.2],
            rotate: [360, 0],
          }}
          transition={{
            duration: 25,
            repeat: Infinity,
            ease: "linear",
            delay: 5
          }}
          className="absolute bottom-1/4 right-1/4 w-80 h-80 bg-gradient-to-r from-[#ff6b35]/20 to-[#d4af37]/20 rounded-full blur-3xl"
        />

        {/* Сетка */}
        <div className="absolute inset-0 opacity-10">
          <div className="absolute inset-0" style={{
            backgroundImage: `radial-gradient(circle at 1px 1px, rgba(212, 175, 55, 0.3) 1px, transparent 0)`,
            backgroundSize: '40px 40px'
          }} />
        </div>
      </div>

      {/* Интерактивный курсор эффект */}
      <motion.div
        className="fixed w-6 h-6 bg-gradient-to-r from-[#d4af37] to-[#f4d03f] rounded-full pointer-events-none z-50 mix-blend-difference hidden lg:block"
        animate={{
          x: mousePosition.x - 12,
          y: mousePosition.y - 12,
        }}
        transition={{ type: "spring", stiffness: 500, damping: 28 }}
      />

      {/* Контент */}
      <div className="relative z-10 text-center px-4 sm:px-6 lg:px-8 max-w-7xl mx-auto">
        {/* Премиальный бейдж */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.1 }}
          className="mb-8"
        >
          <span className="inline-flex items-center px-6 py-3 bg-gradient-to-r from-[#d4af37]/20 to-[#f4d03f]/20 text-[#d4af37] rounded-full text-sm font-semibold border border-[#d4af37]/30 backdrop-blur-sm glass-effect">
            <Crown className="w-5 h-5 mr-2" />
            БЫК ХОЛДИНГ • Премиум рестораны
          </span>
        </motion.div>

        {/* Главный заголовок */}
        <motion.div
          initial={{ opacity: 0, y: 50 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 1.2, delay: 0.3 }}
          className="mb-8"
        >
          <motion.h1 
            className="text-6xl sm:text-8xl md:text-9xl lg:text-[12rem] font-black mb-6 leading-none"
            animate={{
              backgroundPosition: ['0% 50%', '100% 50%', '0% 50%'],
            }}
            transition={{
              duration: 8,
              repeat: Infinity,
              ease: "linear"
            }}
            style={{
              background: 'linear-gradient(90deg, #ffffff, #d4af37, #f4d03f, #d4af37, #ffffff)',
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
            className="text-2xl sm:text-3xl md:text-4xl lg:text-5xl text-white/90 mb-4 font-medium"
          >
            Холдинг премиум ресторанов
          </motion.p>
          
          <motion.div
            initial={{ opacity: 0, scale: 0.8 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.8, delay: 0.8 }}
            className="flex justify-center items-center space-x-2 mb-8"
          >
            {[...Array(5)].map((_, i) => (
              <motion.div
                key={i}
                animate={{ rotate: [0, 360] }}
                transition={{ duration: 3, delay: i * 0.2, repeat: Infinity, ease: "linear" }}
              >
                <Star className="w-6 h-6 sm:w-8 sm:h-8 text-[#d4af37] fill-current" />
              </motion.div>
            ))}
          </motion.div>
        </motion.div>

        {/* Описание */}
        <motion.p
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 1, delay: 0.9 }}
          className="text-lg sm:text-xl md:text-2xl lg:text-3xl text-white/80 mb-12 max-w-5xl mx-auto leading-relaxed px-4"
        >
          Откройте для себя мир премиальной кухни: <span className="text-[#d4af37] font-semibold">THE БЫК</span>, <span className="text-[#d4af37] font-semibold">THE ПИВО</span>, <span className="text-[#d4af37] font-semibold">MOSCA</span>. 
          <br />Изысканные блюда, безупречный сервис, незабываемые впечатления.
        </motion.p>

        {/* Премиальная статистика */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 1, delay: 1.1 }}
          className="grid grid-cols-3 gap-6 sm:gap-8 md:gap-12 mb-16 max-w-3xl mx-auto"
        >
          <motion.div 
            className="text-center group cursor-pointer"
            whileHover={{ scale: 1.1, y: -5 }}
            whileTap={{ scale: 0.95 }}
          >
            <motion.div 
              className="w-16 h-16 sm:w-20 sm:h-20 md:w-24 md:h-24 bg-gradient-to-br from-[#d4af37] to-[#f4d03f] rounded-full flex items-center justify-center mx-auto mb-4 group-hover:rotate-12 transition-transform shadow-lg"
            >
              <Crown className="w-8 h-8 sm:w-10 sm:h-10 md:w-12 md:h-12 text-[#1a1a1a]" />
            </motion.div>
            <div className="text-2xl sm:text-3xl md:text-4xl font-bold text-[#d4af37] mb-2 group-hover:text-[#f4d03f] transition-colors">4.9</div>
            <span className="text-white/70 text-sm sm:text-base">Рейтинг</span>
          </motion.div>
          
          <motion.div 
            className="text-center group cursor-pointer"
            whileHover={{ scale: 1.1, y: -5 }}
            whileTap={{ scale: 0.95 }}
          >
            <motion.div 
              className="w-16 h-16 sm:w-20 sm:h-20 md:w-24 md:h-24 bg-gradient-to-br from-[#ff6b35] to-[#d4af37] rounded-full flex items-center justify-center mx-auto mb-4 group-hover:rotate-12 transition-transform shadow-lg"
            >
              <Clock className="w-8 h-8 sm:w-10 sm:h-10 md:w-12 md:h-12 text-white" />
            </motion.div>
            <div className="text-2xl sm:text-3xl md:text-4xl font-bold text-[#ff6b35] mb-2 group-hover:text-[#d4af37] transition-colors">30</div>
            <span className="text-white/70 text-sm sm:text-base">Минут</span>
          </motion.div>
          
          <motion.div 
            className="text-center group cursor-pointer"
            whileHover={{ scale: 1.1, y: -5 }}
            whileTap={{ scale: 0.95 }}
          >
            <motion.div 
              className="w-16 h-16 sm:w-20 sm:h-20 md:w-24 md:h-24 bg-gradient-to-br from-[#8B4513] to-[#A0522D] rounded-full flex items-center justify-center mx-auto mb-4 group-hover:rotate-12 transition-transform shadow-lg"
            >
              <MapPin className="w-8 h-8 sm:w-10 sm:h-10 md:w-12 md:h-12 text-white" />
            </motion.div>
            <div className="text-2xl sm:text-3xl md:text-4xl font-bold text-[#8B4513] mb-2 group-hover:text-[#A0522D] transition-colors">3</div>
            <span className="text-white/70 text-sm sm:text-base">Ресторана</span>
          </motion.div>
        </motion.div>

        {/* Премиальные кнопки */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 1, delay: 1.3 }}
          className="flex flex-col sm:flex-row gap-6 justify-center items-center mb-16"
        >
          <motion.button
            whileHover={{ scale: 1.05, y: -2 }}
            whileTap={{ scale: 0.95 }}
            className="group bg-gradient-to-r from-[#d4af37] to-[#f4d03f] text-[#1a1a1a] font-bold py-4 sm:py-5 px-8 sm:px-10 rounded-2xl text-lg sm:text-xl transition-all duration-300 shadow-2xl hover:shadow-[#d4af37]/25 flex items-center space-x-3"
          >
            <span>Заказать еду</span>
            <ArrowRight className="w-5 h-5 sm:w-6 sm:h-6 group-hover:translate-x-1 transition-transform" />
          </motion.button>
          
          <motion.button
            whileHover={{ scale: 1.05, y: -2 }}
            whileTap={{ scale: 0.95 }}
            className="group border-2 border-[#d4af37]/50 text-[#d4af37] font-bold py-4 sm:py-5 px-8 sm:px-10 rounded-2xl hover:border-[#d4af37] hover:bg-[#d4af37]/10 transition-all duration-300 backdrop-blur-sm text-lg sm:text-xl flex items-center space-x-3"
          >
            <ChefHat className="w-5 h-5 sm:w-6 sm:h-6 group-hover:scale-110 transition-transform" />
            <span>Посмотреть меню</span>
          </motion.button>
        </motion.div>

        {/* Премиальные преимущества */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 1, delay: 1.5 }}
          className="grid grid-cols-1 sm:grid-cols-3 gap-6 max-w-5xl mx-auto"
        >
          <motion.div 
            className="flex items-center justify-center space-x-4 p-6 glass-card rounded-2xl"
            whileHover={{ scale: 1.02, y: -2 }}
          >
            <Truck className="w-6 h-6 sm:w-8 sm:h-8 text-[#d4af37]" />
            <span className="text-white/90 text-base sm:text-lg font-medium">Бесплатная доставка</span>
          </motion.div>
          
          <motion.div 
            className="flex items-center justify-center space-x-4 p-6 glass-card rounded-2xl"
            whileHover={{ scale: 1.02, y: -2 }}
          >
            <Zap className="w-6 h-6 sm:w-8 sm:h-8 text-[#ff6b35]" />
            <span className="text-white/90 text-base sm:text-lg font-medium">Мгновенная оплата</span>
          </motion.div>
          
          <motion.div 
            className="flex items-center justify-center space-x-4 p-6 glass-card rounded-2xl"
            whileHover={{ scale: 1.02, y: -2 }}
          >
            <Crown className="w-6 h-6 sm:w-8 sm:h-8 text-[#d4af37]" />
            <span className="text-white/90 text-base sm:text-lg font-medium">Премиум качество</span>
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
            className="w-8 h-12 border-2 border-[#d4af37]/30 rounded-full flex justify-center"
          >
            <motion.div
              animate={{ y: [0, 16, 0] }}
              transition={{ duration: 2, repeat: Infinity }}
              className="w-2 h-4 bg-[#d4af37] rounded-full mt-2"
            />
          </motion.div>
        </motion.div>
      </div>
    </section>
  );
}