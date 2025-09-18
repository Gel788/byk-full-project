'use client';

import { motion } from 'framer-motion';
import Navigation from '../../components/Navigation';
import NewsCard from '../../components/NewsCard';
import { news } from '../../lib/data';
import { Crown, Newspaper, Calendar, ArrowLeft, Sparkles, Search } from 'lucide-react';
import Link from 'next/link';
import { useState } from 'react';

export default function NewsPage() {
  const [searchQuery, setSearchQuery] = useState('');

  const filteredNews = news.filter(item => 
    item.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
    item.excerpt.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="min-h-screen bg-gradient-to-br from-[#1a1a1a] via-[#2a2a2a] to-[#1a1a1a]">
      <Navigation />
      
      {/* Hero секция */}
      <section className="pt-32 pb-20 px-4 sm:px-6 lg:px-8">
        <div className="max-w-7xl mx-auto text-center">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
            className="mb-8"
          >
            <div className="inline-flex items-center px-6 py-3 bg-gradient-to-r from-[#d4af37]/20 to-[#f4d03f]/20 text-[#d4af37] rounded-full text-sm font-semibold border border-[#d4af37]/30 backdrop-blur-sm glass-effect mb-6">
              <Newspaper className="w-5 h-5 mr-2" />
              Новости и акции
            </div>
            <h1 className="text-5xl sm:text-6xl md:text-7xl lg:text-8xl font-black text-white mb-6 leading-none">
              Последние{' '}
              <span className="gold-text">новости</span>
            </h1>
            <p className="text-xl sm:text-2xl text-white/80 max-w-4xl mx-auto leading-relaxed">
              Будьте в курсе событий, акций и специальных предложений БЫК Холдинга. 
              Узнавайте первыми о новых блюдах и ресторанах.
            </p>
          </motion.div>

          {/* Поиск */}
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.2 }}
            className="max-w-2xl mx-auto mb-12"
          >
            <div className="relative">
              <Search className="absolute left-4 top-1/2 transform -translate-y-1/2 w-6 h-6 text-[#d4af37]" />
              <input
                type="text"
                placeholder="Поиск новостей..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full pl-14 pr-4 py-4 bg-[#2a2a2a]/50 backdrop-blur-sm border border-[#d4af37]/30 rounded-2xl text-white placeholder-white/50 focus:outline-none focus:ring-2 focus:ring-[#d4af37] focus:border-transparent text-lg"
              />
            </div>
          </motion.div>

          {/* Статистика */}
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.4 }}
            className="grid grid-cols-1 sm:grid-cols-3 gap-8 max-w-4xl mx-auto mb-16"
          >
            {[
              { icon: Newspaper, value: news.length.toString(), label: 'Новостей', color: '#d4af37' },
              { icon: Calendar, value: '2024', label: 'Год', color: '#ff6b35' },
              { icon: Crown, value: 'Премиум', label: 'Качество', color: '#8B4513' }
            ].map((stat, index) => (
              <motion.div
                key={index}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.6, delay: 0.6 + index * 0.1 }}
                whileHover={{ scale: 1.05, y: -5 }}
                className="text-center p-6 glass-card rounded-3xl"
              >
                <motion.div
                  whileHover={{ scale: 1.1, rotate: 5 }}
                  className="w-16 h-16 bg-gradient-to-r from-[#d4af37] to-[#f4d03f] rounded-full flex items-center justify-center mx-auto mb-4 shadow-lg"
                >
                  <stat.icon className="w-8 h-8 text-[#1a1a1a]" />
                </motion.div>
                <div className="text-3xl font-bold text-[#d4af37] mb-2">{stat.value}</div>
                <span className="text-white/70 text-lg">{stat.label}</span>
              </motion.div>
            ))}
          </motion.div>
        </div>
      </section>

      {/* Новости */}
      <section className="py-20 px-4 sm:px-6 lg:px-8">
        <div className="max-w-7xl mx-auto">
          {filteredNews.length > 0 ? (
            <>
              <motion.div
                initial={{ opacity: 0, y: 30 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.8 }}
                className="text-center mb-16"
              >
                <h2 className="text-4xl sm:text-5xl md:text-6xl font-black text-white mb-6 leading-none">
                  Найдено{' '}
                  <span className="gold-text">{filteredNews.length}</span>
                  {' '}новостей
                </h2>
                <p className="text-xl text-white/80">
                  Актуальные события и специальные предложения
                </p>
              </motion.div>

              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
                {filteredNews.map((item, index) => (
                  <NewsCard key={item.id} news={item} index={index} />
                ))}
              </div>
            </>
          ) : (
            <motion.div
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.8 }}
              className="text-center py-20"
            >
              <motion.div 
                whileHover={{ scale: 1.1, rotate: 5 }}
                className="w-24 h-24 mx-auto mb-8 rounded-full bg-gradient-to-r from-[#d4af37] to-[#f4d03f] flex items-center justify-center shadow-2xl"
              >
                <Newspaper className="w-12 h-12 text-[#1a1a1a]" />
              </motion.div>
              <h3 className="text-3xl font-bold text-white mb-6">Новости не найдены</h3>
              <p className="text-white/60 mb-8 text-lg">
                Попробуйте изменить параметры поиска
              </p>
              <motion.button
                whileHover={{ scale: 1.05, y: -2 }}
                whileTap={{ scale: 0.95 }}
                onClick={() => setSearchQuery('')}
                className="px-8 py-4 bg-gradient-to-r from-[#d4af37] to-[#f4d03f] text-[#1a1a1a] font-semibold rounded-2xl hover:shadow-lg transition-all duration-300 text-lg"
              >
                Сбросить поиск
              </motion.button>
            </motion.div>
          )}
        </div>
      </section>

      {/* CTA секция */}
      <section className="py-20 px-4 sm:px-6 lg:px-8 bg-gradient-to-br from-[#d4af37]/10 to-[#f4d03f]/10">
        <div className="max-w-4xl mx-auto text-center">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
          >
            <h2 className="text-4xl sm:text-5xl md:text-6xl font-black text-white mb-6 leading-none">
              Оставайтесь{' '}
              <span className="gold-text">в курсе</span>
            </h2>
            <p className="text-xl sm:text-2xl text-white/80 mb-12 leading-relaxed">
              Подписывайтесь на наши новости и получайте эксклюзивные предложения
            </p>
            
            <div className="flex flex-col sm:flex-row gap-6 justify-center">
              <Link href="/restaurants">
                <motion.button
                  whileHover={{ scale: 1.05, y: -2 }}
                  whileTap={{ scale: 0.95 }}
                  className="group bg-gradient-to-r from-[#d4af37] to-[#f4d03f] text-[#1a1a1a] font-bold py-4 px-8 rounded-2xl text-lg transition-all duration-300 shadow-2xl hover:shadow-[#d4af37]/25 flex items-center space-x-3"
                >
                  <span>Посетить рестораны</span>
                  <Sparkles className="w-5 h-5 group-hover:scale-110 transition-transform" />
                </motion.button>
              </Link>
              
              <Link href="/">
                <motion.button
                  whileHover={{ scale: 1.05, y: -2 }}
                  whileTap={{ scale: 0.95 }}
                  className="group border-2 border-[#d4af37]/50 text-[#d4af37] font-bold py-4 px-8 rounded-2xl hover:border-[#d4af37] hover:bg-[#d4af37]/10 transition-all duration-300 text-lg flex items-center space-x-3"
                >
                  <ArrowLeft className="w-5 h-5 group-hover:-translate-x-1 transition-transform" />
                  <span>На главную</span>
                </motion.button>
              </Link>
            </div>
          </motion.div>
        </div>
      </section>
    </div>
  );
} 