'use client'

import { useState } from 'react'
import { motion } from 'framer-motion'
import { 
  PlusIcon, 
  MagnifyingGlassIcon,
  TruckIcon,
  CurrencyDollarIcon,
  ClockIcon,
  EyeIcon,
  CheckCircleIcon,
  XCircleIcon,
  ExclamationTriangleIcon
} from '@heroicons/react/24/outline'
import { OrderStatus, PaymentMethod, DeliveryType } from '@/types'
import Layout from '@/components/Layout'

const mockOrders = [
  {
    id: 'ORD-001',
    customer: {
      name: 'Алексей Петров',
      phone: '+7 (999) 123-45-67',
      email: 'alexey@example.com'
    },
    restaurant: {
      name: 'THE БЫК на Тверской',
      address: 'ул. Тверская, 15'
    },
    items: [
      { name: 'Рибай стейк', quantity: 1, price: 3200 },
      { name: 'Картофель фри', quantity: 1, price: 250 },
      { name: 'Кока-кола', quantity: 2, price: 150 }
    ],
    total: 3750,
    status: OrderStatus.IN_DELIVERY,
    paymentMethod: PaymentMethod.CARD,
    deliveryType: DeliveryType.DELIVERY,
    deliveryAddress: 'ул. Арбат, 25, кв. 15',
    createdAt: '2024-01-15T14:30:00Z',
    estimatedDelivery: '2024-01-15T15:15:00Z',
    actualDelivery: null,
    notes: 'Позвонить за 10 минут до доставки'
  },
  {
    id: 'ORD-002',
    customer: {
      name: 'Мария Сидорова',
      phone: '+7 (999) 234-56-78',
      email: 'maria@example.com'
    },
    restaurant: {
      name: 'THE ПИВО на Арбате',
      address: 'ул. Арбат, 25'
    },
    items: [
      { name: 'Фирменные колбаски', quantity: 1, price: 890 },
      { name: 'Пиво светлое', quantity: 2, price: 300 }
    ],
    total: 1490,
    status: OrderStatus.PREPARING,
    paymentMethod: PaymentMethod.CASH,
    deliveryType: DeliveryType.PICKUP,
    deliveryAddress: null,
    createdAt: '2024-01-15T15:00:00Z',
    estimatedDelivery: '2024-01-15T15:30:00Z',
    actualDelivery: null,
    notes: ''
  },
  {
    id: 'ORD-003',
    customer: {
      name: 'Дмитрий Козлов',
      phone: '+7 (999) 345-67-89',
      email: 'dmitry@example.com'
    },
    restaurant: {
      name: 'MOSCA в Сити',
      address: 'Пресненская наб., 8с1'
    },
    items: [
      { name: 'Пицца Маргарита', quantity: 1, price: 650 },
      { name: 'Салат Цезарь', quantity: 1, price: 450 },
      { name: 'Вино красное', quantity: 1, price: 800 }
    ],
    total: 1900,
    status: OrderStatus.COMPLETED,
    paymentMethod: PaymentMethod.CARD,
    deliveryType: DeliveryType.DELIVERY,
    deliveryAddress: 'ул. Тверская, 10, кв. 5',
    createdAt: '2024-01-15T13:00:00Z',
    estimatedDelivery: '2024-01-15T13:45:00Z',
    actualDelivery: '2024-01-15T13:42:00Z',
    notes: 'Доставить к подъезду'
  },
  {
    id: 'ORD-004',
    customer: {
      name: 'Анна Волкова',
      phone: '+7 (999) 456-78-90',
      email: 'anna@example.com'
    },
    restaurant: {
      name: 'THE ГРУЗИЯ на Арбате',
      address: 'ул. Арбат, 30'
    },
    items: [
      { name: 'Хинкали', quantity: 2, price: 490 },
      { name: 'Хачапури', quantity: 1, price: 350 }
    ],
    total: 1330,
    status: OrderStatus.CANCELLED,
    paymentMethod: PaymentMethod.CARD,
    deliveryType: DeliveryType.DELIVERY,
    deliveryAddress: 'ул. Новый Арбат, 15, кв. 8',
    createdAt: '2024-01-15T16:00:00Z',
    estimatedDelivery: '2024-01-15T16:30:00Z',
    actualDelivery: null,
    notes: 'Отменен клиентом'
  }
]

