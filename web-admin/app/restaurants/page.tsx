'use client'

import { useState } from 'react'
import { motion } from 'framer-motion'
import { 
  PlusIcon, 
  MagnifyingGlassIcon,
  BuildingStorefrontIcon,
  MapPinIcon,
  StarIcon,
  EyeIcon,
  PencilIcon,
  TrashIcon
} from '@heroicons/react/24/outline'
import { RestaurantBrand } from '@/types'
import Layout from '@/components/Layout'
import Modal from '@/components/Modal'

const mockRestaurants = [
  {
    id: '1',
    name: 'THE БЫК на Тверской',
    brand: RestaurantBrand.THE_BYK,
    address: 'ул. Тверская, 15',
    city: 'Москва',
    rating: 4.8,
    isActive: true,
    deliveryTime: 45,
    averageCheck: 3500,
    createdAt: '2024-01-15'
  },
  {
    id: '2',
    name: 'THE ПИВО на Арбате',
    brand: RestaurantBrand.THE_PIVO,
    address: 'ул. Арбат, 25',
    city: 'Москва',
    rating: 4.6,
    isActive: true,
    deliveryTime: 40,
    averageCheck: 2000,
    createdAt: '2024-02-10'
  },
  {
    id: '3',
    name: 'MOSCA в Сити',
    brand: RestaurantBrand.MOSCA,
    address: 'Пресненская наб., 8с1',
    city: 'Москва',
    rating: 4.7,
    isActive: true,
    deliveryTime: 50,
    averageCheck: 2500,
    createdAt: '2024-03-05'
  },
  {
    id: '4',
    name: 'THE ГРУЗИЯ на Арбате',
    brand: RestaurantBrand.THE_GEORGIA,
    address: 'ул. Арбат, 30',
    city: 'Москва',
    rating: 4.9,
    isActive: false,
    deliveryTime: 40,
    averageCheck: 1800,
    createdAt: '2024-04-12'
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

export default function RestaurantsPage() {
  const [searchTerm, setSearchTerm] = useState('')
  const [selectedBrand, setSelectedBrand] = useState<RestaurantBrand | 'all'>('all')
  const [selectedCity, setSelectedCity] = useState<string>('all')
  const [isAddModalOpen, setIsAddModalOpen] = useState(false)
  const [isViewModalOpen, setIsViewModalOpen] = useState(false)
  const [isEditModalOpen, setIsEditModalOpen] = useState(false)
  const [selectedRestaurant, setSelectedRestaurant] = useState<typeof mockRestaurants[0] | null>(null)

  const filteredRestaurants = mockRestaurants.filter(restaurant => {
    const matchesSearch = restaurant.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         restaurant.address.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesBrand = selectedBrand === 'all' || restaurant.brand === selectedBrand
    const matchesCity = selectedCity === 'all' || restaurant.city === selectedCity
    
    return matchesSearch && matchesBrand && matchesCity
  })

  const cities = Array.from(new Set(mockRestaurants.map(r => r.city)))

  const handleAddRestaurant = () => {
    setIsAddModalOpen(true)
  }

  const handleViewRestaurant = (restaurant: any) => {
    setSelectedRestaurant(restaurant)
    setIsViewModalOpen(true)
  }

  const handleEditRestaurant = (restaurant: any) => {
    setSelectedRestaurant(restaurant)
    setIsEditModalOpen(true)
  }

  const handleDeleteRestaurant = (id: string) => {
    if (confirm('Вы уверены, что хотите удалить этот ресторан?')) {
      console.log('Delete restaurant:', id)
      // Здесь будет логика удаления
    }
  }

  return (
    <Layout title="Рестораны" description="Управление ресторанами сети">
      {/* Header */}
      <div className="flex justify-between items-center mb-6">
        <motion.button
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.95 }}
          onClick={handleAddRestaurant}
          className="btn-primary flex items-center space-x-2"
        >
          <PlusIcon className="h-5 w-5" />
          <span>Добавить ресторан</span>
        </motion.button>
      </div>

      {/* Filters */}
      <div className="card">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          {/* Search */}
          <div className="relative">
            <MagnifyingGlassIcon className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
            <input
              type="text"
              placeholder="Поиск ресторанов..."
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

          {/* City filter */}
          <select
            value={selectedCity}
            onChange={(e) => setSelectedCity(e.target.value)}
            className="input-field"
          >
            <option value="all">Все города</option>
            {cities.map(city => (
              <option key={city} value={city}>{city}</option>
            ))}
          </select>

          {/* Status filter */}
          <select className="input-field">
            <option value="all">Все статусы</option>
            <option value="active">Активные</option>
            <option value="inactive">Неактивные</option>
          </select>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div className="card">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Всего ресторанов</p>
              <p className="text-2xl font-bold text-gray-900">{mockRestaurants.length}</p>
            </div>
            <div className="p-3 bg-blue-100 rounded-lg">
              <BuildingStorefrontIcon className="h-6 w-6 text-blue-600" />
            </div>
          </div>
        </div>

        <div className="card">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Активных</p>
              <p className="text-2xl font-bold text-gray-900">
                {mockRestaurants.filter(r => r.isActive).length}
              </p>
            </div>
            <div className="p-3 bg-green-100 rounded-lg">
              <div className="h-6 w-6 bg-green-600 rounded-full"></div>
            </div>
          </div>
        </div>

        <div className="card">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Средний рейтинг</p>
              <p className="text-2xl font-bold text-gray-900">
                {(mockRestaurants.reduce((sum, r) => sum + r.rating, 0) / mockRestaurants.length).toFixed(1)}
              </p>
            </div>
            <div className="p-3 bg-yellow-100 rounded-lg">
              <StarIcon className="h-6 w-6 text-yellow-600" />
            </div>
          </div>
        </div>

        <div className="card">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Средний чек</p>
              <p className="text-2xl font-bold text-gray-900">
                {Math.round(mockRestaurants.reduce((sum, r) => sum + r.averageCheck, 0) / mockRestaurants.length)} ₽
              </p>
            </div>
            <div className="p-3 bg-purple-100 rounded-lg">
              <MapPinIcon className="h-6 w-6 text-purple-600" />
            </div>
          </div>
        </div>
      </div>

      {/* Restaurants table */}
      <div className="card">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Ресторан
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Бренд
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Адрес
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Рейтинг
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
              {filteredRestaurants.map((restaurant, index) => (
                <motion.tr
                  key={restaurant.id}
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: index * 0.1 }}
                  className="hover:bg-gray-50"
                >
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <div className={`w-10 h-10 rounded-lg ${brandColors[restaurant.brand]} flex items-center justify-center`}>
                        <span className="text-white font-bold text-sm">
                          {brandNames[restaurant.brand].split(' ')[1]?.[0] || 'R'}
                        </span>
                      </div>
                      <div className="ml-4">
                        <div className="text-sm font-medium text-gray-900">{restaurant.name}</div>
                        <div className="text-sm text-gray-500">{restaurant.city}</div>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${brandColors[restaurant.brand]} text-white`}>
                      {brandNames[restaurant.brand]}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center text-sm text-gray-900">
                      <MapPinIcon className="h-4 w-4 mr-1 text-gray-400" />
                      {restaurant.address}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <StarIcon className="h-4 w-4 text-yellow-400 mr-1" />
                      <span className="text-sm text-gray-900">{restaurant.rating}</span>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                      restaurant.isActive 
                        ? 'bg-green-100 text-green-800' 
                        : 'bg-red-100 text-red-800'
                    }`}>
                      {restaurant.isActive ? 'Активен' : 'Неактивен'}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <div className="flex space-x-2">
                      <button 
                        onClick={() => handleViewRestaurant(restaurant)}
                        className="text-blue-600 hover:text-blue-900"
                        title="Просмотр"
                      >
                        <EyeIcon className="h-4 w-4" />
                      </button>
                      <button 
                        onClick={() => handleEditRestaurant(restaurant)}
                        className="text-green-600 hover:text-green-900"
                        title="Редактировать"
                      >
                        <PencilIcon className="h-4 w-4" />
                      </button>
                      <button 
                        onClick={() => handleDeleteRestaurant(restaurant.id)}
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

      {/* Add Restaurant Modal */}
      <Modal
        isOpen={isAddModalOpen}
        onClose={() => setIsAddModalOpen(false)}
        title="Добавить ресторан"
        size="lg"
      >
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Название ресторана
            </label>
            <input
              type="text"
              className="input-field w-full"
              placeholder="Введите название ресторана"
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
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Адрес
            </label>
            <input
              type="text"
              className="input-field w-full"
              placeholder="Введите адрес"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Город
            </label>
            <input
              type="text"
              className="input-field w-full"
              placeholder="Введите город"
            />
          </div>
          <div className="flex justify-end space-x-3 pt-4">
            <button
              onClick={() => setIsAddModalOpen(false)}
              className="btn-secondary"
            >
              Отмена
            </button>
            <button className="btn-primary">
              Добавить ресторан
            </button>
          </div>
        </div>
      </Modal>

      {/* View Restaurant Modal */}
      <Modal
        isOpen={isViewModalOpen}
        onClose={() => setIsViewModalOpen(false)}
        title={selectedRestaurant?.name || 'Просмотр ресторана'}
        size="lg"
      >
        {selectedRestaurant && (
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Название</label>
                <p className="text-gray-900">{selectedRestaurant.name}</p>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Бренд</label>
                <p className="text-gray-900">{brandNames[selectedRestaurant.brand]}</p>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Адрес</label>
                <p className="text-gray-900">{selectedRestaurant.address}</p>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Город</label>
                <p className="text-gray-900">{selectedRestaurant.city}</p>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Рейтинг</label>
                <p className="text-gray-900">{selectedRestaurant.rating}</p>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Статус</label>
                <p className="text-gray-900">{selectedRestaurant.isActive ? 'Активен' : 'Неактивен'}</p>
              </div>
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

      {/* Edit Restaurant Modal */}
      <Modal
        isOpen={isEditModalOpen}
        onClose={() => setIsEditModalOpen(false)}
        title="Редактировать ресторан"
        size="lg"
      >
        {selectedRestaurant && (
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Название ресторана
              </label>
              <input
                type="text"
                className="input-field w-full"
                defaultValue={selectedRestaurant.name}
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Бренд
              </label>
              <select className="input-field w-full" defaultValue={selectedRestaurant.brand}>
                {Object.entries(brandNames).map(([brand, name]) => (
                  <option key={brand} value={brand}>{name}</option>
                ))}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Адрес
              </label>
              <input
                type="text"
                className="input-field w-full"
                defaultValue={selectedRestaurant.address}
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Город
              </label>
              <input
                type="text"
                className="input-field w-full"
                defaultValue={selectedRestaurant.city}
              />
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