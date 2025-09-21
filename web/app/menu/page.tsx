'use client';

import { useState, useEffect } from 'react';
import { motion, useScroll, useTransform } from 'framer-motion';
import { Search, Filter, Star, Clock, Flame, ChefHat, Utensils, Zap, Building2 } from 'lucide-react';
import DishCard from '../../components/DishCard';
import { useRestaurant } from '../../lib/contexts/RestaurantContext';
import { dishes, restaurants } from '../../lib/data';

export default function MenuPage() {
  const { filteredDishes, searchDishes, filterByCategory, clearFilters } = useRestaurant();
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('all');
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

  // Получаем уникальные категории
  const categories = ['all', ...Array.from(new Set(dishes.map(dish => dish.category)))];

  const handleSearch = (query: string) => {
    setSearchQuery(query);
    searchDishes(query);
  };

  const handleCategoryFilter = (category: string) => {
    setSelectedCategory(category);
    filterByCategory(category);
  };

  const handleRestaurantFilter = (restaurantId: string) => {
    setSelectedRestaurant(restaurantId);
    // Фильтрация по ресторану
  };

  const filteredDishesByRestaurant = selectedRestaurant === 'all' 
    ? filteredDishes 
    : filteredDishes.filter(dish => dish.restaurantId === selectedRestaurant);

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
              🍽️ Наше меню
            </span>
          </motion.div>

          <motion.h1
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 1, delay: 0.2 }}
            className="text-5xl sm:text-6xl lg:text-7xl font-bold text-white mb-8"
          >
            Наше <span className="bg-gradient-to-r from-white via-orange-400 to-white bg-clip-text text-transparent">меню</span>
          </motion.h1>
          
          <motion.p
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 1, delay: 0.4 }}
            className="text-xl text-white/70 mb-12 max-w-3xl mx-auto leading-relaxed"
          >
            Исследуйте наше разнообразное меню с блюдами от лучших шеф-поваров. 
            Каждое блюдо готовится с любовью и из свежих ингредиентов.
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
                placeholder="Поиск блюд..."
                value={searchQuery}
                onChange={(e) => handleSearch(e.target.value)}
                className="w-full pl-14 pr-4 py-4 bg-white/10 backdrop-blur-sm border border-white/20 rounded-2xl text-white placeholder-white/50 focus:outline-none focus:ring-2 focus:ring-orange-500 focus:border-transparent text-lg"
              />
            </div>

            {/* Фильтры по ресторанам */}
            <div className="flex flex-wrap justify-center gap-4">
              <motion.button
                whileHover={{ scale: 1.05, y: -2 }}
                whileTap={{ scale: 0.95 }}
                onClick={() => handleRestaurantFilter('all')}
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
                  onClick={() => handleRestaurantFilter(restaurant.id)}
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

            {/* Фильтры по категориям */}
            <div className="flex flex-wrap justify-center gap-4">
              {categories.map((category) => (
                <motion.button
                  key={category}
                  whileHover={{ scale: 1.05, y: -2 }}
                  whileTap={{ scale: 0.95 }}
                  onClick={() => handleCategoryFilter(category)}
                  className={`px-6 py-3 rounded-xl font-semibold transition-all duration-300 ${
                    selectedCategory === category
                      ? 'bg-gradient-to-r from-orange-600 to-red-600 text-white shadow-lg'
                      : 'text-white/70 hover:text-white bg-white/10 hover:bg-white/20 border border-white/20'
                  }`}
                >
                  {category === 'all' ? 'Все категории' : category}
                </motion.button>
              ))}
            </div>
          </motion.div>
        </div>
      </section>

      {/* Статистика меню */}
      <motion.section 
        style={{ y }}
        className="relative py-16 px-4 sm:px-6 lg:px-8 bg-gradient-to-r from-gray-900 to-black overflow-hidden"
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
          <div className="grid grid-cols-2 md:grid-cols-4 gap-8">
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
                className="w-20 h-20 bg-gradient-to-br from-orange-500 to-red-500 rounded-full flex items-center justify-center mx-auto mb-4 shadow-2xl"
              >
                <Utensils className="w-10 h-10 text-white" />
              </motion.div>
              <div className="text-4xl font-bold text-white mb-2 group-hover:text-orange-400 transition-colors">
                {dishes.length}
              </div>
              <div className="text-white/60">Блюд в меню</div>
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
                className="w-20 h-20 bg-gradient-to-br from-blue-500 to-purple-500 rounded-full flex items-center justify-center mx-auto mb-4 shadow-2xl"
              >
                <ChefHat className="w-10 h-10 text-white" />
              </motion.div>
              <div className="text-4xl font-bold text-white mb-2 group-hover:text-blue-400 transition-colors">
                {categories.length - 1}
              </div>
              <div className="text-white/60">Категорий</div>
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
                className="w-20 h-20 bg-gradient-to-br from-green-500 to-emerald-500 rounded-full flex items-center justify-center mx-auto mb-4 shadow-2xl"
              >
                <Building2 className="w-10 h-10 text-white" />
              </motion.div>
              <div className="text-4xl font-bold text-white mb-2 group-hover:text-green-400 transition-colors">
                {restaurants.length}
              </div>
              <div className="text-white/60">Ресторанов</div>
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
                className="w-20 h-20 bg-gradient-to-br from-yellow-500 to-orange-500 rounded-full flex items-center justify-center mx-auto mb-4 shadow-2xl"
              >
                <Zap className="w-10 h-10 text-white" />
              </motion.div>
              <div className="text-4xl font-bold text-white mb-2 group-hover:text-yellow-400 transition-colors">
                100%
              </div>
              <div className="text-white/60">Свежие ингредиенты</div>
            </motion.div>
          </div>
        </div>
      </motion.section>

      {/* Список блюд */}
      <section className="relative py-24 px-4 sm:px-6 lg:px-8 overflow-hidden">
        {/* Анимированный фон */}
        <motion.div
          animate={{
            background: [
              "radial-gradient(circle at 30% 70%, rgba(34, 197, 94, 0.03) 0%, transparent 50%)",
              "radial-gradient(circle at 70% 30%, rgba(34, 197, 94, 0.03) 0%, transparent 50%)",
              "radial-gradient(circle at 30% 70%, rgba(34, 197, 94, 0.03) 0%, transparent 50%)"
            ]
          }}
          transition={{ duration: 12, repeat: Infinity }}
          className="absolute inset-0"
        />
        
        <div className="relative z-10 max-w-7xl mx-auto">
          {filteredDishesByRestaurant.length > 0 ? (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-10">
              {filteredDishesByRestaurant.map((dish, index) => {
                const restaurant = restaurants.find(r => r.id === dish.restaurantId);
                if (!restaurant) return null;
                
                return (
                  <motion.div
                    key={dish.id}
                    initial={{ opacity: 0, y: 80 }}
                    whileInView={{ opacity: 1, y: 0 }}
                    transition={{ duration: 1, delay: 0.1 * index }}
                    viewport={{ once: true }}
                    whileHover={{ y: -15, scale: 1.03 }}
                    className="group"
                  >
                    <DishCard
                      dish={dish}
                      restaurant={restaurant}
                      index={index}
                    />
                  </motion.div>
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
                <span className="text-3xl">🍽️</span>
              </motion.div>
              <h3 className="text-3xl font-bold text-white mb-6">Блюда не найдены</h3>
              <p className="text-white/60 mb-8 text-lg">
                Попробуйте изменить параметры поиска или фильтры
              </p>
              <motion.button
                whileHover={{ scale: 1.05, y: -2 }}
                whileTap={{ scale: 0.95 }}
                onClick={() => {
                  setSearchQuery('');
                  setSelectedCategory('all');
                  setSelectedRestaurant('all');
                  clearFilters();
                }}
                className="px-8 py-4 bg-gradient-to-r from-orange-600 to-red-600 text-white font-semibold rounded-xl hover:shadow-lg transition-all duration-300 text-lg"
              >
                Сбросить фильтры
              </motion.button>
            </motion.div>
          )}
        </div>
      </section>
    </main>
  );
} 