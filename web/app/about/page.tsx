'use client';

import { motion } from 'framer-motion';
import { Star, Users, Award, Heart, Phone, Mail, MapPin, Clock } from 'lucide-react';

export default function AboutPage() {
  const stats = [
    { icon: Star, value: '4.8', label: 'Средний рейтинг' },
    { icon: Users, value: '50K+', label: 'Довольных клиентов' },
    { icon: Award, value: '15+', label: 'Лет опыта' },
    { icon: Heart, value: '100%', label: 'Качество' },
  ];

  const team = [
    {
      name: 'Александр Петров',
      position: 'Главный шеф-повар',
      description: '15 лет опыта в премиальной кухне',
      emoji: '👨‍🍳'
    },
    {
      name: 'Мария Сидорова',
      position: 'Директор по качеству',
      description: 'Контроль качества на всех этапах',
      emoji: '👩‍💼'
    },
    {
      name: 'Дмитрий Козлов',
      position: 'Шеф-повар THE БЫК',
      description: 'Специалист по стейкам',
      emoji: '🥩'
    },
    {
      name: 'Анна Волкова',
      position: 'Шеф-повар MOSCA',
      description: 'Эксперт итальянской кухни',
      emoji: '🍝'
    },
  ];

  const values = [
    {
      title: 'Качество',
      description: 'Используем только свежие и качественные ингредиенты',
      icon: '⭐'
    },
    {
      title: 'Инновации',
      description: 'Постоянно развиваемся и внедряем новые технологии',
      icon: '🚀'
    },
    {
      title: 'Традиции',
      description: 'Сохраняем традиции и добавляем современные нотки',
      icon: '🏛️'
    },
    {
      title: 'Забота',
      description: 'Заботимся о каждом клиенте и его потребностях',
      icon: '💝'
    },
  ];

  return (
    <main className="min-h-screen pt-16">
      
      {/* Hero секция */}
      <section className="relative py-20 px-4 sm:px-6 lg:px-8 overflow-hidden">
        <div className="absolute inset-0">
          <motion.div
            animate={{
              background: [
                'radial-gradient(circle at 20% 50%, rgba(120, 119, 198, 0.3) 0%, transparent 50%)',
                'radial-gradient(circle at 80% 20%, rgba(255, 119, 198, 0.3) 0%, transparent 50%)',
                'radial-gradient(circle at 40% 80%, rgba(120, 219, 255, 0.3) 0%, transparent 50%)',
                'radial-gradient(circle at 20% 50%, rgba(120, 119, 198, 0.3) 0%, transparent 50%)',
              ],
            }}
            transition={{ duration: 10, repeat: Infinity, ease: "easeInOut" }}
            className="absolute inset-0"
          />
        </div>

        <div className="relative z-10 max-w-7xl mx-auto text-center">
          <motion.h1
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
            className="text-4xl sm:text-6xl lg:text-7xl font-bold text-white mb-6"
          >
            О <span className="gradient-text">БЫК</span>
          </motion.h1>
          
          <motion.p
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.2 }}
            className="text-lg sm:text-xl text-white/70 mb-12 max-w-3xl mx-auto"
          >
            Мы создаем незабываемые гастрономические впечатления с 2008 года. 
            Наша миссия - доставлять премиальную еду с любовью к каждому клиенту.
          </motion.p>

          {/* Статистика */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.4 }}
            className="grid grid-cols-2 md:grid-cols-4 gap-8 max-w-4xl mx-auto"
          >
            {stats.map((stat, index) => (
              <motion.div
                key={stat.label}
                initial={{ opacity: 0, scale: 0.5 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ duration: 0.5, delay: 0.6 + index * 0.1 }}
                className="text-center"
              >
                <div className="w-16 h-16 mx-auto mb-4 bg-gradient-to-r from-primary-500 to-accent-500 rounded-full flex items-center justify-center">
                  <stat.icon className="w-8 h-8 text-white" />
                </div>
                <div className="text-3xl font-bold gradient-text mb-2">{stat.value}</div>
                <div className="text-white/60 text-sm">{stat.label}</div>
              </motion.div>
            ))}
          </motion.div>
        </div>
      </section>

      {/* История */}
      <section className="py-20 px-4 sm:px-6 lg:px-8">
        <div className="max-w-7xl mx-auto">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
            <motion.div
              initial={{ opacity: 0, x: -50 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.8 }}
            >
              <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-white mb-6">
                Наша <span className="gradient-text">история</span>
              </h2>
              <div className="space-y-6 text-white/70">
                <p>
                  Все началось в 2008 году, когда группа энтузиастов решила создать 
                  ресторан, который изменит представление о качественной еде в Москве.
                </p>
                <p>
                  Сначала это был небольшой стейк-хаус THE БЫК, который быстро 
                  завоевал любовь гостей своим качеством и атмосферой.
                </p>
                <p>
                  Сегодня у нас три уникальных ресторана: THE БЫК, THE ПИВО и MOSCA, 
                  каждый со своим характером и специализацией.
                </p>
                <p>
                  Мы гордимся тем, что за 15 лет работы стали частью жизни тысяч 
                  москвичей и продолжаем радовать их каждый день.
                </p>
              </div>
            </motion.div>
            
            <motion.div
              initial={{ opacity: 0, x: 50 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.8, delay: 0.2 }}
              className="relative"
            >
              <div className="w-full h-96 bg-gradient-to-br from-primary-500/20 to-accent-500/20 rounded-3xl flex items-center justify-center">
                <span className="text-8xl">🏛️</span>
              </div>
            </motion.div>
          </div>
        </div>
      </section>

      {/* Ценности */}
      <section className="py-20 px-4 sm:px-6 lg:px-8 bg-gradient-to-b from-transparent to-black/50">
        <div className="max-w-7xl mx-auto">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
            className="text-center mb-16"
          >
            <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-white mb-6">
              Наши <span className="gradient-text">ценности</span>
            </h2>
            <p className="text-lg text-white/70 max-w-2xl mx-auto">
              Принципы, которые руководят нами в работе и отношениях с клиентами
            </p>
          </motion.div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
            {values.map((value, index) => (
              <motion.div
                key={value.title}
                initial={{ opacity: 0, y: 50 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.5, delay: index * 0.1 }}
                className="text-center p-6 glass-effect rounded-2xl"
              >
                <div className="text-4xl mb-4">{value.icon}</div>
                <h3 className="text-xl font-bold text-white mb-3">{value.title}</h3>
                <p className="text-white/70">{value.description}</p>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* Команда */}
      <section className="py-20 px-4 sm:px-6 lg:px-8">
        <div className="max-w-7xl mx-auto">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
            className="text-center mb-16"
          >
            <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-white mb-6">
              Наша <span className="gradient-text">команда</span>
            </h2>
            <p className="text-lg text-white/70 max-w-2xl mx-auto">
              Профессионалы, которые делают каждый день особенным
            </p>
          </motion.div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
            {team.map((member, index) => (
              <motion.div
                key={member.name}
                initial={{ opacity: 0, y: 50 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.5, delay: index * 0.1 }}
                whileHover={{ y: -10, scale: 1.02 }}
                className="text-center p-6 glass-effect rounded-2xl card-hover"
              >
                <div className="w-20 h-20 mx-auto mb-4 bg-gradient-to-r from-primary-500 to-accent-500 rounded-full flex items-center justify-center text-3xl">
                  {member.emoji}
                </div>
                <h3 className="text-xl font-bold text-white mb-2">{member.name}</h3>
                <p className="text-primary-400 font-semibold mb-3">{member.position}</p>
                <p className="text-white/70 text-sm">{member.description}</p>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* Контакты */}
      <section className="py-20 px-4 sm:px-6 lg:px-8 bg-gradient-to-b from-transparent to-black/50">
        <div className="max-w-7xl mx-auto">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
            className="text-center mb-16"
          >
            <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-white mb-6">
              Свяжитесь с <span className="gradient-text">нами</span>
            </h2>
            <p className="text-lg text-white/70 max-w-2xl mx-auto">
              Мы всегда рады ответить на ваши вопросы и помочь с выбором
            </p>
          </motion.div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5, delay: 0.1 }}
              className="text-center p-6 glass-effect rounded-2xl"
            >
              <Phone className="w-12 h-12 mx-auto mb-4 text-primary-400" />
              <h3 className="text-xl font-bold text-white mb-3">Телефон</h3>
              <p className="text-white/70 mb-2">+7 (495) 123-45-67</p>
              <p className="text-white/60 text-sm">Ежедневно с 9:00 до 23:00</p>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5, delay: 0.2 }}
              className="text-center p-6 glass-effect rounded-2xl"
            >
              <Mail className="w-12 h-12 mx-auto mb-4 text-primary-400" />
              <h3 className="text-xl font-bold text-white mb-3">Email</h3>
              <p className="text-white/70 mb-2">info@byk.ru</p>
              <p className="text-white/60 text-sm">Ответим в течение часа</p>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5, delay: 0.3 }}
              className="text-center p-6 glass-effect rounded-2xl"
            >
              <MapPin className="w-12 h-12 mx-auto mb-4 text-primary-400" />
              <h3 className="text-xl font-bold text-white mb-3">Адрес</h3>
              <p className="text-white/70 mb-2">ул. Тверская, 15</p>
              <p className="text-white/60 text-sm">Москва, Россия</p>
            </motion.div>
          </div>
        </div>
      </section>
    </main>
  );
} 