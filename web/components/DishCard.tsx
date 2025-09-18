'use client';

import { motion } from 'framer-motion';
import { Plus, Star, Clock, Flame } from 'lucide-react';
import { Dish, Restaurant } from '../lib/data';

interface DishCardProps {
  dish: Dish;
  restaurant?: Restaurant;
  index?: number;
}

export default function DishCard({ dish, restaurant, index = 0 }: DishCardProps) {
  const colors = restaurant ? {
    primary: restaurant.brand === 'THE БЫК' ? '#8B4513' : 
              restaurant.brand === 'THE ПИВО' ? '#FFD700' : 
              restaurant.brand === 'MOSCA' ? '#DC143C' : '#d4af37',
    secondary: restaurant.brand === 'THE БЫК' ? '#A0522D' : 
               restaurant.brand === 'THE ПИВО' ? '#FFA500' : 
               restaurant.brand === 'MOSCA' ? '#B22222' : '#f4d03f'
  } : {
    primary: '#d4af37',
    secondary: '#f4d03f'
  };

  const formatPrice = (price: number) => {
    return price.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ' ');
  };

  return (
    <motion.div
      initial={{ opacity: 0, y: 30 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.6, delay: index * 0.1 }}
      whileHover={{ y: -10, scale: 1.03 }}
      className="group relative overflow-hidden rounded-3xl premium-card"
    >
      {/* Брендинг индикатор */}
      <div 
        className="absolute top-0 left-0 w-2 h-full z-10"
        style={{ background: `linear-gradient(135deg, ${colors.primary}, ${colors.secondary})` }}
      />

      {/* Изображение */}
      <div className="relative h-48 overflow-hidden">
        <div 
          className="w-full h-full bg-gradient-to-br from-gray-800 to-gray-900 flex items-center justify-center"
          style={{
            background: `linear-gradient(135deg, ${colors.primary}20, ${colors.secondary}20)`
          }}
        >
          <div className="text-center">
            <div 
              className="w-12 h-12 mx-auto mb-3 rounded-full flex items-center justify-center text-lg font-bold"
              style={{
                background: `linear-gradient(135deg, ${colors.primary}, ${colors.secondary})`,
                color: restaurant?.brand === 'THE ПИВО' ? '#1a1a1a' : 'white'
              }}
            >
              {dish.name.charAt(0)}
            </div>
            <h3 className="text-lg font-bold text-white">{dish.name}</h3>
          </div>
        </div>

        {/* Цена */}
        <div className="absolute top-4 left-4">
          <div className="px-3 py-1 bg-black/50 backdrop-blur-sm rounded-full">
            <span className="text-[#d4af37] font-bold text-sm">{formatPrice(dish.price)} ₽</span>
          </div>
        </div>

        {/* Статус доступности */}
        {!dish.available && (
          <div className="absolute inset-0 bg-black/60 flex items-center justify-center">
            <span className="text-white font-semibold text-lg">Недоступно</span>
          </div>
        )}

        {/* Кнопка добавления в корзину */}
        {dish.available && (
          <motion.button
            whileHover={{ scale: 1.1 }}
            whileTap={{ scale: 0.9 }}
            className="absolute bottom-4 right-4 w-10 h-10 bg-gradient-to-r from-[#d4af37] to-[#f4d03f] rounded-full flex items-center justify-center shadow-lg hover:shadow-[#d4af37]/25 transition-all duration-300"
          >
            <Plus className="w-5 h-5 text-[#1a1a1a]" />
          </motion.button>
        )}
      </div>

      {/* Контент */}
      <div className="p-6">
        <div className="flex justify-between items-start mb-3">
          <h3 className="text-lg font-bold text-white leading-tight">{dish.name}</h3>
          <div className="text-right">
            <div className="text-[#d4af37] font-bold text-lg">{formatPrice(dish.price)} ₽</div>
            <div className="text-white/60 text-sm">{dish.weight}г</div>
          </div>
        </div>

        <p className="text-white/70 text-sm mb-4 line-clamp-2">{dish.description}</p>

        {/* Характеристики */}
        <div className="flex items-center space-x-4 mb-4">
          <div className="flex items-center space-x-1">
            <Star className="w-3 h-3 text-[#d4af37] fill-current" />
            <span className="text-white/60 text-xs">{dish.rating}</span>
          </div>
          <div className="flex items-center space-x-1">
            <Clock className="w-3 h-3 text-[#d4af37]" />
            <span className="text-white/60 text-xs">{dish.cookingTime} мин</span>
          </div>
          <div className="flex items-center space-x-1">
            <Flame className="w-3 h-3 text-[#ff6b35]" />
            <span className="text-white/60 text-xs">{dish.calories} ккал</span>
          </div>
        </div>

        {/* Категория и аллергены */}
        <div className="flex flex-wrap gap-2">
          <span 
            className="px-2 py-1 rounded-full text-xs font-semibold"
            style={{
              background: `linear-gradient(135deg, ${colors.primary}20, ${colors.secondary}20)`,
              color: colors.primary
            }}
          >
            {dish.category}
          </span>
          {dish.allergens.map((allergen, index) => (
            <span 
              key={index}
              className="px-2 py-1 bg-red-500/20 text-red-400 rounded-full text-xs font-semibold"
            >
              {allergen}
            </span>
          ))}
        </div>
      </div>

      {/* Hover эффект */}
      <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
    </motion.div>
  );
} 