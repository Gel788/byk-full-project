'use client';

import { motion } from 'framer-motion';
import { Star, Clock, MapPin, ArrowRight } from 'lucide-react';
import { Restaurant } from '../types';
import { getBrandColors } from '../lib/data';
import { formatPrice } from '../lib/utils';
import Link from 'next/link';

interface RestaurantCardProps {
  restaurant: Restaurant;
  index?: number;
}

export default function RestaurantCard({ restaurant, index = 0 }: RestaurantCardProps) {
  // Проверяем, что ресторан существует
  if (!restaurant) {
    return null;
  }

  const colors = getBrandColors(restaurant.brand);

  return (
    <motion.div
      initial={{ opacity: 0, y: 30 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.6, delay: index * 0.1 }}
      whileHover={{ y: -10, scale: 1.02 }}
      className="group relative overflow-hidden rounded-2xl sm:rounded-3xl bg-gradient-to-br from-gray-800/50 to-gray-900/50 border border-gray-700/50 hover:border-orange-500/50 transition-all duration-500 backdrop-blur-sm"
    >
      {/* Фоновое изображение */}
      <div className="relative h-48 sm:h-56 md:h-64 overflow-hidden">
        <div 
          className="w-full h-full bg-gradient-to-br from-gray-700 to-gray-800"
          style={{
            background: `linear-gradient(135deg, ${colors.primary}20, ${colors.secondary}20)`
          }}
        />
        
        {/* Статус открытия */}
        <div className="absolute top-3 sm:top-4 right-3 sm:right-4">
          <span className={`px-2 py-1 sm:px-3 sm:py-1 rounded-full text-xs sm:text-sm font-semibold ${
            restaurant.isOpen 
              ? 'bg-green-600 text-white' 
              : 'bg-red-600 text-white'
          }`}>
            {restaurant.isOpen ? '🟢 Открыто' : '🔴 Закрыто'}
          </span>
        </div>

        {/* Рейтинг */}
        <div className="absolute top-3 sm:top-4 left-3 sm:left-4 bg-gray-800/90 backdrop-blur-sm px-2 py-1 sm:px-3 sm:py-1 rounded-full border border-gray-600/50">
          <div className="flex items-center space-x-1 sm:space-x-2">
            <Star className="w-3 h-3 sm:w-4 sm:h-4 text-yellow-500 fill-current" />
            <span className="text-white font-bold text-sm sm:text-base">{restaurant.rating}</span>
          </div>
        </div>
      </div>

      {/* Контент */}
      <div className="p-4 sm:p-6">
        {/* Название и бренд */}
        <div className="mb-4 sm:mb-6">
          <h3 className="text-lg sm:text-xl font-bold text-white mb-2 sm:mb-3">{restaurant.name}</h3>
          <p className="text-white/70 text-xs sm:text-sm leading-relaxed">{restaurant.description}</p>
        </div>

        {/* Информация */}
        <div className="space-y-2 sm:space-y-3 mb-4 sm:mb-6">
          <div className="flex items-center space-x-2 sm:space-x-3 text-white/70">
            <MapPin className="w-3 h-3 sm:w-4 sm:h-4 flex-shrink-0" />
            <span className="text-xs sm:text-sm">{restaurant.address}</span>
          </div>
          
          <div className="flex items-center space-x-2 sm:space-x-3 text-white/70">
            <Clock className="w-3 h-3 sm:w-4 sm:h-4 flex-shrink-0" />
            <span className="text-xs sm:text-sm">{restaurant.deliveryTime}</span>
          </div>
          
          <div className="flex items-center space-x-2 sm:space-x-3 text-white/70">
            <span className="text-xs sm:text-sm">
              Мин. заказ: <span className="text-white font-bold">{formatPrice(restaurant.minOrder)} ₽</span>
            </span>
          </div>
        </div>

        {/* Кнопки действий */}
        <div className="space-y-2 sm:space-y-3">
          <Link href={`/restaurant/${restaurant.id}`}>
            <motion.button
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
              className="w-full bg-gradient-to-r from-orange-600 to-red-600 hover:from-orange-700 hover:to-red-700 text-white font-semibold py-2.5 sm:py-3 px-4 rounded-xl sm:rounded-2xl transition-all duration-300 flex items-center justify-center space-x-2 text-sm sm:text-base"
            >
              <span>Открыть меню</span>
              <ArrowRight className="w-3 h-3 sm:w-4 sm:h-4" />
            </motion.button>
          </Link>

          <Link href={`/reservation/${restaurant.id}`}>
            <motion.button
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
              className="w-full border-2 border-gray-600/50 text-white font-semibold py-2.5 sm:py-3 px-4 rounded-xl sm:rounded-2xl hover:bg-gray-700/50 hover:border-gray-500 transition-all duration-300 text-sm sm:text-base"
            >
              📅 Забронировать
            </motion.button>
          </Link>
        </div>
      </div>

      {/* Брендовый индикатор */}
      <div 
        className="absolute top-0 left-0 w-1 sm:w-2 h-full"
        style={{ backgroundColor: colors.accent }}
      />
    </motion.div>
  );
} 