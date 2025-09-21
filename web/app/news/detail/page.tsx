'use client';

import { motion } from 'framer-motion';
import { useParams, useRouter } from 'next/navigation';
import { useState, useEffect } from 'react';
import { Calendar, Clock, ArrowLeft, Share2, Heart, Bookmark, User, MapPin } from 'lucide-react';
import { news, restaurants } from '../../../lib/data';
import { getBrandColors } from '../../../lib/data';

export default function NewsDetailPage() {
  const params = useParams();
  const router = useRouter();
  const [newsItem, setNewsItem] = useState<any>(null);
  const [restaurant, setRestaurant] = useState<any>(null);
  const [isLiked, setIsLiked] = useState(false);
  const [isBookmarked, setIsBookmarked] = useState(false);

  useEffect(() => {
    const item = news.find(n => n.id === params.id);
    if (item) {
      setNewsItem(item);
      const rest = restaurants.find(r => r.id === item.restaurantId);
      setRestaurant(rest);
    }
  }, [params.id]);

  if (!newsItem) {
    return (
      <div className="min-h-screen pt-16 flex items-center justify-center">
        <div className="text-center">
          <div className="w-16 h-16 mx-auto mb-4 rounded-full bg-gradient-to-r from-orange-500 to-red-500 flex items-center justify-center">
            <span className="text-2xl">📰</span>
          </div>
          <h2 className="text-2xl font-bold text-white mb-2">Новость не найдена</h2>
          <p className="text-white/60 mb-6">Запрашиваемая новость не существует</p>
          <button
            onClick={() => router.push('/news')}
            className="px-6 py-3 bg-gradient-to-r from-orange-600 to-red-600 text-white font-semibold rounded-xl hover:shadow-lg transition-all duration-300"
          >
            Вернуться к новостям
          </button>
        </div>
      </div>
    );
  }

  const colors = restaurant ? getBrandColors(restaurant.brand) : null;

  const formatDate = (date: Date) => {
    return new Intl.DateTimeFormat('ru-RU', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    }).format(date);
  };

  return (
    <main className="min-h-screen pt-16 bg-black">
      {/* Интерактивный курсор эффект */}
      <motion.div
        className="fixed w-6 h-6 bg-orange-500/30 rounded-full pointer-events-none z-50 mix-blend-difference"
        animate={{
          x: typeof window !== 'undefined' ? window.innerWidth / 2 - 12 : 0,
          y: typeof window !== 'undefined' ? window.innerHeight / 2 - 12 : 0,
        }}
        transition={{ type: "spring", stiffness: 500, damping: 28 }}
      />

      {/* Hero секция */}
      <section className="relative py-20 px-4 sm:px-6 lg:px-8 overflow-hidden">
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

        <div className="relative z-10 max-w-4xl mx-auto">
          {/* Кнопка назад */}
          <motion.button
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.5 }}
            onClick={() => router.push('/news')}
            className="group flex items-center space-x-2 text-white/70 hover:text-white mb-8 transition-colors"
          >
            <ArrowLeft className="w-5 h-5 group-hover:-translate-x-1 transition-transform" />
            <span>Вернуться к новостям</span>
          </motion.button>

          {/* Ресторан */}
          {restaurant && (
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5, delay: 0.1 }}
              className="mb-6"
            >
              <span 
                className="inline-flex items-center px-4 py-2 rounded-full text-sm font-semibold"
                style={{
                  backgroundColor: colors ? `${colors.primary}20` : 'rgba(255,255,255,0.1)',
                  color: colors ? colors.accent : '#fff',
                  border: `1px solid ${colors ? colors.primary + '40' : 'rgba(255,255,255,0.2)'}`
                }}
              >
                <MapPin className="w-4 h-4 mr-2" />
                {restaurant.name}
              </span>
            </motion.div>
          )}

          {/* Заголовок */}
          <motion.h1
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.2 }}
            className="text-4xl sm:text-5xl lg:text-6xl font-bold text-white mb-6 leading-tight"
          >
            {newsItem.title}
          </motion.h1>

          {/* Мета информация */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.3 }}
            className="flex flex-wrap items-center gap-6 mb-8 text-white/60"
          >
            <div className="flex items-center space-x-2">
              <Calendar className="w-5 h-5" />
              <span>{formatDate(newsItem.publishedAt)}</span>
            </div>
            <div className="flex items-center space-x-2">
              <Clock className="w-5 h-5" />
              <span>5 мин чтения</span>
            </div>
            <div className="flex items-center space-x-2">
              <User className="w-5 h-5" />
              <span>Редакция БЫК</span>
            </div>
          </motion.div>

          {/* Действия */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.4 }}
            className="flex items-center space-x-4 mb-12"
          >
            <motion.button
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              onClick={() => setIsLiked(!isLiked)}
              className={`flex items-center space-x-2 px-4 py-2 rounded-xl transition-all duration-300 ${
                isLiked 
                  ? 'bg-red-500/20 text-red-400 border border-red-500/30' 
                  : 'bg-white/10 text-white/70 hover:text-white border border-white/20'
              }`}
            >
              <Heart className={`w-5 h-5 ${isLiked ? 'fill-current' : ''}`} />
              <span>Нравится</span>
            </motion.button>

            <motion.button
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              onClick={() => setIsBookmarked(!isBookmarked)}
              className={`flex items-center space-x-2 px-4 py-2 rounded-xl transition-all duration-300 ${
                isBookmarked 
                  ? 'bg-yellow-500/20 text-yellow-400 border border-yellow-500/30' 
                  : 'bg-white/10 text-white/70 hover:text-white border border-white/20'
              }`}
            >
              <Bookmark className={`w-5 h-5 ${isBookmarked ? 'fill-current' : ''}`} />
              <span>Сохранить</span>
            </motion.button>

            <motion.button
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              className="flex items-center space-x-2 px-4 py-2 rounded-xl bg-white/10 text-white/70 hover:text-white border border-white/20 transition-all duration-300"
            >
              <Share2 className="w-5 h-5" />
              <span>Поделиться</span>
            </motion.button>
          </motion.div>
        </div>
      </section>

      {/* Контент */}
      <section className="relative py-20 px-4 sm:px-6 lg:px-8">
        <div className="max-w-4xl mx-auto">
          {/* Изображение */}
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.5 }}
            className="relative h-96 rounded-3xl overflow-hidden mb-12"
          >
            <div 
              className="w-full h-full bg-gradient-to-br from-gray-800 to-gray-900"
              style={{
                background: colors 
                  ? `linear-gradient(135deg, ${colors.primary}20, ${colors.secondary}20)`
                  : 'linear-gradient(135deg, #374151, #1f2937)'
              }}
            />
            
            {/* Брендовый градиент */}
            {colors && (
              <motion.div 
                className="absolute inset-0 opacity-30"
                animate={{
                  background: [
                    `linear-gradient(135deg, ${colors.primary}, ${colors.accent})`,
                    `linear-gradient(135deg, ${colors.accent}, ${colors.primary})`,
                    `linear-gradient(135deg, ${colors.primary}, ${colors.accent})`
                  ]
                }}
                transition={{ duration: 4, repeat: Infinity }}
              />
            )}
          </motion.div>

          {/* Текст контента */}
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.6 }}
            className="prose prose-lg prose-invert max-w-none"
          >
            <div className="text-white/90 leading-relaxed text-lg space-y-6">
              {newsItem.content.split('\n').map((paragraph: string, index: number) => (
                <motion.p
                  key={index}
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.5, delay: 0.7 + index * 0.1 }}
                  className="text-white/90 leading-relaxed"
                >
                  {paragraph}
                </motion.p>
              ))}
            </div>
          </motion.div>

          {/* Дополнительная информация */}
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.8 }}
            className="mt-16 p-8 bg-gradient-to-br from-gray-800/50 to-gray-900/50 rounded-3xl border border-gray-700/50 backdrop-blur-sm"
          >
            <h3 className="text-2xl font-bold text-white mb-6">Дополнительная информация</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <h4 className="text-lg font-semibold text-white mb-3">Категория</h4>
                <p className="text-white/70">Новости ресторана</p>
              </div>
              <div>
                <h4 className="text-lg font-semibold text-white mb-3">Автор</h4>
                <p className="text-white/70">Редакция БЫК</p>
              </div>
              <div>
                <h4 className="text-lg font-semibold text-white mb-3">Дата публикации</h4>
                <p className="text-white/70">{formatDate(newsItem.publishedAt)}</p>
              </div>
              <div>
                <h4 className="text-lg font-semibold text-white mb-3">Время чтения</h4>
                <p className="text-white/70">5 минут</p>
              </div>
            </div>
          </motion.div>
        </div>
      </section>

      {/* Похожие новости */}
      <section className="relative py-20 px-4 sm:px-6 lg:px-8 bg-gradient-to-b from-transparent to-gray-900/50">
        <div className="max-w-7xl mx-auto">
          <motion.h2
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
            className="text-3xl sm:text-4xl font-bold text-white mb-12 text-center"
          >
            Похожие новости
          </motion.h2>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {news
              .filter(item => item.id !== newsItem.id)
              .slice(0, 3)
              .map((item, index) => {
                const itemRestaurant = restaurants.find(r => r.id === item.restaurantId);
                const itemColors = itemRestaurant ? getBrandColors(itemRestaurant.brand) : null;
                
                return (
                  <motion.article
                    key={item.id}
                    initial={{ opacity: 0, y: 50 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ duration: 0.5, delay: 0.1 * index }}
                    whileHover={{ y: -10, scale: 1.02 }}
                    onClick={() => router.push(`/news/${item.id}`)}
                    className="group cursor-pointer relative overflow-hidden rounded-2xl bg-gradient-to-br from-gray-800/50 to-gray-900/50 border border-gray-700/50 hover:border-orange-500/50 transition-all duration-300 backdrop-blur-sm"
                  >
                    {/* Изображение */}
                    <div className="relative h-48 overflow-hidden">
                      <div 
                        className="w-full h-full bg-gradient-to-br from-gray-800 to-gray-900"
                        style={{
                          background: itemColors 
                            ? `linear-gradient(135deg, ${itemColors.primary}20, ${itemColors.secondary}20)`
                            : 'linear-gradient(135deg, #374151, #1f2937)'
                        }}
                      />
                      
                      {/* Брендовый градиент */}
                      {itemColors && (
                        <div 
                          className="absolute inset-0 opacity-20"
                          style={{
                            background: `linear-gradient(135deg, ${itemColors.primary}, ${itemColors.accent})`
                          }}
                        />
                      )}
                      
                      {/* Ресторан */}
                      {itemRestaurant && (
                        <div className="absolute top-4 left-4">
                          <span 
                            className="px-3 py-1 rounded-full text-xs font-semibold"
                            style={{
                              backgroundColor: itemColors ? `${itemColors.primary}20` : 'rgba(255,255,255,0.1)',
                              color: itemColors ? itemColors.accent : '#fff',
                              border: `1px solid ${itemColors ? itemColors.primary + '40' : 'rgba(255,255,255,0.2)'}`
                            }}
                          >
                            {itemRestaurant.name}
                          </span>
                        </div>
                      )}
                    </div>

                    {/* Контент */}
                    <div className="p-6">
                      {/* Дата */}
                      <div className="flex items-center space-x-2 text-white/60 mb-3">
                        <Calendar className="w-4 h-4" />
                        <span className="text-sm">{formatDate(item.publishedAt)}</span>
                      </div>

                      {/* Заголовок */}
                      <h3 className="text-xl font-bold text-white mb-3 line-clamp-2 group-hover:text-orange-400 transition-colors">
                        {item.title}
                      </h3>

                      {/* Описание */}
                      <p className="text-white/70 text-sm mb-6 line-clamp-3">
                        {item.content}
                      </p>

                      {/* Кнопка читать далее */}
                      <div className="flex items-center space-x-2 text-orange-400 group-hover:text-orange-300 transition-colors">
                        <span className="font-semibold">Читать далее</span>
                        <ArrowLeft className="w-4 h-4 rotate-180 group-hover:translate-x-1 transition-transform" />
                      </div>
                    </div>

                    {/* Брендовый индикатор */}
                    {itemColors && (
                      <div 
                        className="absolute top-0 left-0 w-1 h-full"
                        style={{ backgroundColor: itemColors.accent }}
                      />
                    )}
                  </motion.article>
                );
              })}
          </div>
        </div>
      </section>
    </main>
  );
} 