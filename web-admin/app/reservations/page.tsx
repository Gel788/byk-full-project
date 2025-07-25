'use client'

import { useState } from 'react'
import { motion } from 'framer-motion'
import { 
  PlusIcon, 
  MagnifyingGlassIcon,
  CalendarIcon,
  ClockIcon,
  UserIcon,
  BuildingStorefrontIcon,
  CheckCircleIcon,
  XCircleIcon,
  ExclamationTriangleIcon,
  EyeIcon
} from '@heroicons/react/24/outline'
import { ReservationStatus } from '@/types'
import Layout from '@/components/Layout'

const mockReservations = [
  {
    id: 'RES-001',
    customer: {
      name: 'Алексей Петров',
      phone: '+7 (999) 123-45-67',
      email: 'alexey@example.com'
    },
    restaurant: {
      name: 'THE БЫК на Тверской',
      address: 'ул. Тверская, 15'
    },
    date: '2024-01-20T19:00:00Z',
    guestCount: 4,
    status: ReservationStatus.CONFIRMED,
    tableNumber: 'A12',
    specialRequests: 'Стол у окна, если возможно',
    createdAt: '2024-01-15T10:30:00Z'
  },
  {
    id: 'RES-002',
    customer: {
      name: 'Мария Сидорова',
      phone: '+7 (999) 234-56-78',
      email: 'maria@example.com'
    },
    restaurant: {
      name: 'THE ПИВО на Арбате',
      address: 'ул. Арбат, 25'
    },
    date: '2024-01-18T20:00:00Z',
    guestCount: 2,
    status: ReservationStatus.PENDING,
    tableNumber: null,
    specialRequests: '',
    createdAt: '2024-01-16T14:20:00Z'
  },
  {
    id: 'RES-003',
    customer: {
      name: 'Дмитрий Козлов',
      phone: '+7 (999) 345-67-89',
      email: 'dmitry@example.com'
    },
    restaurant: {
      name: 'MOSCA в Сити',
      address: 'Пресненская наб., 8с1'
    },
    date: '2024-01-15T18:30:00Z',
    guestCount: 6,
    status: ReservationStatus.COMPLETED,
    tableNumber: 'B8',
    specialRequests: 'День рождения',
    createdAt: '2024-01-10T09:15:00Z'
  },
  {
    id: 'RES-004',
    customer: {
      name: 'Анна Волкова',
      phone: '+7 (999) 456-78-90',
      email: 'anna@example.com'
    },
    restaurant: {
      name: 'THE ГРУЗИЯ на Арбате',
      address: 'ул. Арбат, 30'
    },
    date: '2024-01-17T19:30:00Z',
    guestCount: 3,
    status: ReservationStatus.CANCELLED,
    tableNumber: null,
    specialRequests: '',
    createdAt: '2024-01-12T16:45:00Z'
  }
]

const statusColors = {
  [ReservationStatus.PENDING]: 'bg-yellow-100 text-yellow-800',
  [ReservationStatus.CONFIRMED]: 'bg-green-100 text-green-800',
  [ReservationStatus.COMPLETED]: 'bg-blue-100 text-blue-800',
  [ReservationStatus.CANCELLED]: 'bg-red-100 text-red-800'
}

const statusNames = {
  [ReservationStatus.PENDING]: 'Ожидает подтверждения',
  [ReservationStatus.CONFIRMED]: 'Подтверждено',
  [ReservationStatus.COMPLETED]: 'Завершено',
  [ReservationStatus.CANCELLED]: 'Отменено'
}

