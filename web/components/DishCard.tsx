'use client';

import { motion } from 'framer-motion';
import { Plus, Minus, Star, Clock, Flame } from 'lucide-react';
import { Dish, Restaurant } from '../types';
import { useCart } from '../lib/contexts/CartContext';
import { getBrandColors } from '../lib/data';
import { formatPrice } from '../lib/utils';

interface DishCardProps {
  dish: Dish;
  restaurant?: Restaurant;
  index?: number;
}

export default function DishCard({ dish, restaurant, index = 0 }: DishCardProps) {
  const { addToCart, updateQuantity, items } = useCart();
  const colors = restaurant ? getBrandColors(restaurant.brand) : { primary: '#ff6b35', secondary: '#f7931e', accent: '#ffd700' };
  
  const cartItem = items.find(item => item.dish.id === dish.id);
  const quantity = cartItem?.quantity || 0;

  const handleAddToCart = () => {
    if (restaurant) {
      addToCart(dish, restaurant);
    }
  };

  const handleUpdateQuantity = (increment: boolean) => {
    updateQuantity(dish.id, increment);
  };

  return (
    <motion.div
      initial={{ opacity: 0, y: 30 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.6, delay: index * 0.1 }}
      whileHover={{ y: -10, scale: 1.03 }}
      className="group relative overflow-hidden rounded-2xl sm:rounded-3xl bg-gradient-to-br from-gray-800/50 to-gray-900/50 border border-gray-700/50 hover:border-orange-500/50 transition-all duration-500 backdrop-blur-sm"
    >
      {/* Изображение блюда */}
      <div className="relative h-40 sm:h-48 overflow-hidden">
        <div 
          className="w-full h-full bg-gradient-to-br from-gray-700 to-gray-800"
          style={{
            background: `linear-gradient(135deg, ${colors.primary}20, ${colors.secondary}20)`
          }}
        />
        
        {/* Статус доступности */}
        {!dish.isAvailable && (
          <div className="absolute inset-0 bg-black/60 flex items-center justify-center">
            <span className="text-white font-semibold text-sm sm:text-base">Недоступно</span>
          </div>
        )}

        {/* Кнопка добавления в корзину */}
        <div className="absolute bottom-3 sm:bottom-4 right-3 sm:right-4">
          {quantity === 0 ? (
            <motion.button
              whileHover={{ scale: 1.1 }}
              whileTap={{ scale: 0.9 }}
              onClick={handleAddToCart}
              disabled={!dish.isAvailable}
              className={`w-8 h-8 sm:w-10 sm:h-10 rounded-full flex items-center justify-center transition-all duration-300 ${
                dish.isAvailable 
                  ? 'bg-gradient-to-r from-orange-600 to-red-600 hover:from-orange-700 hover:to-red-700 shadow-lg' 
                  : 'bg-gray-500 cursor-not-allowed'
              }`}
            >
              <Plus className="w-4 h-4 sm:w-5 sm:h-5 text-white" />
            </motion.button>
          ) : (
            <div className="flex items-center space-x-1 sm:space-x-2 bg-gray-800/90 backdrop-blur-sm rounded-full px-2 sm:px-3 py-1 border border-gray-600/50">
              <motion.button
                whileHover={{ scale: 1.1 }}
                whileTap={{ scale: 0.9 }}
                onClick={() => handleUpdateQuantity(false)}
                className="w-5 h-5 sm:w-6 sm:h-6 rounded-full bg-gray-600 flex items-center justify-center"
              >
                <Minus className="w-2.5 h-2.5 sm:w-3 sm:h-3 text-white" />
              </motion.button>
              
              <span className="text-white font-semibold min-w-[16px] sm:min-w-[20px] text-center text-sm sm:text-base">
                {quantity}
              </span>
              
              <motion.button
                whileHover={{ scale: 1.1 }}
                whileTap={{ scale: 0.9 }}
                onClick={() => handleUpdateQuantity(true)}
                className="w-5 h-5 sm:w-6 sm:h-6 rounded-full bg-gray-600 flex items-center justify-center"
              >
                <Plus className="w-2.5 h-2.5 sm:w-3 sm:h-3 text-white" />
              </motion.button>
            </div>
          )}
        </div>
      </div>

      {/* Контент */}
      <div className="p-4 sm:p-6">
        {/* Название и цена */}
        <div className="flex items-start justify-between mb-2 sm:mb-3">
          <h3 className="text-base sm:text-lg font-bold text-white flex-1 mr-3 sm:mr-4 leading-tight">{dish.name}</h3>
          <span className="text-lg sm:text-xl font-bold text-white whitespace-nowrap">
            {formatPrice(dish.price)} ₽
          </span>
        </div>

        {/* Описание */}
        <p className="text-white/70 text-xs sm:text-sm mb-3 sm:mb-4 line-clamp-2 leading-relaxed">{dish.description}</p>

        {/* Характеристики */}
        <div className="flex items-center space-x-3 sm:space-x-4 mb-3 sm:mb-4">
          <div className="flex items-center space-x-1 text-white/60">
            <Flame className="w-3 h-3 sm:w-4 sm:h-4" />
            <span className="text-xs">{dish.calories} ккал</span>
          </div>
          
          <div className="flex items-center space-x-1 text-white/60">
            <Clock className="w-3 h-3 sm:w-4 sm:h-4" />
            <span className="text-xs">{dish.preparationTime} мин</span>
          </div>
        </div>

        {/* Категория и аллергены */}
        <div className="flex items-center justify-between flex-wrap gap-2">
          <span 
            className="px-2 py-1 sm:px-3 sm:py-1 rounded-full text-xs font-semibold"
            style={{
              backgroundColor: `${colors.primary}20`,
              color: colors.accent,
              border: `1px solid ${colors.primary}40`
            }}
          >
            {dish.category}
          </span>

          {/* Аллергены */}
          {dish.allergens.length > 0 && (
            <div className="flex items-center space-x-1">
              {dish.allergens.slice(0, 2).map((allergen, idx) => (
                <span 
                  key={idx}
                  className="px-1.5 py-0.5 sm:px-2 sm:py-1 rounded text-xs bg-red-500/20 text-red-400 border border-red-500/30"
                >
                  {allergen}
                </span>
              ))}
              {dish.allergens.length > 2 && (
                <span className="text-xs text-white/60">+{dish.allergens.length - 2}</span>
              )}
            </div>
          )}
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