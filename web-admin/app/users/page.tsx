'use client'

import { useState } from 'react'
import { motion } from 'framer-motion'
import { 
  MagnifyingGlassIcon,
  UserIcon,
  EnvelopeIcon,
  PhoneIcon,
  CalendarIcon,
  StarIcon,
  CurrencyDollarIcon,
  ClockIcon
} from '@heroicons/react/24/outline'
import Layout from '@/components/Layout'

const mockUsers = [
  {
    id: '1',
    name: 'Алексей Петров',
    email: 'alexey@example.com',
    phone: '+7 (999) 123-45-67',
    registrationDate: '2023-12-01',
    lastVisit: '2024-01-15T14:30:00Z',
    totalOrders: 15,
    totalSpent: 45000,
    averageOrder: 3000,
    rating: 4.8,
    isActive: true,
    avatar: null
  },
  {
    id: '2',
    name: 'Мария Сидорова',
    email: 'maria@example.com',
    phone: '+7 (999) 234-56-78',
    registrationDate: '2023-11-15',
    lastVisit: '2024-01-14T18:20:00Z',
    totalOrders: 8,
    totalSpent: 12000,
    averageOrder: 1500,
    rating: 4.5,
    isActive: true,
    avatar: null
  },
  {
    id: '3',
    name: 'Дмитрий Козлов',
    email: 'dmitry@example.com',
    phone: '+7 (999) 345-67-89',
    registrationDate: '2023-10-20',
    lastVisit: '2024-01-13T12:15:00Z',
    totalOrders: 25,
    totalSpent: 75000,
    averageOrder: 3000,
    rating: 4.9,
    isActive: true,
    avatar: null
  },
  {
    id: '4',
    name: 'Анна Волкова',
    email: 'anna@example.com',
    phone: '+7 (999) 456-78-90',
    registrationDate: '2023-09-10',
    lastVisit: '2024-01-10T16:45:00Z',
    totalOrders: 3,
    totalSpent: 4000,
    averageOrder: 1333,
    rating: 4.2,
    isActive: false,
    avatar: null
  }
]

