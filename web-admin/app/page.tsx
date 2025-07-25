'use client'

import { motion } from 'framer-motion'
import Layout from '@/components/Layout'

const stats = [
  { name: 'Всего ресторанов', value: '12', change: '+2', changeType: 'positive' },
  { name: 'Активных заказов', value: '47', change: '+12', changeType: 'positive' },
  { name: 'Бронирований сегодня', value: '23', change: '+5', changeType: 'positive' },
  { name: 'Выручка за месяц', value: '2.4M ₽', change: '+18%', changeType: 'positive' },
]

const recentOrders = [
  { id: 1, restaurant: 'THE БЫК на Тверской', customer: 'Алексей Петров', amount: '3,200 ₽', status: 'В доставке' },
  { id: 2, restaurant: 'THE ПИВО на Арбате', customer: 'Мария Сидорова', amount: '1,890 ₽', status: 'Готовится' },
  { id: 3, restaurant: 'MOSCA в Сити', customer: 'Дмитрий Козлов', amount: '2,450 ₽', status: 'Подтвержден' },
  { id: 4, restaurant: 'THE ГРУЗИЯ на Арбате', customer: 'Анна Волкова', amount: '1,750 ₽', status: 'Завершен' },
]

export default function Dashboard() {
  return (
    <Layout title="Дашборд" description="Обзор деятельности сети ресторанов THE БЫК">
      {/* Stats grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        {stats.map((stat, index) => (
          <motion.div
            key={stat.name}
            className="card"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: index * 0.1 }}
          >
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-600">{stat.name}</p>
                <p className="text-2xl font-bold text-gray-900">{stat.value}</p>
              </div>
              <div className={`px-2 py-1 rounded-full text-xs font-medium ${
                stat.changeType === 'positive' 
                  ? 'bg-green-100 text-green-800' 
                  : 'bg-red-100 text-red-800'
              }`}>
                {stat.change}
              </div>
            </div>
          </motion.div>
        ))}
      </div>

      {/* Recent orders */}
      <div className="card">
        <div className="flex items-center justify-between mb-6">
          <h3 className="text-lg font-semibold text-gray-900">Последние заказы</h3>
          <a href="/orders" className="text-sm text-primary-600 hover:text-primary-700">
            Посмотреть все
          </a>
        </div>
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Ресторан
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Клиент
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Сумма
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Статус
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {recentOrders.map((order) => (
                <tr key={order.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                    {order.restaurant}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {order.customer}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {order.amount}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className="inline-flex px-2 py-1 text-xs font-semibold rounded-full bg-green-100 text-green-800">
                      {order.status}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </Layout>
  )
} 