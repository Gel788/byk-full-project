'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, Trash2, ArrowRight, Check } from 'lucide-react';
import { useCart } from '../lib/contexts/CartContext';
import { useRestaurant } from '../lib/contexts/RestaurantContext';
import { getBrandColors } from '../lib/data';

interface CartViewProps {
  isOpen: boolean;
  onClose: () => void;
}

export default function CartView({ isOpen, onClose }: CartViewProps) {
  const { items, totalAmount, hasItems, updateQuantity, removeFromCart, clearCart, groupedCartItems } = useCart();
  const { getRestaurantById } = useRestaurant();
  const [isCheckingOut, setIsCheckingOut] = useState(false);
  const [checkoutComplete, setCheckoutComplete] = useState(false);

  const groupedItems = groupedCartItems();
  const freeDeliveryThreshold = 1500;
  const progressToFreeDelivery = Math.min(totalAmount / freeDeliveryThreshold, 1.0);

  const handleCheckout = async () => {
    setIsCheckingOut(true);
    
    // Имитация процесса оформления заказа
    await new Promise(resolve => setTimeout(resolve, 2000));
    
    setCheckoutComplete(true);
    
    setTimeout(() => {
      clearCart();
      setIsCheckingOut(false);
      setCheckoutComplete(false);
      onClose();
    }, 1500);
  };

  const totalCalories = groupedItems.reduce((sum, item) => sum + (item.dish.calories * item.quantity), 0);

  return (
    <AnimatePresence>
      {isOpen && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          className="fixed inset-0 z-50 flex items-end sm:items-center justify-center"
        >
          {/* Затемнение */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="absolute inset-0 bg-black/50 backdrop-blur-sm"
            onClick={onClose}
          />

          {/* Модальное окно */}
          <motion.div
            initial={{ opacity: 0, y: 100, scale: 0.9 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: 100, scale: 0.9 }}
            transition={{ type: "spring", damping: 25, stiffness: 300 }}
            className="relative w-full max-w-md max-h-[90vh] bg-gradient-to-br from-gray-900 to-black rounded-t-3xl sm:rounded-3xl overflow-hidden shadow-2xl"
          >
            {/* Заголовок */}
            <div className="flex items-center justify-between p-6 border-b border-white/10">
              <h2 className="text-xl font-bold text-white">Корзина</h2>
              <button
                onClick={onClose}
                className="p-2 rounded-full bg-white/10 hover:bg-white/20 transition-colors"
              >
                <X className="w-5 h-5 text-white" />
              </button>
            </div>

            {/* Контент */}
            <div className="flex-1 overflow-y-auto">
              {hasItems ? (
                <div className="p-6 space-y-6">
                  {/* Прогресс бесплатной доставки */}
                  {totalAmount < freeDeliveryThreshold && (
                    <div className="space-y-3">
                      <div className="flex items-center justify-between text-sm">
                        <span className="text-white/70">
                          До бесплатной доставки: {freeDeliveryThreshold - totalAmount} ₽
                        </span>
                        <span className="text-white font-semibold">
                          {totalAmount} / {freeDeliveryThreshold} ₽
                        </span>
                      </div>
                      <div className="w-full bg-white/10 rounded-full h-2">
                        <motion.div
                          initial={{ width: 0 }}
                          animate={{ width: `${progressToFreeDelivery * 100}%` }}
                          className="h-2 bg-gradient-to-r from-primary-500 to-accent-500 rounded-full"
                        />
                      </div>
                    </div>
                  )}

                  {/* Статистика заказа */}
                  <div className="grid grid-cols-3 gap-4 p-4 glass-effect rounded-2xl">
                    <div className="text-center">
                      <div className="text-2xl font-bold text-white">{groupedItems.length}</div>
                      <div className="text-xs text-white/60">Позиций</div>
                    </div>
                    <div className="text-center">
                      <div className="text-2xl font-bold text-white">{totalCalories}</div>
                      <div className="text-xs text-white/60">Ккал</div>
                    </div>
                    <div className="text-center">
                      <div className="text-2xl font-bold text-white">{totalAmount}</div>
                      <div className="text-xs text-white/60">₽</div>
                    </div>
                  </div>

                  {/* Список товаров */}
                  <div className="space-y-4">
                    {groupedItems.map((item) => {
                      const restaurant = item.restaurant;
                      const colors = restaurant ? getBrandColors(restaurant.brand) : null;
                      
                      return (
                        <motion.div
                          key={item.dish.id}
                          layout
                          initial={{ opacity: 0, y: 20 }}
                          animate={{ opacity: 1, y: 0 }}
                          exit={{ opacity: 0, y: -20 }}
                          className="flex items-center space-x-4 p-4 glass-effect rounded-2xl"
                        >
                          {/* Изображение */}
                          <div 
                            className="w-16 h-16 rounded-xl overflow-hidden flex-shrink-0"
                            style={{
                              background: colors 
                                ? `linear-gradient(135deg, ${colors.primary}20, ${colors.secondary}20)`
                                : 'linear-gradient(135deg, #374151, #1f2937)'
                            }}
                          />

                          {/* Информация */}
                          <div className="flex-1 min-w-0">
                            <h3 className="font-semibold text-white truncate">{item.dish.name}</h3>
                            <p className="text-sm text-white/60">{item.dish.price} ₽</p>
                          </div>

                          {/* Управление количеством */}
                          <div className="flex items-center space-x-3">
                            <motion.button
                              whileHover={{ scale: 1.1 }}
                              whileTap={{ scale: 0.9 }}
                              onClick={() => updateQuantity(item.dish.id, false)}
                              className="w-8 h-8 rounded-full bg-white/10 hover:bg-white/20 flex items-center justify-center"
                            >
                              <span className="text-white font-bold">-</span>
                            </motion.button>
                            
                            <span className="text-white font-semibold min-w-[20px] text-center">
                              {item.quantity}
                            </span>
                            
                            <motion.button
                              whileHover={{ scale: 1.1 }}
                              whileTap={{ scale: 0.9 }}
                              onClick={() => updateQuantity(item.dish.id, true)}
                              className="w-8 h-8 rounded-full bg-white/10 hover:bg-white/20 flex items-center justify-center"
                            >
                              <span className="text-white font-bold">+</span>
                            </motion.button>
                          </div>
                        </motion.div>
                      );
                    })}
                  </div>
                </div>
              ) : (
                <div className="p-12 text-center">
                  <div className="w-20 h-20 mx-auto mb-6 rounded-full bg-gradient-to-r from-primary-500 to-accent-500 flex items-center justify-center">
                    <span className="text-2xl">🛒</span>
                  </div>
                  <h3 className="text-xl font-bold text-white mb-2">Корзина пуста</h3>
                  <p className="text-white/60">Добавьте блюда из меню ресторанов</p>
                </div>
              )}
            </div>

            {/* Итоговая секция */}
            {hasItems && (
              <div className="p-6 border-t border-white/10 space-y-4">
                {/* Детализация */}
                <div className="space-y-2">
                  <div className="flex justify-between text-white/70">
                    <span>Стоимость блюд</span>
                    <span>{totalAmount} ₽</span>
                  </div>
                  <div className="flex justify-between text-green-400">
                    <span>Доставка</span>
                    <span>Бесплатно</span>
                  </div>
                  <div className="flex justify-between text-xl font-bold text-white pt-2 border-t border-white/10">
                    <span>Итого</span>
                    <span>{totalAmount} ₽</span>
                  </div>
                </div>

                {/* Кнопка оформления */}
                <motion.button
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.98 }}
                  onClick={handleCheckout}
                  disabled={isCheckingOut}
                  className="w-full relative overflow-hidden rounded-2xl py-4 px-6 text-white font-semibold transition-all duration-300"
                  style={{
                    background: isCheckingOut || checkoutComplete
                      ? 'linear-gradient(135deg, #10b981, #059669)'
                      : 'linear-gradient(135deg, #f2751e, #eab308)'
                  }}
                >
                  <div className="flex items-center justify-center space-x-2">
                    {checkoutComplete ? (
                      <>
                        <Check className="w-5 h-5" />
                        <span>Заказ оформлен!</span>
                      </>
                    ) : isCheckingOut ? (
                      <>
                        <motion.div
                          animate={{ rotate: 360 }}
                          transition={{ duration: 1, repeat: Infinity, ease: "linear" }}
                          className="w-5 h-5 border-2 border-white border-t-transparent rounded-full"
                        />
                        <span>Оформляем заказ...</span>
                      </>
                    ) : (
                      <>
                        <span>Оформить заказ</span>
                        <ArrowRight className="w-5 h-5" />
                      </>
                    )}
                  </div>
                </motion.button>

                {/* Кнопка очистки */}
                <button
                  onClick={clearCart}
                  className="w-full py-3 px-6 text-red-400 hover:text-red-300 transition-colors"
                >
                  Очистить корзину
                </button>
              </div>
            )}
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
} 