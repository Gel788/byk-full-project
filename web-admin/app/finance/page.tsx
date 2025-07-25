'use client'

import { useState } from 'react'
import { motion } from 'framer-motion'
import { 
  CurrencyDollarIcon,
  ArrowUpIcon,
  ArrowDownIcon,
  ChartBarIcon,
  CalendarIcon,
  BuildingStorefrontIcon,
  TruckIcon,
  UserIcon
} from '@heroicons/react/24/outline'
import { RestaurantBrand } from '@/types'
import Layout from '@/components/Layout'

const mockFinancialData = {
  currentMonth: {
    revenue: 2450000,
    orders: 1250,
    averageOrder: 1960,
    growth: 12.5
  },
  previousMonth: {
    revenue: 2180000,
    orders: 1100,
    averageOrder: 1982,
    growth: -2.3
  },
  byRestaurant: [
    {
      name: 'THE БЫК на Тверской',
      brand: RestaurantBrand.THE_BYK,
      revenue: 850000,
      orders: 420,
      averageOrder: 2024,
      growth: 15.2
    },
    {
      name: 'THE ПИВО на Арбате',
      brand: RestaurantBrand.THE_PIVO,
      revenue: 620000,
      orders: 380,
      averageOrder: 1632,
      growth: 8.7
    },
    {
      name: 'MOSCA в Сити',
      brand: RestaurantBrand.MOSCA,
      revenue: 580000,
      orders: 290,
      averageOrder: 2000,
      growth: 5.4
    },
    {
      name: 'THE ГРУЗИЯ на Арбате',
      brand: RestaurantBrand.THE_GEORGIA,
      revenue: 400000,
      orders: 160,
      averageOrder: 2500,
      growth: 22.1
    }
  ],
  dailyRevenue: [
    { date: '2024-01-01', revenue: 85000 },
    { date: '2024-01-02', revenue: 92000 },
    { date: '2024-01-03', revenue: 78000 },
    { date: '2024-01-04', revenue: 105000 },
    { date: '2024-01-05', revenue: 120000 },
    { date: '2024-01-06', revenue: 135000 },
    { date: '2024-01-07', revenue: 95000 },
    { date: '2024-01-08', revenue: 88000 },
    { date: '2024-01-09', revenue: 102000 },
    { date: '2024-01-10', revenue: 115000 },
    { date: '2024-01-11', revenue: 125000 },
    { date: '2024-01-12', revenue: 140000 },
    { date: '2024-01-13', revenue: 150000 },
    { date: '2024-01-14', revenue: 130000 },
    { date: '2024-01-15', revenue: 145000 }
  ]
}

const brandColors = {
  [RestaurantBrand.THE_BYK]: 'bg-gradient-to-r from-byk-500 to-byk-600',
  [RestaurantBrand.THE_PIVO]: 'bg-gradient-to-r from-pivo-500 to-pivo-600',
  [RestaurantBrand.MOSCA]: 'bg-gradient-to-r from-mosca-500 to-mosca-600',
  [RestaurantBrand.THE_GEORGIA]: 'bg-gradient-to-r from-georgia-500 to-georgia-600'
}

