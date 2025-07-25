'use client'

import { useState } from 'react'
import { motion } from 'framer-motion'
import { 
  PlusIcon, 
  MagnifyingGlassIcon,
  NewspaperIcon,
  CalendarIcon,
  EyeIcon,
  PencilIcon,
  TrashIcon,
  PhotoIcon
} from '@heroicons/react/24/outline'
import { RestaurantBrand, NewsType } from '@/types'
import Layout from '@/components/Layout'

const mockNews = [
  {
    id: '1',
    title: 'Открытие нового ресторана THE БЫК в центре Москвы',
    description: 'Мы рады сообщить об открытии нашего нового ресторана в самом сердце столицы. Уникальная атмосфера и лучшие блюда ждут вас!',
    image: '/api/placeholder/400/200',
    brand: RestaurantBrand.THE_BYK,
    type: NewsType.NEWS,
    likes: 45,
    comments: 12,
    isPublished: true,
    createdAt: '2024-01-15T10:00:00Z',
    publishedAt: '2024-01-15T10:00:00Z'
  },
  {
    id: '2',
    title: 'Специальное меню к 8 марта',
    description: 'Праздничное меню с эксклюзивными блюдами и специальными предложениями для прекрасных дам.',
    image: '/api/placeholder/400/200',
    brand: RestaurantBrand.THE_PIVO,
    type: NewsType.PROMOTION,
    likes: 23,
    comments: 8,
    isPublished: true,
    createdAt: '2024-01-14T15:30:00Z',
    publishedAt: '2024-01-14T16:00:00Z'
  },
  {
    id: '3',
    title: 'Вечер живой музыки в MOSCA',
    description: 'Каждую пятницу в ресторане MOSCA выступают лучшие музыканты города. Резервируйте столик заранее!',
    image: '/api/placeholder/400/200',
    brand: RestaurantBrand.MOSCA,
    type: NewsType.EVENT,
    likes: 67,
    comments: 15,
    isPublished: false,
    createdAt: '2024-01-13T12:00:00Z',
    publishedAt: null
  },
  {
    id: '4',
    title: 'Новые блюда грузинской кухни',
    description: 'Попробуйте наши новые блюда, приготовленные по традиционным рецептам грузинской кухни.',
    image: '/api/placeholder/400/200',
    brand: RestaurantBrand.THE_GEORGIA,
    type: NewsType.NEWS,
    likes: 34,
    comments: 9,
    isPublished: true,
    createdAt: '2024-01-12T09:15:00Z',
    publishedAt: '2024-01-12T10:00:00Z'
  }
]

const brandColors = {
  [RestaurantBrand.THE_BYK]: 'bg-gradient-to-r from-byk-500 to-byk-600',
  [RestaurantBrand.THE_PIVO]: 'bg-gradient-to-r from-pivo-500 to-pivo-600',
  [RestaurantBrand.MOSCA]: 'bg-gradient-to-r from-mosca-500 to-mosca-600',
  [RestaurantBrand.THE_GEORGIA]: 'bg-gradient-to-r from-georgia-500 to-georgia-600'
}

const brandNames = {
  [RestaurantBrand.THE_BYK]: 'THE БЫК',
  [RestaurantBrand.THE_PIVO]: 'THE ПИВО',
  [RestaurantBrand.MOSCA]: 'MOSCA',
  [RestaurantBrand.THE_GEORGIA]: 'THE ГРУЗИЯ'
}

const newsTypeNames = {
  [NewsType.NEWS]: 'Новости',
  [NewsType.EVENT]: 'События',
  [NewsType.PROMOTION]: 'Акции'
}