export default function ReservationsPage() {
  const [searchTerm, setSearchTerm] = useState('')
  const [selectedStatus, setSelectedStatus] = useState<ReservationStatus | 'all'>('all')
  const [selectedRestaurant, setSelectedRestaurant] = useState<string>('all')
  const [selectedDate, setSelectedDate] = useState<string>('all')

  const filteredReservations = mockReservations.filter(reservation => {
    const matchesSearch = reservation.id.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         reservation.customer.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         reservation.customer.phone.includes(searchTerm)
    const matchesStatus = selectedStatus === 'all' || reservation.status === selectedStatus
    const matchesRestaurant = selectedRestaurant === 'all' || reservation.restaurant.name === selectedRestaurant
    
    let matchesDate = true
    if (selectedDate !== 'all') {
      const reservationDate = new Date(reservation.date)
      const today = new Date()
      const tomorrow = new Date(today)
      tomorrow.setDate(tomorrow.getDate() + 1)
      
      switch (selectedDate) {
        case 'today':
          matchesDate = reservationDate.toDateString() === today.toDateString()
          break
        case 'tomorrow':
          matchesDate = reservationDate.toDateString() === tomorrow.toDateString()
          break
        case 'week':
          const weekFromNow = new Date(today)
          weekFromNow.setDate(weekFromNow.getDate() + 7)
          matchesDate = reservationDate >= today && reservationDate <= weekFromNow
          break
      }
    }
    
    return matchesSearch && matchesStatus && matchesRestaurant && matchesDate
  })

  const restaurants = Array.from(new Set(mockReservations.map(r => r.restaurant.name)))

  const stats = {
    total: mockReservations.length,
    pending: mockReservations.filter(r => r.status === ReservationStatus.PENDING).length,
    confirmed: mockReservations.filter(r => r.status === ReservationStatus.CONFIRMED).length,
    completed: mockReservations.filter(r => r.status === ReservationStatus.COMPLETED).length,
    today: mockReservations.filter(r => {
      const reservationDate = new Date(r.date)
      const today = new Date()
      return reservationDate.toDateString() === today.toDateString()
    }).length
  }

  return (
    <Layout>
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Бронирования</h1>
          <p className="text-gray-600">Управление бронированиями столов</p>
        </div>
        <motion.button
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.95 }}
          className="btn-primary flex items-center space-x-2"
        >
          <PlusIcon className="h-5 w-5" />
          <span>Новое бронирование</span>
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
              placeholder="Поиск бронирований..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="input-field pl-10"
            />
          </div>

          {/* Status filter */}
          <select
            value={selectedStatus}
            onChange={(e) => setSelectedStatus(e.target.value as ReservationStatus | 'all')}
            className="input-field"
          >
            <option value="all">Все статусы</option>
            {Object.entries(statusNames).map(([status, name]) => (
              <option key={status} value={status}>{name}</option>
            ))}
          </select>

          {/* Restaurant filter */}
          <select
            value={selectedRestaurant}
            onChange={(e) => setSelectedRestaurant(e.target.value)}
            className="input-field"
          >
            <option value="all">Все рестораны</option>
            {restaurants.map(restaurant => (
              <option key={restaurant} value={restaurant}>{restaurant}</option>
            ))}
          </select>

          {/* Date filter */}
          <select
            value={selectedDate}
            onChange={(e) => setSelectedDate(e.target.value)}
            className="input-field"
          >
            <option value="all">Все даты</option>
            <option value="today">Сегодня</option>
            <option value="tomorrow">Завтра</option>
            <option value="week">На неделю</option>
          </select>

          {/* Guest count filter */}
          <select className="input-field">
            <option value="all">Любое количество гостей</option>
            <option value="1-2">1-2 гостя</option>
            <option value="3-4">3-4 гостя</option>
            <option value="5+">5+ гостей</option>
          </select>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div className="card">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Всего бронирований</p>
              <p className="text-2xl font-bold text-gray-900">{stats.total}</p>
            </div>
            <div className="p-3 bg-blue-100 rounded-lg">
              <CalendarIcon className="h-6 w-6 text-blue-600" />
            </div>
          </div>
        </div>

        <div className="card">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Ожидают подтверждения</p>
              <p className="text-2xl font-bold text-gray-900">{stats.pending}</p>
            </div>
            <div className="p-3 bg-yellow-100 rounded-lg">
              <ClockIcon className="h-6 w-6 text-yellow-600" />
            </div>
          </div>
        </div>

        <div className="card">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Подтверждены</p>
              <p className="text-2xl font-bold text-gray-900">{stats.confirmed}</p>
            </div>
            <div className="p-3 bg-green-100 rounded-lg">
              <CheckCircleIcon className="h-6 w-6 text-green-600" />
            </div>
          </div>
        </div>

        <div className="card">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">На сегодня</p>
              <p className="text-2xl font-bold text-gray-900">{stats.today}</p>
            </div>
            <div className="p-3 bg-purple-100 rounded-lg">
              <ExclamationTriangleIcon className="h-6 w-6 text-purple-600" />
            </div>
          </div>
        </div>
      </div>

      {/* Reservations table */}
      <div className="card">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Бронирование
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Клиент
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Ресторан
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Дата и время
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Гости
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
              {filteredReservations.map((reservation, index) => (
                <motion.tr
                  key={reservation.id}
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: index * 0.1 }}
                  className="hover:bg-gray-50"
                >
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div>
                      <div className="text-sm font-medium text-gray-900">{reservation.id}</div>
                      <div className="text-sm text-gray-500">
                        {new Date(reservation.createdAt).toLocaleDateString('ru-RU')}
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <div className="w-8 h-8 bg-gray-200 rounded-full flex items-center justify-center">
                        <UserIcon className="h-4 w-4 text-gray-500" />
                      </div>
                      <div className="ml-3">
                        <div className="text-sm font-medium text-gray-900">{reservation.customer.name}</div>
                        <div className="text-sm text-gray-500">{reservation.customer.phone}</div>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div>
                      <div className="text-sm font-medium text-gray-900">{reservation.restaurant.name}</div>
                      <div className="text-sm text-gray-500">{reservation.restaurant.address}</div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">
                      {new Date(reservation.date).toLocaleDateString('ru-RU')}
                    </div>
                    <div className="text-sm text-gray-500">
                      {new Date(reservation.date).toLocaleTimeString('ru-RU', { hour: '2-digit', minute: '2-digit' })}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm font-medium text-gray-900">
                      {reservation.guestCount} {reservation.guestCount === 1 ? 'гость' : 'гостей'}
                    </div>
                    {reservation.tableNumber && (
                      <div className="text-sm text-gray-500">
                        Стол {reservation.tableNumber}
                      </div>
                    )}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${statusColors[reservation.status]}`}>
                      {statusNames[reservation.status]}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <div className="flex space-x-2">
                      <button className="text-blue-600 hover:text-blue-900">
                        <EyeIcon className="h-4 w-4" />
                      </button>
                      {reservation.status === ReservationStatus.PENDING && (
                        <button className="text-green-600 hover:text-green-900">
                          <CheckCircleIcon className="h-4 w-4" />
                        </button>
                      )}
                      {reservation.status === ReservationStatus.PENDING && (
                        <button className="text-red-600 hover:text-red-900">
                          <XCircleIcon className="h-4 w-4" />
                        </button>
                      )}
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