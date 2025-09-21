'use client';

import React, { useState, useEffect } from 'react';
import { motion, useScroll, useTransform } from 'framer-motion';
import { Search, MapPin, Clock, Star, ArrowRight, Building2, Users, TrendingUp } from 'lucide-react';
import { useRouter } from 'next/navigation';
import { useRestaurants } from '../../lib/hooks/useRestaurants';
import { useBrands } from '../../lib/hooks/useBrands';
import { useCities } from '../../lib/hooks/useCities';

export default function RestaurantsPage() {
  const router = useRouter();
  const { restaurants, isLoading, error, refetch } = useRestaurants();
  const { brands, isLoading: brandsLoading, error: brandsError } = useBrands();
  const { cities, isLoading: citiesLoading, error: citiesError } = useCities();
  const [selectedBrand, setSelectedBrand] = useState('all');
  const [selectedCity, setSelectedCity] = useState('all');
  const [searchQuery, setSearchQuery] = useState('');

  // Отладочная информация
  React.useEffect(() => {
    if (restaurants && restaurants.length > 0) {
      console.log('Loaded restaurants:', restaurants.map(r => ({ name: r.name, brand: r.brand })));
      console.log('Available brands:', [...new Set(restaurants.map(r => r.brand))]);
    }
  }, [restaurants]);
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

  // Получаем бренд по ID для фильтрации
  const getBrandNameById = (brandId: string) => {
    const brand = brands.find(b => b.id === brandId);
    return brand ? brand.name.toLowerCase() : '';
  };

  // Получаем город по ID для фильтрации
  const getCityNameById = (cityId: string) => {
    const city = cities.find(c => c.id === cityId);
    return city ? city.name.toLowerCase() : '';
  };

  const filteredRestaurants = (restaurants || []).filter(restaurant => {
    let matchesBrand = true;
    let matchesCity = true;
    
    if (selectedBrand !== 'all') {
      // Сравниваем по названию бренда
      const selectedBrandName = getBrandNameById(selectedBrand);
      const restaurantBrandName = restaurant.brand.toLowerCase();
      matchesBrand = restaurantBrandName.includes(selectedBrandName) || 
                    selectedBrandName.includes(restaurantBrandName);
    }

    if (selectedCity !== 'all') {
      // Сравниваем по названию города
      const selectedCityName = getCityNameById(selectedCity);
      const restaurantCityName = restaurant.address.toLowerCase();
      matchesCity = restaurantCityName.includes(selectedCityName) || 
                   selectedCityName.includes(restaurantCityName);
    }
    
    const matchesSearch = restaurant.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
                         restaurant.description.toLowerCase().includes(searchQuery.toLowerCase());
    
    // Отладочная информация
    if (process.env.NODE_ENV === 'development') {
      console.log('Filtering restaurant:', {
        name: restaurant.name,
        brand: restaurant.brand,
        address: restaurant.address,
        selectedBrand,
        selectedCity,
        selectedBrandName: getBrandNameById(selectedBrand),
        selectedCityName: getCityNameById(selectedCity),
        matchesBrand,
        matchesCity,
        matchesSearch
      });
    }
    
    return matchesBrand && matchesCity && matchesSearch;
  });

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
        {[...Array(15)].map((_, i) => {
          // Фиксированные значения для предотвращения проблем с гидратацией
          const positions = [
            { left: 10, top: 20 },
            { left: 85, top: 15 },
            { left: 25, top: 60 },
            { left: 70, top: 80 },
            { left: 15, top: 85 },
            { left: 90, top: 50 },
            { left: 50, top: 10 },
            { left: 30, top: 40 },
            { left: 80, top: 25 },
            { left: 60, top: 70 },
            { left: 20, top: 30 },
            { left: 75, top: 60 },
            { left: 40, top: 85 },
            { left: 95, top: 35 },
            { left: 5, top: 75 }
          ];
          
          const pos = positions[i % positions.length];
          const delay = i * 0.2;
          const duration = 4 + (i % 3);
          
          return (
            <motion.div
              key={`floating-bg-${i}`}
              animate={{
                y: [0, -30, 0],
                x: [0, (i % 2 === 0 ? 10 : -10), 0],
                opacity: [0, 0.3, 0],
              }}
              transition={{
                duration,
                repeat: Infinity,
                delay,
              }}
              className="absolute w-2 h-2 bg-orange-400/20 rounded-full"
              style={{
                left: `${pos.left}%`,
                top: `${pos.top}%`,
              }}
            />
          );
        })}
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
              🏆 Лучшие рестораны
            </span>
          </motion.div>

          <motion.h1
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 1, delay: 0.2 }}
            className="text-5xl sm:text-6xl lg:text-7xl font-bold text-white mb-8"
          >
            Наши <span className="bg-gradient-to-r from-white via-orange-400 to-white bg-clip-text text-transparent">рестораны</span>
          </motion.h1>
          
          <motion.p
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 1, delay: 0.4 }}
            className="text-xl text-white/70 mb-12 max-w-3xl mx-auto leading-relaxed"
          >
            Выбирайте из лучших ресторанов с уникальной атмосферой и премиальным качеством. 
            Каждый ресторан предлагает свой неповторимый вкус и стиль.
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
                placeholder="Поиск ресторанов..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full pl-14 pr-4 py-4 bg-white/10 backdrop-blur-sm border border-white/20 rounded-2xl text-white placeholder-white/50 focus:outline-none focus:ring-2 focus:ring-orange-500 focus:border-transparent text-lg"
              />
            </div>

            {/* Фильтры по городам */}
            <div className="flex flex-wrap justify-center gap-4 mb-6">
              {/* Кнопка "Все города" */}
              <motion.button
                whileHover={{ scale: 1.05, y: -2 }}
                whileTap={{ scale: 0.95 }}
                onClick={() => {
                  console.log('Selected city: all');
                  setSelectedCity('all');
                }}
                className={`px-6 py-3 rounded-xl font-semibold transition-all duration-300 ${
                  selectedCity === 'all'
                    ? 'bg-gradient-to-r from-blue-600 to-purple-600 text-white shadow-lg'
                    : 'text-white/70 hover:text-white bg-white/10 hover:bg-white/20 border border-white/20'
                }`}
              >
                <MapPin className="w-4 h-4 inline mr-2" />
                Все города ({restaurants?.length || 0})
              </motion.button>
              
              {/* Динамические города */}
              {citiesLoading ? (
                <div className="px-6 py-3 text-white/50">Загрузка городов...</div>
              ) : citiesError ? (
                <div className="px-6 py-3 text-red-400">Ошибка загрузки городов</div>
              ) : (
                cities.map((city) => {
                  // Подсчитываем количество ресторанов для каждого города
                  const cityName = city.name.toLowerCase();
                  const count = restaurants?.filter(r => {
                    const restaurantCity = r.address.toLowerCase();
                    return restaurantCity.includes(cityName) || cityName.includes(restaurantCity);
                  }).length || 0;
                  
                  return (
                    <motion.button
                      key={city.id}
                      whileHover={{ scale: 1.05, y: -2 }}
                      whileTap={{ scale: 0.95 }}
                      onClick={() => {
                        console.log('Selected city:', city.id, city.name);
                        setSelectedCity(city.id);
                      }}
                      className={`px-6 py-3 rounded-xl font-semibold transition-all duration-300 ${
                        selectedCity === city.id
                          ? 'bg-gradient-to-r from-blue-600 to-purple-600 text-white shadow-lg'
                          : 'text-white/70 hover:text-white bg-white/10 hover:bg-white/20 border border-white/20'
                      }`}
                    >
                      <MapPin className="w-4 h-4 inline mr-2" />
                      {city.name} ({count})
                    </motion.button>
                  );
                })
              )}
            </div>

            {/* Фильтры по брендам */}
            <div className="flex flex-wrap justify-center gap-4">
              {/* Кнопка "Все" */}
              <motion.button
                whileHover={{ scale: 1.05, y: -2 }}
                whileTap={{ scale: 0.95 }}
                onClick={() => {
                  console.log('Selected brand: all');
                  setSelectedBrand('all');
                }}
                className={`px-6 py-3 rounded-xl font-semibold transition-all duration-300 ${
                  selectedBrand === 'all'
                    ? 'bg-gradient-to-r from-orange-600 to-red-600 text-white shadow-lg'
                    : 'text-white/70 hover:text-white bg-white/10 hover:bg-white/20 border border-white/20'
                }`}
              >
                Все ({restaurants?.length || 0})
              </motion.button>
              
              {/* Динамические бренды */}
              {brandsLoading ? (
                <div className="px-6 py-3 text-white/50">Загрузка брендов...</div>
              ) : brandsError ? (
                <div className="px-6 py-3 text-red-400">Ошибка загрузки брендов</div>
              ) : (
                brands.map((brand) => {
                  // Подсчитываем количество ресторанов для каждого бренда
                  const brandName = brand.name.toLowerCase();
                  const count = restaurants?.filter(r => {
                    const restaurantBrand = r.brand.toLowerCase();
                    return restaurantBrand.includes(brandName) || brandName.includes(restaurantBrand);
                  }).length || 0;
                  
                  return (
                    <motion.button
                      key={brand.id}
                      whileHover={{ scale: 1.05, y: -2 }}
                      whileTap={{ scale: 0.95 }}
                      onClick={() => {
                        console.log('Selected brand:', brand.id, brand.name);
                        setSelectedBrand(brand.id);
                      }}
                      className={`px-6 py-3 rounded-xl font-semibold transition-all duration-300 ${
                        selectedBrand === brand.id
                          ? 'bg-gradient-to-r from-orange-600 to-red-600 text-white shadow-lg'
                          : 'text-white/70 hover:text-white bg-white/10 hover:bg-white/20 border border-white/20'
                      }`}
                      style={{
                        borderColor: brand.color !== '#000000' ? brand.color : undefined
                      }}
                    >
                      {brand.name} ({count})
                    </motion.button>
                  );
                })
              )}
            </div>
          </motion.div>
        </div>
      </section>

      {/* Статистика */}
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
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
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
                <Building2 className="w-10 h-10 text-white" />
              </motion.div>
              <div className="text-4xl font-bold text-white mb-2 group-hover:text-orange-400 transition-colors">
                {restaurants.length}
              </div>
              <div className="text-white/60">Ресторанов</div>
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
                <Users className="w-10 h-10 text-white" />
              </motion.div>
              <div className="text-4xl font-bold text-white mb-2 group-hover:text-blue-400 transition-colors">
                15K+
              </div>
              <div className="text-white/60">Довольных клиентов</div>
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
                <TrendingUp className="w-10 h-10 text-white" />
              </motion.div>
              <div className="text-4xl font-bold text-white mb-2 group-hover:text-green-400 transition-colors">
                4.9
              </div>
              <div className="text-white/60">Средний рейтинг</div>
            </motion.div>
          </div>
        </div>
      </motion.section>

      {/* Сетка ресторанов */}
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
          {/* Состояние загрузки */}
          {isLoading && (
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              className="flex flex-col items-center justify-center py-20"
            >
              <motion.div
                animate={{ rotate: 360 }}
                transition={{ duration: 2, repeat: Infinity, ease: "linear" }}
                className="w-16 h-16 border-4 border-orange-500/30 border-t-orange-500 rounded-full mb-6"
              />
              <h3 className="text-2xl font-bold text-white mb-4">Загружаем рестораны...</h3>
              <p className="text-white/60">Пожалуйста, подождите</p>
            </motion.div>
          )}

          {/* Состояние ошибки */}
          {error && (
            <motion.div
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              className="text-center py-20"
            >
              <motion.div 
                whileHover={{ scale: 1.1, rotate: 5 }}
                className="w-24 h-24 mx-auto mb-8 rounded-full bg-gradient-to-br from-red-500 to-red-600 flex items-center justify-center shadow-2xl"
              >
                <span className="text-3xl">⚠️</span>
              </motion.div>
              <h3 className="text-3xl font-bold text-white mb-6">Ошибка загрузки</h3>
              <p className="text-white/60 mb-8 text-lg max-w-md mx-auto">
                {error}
              </p>
              <motion.button
                whileHover={{ scale: 1.05, y: -2 }}
                whileTap={{ scale: 0.95 }}
                onClick={refetch}
                className="px-8 py-4 bg-gradient-to-r from-orange-600 to-red-600 text-white font-semibold rounded-xl hover:shadow-lg transition-all duration-300 text-lg"
              >
                Попробовать снова
              </motion.button>
            </motion.div>
          )}

          {/* Успешная загрузка */}
          {!isLoading && !error && filteredRestaurants.length > 0 && (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-10">
              {filteredRestaurants.map((restaurant, index) => (
                <motion.div
                  key={restaurant.id}
                  initial={{ opacity: 0, y: 80 }}
                  whileInView={{ opacity: 1, y: 0 }}
                  transition={{ duration: 1, delay: 0.1 * index }}
                  viewport={{ once: true }}
                  whileHover={{ y: -15, scale: 1.02 }}
                  onClick={() => {
                    console.log('Клик по карточке ресторана:', restaurant.id);
                    try {
                      router.push(`/restaurant/${restaurant.id}`);
                    } catch (error) {
                      console.error('Ошибка при переходе к ресторану:', error);
                    }
                  }}
                  className="group cursor-pointer relative overflow-hidden rounded-3xl bg-gradient-to-br from-gray-800/50 to-gray-900/50 border border-gray-700/50 hover:border-orange-500/50 transition-all duration-500 backdrop-blur-sm"
                  style={{
                    pointerEvents: 'auto',
                    userSelect: 'none'
                  }}
                >
                  {/* Изображение */}
                  <div className="relative h-64 overflow-hidden">
                    {restaurant.image && restaurant.image !== '/images/restaurants/default.jpg' ? (
                      <img
                        src={restaurant.image}
                        alt={restaurant.name}
                        className="w-full h-full object-cover"
                        onError={(e) => {
                          // Если изображение не загрузилось, показываем градиент
                          const target = e.target as HTMLImageElement;
                          target.style.display = 'none';
                          const fallback = target.nextElementSibling as HTMLElement;
                          if (fallback) fallback.classList.remove('hidden');
                        }}
                      />
                    ) : null}
                    <div 
                      className={`w-full h-full bg-gradient-to-br from-gray-800 to-gray-900 ${restaurant.image ? 'hidden' : ''}`}
                      style={{
                        background: restaurant.brand === 'theByk' 
                          ? 'linear-gradient(135deg, #8B451320, #D2691E20)'
                          : restaurant.brand === 'thePivo'
                          ? 'linear-gradient(135deg, #FF6B3520, #F7931E20)'
                          : 'linear-gradient(135deg, #2C3E5020, #34495E20)'
                      }}
                    />
                    
                    <motion.div 
                      className="absolute inset-0 opacity-20"
                      animate={{
                        background: [
                          restaurant.brand === 'theByk' 
                            ? 'linear-gradient(135deg, #8B4513, #FFD700)'
                            : restaurant.brand === 'thePivo'
                            ? 'linear-gradient(135deg, #FF6B35, #FFD700)'
                            : 'linear-gradient(135deg, #2C3E50, #E74C3C)',
                          restaurant.brand === 'theByk' 
                            ? 'linear-gradient(135deg, #FFD700, #8B4513)'
                            : restaurant.brand === 'thePivo'
                            ? 'linear-gradient(135deg, #FFD700, #FF6B35)'
                            : 'linear-gradient(135deg, #E74C3C, #2C3E50)',
                          restaurant.brand === 'theByk' 
                            ? 'linear-gradient(135deg, #8B4513, #FFD700)'
                            : restaurant.brand === 'thePivo'
                            ? 'linear-gradient(135deg, #FF6B35, #FFD700)'
                            : 'linear-gradient(135deg, #2C3E50, #E74C3C)'
                        ]
                      }}
                      transition={{ duration: 4, repeat: Infinity }}
                    />
                    
                    {/* Status Badge */}
                    <div className="absolute top-4 right-4">
                      <span className="px-4 py-2 rounded-full text-sm font-semibold bg-green-500/20 text-green-400 border border-green-500/30 backdrop-blur-sm">
                        {restaurant.isOpen ? 'Открыто' : 'Закрыто'}
                      </span>
                    </div>
                    
                    {/* Rating */}
                    <div className="absolute top-4 left-4 flex items-center space-x-1 bg-black/50 backdrop-blur-sm px-3 py-2 rounded-full">
                      <Star className="w-4 h-4 text-yellow-400 fill-current" />
                      <span className="text-white font-semibold text-sm">{restaurant.rating}</span>
                    </div>
                  </div>

                  {/* Контент */}
                  <div className="p-8">
                    <div className="mb-6">
                      <h3 className="text-2xl font-bold text-white mb-3 group-hover:text-orange-400 transition-colors">
                        {restaurant.name}
                      </h3>
                      <p className="text-white/70 text-base leading-relaxed">
                        {restaurant.description}
                      </p>
                    </div>

                    <div className="space-y-4 mb-8">
                      <div className="flex items-center space-x-3 text-white/60">
                        <MapPin className="w-5 h-5" />
                        <span className="text-sm">{restaurant.address}</span>
                      </div>
                      <div className="flex items-center space-x-3 text-white/60">
                        <Clock className="w-5 h-5" />
                        <span className="text-sm">{restaurant.deliveryTime}</span>
                      </div>
                      <div className="text-sm text-white/60">
                        Мин. заказ: <span className="text-white font-semibold">{restaurant.minOrder} ₽</span>
                      </div>
                    </div>

                    <div className="space-y-4">
                      <motion.button 
                        whileHover={{ scale: 1.02 }}
                        whileTap={{ scale: 0.98 }}
                        onClick={(e) => {
                          e.stopPropagation();
                          console.log('Клик по кнопке "Открыть меню" для ресторана:', restaurant.id);
                          try {
                            router.push(`/restaurant/${restaurant.id}`);
                          } catch (error) {
                            console.error('Ошибка при переходе к ресторану:', error);
                          }
                        }}
                        className="w-full group/btn relative overflow-hidden rounded-xl py-4 px-6 text-white font-semibold transition-all duration-300 cursor-pointer text-lg"
                        style={{
                          background: restaurant.brand === 'theByk' 
                            ? 'linear-gradient(135deg, #8B4513, #FFD700)'
                            : restaurant.brand === 'thePivo'
                            ? 'linear-gradient(135deg, #FF6B35, #FFD700)'
                            : 'linear-gradient(135deg, #2C3E50, #E74C3C)'
                        }}
                      >
                        <span className="relative z-10 flex items-center justify-center space-x-3">
                          <span>Открыть меню</span>
                          <ArrowRight className="w-5 h-5 group-hover/btn:translate-x-1 transition-transform" />
                        </span>
                        <motion.div 
                          className="absolute inset-0 opacity-0 group-hover/btn:opacity-100 transition-opacity duration-300"
                          style={{
                            background: restaurant.brand === 'theByk' 
                              ? 'linear-gradient(135deg, #D2691E, #8B4513)'
                              : restaurant.brand === 'thePivo'
                              ? 'linear-gradient(135deg, #F7931E, #FF6B35)'
                              : 'linear-gradient(135deg, #34495E, #2C3E50)'
                          }}
                        />
                      </motion.button>
                      
                      <motion.button 
                        whileHover={{ scale: 1.02 }}
                        whileTap={{ scale: 0.98 }}
                        onClick={(e) => {
                          e.stopPropagation();
                          console.log('Клик по кнопке "Забронировать столик" для ресторана:', restaurant.id);
                          try {
                            router.push(`/reservation/${restaurant.id}`);
                          } catch (error) {
                            console.error('Ошибка при переходе к бронированию:', error);
                          }
                        }}
                        className="w-full group/btn relative overflow-hidden rounded-xl py-4 px-6 text-white font-semibold transition-all duration-300 border-2 cursor-pointer text-lg"
                        style={{
                          borderColor: restaurant.brand === 'theByk' 
                            ? '#FFD700'
                            : restaurant.brand === 'thePivo'
                            ? '#FFD700'
                            : '#E74C3C',
                          color: restaurant.brand === 'theByk' 
                            ? '#FFD700'
                            : restaurant.brand === 'thePivo'
                            ? '#FFD700'
                            : '#E74C3C'
                        }}
                      >
                        <span className="relative z-10 flex items-center justify-center space-x-3">
                          <span>Забронировать столик</span>
                          <ArrowRight className="w-5 h-5 group-hover/btn:translate-x-1 transition-transform" />
                        </span>
                      </motion.button>
                    </div>
                  </div>

                  {/* Hover эффект */}
                  <motion.div
                    className="absolute inset-0 bg-gradient-to-r from-orange-500/5 to-red-500/5 opacity-0 group-hover:opacity-100 transition-opacity duration-300"
                    initial={false}
                  />
                </motion.div>
              ))}
            </div>
          )}

          {/* Пустое состояние */}
          {!isLoading && !error && filteredRestaurants.length === 0 && (
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
                <span className="text-3xl">🏪</span>
              </motion.div>
              <h3 className="text-3xl font-bold text-white mb-6">Рестораны не найдены</h3>
              <p className="text-white/60 mb-8 text-lg">
                Попробуйте изменить параметры поиска или фильтры
              </p>
                     <motion.button
                       whileHover={{ scale: 1.05, y: -2 }}
                       whileTap={{ scale: 0.95 }}
                       onClick={() => {
                         setSearchQuery('');
                         setSelectedBrand('all');
                         setSelectedCity('all');
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