const statusColors = {
  [OrderStatus.PENDING]: 'bg-yellow-100 text-yellow-800',
  [OrderStatus.CONFIRMED]: 'bg-blue-100 text-blue-800',
  [OrderStatus.PREPARING]: 'bg-orange-100 text-orange-800',
  [OrderStatus.READY]: 'bg-purple-100 text-purple-800',
  [OrderStatus.IN_DELIVERY]: 'bg-indigo-100 text-indigo-800',
  [OrderStatus.COMPLETED]: 'bg-green-100 text-green-800',
  [OrderStatus.CANCELLED]: 'bg-red-100 text-red-800'
}

const statusIcons = {
  [OrderStatus.PENDING]: ClockIcon,
  [OrderStatus.CONFIRMED]: CheckCircleIcon,
  [OrderStatus.PREPARING]: ExclamationTriangleIcon,
  [OrderStatus.READY]: CheckCircleIcon,
  [OrderStatus.IN_DELIVERY]: TruckIcon,
  [OrderStatus.COMPLETED]: CheckCircleIcon,
  [OrderStatus.CANCELLED]: XCircleIcon
}

const statusNames = {
  [OrderStatus.PENDING]: 'Ожидает подтверждения',
  [OrderStatus.CONFIRMED]: 'Подтвержден',
  [OrderStatus.PREPARING]: 'Готовится',
  [OrderStatus.READY]: 'Готов к выдаче',
  [OrderStatus.IN_DELIVERY]: 'В доставке',
  [OrderStatus.COMPLETED]: 'Завершен',
  [OrderStatus.CANCELLED]: 'Отменен'
}

