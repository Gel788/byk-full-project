'use client';

import { useState, useEffect } from 'react';
import { motion, useScroll, useTransform } from 'framer-motion';
import { ArrowLeft, Trash2, Plus, Minus, MapPin, Clock, CreditCard, Truck, Store, ShoppingCart, Package, Zap } from 'lucide-react';
import { useRouter } from 'next/navigation';
import { useCart } from '../../lib/contexts/CartContext';
import { useRestaurants } from '../../lib/contexts/RestaurantContext';

const deliveryMethods = [
  { id: 'delivery', name: 'Доставка', icon: Truck, description: 'Доставка курьером', time: '30-45 мин', fee: 200, color: 'from-blue-500 to-purple-500' },
  { id: 'pickup', name: 'Самовывоз', icon: Store, description: 'Забрать из ресторана', time: '15-20 мин', fee: 0, color: 'from-green-500 to-emerald-500' }
];

const paymentMethods = [
  { id: 'card', name: 'Банковская карта', icon: CreditCard, color: 'from-orange-500 to-red-500' },
  { id: 'cash', name: 'Наличными', icon: CreditCard, color: 'from-green-500 to-blue-500' }
];

export default function CartPage() {
  const router = useRouter();
  const { items, removeFromCart, updateQuantity, clearCart } = useCart();
  const { restaurants } = useRestaurants();
  
  const [deliveryMethod, setDeliveryMethod] = useState('delivery');
  const [paymentMethod, setPaymentMethod] = useState('card');
  const [address, setAddress] = useState('');
  const [phone, setPhone] = useState('');
  const [name, setName] = useState('');
  const [comment, setComment] = useState('');
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

  const subtotal = items.reduce((sum, item) => sum + (item.dish.price * item.quantity), 0);
  const deliveryFee = deliveryMethod === 'delivery' ? 200 : 0;
  const total = subtotal + deliveryFee;

  const selectedMethod = deliveryMethods.find(m => m.id === deliveryMethod);

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('ru-RU').format(price);
  };

  const handleCheckout = () => {
    if (!name || !phone || (deliveryMethod === 'delivery' && !address)) {
      alert('Пожалуйста, заполните все обязательные поля');
      return;
    }
    
    // Здесь будет логика оформления заказа
    alert('Заказ оформлен! Спасибо за заказ.');
    clearCart();
    router.push('/delivery/success');
  };

  if (items.length === 0) {
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

        <div className="relative z-10 pt-24 px-4 sm:px-6 lg:px-8">
          <div className="max-w-4xl mx-auto">
            <motion.button
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              onClick={() => router.back()}
              className="flex items-center space-x-2 text-white/70 hover:text-white mb-8 transition-colors"
            >
              <ArrowLeft className="w-5 h-5" />
              <span>Назад</span>
            </motion.button>

            <motion.div
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              className="text-center py-20"
            >
              <motion.div 
                whileHover={{ scale: 1.1, rotate: 5 }}
                className="w-24 h-24 mx-auto mb-8 rounded-full bg-gradient-to-br from-orange-500 to-red-500 flex items-center justify-center shadow-2xl"
              >
                <span className="text-3xl">🛒</span>
              </motion.div>
              <h1 className="text-4xl font-bold text-white mb-6">Корзина пуста</h1>
              <p className="text-xl text-white/60 mb-8 max-w-2xl mx-auto leading-relaxed">
                Добавьте блюда из меню ресторанов, чтобы оформить заказ
              </p>
              <motion.button
                whileHover={{ scale: 1.05, y: -2 }}
                whileTap={{ scale: 0.95 }}
                onClick={() => router.push('/restaurants')}
                className="px-8 py-4 bg-gradient-to-r from-orange-600 to-red-600 text-white font-semibold rounded-xl hover:shadow-lg transition-all duration-300 text-lg"
              >
                Перейти к ресторанам
              </motion.button>
            </motion.div>
          </div>
        </div>
      </main>
    );
  }

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

        <div className="relative z-10 max-w-7xl mx-auto">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 1 }}
            className="text-center mb-12"
          >
            <span className="inline-block px-6 py-3 bg-orange-600/20 text-orange-400 rounded-full text-sm font-semibold border border-orange-600/30 backdrop-blur-sm mb-6">
              🛒 Ваша корзина
            </span>
            <h1 className="text-5xl sm:text-6xl font-bold text-white mb-6">
              Оформление <span className="bg-gradient-to-r from-white via-orange-400 to-white bg-clip-text text-transparent">заказа</span>
            </h1>
            <p className="text-xl text-white/70 max-w-3xl mx-auto leading-relaxed">
              Проверьте состав заказа и заполните данные для доставки
            </p>
          </motion.div>

          {/* Статистика корзины */}
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 1, delay: 0.2 }}
            className="grid grid-cols-1 md:grid-cols-3 gap-8 mb-12"
          >
            <motion.div 
              whileHover={{ scale: 1.05, y: -5 }}
              className="group text-center p-8 bg-gradient-to-br from-gray-800/50 to-gray-900/50 rounded-3xl border border-gray-700/50 hover:border-orange-500/50 transition-all duration-500 backdrop-blur-sm"
            >
              <motion.div 
                whileHover={{ scale: 1.1, rotate: 5 }}
                className="w-20 h-20 bg-gradient-to-br from-orange-500 to-red-500 rounded-full flex items-center justify-center mx-auto mb-6 group-hover:scale-110 transition-transform shadow-2xl"
              >
                <ShoppingCart className="w-10 h-10 text-white" />
              </motion.div>
              <div className="text-4xl font-bold text-white mb-2 group-hover:text-orange-400 transition-colors">
                {items.length}
              </div>
              <div className="text-white/60">Позиций в корзине</div>
            </motion.div>

            <motion.div 
              whileHover={{ scale: 1.05, y: -5 }}
              className="group text-center p-8 bg-gradient-to-br from-gray-800/50 to-gray-900/50 rounded-3xl border border-gray-700/50 hover:border-green-500/50 transition-all duration-500 backdrop-blur-sm"
            >
              <motion.div 
                whileHover={{ scale: 1.1, rotate: -5 }}
                className="w-20 h-20 bg-gradient-to-br from-green-500 to-emerald-500 rounded-full flex items-center justify-center mx-auto mb-6 group-hover:scale-110 transition-transform shadow-2xl"
              >
                <Package className="w-10 h-10 text-white" />
              </motion.div>
              <div className="text-4xl font-bold text-white mb-2 group-hover:text-green-400 transition-colors">
                {formatPrice(subtotal)} ₽
              </div>
              <div className="text-white/60">Сумма заказа</div>
            </motion.div>

            <motion.div 
              whileHover={{ scale: 1.05, y: -5 }}
              className="group text-center p-8 bg-gradient-to-br from-gray-800/50 to-gray-900/50 rounded-3xl border border-gray-700/50 hover:border-blue-500/50 transition-all duration-500 backdrop-blur-sm"
            >
              <motion.div 
                whileHover={{ scale: 1.1, rotate: 5 }}
                className="w-20 h-20 bg-gradient-to-br from-blue-500 to-purple-500 rounded-full flex items-center justify-center mx-auto mb-6 group-hover:scale-110 transition-transform shadow-2xl"
              >
                <Zap className="w-10 h-10 text-white" />
              </motion.div>
              <div className="text-4xl font-bold text-white mb-2 group-hover:text-blue-400 transition-colors">
                {selectedMethod?.time}
              </div>
              <div className="text-white/60">Время доставки</div>
            </motion.div>
          </motion.div>
        </div>
      </section>

      {/* Основной контент */}
      <section className="relative py-12 px-4 sm:px-6 lg:px-8 overflow-hidden">
        <div className="max-w-7xl mx-auto">
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-12">
            {/* Товары в корзине */}
            <div className="lg:col-span-2">
              <motion.div
                initial={{ opacity: 0, y: 30 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 1, delay: 0.4 }}
                className="space-y-6"
              >
                <div className="flex items-center justify-between mb-8">
                  <h2 className="text-3xl font-bold text-white">Товары в корзине</h2>
                  <motion.button
                    whileHover={{ scale: 1.05, y: -2 }}
                    whileTap={{ scale: 0.95 }}
                    onClick={clearCart}
                    className="flex items-center space-x-2 px-4 py-2 rounded-xl bg-red-500/20 text-red-400 hover:bg-red-500/30 transition-all duration-300 backdrop-blur-sm border border-red-500/30"
                  >
                    <Trash2 className="w-4 h-4" />
                    <span>Очистить</span>
                  </motion.button>
                </div>

                {items.map((item, index) => {
                  const restaurant = restaurants.find(r => r.id === item.restaurantId);
                  return (
                    <motion.div
                      key={item.id}
                      initial={{ opacity: 0, x: -20 }}
                      animate={{ opacity: 1, x: 0 }}
                      transition={{ delay: 0.1 * index }}
                      whileHover={{ scale: 1.02, y: -2 }}
                      className="group relative overflow-hidden rounded-3xl bg-gradient-to-br from-gray-800/50 to-gray-900/50 border border-gray-700/50 hover:border-orange-500/50 transition-all duration-500 backdrop-blur-sm p-6"
                    >
                      <div className="flex items-start space-x-6">
                        <div className="relative w-24 h-24 rounded-2xl overflow-hidden flex-shrink-0">
                          <div 
                            className="w-full h-full bg-gradient-to-br from-gray-800 to-gray-900"
                            style={{
                              background: restaurant?.brand === 'theByk' 
                                ? 'linear-gradient(135deg, #8B451320, #D2691E20)'
                                : restaurant?.brand === 'thePivo'
                                ? 'linear-gradient(135deg, #FF6B3520, #F7931E20)'
                                : 'linear-gradient(135deg, #2C3E5020, #34495E20)'
                            }}
                          />
                        </div>

                        <div className="flex-1 min-w-0">
                          <div className="flex items-start justify-between mb-4">
                            <div>
                              <h3 className="text-xl font-bold text-white mb-2">{item.dish.name}</h3>
                              <p className="text-white/60 text-sm">{restaurant?.name}</p>
                            </div>
                            <span className="text-2xl font-bold text-white">{formatPrice(item.dish.price)} ₽</span>
                          </div>

                          <div className="flex items-center justify-between">
                            <div className="flex items-center space-x-4">
                              <motion.button
                                whileHover={{ scale: 1.1 }}
                                whileTap={{ scale: 0.9 }}
                                onClick={() => updateQuantity(item.dish.id, false)}
                                className="w-10 h-10 rounded-full flex items-center justify-center bg-white/10 hover:bg-white/20 transition-all duration-300 border border-white/20"
                              >
                                <Minus className="w-5 h-5 text-white" />
                              </motion.button>
                              <span className="text-white font-bold text-lg min-w-[30px] text-center">
                                {item.quantity}
                              </span>
                              <motion.button
                                whileHover={{ scale: 1.1 }}
                                whileTap={{ scale: 0.9 }}
                                onClick={() => updateQuantity(item.dish.id, true)}
                                className="w-10 h-10 rounded-full flex items-center justify-center bg-white/10 hover:bg-white/20 transition-all duration-300 border border-white/20"
                              >
                                <Plus className="w-5 h-5 text-white" />
                              </motion.button>
                            </div>
                            <motion.button
                              whileHover={{ scale: 1.1 }}
                              whileTap={{ scale: 0.9 }}
                              onClick={() => removeFromCart(item.dish.id)}
                              className="text-red-400 hover:text-red-300 transition-colors"
                            >
                              <Trash2 className="w-6 h-6" />
                            </motion.button>
                          </div>
                        </div>
                      </div>

                      {/* Брендовый индикатор */}
                      <div 
                        className="absolute top-0 left-0 w-1 h-full"
                        style={{
                          backgroundColor: restaurant?.brand === 'theByk' 
                            ? '#FFD700'
                            : restaurant?.brand === 'thePivo'
                            ? '#FFD700'
                            : '#E74C3C'
                        }}
                      />
                    </motion.div>
                  );
                })}
              </motion.div>
            </div>

            {/* Форма оформления */}
            <motion.div
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 1, delay: 0.6 }}
              className="space-y-8"
            >
              {/* Способ доставки */}
              <div className="bg-gradient-to-br from-gray-800/50 to-gray-900/50 rounded-3xl p-8 border border-gray-700/50 backdrop-blur-sm">
                <h3 className="text-2xl font-bold text-white mb-6 flex items-center space-x-3">
                  <Truck className="w-6 h-6 text-blue-400" />
                  <span>Способ получения</span>
                </h3>
                <div className="space-y-4">
                  {deliveryMethods.map((method) => {
                    const Icon = method.icon;
                    return (
                      <motion.button
                        key={method.id}
                        whileHover={{ scale: 1.02, y: -2 }}
                        whileTap={{ scale: 0.98 }}
                        onClick={() => setDeliveryMethod(method.id)}
                        className={`w-full p-6 rounded-2xl border-2 transition-all duration-300 ${
                          deliveryMethod === method.id
                            ? `border-orange-500 bg-gradient-to-br ${method.color}20`
                            : 'border-white/20 bg-white/5 hover:border-white/40'
                        }`}
                      >
                        <div className="flex items-center space-x-4">
                          <div className={`w-12 h-12 rounded-full bg-gradient-to-br ${method.color} flex items-center justify-center`}>
                            <Icon className="w-6 h-6 text-white" />
                          </div>
                          <div className="text-left flex-1">
                            <div className="text-white font-semibold text-lg">{method.name}</div>
                            <div className="text-white/60 text-sm">{method.description}</div>
                            <div className="flex items-center space-x-4 text-white/50 text-sm mt-2">
                              <span className="flex items-center space-x-2">
                                <Clock className="w-4 h-4" />
                                <span>{method.time}</span>
                              </span>
                              {method.fee > 0 && (
                                <span>Стоимость: {method.fee} ₽</span>
                              )}
                            </div>
                          </div>
                        </div>
                      </motion.button>
                    );
                  })}
                </div>
              </div>

              {/* Контактная информация */}
              <div className="bg-gradient-to-br from-gray-800/50 to-gray-900/50 rounded-3xl p-8 border border-gray-700/50 backdrop-blur-sm">
                <h3 className="text-2xl font-bold text-white mb-6 flex items-center space-x-3">
                  <MapPin className="w-6 h-6 text-green-400" />
                  <span>Контактная информация</span>
                </h3>
                <div className="space-y-6">
                  <div>
                    <label className="block text-white/70 text-sm mb-2">Имя *</label>
                    <input
                      type="text"
                      value={name}
                      onChange={(e) => setName(e.target.value)}
                      className="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-xl text-white placeholder-white/50 focus:outline-none focus:ring-2 focus:ring-orange-500 focus:border-transparent backdrop-blur-sm"
                      placeholder="Ваше имя"
                    />
                  </div>
                  <div>
                    <label className="block text-white/70 text-sm mb-2">Телефон *</label>
                    <input
                      type="tel"
                      value={phone}
                      onChange={(e) => setPhone(e.target.value)}
                      className="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-xl text-white placeholder-white/50 focus:outline-none focus:ring-2 focus:ring-orange-500 focus:border-transparent backdrop-blur-sm"
                      placeholder="+7 (999) 123-45-67"
                    />
                  </div>
                  {deliveryMethod === 'delivery' && (
                    <div>
                      <label className="block text-white/70 text-sm mb-2">Адрес доставки *</label>
                      <input
                        type="text"
                        value={address}
                        onChange={(e) => setAddress(e.target.value)}
                        className="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-xl text-white placeholder-white/50 focus:outline-none focus:ring-2 focus:ring-orange-500 focus:border-transparent backdrop-blur-sm"
                        placeholder="ул. Тверская, 15, кв. 42"
                      />
                    </div>
                  )}
                  <div>
                    <label className="block text-white/70 text-sm mb-2">Комментарий к заказу</label>
                    <textarea
                      value={comment}
                      onChange={(e) => setComment(e.target.value)}
                      rows={3}
                      className="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-xl text-white placeholder-white/50 focus:outline-none focus:ring-2 focus:ring-orange-500 focus:border-transparent backdrop-blur-sm resize-none"
                      placeholder="Дополнительные пожелания..."
                    />
                  </div>
                </div>
              </div>

              {/* Способ оплаты */}
              <div className="bg-gradient-to-br from-gray-800/50 to-gray-900/50 rounded-3xl p-8 border border-gray-700/50 backdrop-blur-sm">
                <h3 className="text-2xl font-bold text-white mb-6 flex items-center space-x-3">
                  <CreditCard className="w-6 h-6 text-purple-400" />
                  <span>Способ оплаты</span>
                </h3>
                <div className="space-y-4">
                  {paymentMethods.map((method) => {
                    const Icon = method.icon;
                    return (
                      <motion.button
                        key={method.id}
                        whileHover={{ scale: 1.02, y: -2 }}
                        whileTap={{ scale: 0.98 }}
                        onClick={() => setPaymentMethod(method.id)}
                        className={`w-full p-4 rounded-2xl border-2 transition-all duration-300 ${
                          paymentMethod === method.id
                            ? `border-orange-500 bg-gradient-to-br ${method.color}20`
                            : 'border-white/20 bg-white/5 hover:border-white/40'
                        }`}
                      >
                        <div className="flex items-center space-x-3">
                          <div className={`w-10 h-10 rounded-full bg-gradient-to-br ${method.color} flex items-center justify-center`}>
                            <Icon className="w-5 h-5 text-white" />
                          </div>
                          <span className="text-white font-semibold">{method.name}</span>
                        </div>
                      </motion.button>
                    );
                  })}
                </div>
              </div>

              {/* Итого */}
              <div className="bg-gradient-to-br from-gray-800/50 to-gray-900/50 rounded-3xl p-8 border border-gray-700/50 backdrop-blur-sm">
                <h3 className="text-2xl font-bold text-white mb-6">Итого к оплате</h3>
                <div className="space-y-4 mb-6">
                  <div className="flex justify-between text-white/70">
                    <span>Сумма заказа:</span>
                    <span>{formatPrice(subtotal)} ₽</span>
                  </div>
                  <div className="flex justify-between text-white/70">
                    <span>Доставка:</span>
                    <span>{deliveryFee} ₽</span>
                  </div>
                  <div className="border-t border-white/20 pt-4">
                    <div className="flex justify-between text-white font-bold text-xl">
                      <span>Итого:</span>
                      <span>{formatPrice(total)} ₽</span>
                    </div>
                  </div>
                </div>
                <motion.button
                  whileHover={{ scale: 1.02, y: -2 }}
                  whileTap={{ scale: 0.98 }}
                  onClick={handleCheckout}
                  className="w-full py-4 bg-gradient-to-r from-orange-600 to-red-600 text-white font-bold rounded-xl hover:shadow-lg transition-all duration-300 text-lg"
                >
                  Оформить заказ
                </motion.button>
              </div>
            </motion.div>
          </div>
        </div>
      </section>
    </main>
  );
} 