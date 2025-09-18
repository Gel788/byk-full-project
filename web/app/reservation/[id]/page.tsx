'use client';

import { useState, useEffect } from 'react';
import { motion, useScroll, useTransform } from 'framer-motion';
import { ArrowLeft, Calendar, Clock, Users, Phone, MapPin, Star, CalendarDays, User, Mail, MessageSquare, CheckCircle } from 'lucide-react';
import { useRouter } from 'next/navigation';
import { useRestaurants } from '../../../lib/contexts/RestaurantContext';

const timeSlots = [
  '12:00', '12:30', '13:00', '13:30', '14:00', '14:30', '15:00', '15:30',
  '16:00', '16:30', '17:00', '17:30', '18:00', '18:30', '19:00', '19:30',
  '20:00', '20:30', '21:00', '21:30', '22:00', '22:30'
];

const guestOptions = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

export default function ReservationPage({ params }: { params: { id: string } }) {
  const router = useRouter();
  const { restaurants } = useRestaurants();
  
  const [selectedDate, setSelectedDate] = useState('');
  const [selectedTime, setSelectedTime] = useState('');
  const [guests, setGuests] = useState(2);
  const [name, setName] = useState('');
  const [phone, setPhone] = useState('');
  const [email, setEmail] = useState('');
  const [specialRequests, setSpecialRequests] = useState('');
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

  const restaurant = restaurants.find(r => r.id === params.id);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!selectedDate || !selectedTime || !name || !phone) {
      alert('Пожалуйста, заполните все обязательные поля');
      return;
    }
    
    // Здесь будет логика отправки бронирования
    alert('Бронирование отправлено! Мы свяжемся с вами для подтверждения.');
    router.push('/reservation/success');
  };

  if (!restaurant) {
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

        <div className="relative z-10 flex items-center justify-center min-h-screen">
          <div className="text-center">
            <motion.div 
              whileHover={{ scale: 1.1, rotate: 5 }}
              className="w-24 h-24 mx-auto mb-8 rounded-full bg-gradient-to-br from-orange-500 to-red-500 flex items-center justify-center shadow-2xl"
            >
              <span className="text-3xl">🏪</span>
            </motion.div>
            <h1 className="text-3xl font-bold text-white mb-6">Ресторан не найден</h1>
            <motion.button
              whileHover={{ scale: 1.05, y: -2 }}
              whileTap={{ scale: 0.95 }}
              onClick={() => router.back()}
              className="px-8 py-4 bg-gradient-to-r from-orange-600 to-red-600 text-white font-semibold rounded-xl hover:shadow-lg transition-all duration-300 text-lg"
            >
              Назад
            </motion.button>
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
              📅 Бронирование столика
            </span>
            <h1 className="text-5xl sm:text-6xl font-bold text-white mb-6">
              Забронировать <span className="bg-gradient-to-r from-white via-orange-400 to-white bg-clip-text text-transparent">столик</span>
            </h1>
            <p className="text-xl text-white/70 max-w-3xl mx-auto leading-relaxed">
              Выберите удобное время и количество гостей для бронирования столика
            </p>
          </motion.div>

          {/* Информация о ресторане */}
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 1, delay: 0.2 }}
            className="bg-gradient-to-br from-gray-800/50 to-gray-900/50 rounded-3xl p-8 border border-gray-700/50 backdrop-blur-sm mb-12"
          >
            <div className="flex flex-col lg:flex-row items-center lg:items-start space-y-6 lg:space-y-0 lg:space-x-8">
              <div className="w-32 h-32 rounded-full bg-gradient-to-br from-orange-500 to-red-500 flex items-center justify-center text-white text-4xl font-bold shadow-2xl">
                {restaurant.name.split(' ').map(n => n[0]).join('')}
              </div>
              
              <div className="flex-1 text-center lg:text-left">
                <h2 className="text-3xl font-bold text-white mb-4">{restaurant.name}</h2>
                <p className="text-white/70 text-lg mb-6 leading-relaxed">{restaurant.description}</p>
                
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <div className="flex items-center justify-center lg:justify-start space-x-3 text-white/60">
                    <MapPin className="w-5 h-5" />
                    <span className="text-sm">{restaurant.address}</span>
                  </div>
                  <div className="flex items-center justify-center lg:justify-start space-x-3 text-white/60">
                    <Phone className="w-5 h-5" />
                    <span className="text-sm">{restaurant.phone}</span>
                  </div>
                  <div className="flex items-center justify-center lg:justify-start space-x-3 text-white/60">
                    <Star className="w-5 h-5 text-yellow-400 fill-current" />
                    <span className="text-sm">{restaurant.rating} / 5</span>
                  </div>
                </div>
              </div>
            </div>
          </motion.div>
        </div>
      </section>

      {/* Основной контент */}
      <section className="relative py-12 px-4 sm:px-6 lg:px-8 overflow-hidden">
        <div className="max-w-7xl mx-auto">
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-12">
            {/* Информация о бронировании */}
            <motion.div
              initial={{ opacity: 0, x: -30 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ duration: 1, delay: 0.4 }}
              className="space-y-8"
            >
              <div className="bg-gradient-to-br from-gray-800/50 to-gray-900/50 rounded-3xl p-8 border border-gray-700/50 backdrop-blur-sm">
                <h3 className="text-2xl font-bold text-white mb-6 flex items-center space-x-3">
                  <CheckCircle className="w-6 h-6 text-green-400" />
                  <span>Правила бронирования</span>
                </h3>
                <div className="space-y-4 text-white/70">
                  <div className="flex items-start space-x-3">
                    <div className="w-2 h-2 bg-green-400 rounded-full mt-2 flex-shrink-0"></div>
                    <p className="text-sm">Бронирование действует 15 минут</p>
                  </div>
                  <div className="flex items-start space-x-3">
                    <div className="w-2 h-2 bg-green-400 rounded-full mt-2 flex-shrink-0"></div>
                    <p className="text-sm">При опоздании более чем на 15 минут бронь аннулируется</p>
                  </div>
                  <div className="flex items-start space-x-3">
                    <div className="w-2 h-2 bg-green-400 rounded-full mt-2 flex-shrink-0"></div>
                    <p className="text-sm">Отмена брони за 2 часа до времени</p>
                  </div>
                  <div className="flex items-start space-x-3">
                    <div className="w-2 h-2 bg-green-400 rounded-full mt-2 flex-shrink-0"></div>
                    <p className="text-sm">Дресс-код: smart casual</p>
                  </div>
                </div>
              </div>

              <div className="bg-gradient-to-br from-gray-800/50 to-gray-900/50 rounded-3xl p-8 border border-gray-700/50 backdrop-blur-sm">
                <h3 className="text-2xl font-bold text-white mb-6 flex items-center space-x-3">
                  <CalendarDays className="w-6 h-6 text-blue-400" />
                  <span>Часы работы</span>
                </h3>
                <div className="space-y-3 text-white/70">
                  <div className="flex justify-between">
                    <span>Понедельник - Пятница:</span>
                    <span className="font-semibold">12:00 - 23:00</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Суббота - Воскресенье:</span>
                    <span className="font-semibold">12:00 - 00:00</span>
                  </div>
                </div>
              </div>
            </motion.div>

            {/* Форма бронирования */}
            <motion.div
              initial={{ opacity: 0, x: 30 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ duration: 1, delay: 0.6 }}
              className="lg:col-span-2"
            >
              <form onSubmit={handleSubmit} className="bg-gradient-to-br from-gray-800/50 to-gray-900/50 rounded-3xl p-8 border border-gray-700/50 backdrop-blur-sm">
                <h2 className="text-3xl font-bold text-white mb-8 flex items-center space-x-3">
                  <Calendar className="w-8 h-8 text-orange-400" />
                  <span>Забронировать столик</span>
                </h2>
                
                <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                  {/* Дата */}
                  <div>
                    <label className="block text-white font-semibold mb-4 flex items-center space-x-2">
                      <Calendar className="w-5 h-5 text-orange-400" />
                      <span>Дата *</span>
                    </label>
                    <input
                      type="date"
                      value={selectedDate}
                      onChange={(e) => setSelectedDate(e.target.value)}
                      min={new Date().toISOString().split('T')[0]}
                      className="w-full px-4 py-4 bg-white/10 border border-white/20 rounded-xl text-white focus:outline-none focus:ring-2 focus:ring-orange-500 focus:border-transparent backdrop-blur-sm"
                      required
                    />
                  </div>

                  {/* Время */}
                  <div>
                    <label className="block text-white font-semibold mb-4 flex items-center space-x-2">
                      <Clock className="w-5 h-5 text-blue-400" />
                      <span>Время *</span>
                    </label>
                    <select
                      value={selectedTime}
                      onChange={(e) => setSelectedTime(e.target.value)}
                      className="w-full px-4 py-4 bg-white/10 border border-white/20 rounded-xl text-white focus:outline-none focus:ring-2 focus:ring-orange-500 focus:border-transparent backdrop-blur-sm"
                      required
                    >
                      <option value="">Выберите время</option>
                      {timeSlots.map((time) => (
                        <option key={time} value={time}>{time}</option>
                      ))}
                    </select>
                  </div>

                  {/* Количество гостей */}
                  <div>
                    <label className="block text-white font-semibold mb-4 flex items-center space-x-2">
                      <Users className="w-5 h-5 text-green-400" />
                      <span>Количество гостей *</span>
                    </label>
                    <select
                      value={guests}
                      onChange={(e) => setGuests(Number(e.target.value))}
                      className="w-full px-4 py-4 bg-white/10 border border-white/20 rounded-xl text-white focus:outline-none focus:ring-2 focus:ring-orange-500 focus:border-transparent backdrop-blur-sm"
                      required
                    >
                      {guestOptions.map((num) => (
                        <option key={num} value={num}>{num} {num === 1 ? 'гость' : num < 5 ? 'гостя' : 'гостей'}</option>
                      ))}
                    </select>
                  </div>

                  {/* Телефон */}
                  <div>
                    <label className="block text-white font-semibold mb-4 flex items-center space-x-2">
                      <Phone className="w-5 h-5 text-purple-400" />
                      <span>Телефон *</span>
                    </label>
                    <input
                      type="tel"
                      value={phone}
                      onChange={(e) => setPhone(e.target.value)}
                      placeholder="+7 (999) 123-45-67"
                      className="w-full px-4 py-4 bg-white/10 border border-white/20 rounded-xl text-white placeholder-white/50 focus:outline-none focus:ring-2 focus:ring-orange-500 focus:border-transparent backdrop-blur-sm"
                      required
                    />
                  </div>

                  {/* Имя */}
                  <div className="md:col-span-2">
                    <label className="block text-white font-semibold mb-4 flex items-center space-x-2">
                      <User className="w-5 h-5 text-orange-400" />
                      <span>Имя *</span>
                    </label>
                    <input
                      type="text"
                      value={name}
                      onChange={(e) => setName(e.target.value)}
                      placeholder="Ваше имя"
                      className="w-full px-4 py-4 bg-white/10 border border-white/20 rounded-xl text-white placeholder-white/50 focus:outline-none focus:ring-2 focus:ring-orange-500 focus:border-transparent backdrop-blur-sm"
                      required
                    />
                  </div>

                  {/* Email */}
                  <div className="md:col-span-2">
                    <label className="block text-white font-semibold mb-4 flex items-center space-x-2">
                      <Mail className="w-5 h-5 text-blue-400" />
                      <span>Email</span>
                    </label>
                    <input
                      type="email"
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      placeholder="your@email.com"
                      className="w-full px-4 py-4 bg-white/10 border border-white/20 rounded-xl text-white placeholder-white/50 focus:outline-none focus:ring-2 focus:ring-orange-500 focus:border-transparent backdrop-blur-sm"
                    />
                  </div>

                  {/* Особые пожелания */}
                  <div className="md:col-span-2">
                    <label className="block text-white font-semibold mb-4 flex items-center space-x-2">
                      <MessageSquare className="w-5 h-5 text-green-400" />
                      <span>Особые пожелания</span>
                    </label>
                    <textarea
                      value={specialRequests}
                      onChange={(e) => setSpecialRequests(e.target.value)}
                      placeholder="Например: столик у окна, детский стул, аллергия на орехи..."
                      rows={4}
                      className="w-full px-4 py-4 bg-white/10 border border-white/20 rounded-xl text-white placeholder-white/50 focus:outline-none focus:ring-2 focus:ring-orange-500 focus:border-transparent backdrop-blur-sm resize-none"
                    />
                  </div>
                </div>

                {/* Кнопка отправки */}
                <div className="mt-12">
                  <motion.button
                    type="submit"
                    whileHover={{ scale: 1.02, y: -2 }}
                    whileTap={{ scale: 0.98 }}
                    className="w-full py-4 bg-gradient-to-r from-orange-600 to-red-600 text-white font-bold rounded-xl hover:shadow-lg transition-all duration-300 text-lg"
                  >
                    Забронировать столик
                  </motion.button>
                </div>
              </form>
            </motion.div>
          </div>
        </div>
      </section>
    </main>
  );
} 