export default function FinancePage() {
  const [selectedPeriod, setSelectedPeriod] = useState<'week' | 'month' | 'quarter' | 'year'>('month')

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('ru-RU', {
      style: 'currency',
      currency: 'RUB',
      minimumFractionDigits: 0,
      maximumFractionDigits: 0
    }).format(amount)
  }

  const formatGrowth = (growth: number) => {
    const isPositive = growth >= 0
    return (
      <div className={`flex items-center ${isPositive ? 'text-green-600' : 'text-red-600'}`}>
        {isPositive ? (
          <ArrowUpIcon className="h-4 w-4 mr-1" />
        ) : (
          <ArrowDownIcon className="h-4 w-4 mr-1" />
        )}
        <span className="text-sm font-medium">
          {isPositive ? '+' : ''}{growth.toFixed(1)}%
        </span>
      </div>
    )
  }

  return (
    <Layout>
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Финансы</h1>
          <p className="text-gray-600">Финансовая аналитика и отчеты</p>
        </div>
        <div className="flex space-x-2">
          <select
            value={selectedPeriod}
            onChange={(e) => setSelectedPeriod(e.target.value as 'week' | 'month' | 'quarter' | 'year')}
            className="input-field"
          >
            <option value="week">Неделя</option>
            <option value="month">Месяц</option>
            <option value="quarter">Квартал</option>
            <option value="year">Год</option>
          </select>
        </div>
      </div>

      {/* Main Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
          className="card"
        >
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Общая выручка</p>
              <p className="text-2xl font-bold text-gray-900">
                {formatCurrency(mockFinancialData.currentMonth.revenue)}
              </p>
              {formatGrowth(mockFinancialData.currentMonth.growth)}
            </div>
            <div className="p-3 bg-green-100 rounded-lg">
              <CurrencyDollarIcon className="h-6 w-6 text-green-600" />
            </div>
          </div>
        </motion.div>

        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
          className="card"
        >
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Количество заказов</p>
              <p className="text-2xl font-bold text-gray-900">
                {mockFinancialData.currentMonth.orders.toLocaleString()}
              </p>
              <div className="text-sm text-gray-500">
                Средний чек: {formatCurrency(mockFinancialData.currentMonth.averageOrder)}
              </div>
            </div>
            <div className="p-3 bg-blue-100 rounded-lg">
              <TruckIcon className="h-6 w-6 text-blue-600" />
            </div>
          </div>
        </motion.div>

        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
          className="card"
        >
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Активные рестораны</p>
              <p className="text-2xl font-bold text-gray-900">4</p>
              <div className="text-sm text-gray-500">
                Всего заказов сегодня: 47
              </div>
            </div>
            <div className="p-3 bg-purple-100 rounded-lg">
              <BuildingStorefrontIcon className="h-6 w-6 text-purple-600" />
            </div>
          </div>
        </motion.div>

        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.4 }}
          className="card"
        >
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Новые клиенты</p>
              <p className="text-2xl font-bold text-gray-900">23</p>
              <div className="text-sm text-gray-500">
                За текущий месяц
              </div>
            </div>
            <div className="p-3 bg-orange-100 rounded-lg">
              <UserIcon className="h-6 w-6 text-orange-600" />
            </div>
          </div>
        </motion.div>
      </div>

      {/* Revenue Chart Placeholder */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.5 }}
        className="card"
      >
        <div className="flex items-center justify-between mb-6">
          <h3 className="text-lg font-semibold text-gray-900">Динамика выручки</h3>
          <div className="flex space-x-2">
            <button className="px-3 py-1 text-sm bg-primary-100 text-primary-700 rounded-lg">
              График
            </button>
            <button className="px-3 py-1 text-sm bg-gray-100 text-gray-600 rounded-lg">
              Таблица
            </button>
          </div>
        </div>
        <div className="h-64 bg-gray-50 rounded-lg flex items-center justify-center">
          <div className="text-center">
            <ChartBarIcon className="h-12 w-12 text-gray-400 mx-auto mb-2" />
            <p className="text-gray-500">График выручки по дням</p>
            <p className="text-sm text-gray-400">Интеграция с Recharts</p>
          </div>
        </div>
      </motion.div>

      {/* Restaurant Performance */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.6 }}
        className="card"
      >
        <h3 className="text-lg font-semibold text-gray-900 mb-6">Выручка по ресторанам</h3>
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Ресторан
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Выручка
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Заказы
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Средний чек
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Рост
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {mockFinancialData.byRestaurant.map((restaurant, index) => (
                <motion.tr
                  key={restaurant.name}
                  initial={{ opacity: 0, x: -20 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: 0.7 + index * 0.1 }}
                  className="hover:bg-gray-50"
                >
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <div className={`w-8 h-8 rounded-lg ${brandColors[restaurant.brand]} flex items-center justify-center`}>
                        <span className="text-white font-bold text-xs">
                          {restaurant.name.split(' ')[1]?.[0] || 'R'}
                        </span>
                      </div>
                      <div className="ml-3">
                        <div className="text-sm font-medium text-gray-900">{restaurant.name}</div>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm font-medium text-gray-900">
                      {formatCurrency(restaurant.revenue)}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">{restaurant.orders}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">
                      {formatCurrency(restaurant.averageOrder)}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    {formatGrowth(restaurant.growth)}
                  </td>
                </motion.tr>
              ))}
            </tbody>
          </table>
        </div>
      </motion.div>

      {/* Additional Analytics */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.8 }}
          className="card"
        >
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Топ блюд по выручке</h3>
          <div className="space-y-3">
            <div className="flex items-center justify-between">
              <div className="flex items-center">
                <div className="w-8 h-8 bg-gray-200 rounded-lg flex items-center justify-center">
                  <span className="text-xs font-medium">1</span>
                </div>
                <span className="ml-3 text-sm font-medium">Рибай стейк</span>
              </div>
              <span className="text-sm font-medium text-gray-900">320,000 ₽</span>
            </div>
            <div className="flex items-center justify-between">
              <div className="flex items-center">
                <div className="w-8 h-8 bg-gray-200 rounded-lg flex items-center justify-center">
                  <span className="text-xs font-medium">2</span>
                </div>
                <span className="ml-3 text-sm font-medium">Фирменные колбаски</span>
              </div>
              <span className="text-sm font-medium text-gray-900">180,000 ₽</span>
            </div>
            <div className="flex items-center justify-between">
              <div className="flex items-center">
                <div className="w-8 h-8 bg-gray-200 rounded-lg flex items-center justify-center">
                  <span className="text-xs font-medium">3</span>
                </div>
                <span className="ml-3 text-sm font-medium">Пицца Маргарита</span>
              </div>
              <span className="text-sm font-medium text-gray-900">150,000 ₽</span>
            </div>
          </div>
        </motion.div>

        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.9 }}
          className="card"
        >
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Популярные часы</h3>
          <div className="space-y-3">
            <div className="flex items-center justify-between">
              <span className="text-sm font-medium">19:00 - 21:00</span>
              <div className="flex items-center">
                <div className="w-24 bg-gray-200 rounded-full h-2 mr-2">
                  <div className="bg-primary-600 h-2 rounded-full" style={{ width: '85%' }}></div>
                </div>
                <span className="text-sm text-gray-600">85%</span>
              </div>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-sm font-medium">12:00 - 14:00</span>
              <div className="flex items-center">
                <div className="w-24 bg-gray-200 rounded-full h-2 mr-2">
                  <div className="bg-primary-600 h-2 rounded-full" style={{ width: '70%' }}></div>
                </div>
                <span className="text-sm text-gray-600">70%</span>
              </div>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-sm font-medium">21:00 - 23:00</span>
              <div className="flex items-center">
                <div className="w-24 bg-gray-200 rounded-full h-2 mr-2">
                  <div className="bg-primary-600 h-2 rounded-full" style={{ width: '60%' }}></div>
                </div>
                <span className="text-sm text-gray-600">60%</span>
              </div>
            </div>
          </div>
        </motion.div>
      </div>
    </Layout>
  )
} 