export default function OrdersPage() {
  const [searchTerm, setSearchTerm] = useState('')
  const [selectedStatus, setSelectedStatus] = useState<OrderStatus | 'all'>('all')
  const [selectedRestaurant, setSelectedRestaurant] = useState<string>('all')

  const filteredOrders = mockOrders.filter(order => {
    const matchesSearch = order.id.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         order.customer.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         order.customer.phone.includes(searchTerm)
    const matchesStatus = selectedStatus === 'all' || order.status === selectedStatus
    const matchesRestaurant = selectedRestaurant === 'all' || order.restaurant.name === selectedRestaurant
    
    return matchesSearch && matchesStatus && matchesRestaurant
  })

  const restaurants = Array.from(new Set(mockOrders.map(o => o.restaurant.name)))

  const stats = {
    total: mockOrders.length,
    pending: mockOrders.filter(o => o.status === OrderStatus.PENDING).length,
    inProgress: mockOrders.filter(o => 
      [OrderStatus.CONFIRMED, OrderStatus.PREPARING, OrderStatus.READY, OrderStatus.IN_DELIVERY].includes(o.status)
    ).length,
    completed: mockOrders.filter(o => o.status === OrderStatus.COMPLETED).length,
    revenue: mockOrders.filter(o => o.status === OrderStatus.COMPLETED).reduce((acc, o) => acc + o.total, 0)
  }

  return (
    <Layout>
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Заказы</h1>
          <p className="text-gray-600">Управление заказами и доставкой</p>
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
              placeholder="Поиск заказов..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="input-field pl-10"
            />
          </div>

          {/* Status filter */}
          <select
            value={selectedStatus}
            onChange={(e) => setSelectedStatus(e.target.value as OrderStatus | 'all')}
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
          <select className="input-field">
            <option value="today">Сегодня</option>
            <option value="week">За неделю</option>
            <option value="month">За месяц</option>
            <option value="all">Все время</option>
          </select>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-5 gap-6">
        <div className="card">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Всего заказов</p>
              <p className="text-2xl font-bold text-gray-900">{stats.total}</p>
            </div>
            <div className="p-3 bg-blue-100 rounded-lg">
              <TruckIcon className="h-6 w-6 text-blue-600" />
            </div>
          </div>
        </div>

        <div className="card">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Ожидают</p>
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
              <p className="text-sm font-medium text-gray-600">В работе</p>
              <p className="text-2xl font-bold text-gray-900">{stats.inProgress}</p>
            </div>
            <div className="p-3 bg-orange-100 rounded-lg">
              <ExclamationTriangleIcon className="h-6 w-6 text-orange-600" />
            </div>
          </div>
        </div>

        <div className="card">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Завершены</p>
              <p className="text-2xl font-bold text-gray-900">{stats.completed}</p>
            </div>
            <div className="p-3 bg-green-100 rounded-lg">
              <CheckCircleIcon className="h-6 w-6 text-green-600" />
            </div>
          </div>
        </div>

        <div className="card">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Выручка</p>
              <p className="text-2xl font-bold text-gray-900">{stats.revenue.toLocaleString()} ₽</p>
            </div>
            <div className="p-3 bg-purple-100 rounded-lg">
              <CurrencyDollarIcon className="h-6 w-6 text-purple-600" />
            </div>
          </div>
        </div>
      </div>

      {/* Orders table */}
      <div className="card">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Заказ
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Клиент
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Ресторан
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Сумма
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Статус
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Время
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Действия
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredOrders.map((order, index) => {
                const StatusIcon = statusIcons[order.status]
                return (
                  <motion.tr
                    key={order.id}
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: index * 0.1 }}
                    className="hover:bg-gray-50"
                  >
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div>
                        <div className="text-sm font-medium text-gray-900">{order.id}</div>
                        <div className="text-sm text-gray-500">
                          {new Date(order.createdAt).toLocaleString('ru-RU')}
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        <div className="w-8 h-8 bg-gray-200 rounded-full flex items-center justify-center">
                          {/* Assuming UserIcon is available, otherwise replace with a placeholder */}
                          {/* <UserIcon className="h-4 w-4 text-gray-500" /> */}
                        </div>
                        <div className="ml-3">
                          <div className="text-sm font-medium text-gray-900">{order.customer.name}</div>
                          <div className="text-sm text-gray-500">{order.customer.phone}</div>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div>
                        <div className="text-sm font-medium text-gray-900">{order.restaurant.name}</div>
                        <div className="text-sm text-gray-500">{order.restaurant.address}</div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm font-medium text-gray-900">{order.total.toLocaleString()} ₽</div>
                      <div className="text-sm text-gray-500">
                        {order.items.length} {order.items.length === 1 ? 'позиция' : 'позиции'}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        <StatusIcon className="h-4 w-4 mr-2" />
                        <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${statusColors[order.status]}`}>
                          {statusNames[order.status]}
                        </span>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm text-gray-900">
                        {order.estimatedDelivery ? 
                          new Date(order.estimatedDelivery).toLocaleTimeString('ru-RU', { hour: '2-digit', minute: '2-digit' }) : 
                          '-'
                        }
                      </div>
                      <div className="text-sm text-gray-500">
                        {order.deliveryType === DeliveryType.DELIVERY ? 'Доставка' : 'Самовывоз'}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                      <div className="flex space-x-2">
                        <button className="text-blue-600 hover:text-blue-900">
                          <EyeIcon className="h-4 w-4" />
                        </button>
                        {order.status === OrderStatus.PENDING && (
                          <button className="text-green-600 hover:text-green-900">
                            <CheckCircleIcon className="h-4 w-4" />
                          </button>
                        )}
                        {order.status === OrderStatus.PENDING && (
                          <button className="text-red-600 hover:text-red-900">
                            <XCircleIcon className="h-4 w-4" />
                          </button>
                        )}
                      </div>
                    </td>
                  </motion.tr>
                )
              })}
            </tbody>
          </table>
        </div>
      </div>
    </Layout>
  )
} 