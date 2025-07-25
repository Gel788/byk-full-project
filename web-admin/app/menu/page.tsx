'use client'

import { useState } from 'react'
import { motion } from 'framer-motion'
import { 
  PlusIcon, 
  MagnifyingGlassIcon,
  CogIcon,
  CurrencyDollarIcon,
  EyeIcon,
  PencilIcon,
  TrashIcon,
  ViewColumnsIcon,
  ListBulletIcon
} from '@heroicons/react/24/outline'
import { RestaurantBrand, DishTag, SpicyLevel } from '@/types'
import Layout from '@/components/Layout'
import Modal from '@/components/Modal'

const mockDishes = [
  {
    id: '1',
    name: 'Рибай стейк',
    description: 'Сочный стейк из мраморной говядины, приготовленный на гриле',
    price: 2500,
    image: '/api/placeholder/300/200',
    category: 'Горячие блюда',
    restaurantBrand: RestaurantBrand.THE_BYK,
    isAvailable: true,
    preparationTime: 25,
    calories: 450,
    allergens: ['Глютен'],
    tags: [DishTag.BESTSELLER, DishTag.CHEF_SPECIAL],
    spicyLevel: SpicyLevel.NONE
  },
  {
    id: '2',
    name: 'Фирменные колбаски',
    description: 'Домашние колбаски из отборной свинины с травами',
    price: 1200,
    image: '/api/placeholder/300/200',
    category: 'Горячие блюда',
    restaurantBrand: RestaurantBrand.THE_PIVO,
    isAvailable: true,
    preparationTime: 20,
    calories: 380,
    allergens: ['Глютен', 'Лактоза'],
    tags: [DishTag.BESTSELLER],
    spicyLevel: SpicyLevel.MILD
  },
  {
    id: '3',
    name: 'Пицца Маргарита',
    description: 'Классическая пицца с томатным соусом и моцареллой',
    price: 800,
    image: '/api/placeholder/300/200',
    category: 'Пицца',
    restaurantBrand: RestaurantBrand.MOSCA,
    isAvailable: true,
    preparationTime: 15,
    calories: 280,
    allergens: ['Глютен', 'Лактоза'],
    tags: [DishTag.VEGETARIAN],
    spicyLevel: SpicyLevel.NONE
  },
  {
    id: '4',
    name: 'Хачапури по-аджарски',
    description: 'Традиционное грузинское блюдо с яйцом и сыром',
    price: 950,
    image: '/api/placeholder/300/200',
    category: 'Горячие блюда',
    restaurantBrand: RestaurantBrand.THE_GEORGIA,
    isAvailable: false,
    preparationTime: 30,
    calories: 420,
    allergens: ['Глютен', 'Лактоза'],
    tags: [DishTag.CHEF_SPECIAL],
    spicyLevel: SpicyLevel.NONE
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

const spicyLevelNames = {
  [SpicyLevel.NONE]: 'Не острое',
  [SpicyLevel.MILD]: 'Слабо острое',
  [SpicyLevel.MEDIUM]: 'Средне острое',
  [SpicyLevel.HOT]: 'Острое',
  [SpicyLevel.EXTRA_HOT]: 'Очень острое'
}

export default function MenuPage() {
  const [searchTerm, setSearchTerm] = useState('')
  const [selectedBrand, setSelectedBrand] = useState<RestaurantBrand | 'all'>('all')
  const [selectedCategory, setSelectedCategory] = useState<string>('all')
  const [viewMode, setViewMode] = useState<'grid' | 'list'>('grid')
  const [isAddModalOpen, setIsAddModalOpen] = useState(false)
  const [isViewModalOpen, setIsViewModalOpen] = useState(false)
  const [isEditModalOpen, setIsEditModalOpen] = useState(false)
  const [selectedDish, setSelectedDish] = useState<typeof mockDishes[0] | null>(null)

  const filteredDishes = mockDishes.filter(dish => {
    const matchesSearch = dish.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         dish.description.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesBrand = selectedBrand === 'all' || dish.restaurantBrand === selectedBrand
    const matchesCategory = selectedCategory === 'all' || dish.category === selectedCategory
    
    return matchesSearch && matchesBrand && matchesCategory
  })

  const categories = Array.from(new Set(mockDishes.map(d => d.category)))

  const stats = {
    total: mockDishes.length,
    available: mockDishes.filter(d => d.isAvailable).length,
    averagePrice: Math.round(mockDishes.reduce((sum, d) => sum + d.price, 0) / mockDishes.length),
    categories: categories.length
  }

  const handleAddDish = () => {
    setIsAddModalOpen(true)
  }

  const handleViewDish = (dish: typeof mockDishes[0]) => {
    setSelectedDish(dish)
    setIsViewModalOpen(true)
  }

  const handleEditDish = (dish: typeof mockDishes[0]) => {
    setSelectedDish(dish)
    setIsEditModalOpen(true)
  }

  const handleDeleteDish = (id: string) => {
    if (confirm('Вы уверены, что хотите удалить это блюдо?')) {
      console.log('Delete dish:', id)
      // Здесь будет логика удаления
    }
  }

  const handleToggleAvailability = (id: string) => {
    console.log('Toggle availability:', id)
    // Здесь будет логика изменения доступности
  }

  return (
    <Layout title="Меню" description="Управление блюдами и меню">
      {/* Header */}
      <div className="flex justify-between items-center mb-6">
        <div className="flex space-x-2">
          <motion.button
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            onClick={handleAddDish}
            className="btn-primary flex items-center space-x-2"
          >
            <PlusIcon className="h-5 w-5" />
            <span>Добавить блюдо</span>
          </motion.button>
        </div>
        <div className="flex space-x-2">
          <button
            onClick={() => setViewMode('grid')}
            className={`p-2 rounded-lg ${viewMode === 'grid' ? 'bg-primary-100 text-primary-700' : 'bg-gray-100 text-gray-600'}`}
          >
            <ViewColumnsIcon className="h-5 w-5" />
          </button>
          <button
            onClick={() => setViewMode('list')}
            className={`p-2 rounded-lg ${viewMode === 'list' ? 'bg-primary-100 text-primary-700' : 'bg-gray-100 text-gray-600'}`}
          >
            <ListBulletIcon className="h-5 w-5" />
          </button>
        </div>
      </div>

      {/* Filters */}
      <div className="card">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          {/* Search */}
          <div className="relative">
            <MagnifyingGlassIcon className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
            <input
              type="text"
              placeholder="Поиск блюд..."
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

          {/* Category filter */}
          <select
            value={selectedCategory}
            onChange={(e) => setSelectedCategory(e.target.value)}
            className="input-field"
          >
            <option value="all">Все категории</option>
            {categories.map(category => (
              <option key={category} value={category}>{category}</option>
            ))}
          </select>

          {/* Availability filter */}
          <select className="input-field">
            <option value="all">Все блюда</option>
            <option value="available">Доступные</option>
            <option value="unavailable">Недоступные</option>
          </select>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div className="card">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Всего блюд</p>
              <p className="text-2xl font-bold text-gray-900">{stats.total}</p>
            </div>
            <div className="p-3 bg-blue-100 rounded-lg">
              <ViewColumnsIcon className="h-6 w-6 text-blue-600" />
            </div>
          </div>
        </div>

        <div className="card">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Доступных</p>
              <p className="text-2xl font-bold text-gray-900">{stats.available}</p>
            </div>
            <div className="p-3 bg-green-100 rounded-lg">
              <ListBulletIcon className="h-6 w-6 text-green-600" />
            </div>
          </div>
        </div>

        <div className="card">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Средняя цена</p>
              <p className="text-2xl font-bold text-gray-900">{stats.averagePrice} ₽</p>
            </div>
            <div className="p-3 bg-orange-100 rounded-lg">
              <ViewColumnsIcon className="h-6 w-6 text-orange-600" />
            </div>
          </div>
        </div>

        <div className="card">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Категорий</p>
              <p className="text-2xl font-bold text-gray-900">{stats.categories}</p>
            </div>
            <div className="p-3 bg-purple-100 rounded-lg">
              <CogIcon className="h-6 w-6 text-purple-600" />
            </div>
          </div>
        </div>
      </div>

      {/* Dishes Grid */}
      {viewMode === 'grid' && (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredDishes.map((dish, index) => (
            <motion.div
              key={dish.id}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: index * 0.1 }}
              className="card overflow-hidden"
            >
              {/* Image */}
              <div className="relative h-48 bg-gray-200">
                <div className="w-full h-full bg-gradient-to-br from-gray-300 to-gray-400 flex items-center justify-center">
                  <ViewColumnsIcon className="h-12 w-12 text-gray-500" />
                </div>
                <div className="absolute top-2 left-2">
                  <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${brandColors[dish.restaurantBrand]} text-white`}>
                    {brandNames[dish.restaurantBrand]}
                  </span>
                </div>
                <div className="absolute top-2 right-2">
                  <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                    dish.isAvailable ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                  }`}>
                    {dish.isAvailable ? 'Доступно' : 'Недоступно'}
                  </span>
                </div>
              </div>

              {/* Content */}
              <div className="p-4">
                <div className="flex items-center justify-between mb-2">
                  <span className="text-xs text-gray-500 bg-gray-100 px-2 py-1 rounded">
                    {dish.category}
                  </span>
                  <span className="text-lg font-bold text-gray-900">
                    {dish.price} ₽
                  </span>
                </div>

                <h3 className="text-lg font-semibold text-gray-900 mb-2">
                  {dish.name}
                </h3>

                <p className="text-sm text-gray-600 mb-4 line-clamp-2">
                  {dish.description}
                </p>

                {/* Tags */}
                <div className="flex flex-wrap gap-1 mb-4">
                  {dish.tags.map(tag => (
                    <span key={tag} className="text-xs bg-blue-100 text-blue-800 px-2 py-1 rounded">
                      {tag}
                    </span>
                  ))}
                  <span className="text-xs bg-orange-100 text-orange-800 px-2 py-1 rounded">
                    {spicyLevelNames[dish.spicyLevel]}
                  </span>
                </div>

                {/* Stats */}
                <div className="flex justify-between items-center text-xs text-gray-500 mb-4">
                  <div className="flex items-center">
                    <CogIcon className="h-4 w-4 mr-1" />
                    {dish.preparationTime} мин
                  </div>
                  <div className="flex items-center">
                    <CurrencyDollarIcon className="h-4 w-4 mr-1" />
                    {dish.calories} ккал
                  </div>
                </div>

                {/* Actions */}
                <div className="flex items-center justify-between">
                  <div className="flex space-x-2">
                    <button
                      onClick={() => handleViewDish(dish)}
                      className="text-blue-600 hover:text-blue-900"
                      title="Просмотр"
                    >
                      <EyeIcon className="h-4 w-4" />
                    </button>
                    <button
                      onClick={() => handleEditDish(dish)}
                      className="text-green-600 hover:text-green-900"
                      title="Редактировать"
                    >
                      <PencilIcon className="h-4 w-4" />
                    </button>
                    <button
                      onClick={() => handleDeleteDish(dish.id)}
                      className="text-red-600 hover:text-red-900"
                      title="Удалить"
                    >
                      <TrashIcon className="h-4 w-4" />
                    </button>
                  </div>
                  <button
                    onClick={() => handleToggleAvailability(dish.id)}
                    className={`text-sm px-3 py-1 rounded ${
                      dish.isAvailable 
                        ? 'bg-red-600 text-white hover:bg-red-700' 
                        : 'bg-green-600 text-white hover:bg-green-700'
                    }`}
                  >
                    {dish.isAvailable ? 'Скрыть' : 'Показать'}
                  </button>
                </div>
              </div>
            </motion.div>
          ))}
        </div>
      )}

      {/* Dishes List */}
      {viewMode === 'list' && (
        <div className="card">
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Блюдо
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Бренд
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Категория
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Цена
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Статус
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Действия
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {filteredDishes.map((dish, index) => (
                  <motion.tr
                    key={dish.id}
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: index * 0.1 }}
                    className="hover:bg-gray-50"
                  >
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        <div className="w-10 h-10 bg-gray-200 rounded-lg flex items-center justify-center">
                          <ViewColumnsIcon className="h-5 w-5 text-gray-500" />
                        </div>
                        <div className="ml-4">
                          <div className="text-sm font-medium text-gray-900">{dish.name}</div>
                          <div className="text-sm text-gray-500">{dish.description.substring(0, 50)}...</div>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${brandColors[dish.restaurantBrand]} text-white`}>
                        {brandNames[dish.restaurantBrand]}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {dish.category}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                      {dish.price} ₽
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                        dish.isAvailable ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                      }`}>
                        {dish.isAvailable ? 'Доступно' : 'Недоступно'}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                      <div className="flex space-x-2">
                        <button
                          onClick={() => handleViewDish(dish)}
                          className="text-blue-600 hover:text-blue-900"
                          title="Просмотр"
                        >
                          <EyeIcon className="h-4 w-4" />
                        </button>
                        <button
                          onClick={() => handleEditDish(dish)}
                          className="text-green-600 hover:text-green-900"
                          title="Редактировать"
                        >
                          <PencilIcon className="h-4 w-4" />
                        </button>
                        <button
                          onClick={() => handleDeleteDish(dish.id)}
                          className="text-red-600 hover:text-red-900"
                          title="Удалить"
                        >
                          <TrashIcon className="h-4 w-4" />
                        </button>
                      </div>
                    </td>
                  </motion.tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {filteredDishes.length === 0 && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          className="card text-center py-12"
        >
          <ViewColumnsIcon className="h-12 w-12 text-gray-400 mx-auto mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">Нет блюд</h3>
          <p className="text-gray-500">По выбранным фильтрам блюда не найдены</p>
        </motion.div>
      )}

      {/* Add Dish Modal */}
      <Modal
        isOpen={isAddModalOpen}
        onClose={() => setIsAddModalOpen(false)}
        title="Добавить блюдо"
        size="xl"
      >
        <div className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Название блюда
              </label>
              <input
                type="text"
                className="input-field w-full"
                placeholder="Введите название блюда"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Бренд
              </label>
              <select className="input-field w-full">
                {Object.entries(brandNames).map(([brand, name]) => (
                  <option key={brand} value={brand}>{name}</option>
                ))}
              </select>
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Описание
            </label>
            <textarea
              className="input-field w-full"
              rows={3}
              placeholder="Введите описание блюда"
            />
          </div>
          <div className="grid grid-cols-3 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Цена (₽)
              </label>
              <input
                type="number"
                className="input-field w-full"
                placeholder="0"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Категория
              </label>
              <input
                type="text"
                className="input-field w-full"
                placeholder="Введите категорию"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Время приготовления (мин)
              </label>
              <input
                type="number"
                className="input-field w-full"
                placeholder="0"
              />
            </div>
          </div>
          <div className="flex justify-end space-x-3 pt-4">
            <button
              onClick={() => setIsAddModalOpen(false)}
              className="btn-secondary"
            >
              Отмена
            </button>
            <button className="btn-primary">
              Добавить блюдо
            </button>
          </div>
        </div>
      </Modal>

      {/* View Dish Modal */}
      <Modal
        isOpen={isViewModalOpen}
        onClose={() => setIsViewModalOpen(false)}
        title={selectedDish?.name || 'Просмотр блюда'}
        size="lg"
      >
        {selectedDish && (
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Название</label>
                <p className="text-gray-900">{selectedDish.name}</p>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Бренд</label>
                <p className="text-gray-900">{brandNames[selectedDish.restaurantBrand]}</p>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Категория</label>
                <p className="text-gray-900">{selectedDish.category}</p>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Цена</label>
                <p className="text-gray-900">{selectedDish.price} ₽</p>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Статус</label>
                <p className="text-gray-900">{selectedDish.isAvailable ? 'Доступно' : 'Недоступно'}</p>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Острота</label>
                <p className="text-gray-900">{spicyLevelNames[selectedDish.spicyLevel]}</p>
              </div>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Описание</label>
              <p className="text-gray-900">{selectedDish.description}</p>
            </div>
            <div className="flex justify-end pt-4">
              <button
                onClick={() => setIsViewModalOpen(false)}
                className="btn-secondary"
              >
                Закрыть
              </button>
            </div>
          </div>
        )}
      </Modal>

      {/* Edit Dish Modal */}
      <Modal
        isOpen={isEditModalOpen}
        onClose={() => setIsEditModalOpen(false)}
        title="Редактировать блюдо"
        size="xl"
      >
        {selectedDish && (
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Название блюда
                </label>
                <input
                  type="text"
                  className="input-field w-full"
                  defaultValue={selectedDish.name}
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Бренд
                </label>
                <select className="input-field w-full" defaultValue={selectedDish.restaurantBrand}>
                  {Object.entries(brandNames).map(([brand, name]) => (
                    <option key={brand} value={brand}>{name}</option>
                  ))}
                </select>
              </div>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Описание
              </label>
              <textarea
                className="input-field w-full"
                rows={3}
                defaultValue={selectedDish.description}
              />
            </div>
            <div className="grid grid-cols-3 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Цена (₽)
                </label>
                <input
                  type="number"
                  className="input-field w-full"
                  defaultValue={selectedDish.price}
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Категория
                </label>
                <input
                  type="text"
                  className="input-field w-full"
                  defaultValue={selectedDish.category}
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Время приготовления (мин)
                </label>
                <input
                  type="number"
                  className="input-field w-full"
                  defaultValue={selectedDish.preparationTime}
                />
              </div>
            </div>
            <div className="flex justify-end space-x-3 pt-4">
              <button
                onClick={() => setIsEditModalOpen(false)}
                className="btn-secondary"
              >
                Отмена
              </button>
              <button className="btn-primary">
                Сохранить изменения
              </button>
            </div>
          </div>
        )}
      </Modal>
    </Layout>
  )
} 