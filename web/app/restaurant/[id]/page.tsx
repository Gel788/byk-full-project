'use client';

import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { ArrowLeft, MapPin, Clock, Star, Phone, Plus, Minus, ShoppingCart } from 'lucide-react';
import { useRouter } from 'next/navigation';
import { useRestaurants } from '../../../lib/contexts/RestaurantContext';
import { useCart } from '../../../lib/contexts/CartContext';
import { dishes } from '../../../lib/data';

const categories = [
  { id: 'all', name: 'Все' },
  { id: 'Стейки', name: 'Стейки' },
  { id: 'Салаты', name: 'Салаты' },
  { id: 'Паста', name: 'Паста' },
  { id: 'Пицца', name: 'Пицца' },
  { id: 'Горячие блюда', name: 'Горячие блюда' },
  { id: 'Закуски', name: 'Закуски' },
  { id: 'Напитки', name: 'Напитки' }
];

export default function RestaurantDetailPage({ params }: { params: { id: string } }) {
  const router = useRouter();
  const { restaurants } = useRestaurants();
  const { addToCart, removeFromCart, getItemQuantity } = useCart();
  const [selectedCategory, setSelectedCategory] = useState('all');
  const [searchQuery, setSearchQuery] = useState('');

  const restaurant = restaurants.find(r => r.id === params.id);
  const restaurantDishes = dishes.filter(dish => dish.restaurantId === params.id);

  // Проверяем, что данные загружены и ресторан найден
  if (!restaurants.length || !restaurant) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-black via-gray-900 to-black flex items-center justify-center">
        <div className="text-center">
          <h1 className="text-2xl font-bold text-white mb-4">
            {!restaurants.length ? 'Загрузка...' : 'Ресторан не найден'}
          </h1>
          <button
            onClick={() => router.back()}
            className="px-6 py-3 bg-gradient-to-r from-primary-500 to-accent-500 text-white rounded-full"
          >
            Назад
          </button>
        </div>
      </div>
    );
  }

  const filteredDishes = restaurantDishes.filter(dish => {
    const matchesCategory = selectedCategory === 'all' || dish.category === selectedCategory;
    const matchesSearch = dish.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
                         dish.description.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesCategory && matchesSearch;
  });

  const cartItems = filteredDishes.filter(dish => getItemQuantity(dish.id) > 0);
  const totalItems = cartItems.reduce((sum, item) => sum + getItemQuantity(item.id), 0);
  const totalPrice = cartItems.reduce((sum, item) => sum + (item.price * getItemQuantity(item.id)), 0);

  return (
    <div className="min-h-screen bg-gradient-to-br from-black via-gray-900 to-black">
      {/* Header */}
      <div className="relative">
        <div className="absolute inset-0 bg-gradient-to-b from-black/50 to-transparent z-10"></div>
        <div className="relative z-20 pt-20 pb-12 px-4 sm:px-6 lg:px-8">
          <div className="max-w-7xl mx-auto">
            {/* Back Button */}
            <motion.button
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              onClick={() => router.back()}
              className="flex items-center space-x-2 text-white/70 hover:text-white mb-8 transition-colors"
            >
              <ArrowLeft className="w-5 h-5" />
              <span>Назад к ресторанам</span>
            </motion.button>

            {/* Restaurant Info */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              className="text-center mb-8"
            >
              <h1 className="text-4xl sm:text-5xl lg:text-6xl font-bold text-white mb-4">
                {restaurant.name}
              </h1>
              <p className="text-lg text-white/70 max-w-2xl mx-auto mb-6">
                {restaurant.description}
              </p>
              
              <div className="flex flex-wrap justify-center gap-6 text-white/60 mb-8">
                <div className="flex items-center space-x-2">
                  <MapPin className="w-4 h-4" />
                  <span>{restaurant.address}</span>
                </div>
                <div className="flex items-center space-x-2">
                  <Clock className="w-4 h-4" />
                  <span>{restaurant.deliveryTime}</span>
                </div>
                <div className="flex items-center space-x-2">
                  <Star className="w-4 h-4 text-yellow-400 fill-current" />
                  <span>{restaurant.rating}</span>
                </div>
                <div className="flex items-center space-x-2">
                  <Phone className="w-4 h-4" />
                  <span>{restaurant.phone}</span>
                </div>
              </div>

              {/* Reservation Button */}
              <motion.button
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.4 }}
                onClick={() => router.push(`/reservation/${restaurant.id}`)}
                className="group relative overflow-hidden rounded-xl py-4 px-8 text-white font-semibold transition-all duration-300 border-2 mb-8"
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
                  <span className="text-lg">📅</span>
                  <span>Забронировать столик</span>
                </span>
                <div 
                  className="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity duration-300"
                  style={{
                    background: restaurant.brand === 'theByk' 
                      ? 'linear-gradient(135deg, #FFD70020, #8B451320)'
                      : restaurant.brand === 'thePivo'
                      ? 'linear-gradient(135deg, #FFD70020, #FF6B3520)'
                      : 'linear-gradient(135deg, #E74C3C20, #2C3E5020)'
                  }}
                ></div>
              </motion.button>
            </motion.div>

            {/* Search */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.2 }}
              className="max-w-md mx-auto mb-8"
            >
              <input
                type="text"
                placeholder="Поиск блюд..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-full text-white placeholder-white/50 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent backdrop-blur-sm"
              />
            </motion.div>

            {/* Categories */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.3 }}
              className="flex flex-wrap justify-center gap-3 mb-12"
            >
              {categories.map((category) => (
                <button
                  key={category.id}
                  onClick={() => setSelectedCategory(category.id)}
                  className={`px-4 py-2 rounded-full text-sm font-medium transition-all duration-300 ${
                    selectedCategory === category.id
                      ? 'bg-gradient-to-r from-primary-500 to-accent-500 text-white shadow-lg'
                      : 'bg-white/10 text-white/70 hover:bg-white/20 hover:text-white'
                  }`}
                >
                  {category.name}
                </button>
              ))}
            </motion.div>
          </div>
        </div>
      </div>

      {/* Menu */}
      <div className="px-4 sm:px-6 lg:px-8 pb-32">
        <div className="max-w-7xl mx-auto">
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.4 }}
            className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6"
          >
            {filteredDishes.map((dish, index) => (
              <motion.div
                key={dish.id}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.1 * index }}
                className="group relative overflow-hidden rounded-2xl glass-effect card-hover"
              >
                <div className="relative h-48 overflow-hidden">
                  <div 
                    className="w-full h-full bg-gradient-to-br from-gray-800 to-gray-900"
                    style={{
                      background: restaurant.brand === 'theByk' 
                        ? 'linear-gradient(135deg, #8B451320, #D2691E20)'
                        : restaurant.brand === 'thePivo'
                        ? 'linear-gradient(135deg, #FF6B3520, #F7931E20)'
                        : 'linear-gradient(135deg, #2C3E5020, #34495E20)'
                    }}
                  ></div>
                  <div 
                    className="absolute inset-0 opacity-20"
                    style={{
                      background: restaurant.brand === 'theByk' 
                        ? 'linear-gradient(135deg, #8B4513, #FFD700)'
                        : restaurant.brand === 'thePivo'
                        ? 'linear-gradient(135deg, #FF6B35, #FFD700)'
                        : 'linear-gradient(135deg, #2C3E50, #E74C3C)'
                    }}
                  ></div>
                </div>

                <div className="p-6">
                  <div className="flex items-start justify-between mb-3">
                    <h3 className="text-lg font-bold text-white flex-1 mr-4">{dish.name}</h3>
                    <span className="text-xl font-bold text-white whitespace-nowrap">{dish.price} ₽</span>
                  </div>
                  
                  <p className="text-white/70 text-sm mb-4 line-clamp-2">{dish.description}</p>
                  
                  <div className="flex items-center space-x-4 mb-4">
                    <div className="flex items-center space-x-1 text-white/60">
                      <span className="text-xs">🔥 {dish.calories} ккал</span>
                    </div>
                    <div className="flex items-center space-x-1 text-white/60">
                      <span className="text-xs">⏱️ {dish.preparationTime} мин</span>
                    </div>
                  </div>

                  <div className="flex items-center justify-between mb-4">
                    <span 
                      className="px-3 py-1 rounded-full text-xs font-semibold"
                      style={{
                        backgroundColor: restaurant.brand === 'theByk' 
                          ? '#8B451320'
                          : restaurant.brand === 'thePivo'
                          ? '#FF6B3520'
                          : '#2C3E5020',
                        color: restaurant.brand === 'theByk' 
                          ? '#FFD700'
                          : restaurant.brand === 'thePivo'
                          ? '#FFD700'
                          : '#E74C3C',
                        border: `1px solid ${
                          restaurant.brand === 'theByk' 
                            ? '#8B451340'
                            : restaurant.brand === 'thePivo'
                            ? '#FF6B3540'
                            : '#2C3E5040'
                        }`
                      }}
                    >
                      {dish.category}
                    </span>
                    
                    {dish.allergens.length > 0 && (
                      <div className="flex items-center space-x-1">
                        {dish.allergens.map((allergen, idx) => (
                          <span key={idx} className="px-2 py-1 rounded text-xs bg-red-500/20 text-red-400 border border-red-500/30">
                            {allergen}
                          </span>
                        ))}
                      </div>
                    )}
                  </div>

                  {/* Quantity Controls */}
                  <div className="flex items-center justify-between">
                    {getItemQuantity(dish.id) > 0 ? (
                      <div className="flex items-center space-x-3">
                        <button
                          onClick={() => removeFromCart(dish.id)}
                          className="w-8 h-8 rounded-full flex items-center justify-center bg-red-500/20 text-red-400 hover:bg-red-500/30 transition-colors"
                        >
                          <Minus className="w-4 h-4" />
                        </button>
                        <span className="text-white font-semibold min-w-[20px] text-center">
                          {getItemQuantity(dish.id)}
                        </span>
                        <button
                          onClick={() => addToCart(dish, restaurant)}
                          className="w-8 h-8 rounded-full flex items-center justify-center bg-green-500/20 text-green-400 hover:bg-green-500/30 transition-colors"
                        >
                          <Plus className="w-4 h-4" />
                        </button>
                      </div>
                    ) : (
                      <button
                        onClick={() => addToCart(dish, restaurant)}
                        className="w-full group/btn relative overflow-hidden rounded-xl py-3 px-4 text-white font-semibold transition-all duration-300"
                        style={{
                          background: restaurant.brand === 'theByk' 
                            ? 'linear-gradient(135deg, #8B4513, #FFD700)'
                            : restaurant.brand === 'thePivo'
                            ? 'linear-gradient(135deg, #FF6B35, #FFD700)'
                            : 'linear-gradient(135deg, #2C3E50, #E74C3C)'
                        }}
                      >
                        <span className="relative z-10 flex items-center justify-center space-x-2">
                          <Plus className="w-4 h-4" />
                          <span>Добавить</span>
                        </span>
                      </button>
                    )}
                  </div>
                </div>

                {/* Brand Color Bar */}
                <div 
                  className="absolute top-0 left-0 w-1 h-full"
                  style={{
                    backgroundColor: restaurant.brand === 'theByk' 
                      ? '#FFD700'
                      : restaurant.brand === 'thePivo'
                      ? '#FFD700'
                      : '#E74C3C'
                  }}
                ></div>
              </motion.div>
            ))}
          </motion.div>

          {filteredDishes.length === 0 && (
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              className="text-center py-20"
            >
              <p className="text-white/50 text-lg">Блюда не найдены</p>
            </motion.div>
          )}
        </div>
      </div>

      {/* Floating Cart Button */}
      {totalItems > 0 && (
        <motion.div
          initial={{ opacity: 0, y: 100 }}
          animate={{ opacity: 1, y: 0 }}
          className="fixed bottom-6 right-6 z-50"
        >
          <button
            onClick={() => router.push('/cart')}
            className="group relative overflow-hidden rounded-full p-4 shadow-2xl transition-all duration-300"
            style={{
              background: restaurant.brand === 'theByk' 
                ? 'linear-gradient(135deg, #8B4513, #FFD700)'
                : restaurant.brand === 'thePivo'
                ? 'linear-gradient(135deg, #FF6B35, #FFD700)'
                : 'linear-gradient(135deg, #2C3E50, #E74C3C)'
            }}
          >
            <div className="relative z-10 flex items-center space-x-3">
              <ShoppingCart className="w-6 h-6 text-white" />
              <div className="text-left">
                <div className="text-white font-semibold">{totalItems} товар(ов)</div>
                <div className="text-white/80 text-sm">{totalPrice} ₽</div>
              </div>
            </div>
            <div className="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity duration-300 bg-white/20"></div>
          </button>
        </motion.div>
      )}
    </div>
  );
} 