export default function UsersPage() {
  const [searchTerm, setSearchTerm] = useState('')
  const [selectedStatus, setSelectedStatus] = useState<'all' | 'active' | 'inactive'>('all')

  const filteredUsers = mockUsers.filter(user => {
    const matchesSearch = user.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         user.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         user.phone.includes(searchTerm)
    const matchesStatus = selectedStatus === 'all' || 
                         (selectedStatus === 'active' && user.isActive) ||
                         (selectedStatus === 'inactive' && !user.isActive)
    
    return matchesSearch && matchesStatus
  })

  const stats = {
    total: mockUsers.length,
    active: mockUsers.filter(u => u.isActive).length,
    newThisMonth: mockUsers.filter(u => {
      const registrationDate = new Date(u.registrationDate)
      const thisMonth = new Date()
      return registrationDate.getMonth() === thisMonth.getMonth() && 
             registrationDate.getFullYear() === thisMonth.getFullYear()
    }).length,
    totalRevenue: mockUsers.reduce((acc, u) => acc + u.totalSpent, 0),
    averageRating: mockUsers.reduce((acc, u) => acc + u.rating, 0) / mockUsers.length
  }

  return (
    <Layout>
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Пользователи</h1>
          <p className="text-gray-600">Управление пользователями и аналитика</p>
        </div>
      </div>

      {/* Filters */}
      <div className="card">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          {/* Search */}
          <div className="relative">
            <MagnifyingGlassIcon className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
            <input
              type="text"
              placeholder="Поиск пользователей..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="input-field pl-10"
            />
          </div>

          {/* Status filter */}
          <select
            value={selectedStatus}
            onChange={(e) => setSelectedStatus(e.target.value as 'all' | 'active' | 'inactive')}
            className="input-field"
          >
            <option value="all">Все пользователи</option>
            <option value="active">Активные</option>
            <option value="inactive">Неактивные</option>
          </select>

          {/* Sort by */}
          <select className="input-field">
            <option value="name">По имени</option>
            <option value="registration">По дате регистрации</option>
            <option value="orders">По количеству заказов</option>
            <option value="spent">По сумме покупок</option>
            <option value="rating">По рейтингу</option>
          </select>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-5 gap-6">
        <div className="card">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Всего пользователей</p>
              <p className="text-2xl font-bold text-gray-900">{stats.total}</p>
            </div>
            <div className="p-3 bg-blue-100 rounded-lg">
              <UserIcon className="h-6 w-6 text-blue-600" />
            </div>
          </div>
        </div>

        <div className="card">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Активные</p>
              <p className="text-2xl font-bold text-gray-900">{stats.active}</p>
            </div>
            <div className="p-3 bg-green-100 rounded-lg">
              <div className="h-6 w-6 bg-green-600 rounded-full"></div>
            </div>
          </div>
        </div>

        <div className="card">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Новые в этом месяце</p>
              <p className="text-2xl font-bold text-gray-900">{stats.newThisMonth}</p>
            </div>
            <div className="p-3 bg-purple-100 rounded-lg">
              <CalendarIcon className="h-6 w-6 text-purple-600" />
            </div>
          </div>
        </div>

        <div className="card">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Общая выручка</p>
              <p className="text-2xl font-bold text-gray-900">{stats.totalRevenue.toLocaleString()} ₽</p>
            </div>
            <div className="p-3 bg-yellow-100 rounded-lg">
              <CurrencyDollarIcon className="h-6 w-6 text-yellow-600" />
            </div>
          </div>
        </div>

        <div className="card">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Средний рейтинг</p>
              <p className="text-2xl font-bold text-gray-900">{stats.averageRating.toFixed(1)}</p>
            </div>
            <div className="p-3 bg-orange-100 rounded-lg">
              <StarIcon className="h-6 w-6 text-orange-600" />
            </div>
          </div>
        </div>
      </div>

      {/* Users table */}
      <div className="card">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Пользователь
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Контакты
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Статистика
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Рейтинг
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Статус
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Последний визит
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredUsers.map((user, index) => (
                <motion.tr
                  key={user.id}
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: index * 0.1 }}
                  className="hover:bg-gray-50"
                >
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <div className="w-10 h-10 bg-gray-200 rounded-full flex items-center justify-center">
                        <UserIcon className="h-5 w-5 text-gray-500" />
                      </div>
                      <div className="ml-4">
                        <div className="text-sm font-medium text-gray-900">{user.name}</div>
                        <div className="text-sm text-gray-500">
                          Регистрация: {new Date(user.registrationDate).toLocaleDateString('ru-RU')}
                        </div>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="space-y-1">
                      <div className="flex items-center text-sm text-gray-900">
                        <EnvelopeIcon className="h-4 w-4 mr-2 text-gray-400" />
                        {user.email}
                      </div>
                      <div className="flex items-center text-sm text-gray-500">
                        <PhoneIcon className="h-4 w-4 mr-2 text-gray-400" />
                        {user.phone}
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="space-y-1">
                      <div className="text-sm text-gray-900">
                        Заказов: <span className="font-medium">{user.totalOrders}</span>
                      </div>
                      <div className="text-sm text-gray-500">
                        Потрачено: <span className="font-medium">{user.totalSpent.toLocaleString()} ₽</span>
                      </div>
                      <div className="text-sm text-gray-500">
                        Средний чек: <span className="font-medium">{user.averageOrder} ₽</span>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <StarIcon className="h-4 w-4 text-yellow-400 mr-1" />
                      <span className="text-sm font-medium text-gray-900">{user.rating}</span>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                      user.isActive 
                        ? 'bg-green-100 text-green-800' 
                        : 'bg-red-100 text-red-800'
                    }`}>
                      {user.isActive ? 'Активен' : 'Неактивен'}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">
                      {new Date(user.lastVisit).toLocaleDateString('ru-RU')}
                    </div>
                    <div className="text-sm text-gray-500">
                      {new Date(user.lastVisit).toLocaleTimeString('ru-RU', { hour: '2-digit', minute: '2-digit' })}
                    </div>
                  </td>
                </motion.tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </Layout>
  )
} 