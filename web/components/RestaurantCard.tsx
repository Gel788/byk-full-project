'use client';

import { motion } from 'framer-motion';
import { Star, Clock, MapPin, ArrowRight } from 'lucide-react';
import Link from 'next/link';
import { Restaurant } from '../lib/data';

interface RestaurantCardProps {
  restaurant: Restaurant;
  index?: number;
}

export default function RestaurantCard({ restaurant, index = 0 }: RestaurantCardProps) {
  const getBrandColors = (brand: string) => {
    switch (brand) {
      case 'THE БЫК':
        return {
          primary: '#8B4513',
          secondary: '#A0522D',
          accent: '#d4af37'
        };
      case 'THE ПИВО':
        return {
          primary: '#FFD700',
          secondary: '#FFA500',
          accent: '#d4af37'
        };
      case 'MOSCA':
        return {
          primary: '#DC143C',
          secondary: '#B22222',
          accent: '#d4af37'
        };
      default:
        return {
          primary: '#d4af37',
          secondary: '#f4d03f',
          accent: '#ff6b35'
        };
    }
  };

  const colors = getBrandColors(restaurant.brand);

  return (
    <motion.div
      initial={{ opacity: 0, y: 30 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.6, delay: index * 0.1 }}
      whileHover={{ y: -10, scale: 1.02 }}
      className="group relative overflow-hidden rounded-3xl premium-card"
    >
      {/* Брендинг индикатор */}
      <div 
        className="absolute top-0 left-0 w-2 h-full z-10"
        style={{ background: `linear-gradient(135deg, ${colors.primary}, ${colors.secondary})` }}
      />

      {/* Изображение */}
      <div className="relative h-64 overflow-hidden">
        <div 
          className="w-full h-full bg-gradient-to-br from-gray-800 to-gray-900 flex items-center justify-center"
          style={{
            background: `linear-gradient(135deg, ${colors.primary}20, ${colors.secondary}20)`
          }}
        >
          <div className="text-center">
            <div 
              className="w-16 h-16 mx-auto mb-4 rounded-full flex items-center justify-center text-2xl font-bold"
              style={{
                background: `linear-gradient(135deg, ${colors.primary}, ${colors.secondary})`,
                color: restaurant.brand === 'THE ПИВО' ? '#1a1a1a' : 'white'
              }}
            >
              {restaurant.name.charAt(0)}
            </div>
            <h3 className="text-xl font-bold text-white">{restaurant.name}</h3>
          </div>
        </div>

        {/* Статус и рейтинг */}
        <div className="absolute top-4 right-4 flex flex-col gap-2">
          <div 
            className="px-3 py-1 rounded-full text-xs font-semibold"
            style={{
              background: `linear-gradient(135deg, ${colors.primary}, ${colors.secondary})`,
              color: restaurant.brand === 'THE ПИВО' ? '#1a1a1a' : 'white'
            }}
          >
            {restaurant.status}
          </div>
          <div className="flex items-center space-x-1 px-2 py-1 bg-black/50 backdrop-blur-sm rounded-full">
            <Star className="w-3 h-3 text-[#d4af37] fill-current" />
            <span className="text-white text-xs font-semibold">{restaurant.rating}</span>
          </div>
        </div>
      </div>

      {/* Контент */}
      <div className="p-6">
        <h3 className="text-xl font-bold text-white mb-3 leading-tight">{restaurant.name}</h3>
        <p className="text-white/70 text-sm mb-4 line-clamp-2">{restaurant.description}</p>

        {/* Информация */}
        <div className="space-y-3 mb-6">
          <div className="flex items-center space-x-3">
            <Clock className="w-4 h-4 text-[#d4af37]" />
            <span className="text-white/60 text-sm">{restaurant.deliveryTime} мин</span>
          </div>
          <div className="flex items-center space-x-3">
            <MapPin className="w-4 h-4 text-[#d4af37]" />
            <span className="text-white/60 text-sm">{restaurant.location}</span>
          </div>
        </div>

        {/* Кнопки */}
        <div className="flex space-x-3">
          <Link href={`/restaurant/${restaurant.id}`} className="flex-1">
            <motion.button
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
              className="w-full bg-gradient-to-r from-[#d4af37] to-[#f4d03f] text-[#1a1a1a] font-semibold py-3 rounded-2xl transition-all duration-300 shadow-lg hover:shadow-[#d4af37]/25 flex items-center justify-center space-x-2"
            >
              <span>Меню</span>
              <ArrowRight className="w-4 h-4" />
            </motion.button>
          </Link>
          
          <Link href={`/reservation/${restaurant.id}`}>
            <motion.button
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
              className="px-4 py-3 border-2 border-[#d4af37]/50 text-[#d4af37] font-semibold rounded-2xl hover:border-[#d4af37] hover:bg-[#d4af37]/10 transition-all duration-300"
            >
              Стол
            </motion.button>
          </Link>
        </div>
      </div>

      {/* Hover эффект */}
      <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
    </motion.div>
  );
} 