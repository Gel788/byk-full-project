'use client';

import { useState, useEffect } from 'react';
import { motion, useScroll, useTransform } from 'framer-motion';
import { Calendar, Clock, ArrowRight, Search, Newspaper, TrendingUp } from 'lucide-react';
import { useRouter } from 'next/navigation';
import { news, restaurants } from '../../lib/data';
import { getBrandColors } from '../../lib/data';

export default function NewsPage() {
  const router = useRouter();
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedRestaurant, setSelectedRestaurant] = useState('all');
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

  const filteredNews = news.filter(item => {
    const matchesSearch = item.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
                         item.content.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesRestaurant = selectedRestaurant === 'all' || item.restaurantId === selectedRestaurant;
    return matchesSearch && matchesRestaurant;
  });

  const formatDate = (date: Date) => {
    return new Intl.DateTimeFormat('ru-RU', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    }).format(date);
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

        <div className="relative z-10 max-w-7xl mx-auto text-center">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 1 }}
            className="mb-6"
          >
            <span className="inline-block px-6 py-3 bg-orange-600/20 text-orange-400 rounded-full text-sm font-semibold border border-orange-600/30 backdrop-blur-sm">
              📰 Новости и события
            </span>
          </motion.div>

          <motion.h1
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 1, delay: 0.2 }}
            className="text-5xl sm:text-6xl lg:text-7xl font-bold text-white mb-8"
          >
            <span className="bg-gradient-to-r from-white via-orange-400 to-white bg-clip-text text-transparent">
              Новости
            </span> и события
          </motion.h1>
          
          <motion.p
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 1, delay: 0.4 }}
            className="text-xl text-white/70 mb-12 max-w-3xl mx-auto leading-relaxed"
          >
            Будьте в курсе последних новостей, акций и событий в наших ресторанах. 
            Узнавайте первыми о новых блюдах и специальных предложениях.
          </motion.p>

          {/* Поиск и фильтры */}
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 1, delay: 0.6 }}
            className="max-w-4xl mx-auto space-y-8"
          >
            {/* Поиск */}
            <div className="relative">
              <Search className="absolute left-4 top-1/2 transform -translate-y-1/2 w-6 h-6 text-white/50" />
              <input
                type="text"
                placeholder="Поиск новостей..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full pl-14 pr-4 py-4 bg-white/10 backdrop-blur-sm border border-white/20 rounded-2xl text-white placeholder-white/50 focus:outline-none focus:ring-2 focus:ring-orange-500 focus:border-transparent text-lg"
              />
            </div>

            {/* Фильтры по ресторанам */}
            <div className="flex flex-wrap justify-center gap-4">
              <motion.button
                whileHover={{ scale: 1.05, y: -2 }}
                whileTap={{ scale: 0.95 }}
                onClick={() => setSelectedRestaurant('all')}
                className={`px-6 py-3 rounded-xl font-semibold transition-all duration-300 ${
                  selectedRestaurant === 'all'
                    ? 'bg-gradient-to-r from-orange-600 to-red-600 text-white shadow-lg'
                    : 'text-white/70 hover:text-white bg-white/10 hover:bg-white/20 border border-white/20'
                }`}
              >
                Все рестораны
              </motion.button>
              {restaurants.map((restaurant) => (
                <motion.button
                  key={restaurant.id}
                  whileHover={{ scale: 1.05, y: -2 }}
                  whileTap={{ scale: 0.95 }}
                  onClick={() => setSelectedRestaurant(restaurant.id)}
                  className={`px-6 py-3 rounded-xl font-semibold transition-all duration-300 ${
                    selectedRestaurant === restaurant.id
                      ? 'bg-gradient-to-r from-orange-600 to-red-600 text-white shadow-lg'
                      : 'text-white/70 hover:text-white bg-white/10 hover:bg-white/20 border border-white/20'
                  }`}
                >
                  {restaurant.name}
                </motion.button>
              ))}
            </div>
          </motion.div>
        </div>
      </section>

      {/* Список новостей */}
      <section className="relative py-24 px-4 sm:px-6 lg:px-8 overflow-hidden">
        {/* Анимированный фон */}
        <motion.div
          animate={{
            background: [
              "radial-gradient(circle at 10% 20%, rgba(255, 165, 0, 0.03) 0%, transparent 50%)",
              "radial-gradient(circle at 90% 80%, rgba(255, 165, 0, 0.03) 0%, transparent 50%)",
              "radial-gradient(circle at 10% 20%, rgba(255, 165, 0, 0.03) 0%, transparent 50%)"
            ]
          }}
          transition={{ duration: 10, repeat: Infinity }}
          className="absolute inset-0"
        />
        
        <div className="relative z-10 max-w-7xl mx-auto">
          {filteredNews.length > 0 ? (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-10">
              {filteredNews.map((item, index) => {
                const restaurant = restaurants.find(r => r.id === item.restaurantId);
                const colors = restaurant ? getBrandColors(restaurant.brand) : null;
                
                return (
                  <motion.article
                    key={item.id}
                    initial={{ opacity: 0, y: 80 }}
                    whileInView={{ opacity: 1, y: 0 }}
                    transition={{ duration: 1, delay: 0.1 * index }}
                    viewport={{ once: true }}
                    whileHover={{ y: -15, scale: 1.02 }}
                    onClick={() => router.push(`/news/${item.id}`)}
                    className="group cursor-pointer relative overflow-hidden rounded-3xl bg-gradient-to-br from-gray-800/50 to-gray-900/50 border border-gray-700/50 hover:border-orange-500/50 transition-all duration-500 backdrop-blur-sm"
                  >
                    {/* Изображение */}
                    <div className="relative h-56 overflow-hidden">
                      <div 
                        className="w-full h-full bg-gradient-to-br from-gray-800 to-gray-900"
                        style={{
                          background: colors 
                            ? `linear-gradient(135deg, ${colors.primary}20, ${colors.secondary}20)`
                            : 'linear-gradient(135deg, #374151, #1f2937)'
                        }}
                      />
                      
                      {/* Брендовый градиент */}
                      {colors && (
                        <motion.div 
                          className="absolute inset-0 opacity-20"
                          animate={{
                            background: [
                              `linear-gradient(135deg, ${colors.primary}, ${colors.accent})`,
                              `linear-gradient(135deg, ${colors.accent}, ${colors.primary})`,
                              `linear-gradient(135deg, ${colors.primary}, ${colors.accent})`
                            ]
                          }}
                          transition={{ duration: 4, repeat: Infinity }}
                        />
                      )}
                      
                      {/* Ресторан */}
                      {restaurant && (
                        <div className="absolute top-4 left-4">
                          <span 
                            className="px-4 py-2 rounded-full text-sm font-semibold backdrop-blur-sm"
                            style={{
                              backgroundColor: colors ? `${colors.primary}20` : 'rgba(255,255,255,0.1)',
                              color: colors ? colors.accent : '#fff',
                              border: `1px solid ${colors ? colors.primary + '40' : 'rgba(255,255,255,0.2)'}`
                            }}
                          >
                            {restaurant.name}
                          </span>
                        </div>
                      )}

                      {/* Иконка новости */}
                      <div className="absolute top-4 right-4">
                        <div className="w-10 h-10 bg-white/20 backdrop-blur-sm rounded-full flex items-center justify-center">
                          <Newspaper className="w-5 h-5 text-white" />
                        </div>
                      </div>
                    </div>

                    {/* Контент */}
                    <div className="p-8">
                      {/* Дата */}
                      <div className="flex items-center space-x-2 text-white/60 mb-4">
                        <Calendar className="w-4 h-4" />
                        <span className="text-sm">{formatDate(item.publishedAt)}</span>
                      </div>

                      {/* Заголовок */}
                      <h3 className="text-2xl font-bold text-white mb-4 line-clamp-2 group-hover:text-orange-400 transition-colors leading-tight">
                        {item.title}
                      </h3>

                      {/* Описание */}
                      <p className="text-white/70 text-base mb-8 line-clamp-3 leading-relaxed">
                        {item.content}
                      </p>

                      {/* Кнопка читать далее */}
                      <div className="flex items-center space-x-3 text-orange-400 group-hover:text-orange-300 transition-colors">
                        <span className="font-semibold text-lg">Читать далее</span>
                        <ArrowRight className="w-5 h-5 group-hover:translate-x-1 transition-transform" />
                      </div>
                    </div>

                    {/* Брендовый индикатор */}
                    {colors && (
                      <div 
                        className="absolute top-0 left-0 w-1 h-full"
                        style={{ backgroundColor: colors.accent }}
                      />
                    )}

                    {/* Hover эффект */}
                    <motion.div
                      className="absolute inset-0 bg-gradient-to-r from-orange-500/5 to-red-500/5 opacity-0 group-hover:opacity-100 transition-opacity duration-300"
                      initial={false}
                    />
                  </motion.article>
                );
              })}
            </div>
          ) : (
            <motion.div
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 1 }}
              className="text-center py-20"
            >
              <motion.div 
                whileHover={{ scale: 1.1, rotate: 5 }}
                className="w-24 h-24 mx-auto mb-8 rounded-full bg-gradient-to-br from-orange-500 to-red-500 flex items-center justify-center shadow-2xl"
              >
                <span className="text-3xl">📰</span>
              </motion.div>
              <h3 className="text-3xl font-bold text-white mb-6">Новости не найдены</h3>
              <p className="text-white/60 mb-8 text-lg">
                Попробуйте изменить параметры поиска или фильтры
              </p>
              <motion.button
                whileHover={{ scale: 1.05, y: -2 }}
                whileTap={{ scale: 0.95 }}
                onClick={() => {
                  setSearchQuery('');
                  setSelectedRestaurant('all');
                }}
                className="px-8 py-4 bg-gradient-to-r from-orange-600 to-red-600 text-white font-semibold rounded-xl hover:shadow-lg transition-all duration-300 text-lg"
              >
                Сбросить фильтры
              </motion.button>
            </motion.div>
          )}
        </div>
      </section>

      {/* Подписка на новости */}
      <section className="relative py-24 px-4 sm:px-6 lg:px-8 bg-gradient-to-b from-transparent to-gray-900/50 overflow-hidden">
        {/* Анимированный фон */}
        <motion.div
          animate={{
            background: [
              "radial-gradient(circle at 25% 25%, rgba(255, 165, 0, 0.1) 0%, transparent 50%)",
              "radial-gradient(circle at 75% 75%, rgba(255, 165, 0, 0.1) 0%, transparent 50%)",
              "radial-gradient(circle at 25% 25%, rgba(255, 165, 0, 0.1) 0%, transparent 50%)"
            ]
          }}
          transition={{ duration: 6, repeat: Infinity }}
          className="absolute inset-0"
        />
        
        <div className="relative z-10 max-w-4xl mx-auto text-center">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 1 }}
            viewport={{ once: true }}
            className="relative overflow-hidden bg-gradient-to-br from-gray-800/50 to-gray-900/50 rounded-3xl p-16 border border-gray-700/50 backdrop-blur-sm"
          >
            <motion.div
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              transition={{ duration: 1 }}
              viewport={{ once: true }}
              className="mb-6"
            >
              <span className="inline-block px-6 py-3 bg-orange-600/20 text-orange-400 rounded-full text-sm font-semibold border border-orange-600/30 backdrop-blur-sm">
                📧 Подписка на новости
              </span>
            </motion.div>
            <h2 className="text-4xl sm:text-5xl font-bold text-white mb-8">
              Будьте в курсе событий
            </h2>
            <p className="text-xl text-white/70 mb-12 max-w-2xl mx-auto leading-relaxed">
              Подпишитесь на нашу рассылку и получайте первыми информацию о новых блюдах, 
              акциях и специальных предложениях
            </p>
            
            <div className="flex flex-col sm:flex-row gap-4 max-w-md mx-auto">
              <input
                type="email"
                placeholder="Ваш email"
                className="flex-1 px-6 py-4 bg-white/10 border border-white/20 rounded-xl text-white placeholder-white/50 focus:outline-none focus:ring-2 focus:ring-orange-500 focus:border-transparent backdrop-blur-sm"
              />
              <motion.button
                whileHover={{ scale: 1.05, y: -2 }}
                whileTap={{ scale: 0.95 }}
                className="px-8 py-4 bg-gradient-to-r from-orange-600 to-red-600 text-white font-semibold rounded-xl hover:shadow-lg transition-all duration-300"
              >
                Подписаться
              </motion.button>
            </div>
          </motion.div>
        </div>
      </section>
    </main>
  );
} 