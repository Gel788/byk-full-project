'use client';

import { motion } from 'framer-motion';
import { Calendar, Clock, ArrowRight, Sparkles } from 'lucide-react';
import Link from 'next/link';
import { News } from '../lib/data';

interface NewsCardProps {
  news: News;
  index?: number;
}

export default function NewsCard({ news, index = 0 }: NewsCardProps) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 30 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.6, delay: index * 0.1 }}
      whileHover={{ y: -10, scale: 1.02 }}
      className="group relative overflow-hidden rounded-3xl premium-card"
    >
      {/* Брендинг индикатор */}
      <div className="absolute top-0 left-0 w-2 h-full z-10 bg-gradient-to-b from-[#d4af37] to-[#f4d03f]" />

      {/* Изображение */}
      <div className="relative h-48 overflow-hidden">
        <div className="w-full h-full bg-gradient-to-br from-gray-800 to-gray-900 flex items-center justify-center">
          <div className="text-center">
            <div className="w-16 h-16 mx-auto mb-4 rounded-full flex items-center justify-center text-2xl font-bold bg-gradient-to-r from-[#d4af37] to-[#f4d03f] text-[#1a1a1a]">
              <Sparkles className="w-8 h-8" />
            </div>
            <h3 className="text-xl font-bold text-white">{news.title}</h3>
          </div>
        </div>

        {/* Дата */}
        <div className="absolute top-4 right-4">
          <div className="px-3 py-1 bg-black/50 backdrop-blur-sm rounded-full">
            <span className="text-[#d4af37] font-semibold text-xs">{news.date}</span>
          </div>
        </div>
      </div>

      {/* Контент */}
      <div className="p-6">
        <h3 className="text-xl font-bold text-white mb-3 leading-tight">{news.title}</h3>
        <p className="text-white/70 text-sm mb-4 line-clamp-3">{news.excerpt}</p>

        {/* Мета информация */}
        <div className="flex items-center justify-between mb-6">
          <div className="flex items-center space-x-4">
            <div className="flex items-center space-x-1">
              <Calendar className="w-4 h-4 text-[#d4af37]" />
              <span className="text-white/60 text-xs">{news.date}</span>
            </div>
            <div className="flex items-center space-x-1">
              <Clock className="w-4 h-4 text-[#d4af37]" />
              <span className="text-white/60 text-xs">{news.readTime} мин</span>
            </div>
          </div>
        </div>

        {/* Кнопка */}
        <Link href={`/news/${news.id}`}>
          <motion.button
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
            className="w-full bg-gradient-to-r from-[#d4af37] to-[#f4d03f] text-[#1a1a1a] font-semibold py-3 rounded-2xl transition-all duration-300 shadow-lg hover:shadow-[#d4af37]/25 flex items-center justify-center space-x-2"
          >
            <span>Читать</span>
            <ArrowRight className="w-4 h-4" />
          </motion.button>
        </Link>
      </div>

      {/* Hover эффект */}
      <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
    </motion.div>
  );
} 