export default function NewsPage() {
  const [searchTerm, setSearchTerm] = useState('')
  const [selectedBrand, setSelectedBrand] = useState<RestaurantBrand | 'all'>('all')
  const [selectedType, setSelectedType] = useState<NewsType | 'all'>('all')
  const [showPublished, setShowPublished] = useState<'all' | 'published' | 'draft'>('all')

  const filteredNews = mockNews.filter(news => {
    const matchesSearch = news.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         news.description.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesBrand = selectedBrand === 'all' || news.brand === selectedBrand
    const matchesType = selectedType === 'all' || news.type === selectedType
    const matchesStatus = showPublished === 'all' || 
                         (showPublished === 'published' && news.isPublished) ||
                         (showPublished === 'draft' && !news.isPublished)
    
    return matchesSearch && matchesBrand && matchesType && matchesStatus
  })

  const stats = {
    total: mockNews.length,
    published: mockNews.filter(n => n.isPublished).length,
    drafts: mockNews.filter(n => !n.isPublished).length,
    totalLikes: mockNews.reduce((sum, n) => sum + n.likes, 0),
    totalComments: mockNews.reduce((sum, n) => sum + n.comments, 0)
  }

  const handleAddNews = () => {
    // Здесь будет логика добавления новости
    console.log('Add news')
  }

  const handleViewNews = (id: string) => {
    // Здесь будет логика просмотра новости
    console.log('View news:', id)
  }

  const handleEditNews = (id: string) => {
    // Здесь будет логика редактирования новости
    console.log('Edit news:', id)
  }

  const handleDeleteNews = (id: string) => {
    // Здесь будет логика удаления новости
    console.log('Delete news:', id)
  }

  const handlePublishNews = (id: string) => {
    // Здесь будет логика публикации новости
    console.log('Publish news:', id)
  }

  return (
    <Layout title="Новости" description="Управление новостями и событиями">
      {/* Header */}
      <div className="flex justify-between items-center mb-6">
        <motion.button
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.95 }}
          onClick={handleAddNews}
          className="btn-primary flex items-center space-x-2"
        >
          <PlusIcon className="h-5 w-5" />
          <span>Добавить новость</span>
        </motion.button>
      </div>

      {/* Filters */}
      <div className="card">
        <div className="grid grid-cols-1 md:grid-cols-5 gap-4">
          {/* Search */}
          <div className="relative">
            <MagnifyingGlassIcon className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
            <input
              type="text"
              placeholder="Поиск новостей..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="input-field pl-10"
            />
          </div>

          {/* Brand filter */}
          <select
            value={selectedBrand}
            onChange={(e) => setSelectedBrand(e.target.value as RestaurantBrand | 'all')}
            className="input-field"
          >
            <option value="all">Все бренды</option>
            {Object.entries(brandNames).map(([brand, name]) => (
              <option key={brand} value={brand}>{name}</option>
            ))}
          </select>

          {/* Type filter */}
          <select
            value={selectedType}
            onChange={(e) => setSelectedType(e.target.value as NewsType | 'all')}
            className="input-field"
          >
            <option value="all">Все типы</option>
            {Object.entries(newsTypeNames).map(([type, name]) => (
              <option key={type} value={type}>{name}</option>
            ))}
          </select>

          {/* Status filter */}
          <select
            value={showPublished}
            onChange={(e) => setShowPublished(e.target.value as 'all' | 'published' | 'draft')}
            className="input-field"
          >
            <option value="all">Все статусы</option>
            <option value="published">Опубликованные</option>
            <option value="draft">Черновики</option>
          </select>

          {/* Sort */}
          <select className="input-field">
            <option value="newest">Сначала новые</option>
            <option value="oldest">Сначала старые</option>
            <option value="popular">По популярности</option>
          </select>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-5 gap-6">
        <div className="card">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Всего новостей</p>
              <p className="text-2xl font-bold text-gray-900">{stats.total}</p>
            </div>
            <div className="p-3 bg-blue-100 rounded-lg">
              <NewspaperIcon className="h-6 w-6 text-blue-600" />
            </div>
          </div>
        </div>

        <div className="card">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Опубликовано</p>
              <p className="text-2xl font-bold text-gray-900">{stats.published}</p>
            </div>
            <div className="p-3 bg-green-100 rounded-lg">
              <div className="h-6 w-6 bg-green-600 rounded-full"></div>
            </div>
          </div>
        </div>

        <div className="card">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Черновики</p>
              <p className="text-2xl font-bold text-gray-900">{stats.drafts}</p>
            </div>
            <div className="p-3 bg-yellow-100 rounded-lg">
              <PencilIcon className="h-6 w-6 text-yellow-600" />
            </div>
          </div>
        </div>

        <div className="card">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Всего лайков</p>
              <p className="text-2xl font-bold text-gray-900">{stats.totalLikes}</p>
            </div>
            <div className="p-3 bg-red-100 rounded-lg">
              <div className="h-6 w-6 bg-red-600 rounded-full"></div>
            </div>
          </div>
        </div>

        <div className="card">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Всего комментариев</p>
              <p className="text-2xl font-bold text-gray-900">{stats.totalComments}</p>
            </div>
            <div className="p-3 bg-purple-100 rounded-lg">
              <div className="h-6 w-6 bg-purple-600 rounded-full"></div>
            </div>
          </div>
        </div>
      </div>

      {/* News grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {filteredNews.map((news, index) => (
          <motion.div
            key={news.id}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: index * 0.1 }}
            className="card overflow-hidden"
          >
            {/* Image */}
            <div className="relative h-48 bg-gray-200">
              <div className="w-full h-full bg-gradient-to-br from-gray-300 to-gray-400 flex items-center justify-center">
                <PhotoIcon className="h-12 w-12 text-gray-500" />
              </div>
              <div className="absolute top-2 left-2">
                <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${brandColors[news.brand]} text-white`}>
                  {brandNames[news.brand]}
                </span>
              </div>
              <div className="absolute top-2 right-2">
                <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                  news.isPublished ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800'
                }`}>
                  {news.isPublished ? 'Опубликовано' : 'Черновик'}
                </span>
              </div>
            </div>

            {/* Content */}
            <div className="p-4">
              <div className="flex items-center justify-between mb-2">
                <span className="text-xs text-gray-500 bg-gray-100 px-2 py-1 rounded">
                  {newsTypeNames[news.type]}
                </span>
                <div className="flex items-center text-xs text-gray-500">
                  <CalendarIcon className="h-3 w-3 mr-1" />
                  {new Date(news.createdAt).toLocaleDateString('ru-RU')}
                </div>
              </div>

              <h3 className="text-lg font-semibold text-gray-900 mb-2 line-clamp-2">
                {news.title}
              </h3>

              <p className="text-sm text-gray-600 mb-4 line-clamp-3">
                {news.description}
              </p>

              {/* Stats */}
              <div className="flex items-center justify-between text-xs text-gray-500 mb-4">
                <div className="flex items-center space-x-4">
                  <span>❤️ {news.likes}</span>
                  <span>💬 {news.comments}</span>
                </div>
              </div>

              {/* Actions */}
              <div className="flex items-center justify-between">
                <div className="flex space-x-2">
                  <button
                    onClick={() => handleViewNews(news.id)}
                    className="text-blue-600 hover:text-blue-900"
                    title="Просмотр"
                  >
                    <EyeIcon className="h-4 w-4" />
                  </button>
                  <button
                    onClick={() => handleEditNews(news.id)}
                    className="text-green-600 hover:text-green-900"
                    title="Редактировать"
                  >
                    <PencilIcon className="h-4 w-4" />
                  </button>
                  <button
                    onClick={() => handleDeleteNews(news.id)}
                    className="text-red-600 hover:text-red-900"
                    title="Удалить"
                  >
                    <TrashIcon className="h-4 w-4" />
                  </button>
                </div>
                {!news.isPublished && (
                  <button
                    onClick={() => handlePublishNews(news.id)}
                    className="text-sm bg-green-600 text-white px-3 py-1 rounded hover:bg-green-700"
                  >
                    Опубликовать
                  </button>
                )}
              </div>
            </div>
          </motion.div>
        ))}
      </div>

      {filteredNews.length === 0 && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          className="card text-center py-12"
        >
          <NewspaperIcon className="h-12 w-12 text-gray-400 mx-auto mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">Нет новостей</h3>
          <p className="text-gray-500">По выбранным фильтрам новости не найдены</p>
        </motion.div>
      )}
    </Layout>
  )
} 