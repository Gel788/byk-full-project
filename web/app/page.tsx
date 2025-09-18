'use client';

import { motion } from 'framer-motion';
import Hero from '../components/Hero';
import Navigation from '../components/Navigation';
import RestaurantCard from '../components/RestaurantCard';
import NewsCard from '../components/NewsCard';
import { restaurants, news } from '../lib/data';
import { ArrowRight, Crown, Star, Clock, MapPin, Sparkles } from 'lucide-react';
import Link from 'next/link';

export default function HomePage() {
  const featuredRestaurants = restaurants.slice(0, 3);
  const featuredNews = news.slice(0, 3);

  return (
    <div className="min-h-screen bg-gradient-to-br from-[#1a1a1a] via-[#2a2a2a] to-[#1a1a1a]">
      <Navigation />
      
      {/* Hero секция */}
      <Hero />

      {/* Премиальные рестораны */}
      <section className="py-20 sm:py-24 md:py-32 px-4 sm:px-6 lg:px-8">
        <div className="max-w-7xl mx-auto">
          {/* Заголовок секции */}
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.8 }}
            className="text-center mb-16"
          >
            <div className="inline-flex items-center px-6 py-3 bg-gradient-to-r from-[#d4af37]/20 to-[#f4d03f]/20 text-[#d4af37] rounded-full text-sm font-semibold border border-[#d4af37]/30 backdrop-blur-sm glass-effect mb-6">
              <Crown className="w-5 h-5 mr-2" />
              Наши рестораны
            </div>
            <h2 className="text-4xl sm:text-5xl md:text-6xl lg:text-7xl font-black text-white mb-6 leading-none">
              Премиум{' '}
              <span className="gold-text">рестораны</span>
            </h2>
            <p className="text-xl sm:text-2xl text-white/80 max-w-3xl mx-auto leading-relaxed">
              Откройте для себя мир изысканной кухни в лучших ресторанах БЫК Холдинга
            </p>
          </motion.div>

          {/* Карточки ресторанов */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 mb-16">
            {featuredRestaurants.map((restaurant, index) => (
              <RestaurantCard key={restaurant.id} restaurant={restaurant} index={index} />
            ))}
          </div>

          {/* Кнопка "Все рестораны" */}
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.8, delay: 0.2 }}
            className="text-center"
          >
            <Link href="/restaurants">
              <motion.button
                whileHover={{ scale: 1.05, y: -2 }}
                whileTap={{ scale: 0.95 }}
                className="group bg-gradient-to-r from-[#d4af37] to-[#f4d03f] text-[#1a1a1a] font-bold py-4 px-8 rounded-2xl text-lg transition-all duration-300 shadow-2xl hover:shadow-[#d4af37]/25 flex items-center space-x-3 mx-auto"
              >
                <span>Все рестораны</span>
                <ArrowRight className="w-5 h-5 group-hover:translate-x-1 transition-transform" />
              </motion.button>
            </Link>
          </motion.div>
        </div>
      </section>

      {/* Преимущества */}
      <section className="py-20 sm:py-24 md:py-32 px-4 sm:px-6 lg:px-8 bg-gradient-to-br from-[#2a2a2a] to-[#1a1a1a]">
        <div className="max-w-7xl mx-auto">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.8 }}
            className="text-center mb-16"
          >
            <h2 className="text-4xl sm:text-5xl md:text-6xl lg:text-7xl font-black text-white mb-6 leading-none">
              Почему{' '}
              <span className="gold-text">БЫК Холдинг</span>
            </h2>
            <p className="text-xl sm:text-2xl text-white/80 max-w-3xl mx-auto leading-relaxed">
              Мы создаем незабываемые впечатления от еды
            </p>
          </motion.div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
            {[
              {
                icon: Crown,
                title: 'Премиум качество',
                description: 'Только лучшие ингредиенты и технологии приготовления'
              },
              {
                icon: Clock,
                title: 'Быстрая доставка',
                description: 'Доставляем за 30 минут или возвращаем деньги'
              },
              {
                icon: Star,
                title: 'Экспертные повара',
                description: 'Команда профессионалов с многолетним опытом'
              },
              {
                icon: Sparkles,
                title: 'Уникальный опыт',
                description: 'Каждый ресторан - это особенная атмосфера'
              }
            ].map((feature, index) => (
              <motion.div
                key={index}
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.8, delay: index * 0.1 }}
                whileHover={{ y: -10, scale: 1.02 }}
                className="text-center p-8 glass-card rounded-3xl"
              >
                <motion.div
                  whileHover={{ scale: 1.1, rotate: 5 }}
                  className="w-16 h-16 bg-gradient-to-r from-[#d4af37] to-[#f4d03f] rounded-full flex items-center justify-center mx-auto mb-6 shadow-lg"
                >
                  <feature.icon className="w-8 h-8 text-[#1a1a1a]" />
                </motion.div>
                <h3 className="text-xl font-bold text-white mb-4">{feature.title}</h3>
                <p className="text-white/70 leading-relaxed">{feature.description}</p>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* Новости */}
      <section className="py-20 sm:py-24 md:py-32 px-4 sm:px-6 lg:px-8">
        <div className="max-w-7xl mx-auto">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.8 }}
            className="text-center mb-16"
          >
            <div className="inline-flex items-center px-6 py-3 bg-gradient-to-r from-[#d4af37]/20 to-[#f4d03f]/20 text-[#d4af37] rounded-full text-sm font-semibold border border-[#d4af37]/30 backdrop-blur-sm glass-effect mb-6">
              <Sparkles className="w-5 h-5 mr-2" />
              Новости и акции
            </div>
            <h2 className="text-4xl sm:text-5xl md:text-6xl lg:text-7xl font-black text-white mb-6 leading-none">
              Последние{' '}
              <span className="gold-text">новости</span>
            </h2>
            <p className="text-xl sm:text-2xl text-white/80 max-w-3xl mx-auto leading-relaxed">
              Будьте в курсе событий и специальных предложений
            </p>
          </motion.div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 mb-16">
            {featuredNews.map((item, index) => (
              <NewsCard key={item.id} news={item} index={index} />
            ))}
          </div>

          <motion.div
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.8, delay: 0.2 }}
            className="text-center"
          >
            <Link href="/news">
              <motion.button
                whileHover={{ scale: 1.05, y: -2 }}
                whileTap={{ scale: 0.95 }}
                className="group border-2 border-[#d4af37]/50 text-[#d4af37] font-bold py-4 px-8 rounded-2xl hover:border-[#d4af37] hover:bg-[#d4af37]/10 transition-all duration-300 text-lg flex items-center space-x-3 mx-auto"
              >
                <span>Все новости</span>
                <ArrowRight className="w-5 h-5 group-hover:translate-x-1 transition-transform" />
              </motion.button>
            </Link>
          </motion.div>
        </div>
      </section>

      {/* CTA секция */}
      <section className="py-20 sm:py-24 md:py-32 px-4 sm:px-6 lg:px-8 bg-gradient-to-br from-[#d4af37]/10 to-[#f4d03f]/10">
        <div className="max-w-4xl mx-auto text-center">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.8 }}
          >
            <h2 className="text-4xl sm:text-5xl md:text-6xl lg:text-7xl font-black text-white mb-6 leading-none">
              Готовы{' '}
              <span className="gold-text">попробовать?</span>
            </h2>
            <p className="text-xl sm:text-2xl text-white/80 mb-12 leading-relaxed">
              Закажите еду прямо сейчас и получите незабываемые впечатления от кухни БЫК Холдинга
            </p>
            
            <div className="flex flex-col sm:flex-row gap-6 justify-center">
              <Link href="/menu">
                <motion.button
                  whileHover={{ scale: 1.05, y: -2 }}
                  whileTap={{ scale: 0.95 }}
                  className="group bg-gradient-to-r from-[#d4af37] to-[#f4d03f] text-[#1a1a1a] font-bold py-4 px-8 rounded-2xl text-lg transition-all duration-300 shadow-2xl hover:shadow-[#d4af37]/25 flex items-center space-x-3"
                >
                  <span>Заказать еду</span>
                  <ArrowRight className="w-5 h-5 group-hover:translate-x-1 transition-transform" />
                </motion.button>
              </Link>
              
              <Link href="/restaurants">
                <motion.button
                  whileHover={{ scale: 1.05, y: -2 }}
                  whileTap={{ scale: 0.95 }}
                  className="group border-2 border-[#d4af37]/50 text-[#d4af37] font-bold py-4 px-8 rounded-2xl hover:border-[#d4af37] hover:bg-[#d4af37]/10 transition-all duration-300 text-lg flex items-center space-x-3"
                >
                  <span>Забронировать стол</span>
                  <Crown className="w-5 h-5 group-hover:scale-110 transition-transform" />
                </motion.button>
              </Link>
            </div>
          </motion.div>
        </div>
      </section>
    </div>
  );
} 