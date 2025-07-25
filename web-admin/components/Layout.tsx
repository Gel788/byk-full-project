'use client'

import { useState, useEffect } from 'react'
import { motion } from 'framer-motion'
import { usePathname } from 'next/navigation'
import { 
  BuildingStorefrontIcon, 
  UsersIcon, 
  CurrencyDollarIcon, 
  ChartBarIcon,
  CalendarIcon,
  TruckIcon,
  BellIcon,
  CogIcon,
  Bars3Icon,
  XMarkIcon,
  NewspaperIcon
} from '@heroicons/react/24/outline'
import { 
  BuildingStorefrontIcon as BuildingStorefrontSolid,
  UsersIcon as UsersSolid,
  CurrencyDollarIcon as CurrencyDollarSolid,
  ChartBarIcon as ChartBarSolid,
  CalendarIcon as CalendarSolid,
  TruckIcon as TruckSolid,
  BellIcon as BellSolid,
  CogIcon as CogSolid,
  NewspaperIcon as NewspaperSolid
} from '@heroicons/react/24/solid'

const navigation = [
  { name: 'Дашборд', href: '/', icon: ChartBarIcon, iconSolid: ChartBarSolid },
  { name: 'Рестораны', href: '/restaurants', icon: BuildingStorefrontIcon, iconSolid: BuildingStorefrontSolid },
  { name: 'Меню', href: '/menu', icon: CogIcon, iconSolid: CogSolid },
  { name: 'Заказы', href: '/orders', icon: TruckIcon, iconSolid: TruckSolid },
  { name: 'Бронирования', href: '/reservations', icon: CalendarIcon, iconSolid: CalendarSolid },
  { name: 'Пользователи', href: '/users', icon: UsersIcon, iconSolid: UsersSolid },
  { name: 'Финансы', href: '/finance', icon: CurrencyDollarIcon, iconSolid: CurrencyDollarSolid },
  { name: 'Новости', href: '/news', icon: NewspaperIcon, iconSolid: NewspaperSolid },
  { name: 'Уведомления', href: '/notifications', icon: BellIcon, iconSolid: BellSolid },
]

interface LayoutProps {
  children: React.ReactNode
  title?: string
  description?: string
}

export default function Layout({ children, title = 'Админ панель', description }: LayoutProps) {
  const [sidebarOpen, setSidebarOpen] = useState(false)
  const pathname = usePathname()
  
  // Определяем активную страницу на основе текущего пути
  const getActivePage = () => {
    if (pathname === '/') return 'Дашборд'
    const page = navigation.find(item => item.href === pathname)
    return page ? page.name : 'Дашборд'
  }

  const activePage = getActivePage()

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Mobile sidebar */}
      <div className={`fixed inset-0 z-50 lg:hidden ${sidebarOpen ? 'block' : 'hidden'}`}>
        <div className="fixed inset-0 bg-gray-600 bg-opacity-75" onClick={() => setSidebarOpen(false)} />
        <div className="fixed inset-y-0 left-0 flex w-64 flex-col bg-white">
          <div className="flex h-16 items-center justify-between px-4">
            <h1 className="text-xl font-bold text-gray-900">
              <span className="text-byk-600">THE БЫК</span> Админ
            </h1>
            <button
              onClick={() => setSidebarOpen(false)}
              className="text-gray-400 hover:text-gray-500"
            >
              <XMarkIcon className="h-6 w-6" />
            </button>
          </div>
          <nav className="flex-1 space-y-2 px-4 py-4">
            {navigation.map((item) => {
              const isActive = activePage === item.name
              const Icon = isActive ? item.iconSolid : item.icon
              return (
                <motion.a
                  key={item.name}
                  href={item.href}
                  className={`sidebar-item ${isActive ? 'active' : ''}`}
                  whileHover={{ x: 4 }}
                  whileTap={{ scale: 0.98 }}
                  onClick={() => setSidebarOpen(false)}
                >
                  <Icon className="mr-3 h-5 w-5" />
                  {item.name}
                </motion.a>
              )
            })}
          </nav>
        </div>
      </div>

      {/* Desktop sidebar */}
      <div className="hidden lg:fixed lg:inset-y-0 lg:flex lg:w-64 lg:flex-col">
        <div className="flex flex-col flex-grow bg-white shadow-sm border-r border-gray-200">
          <div className="flex h-16 items-center px-4">
            <h1 className="text-xl font-bold text-gray-900">
              <span className="text-byk-600">THE БЫК</span> Админ
            </h1>
          </div>
          <nav className="flex-1 space-y-2 px-4 py-4">
            {navigation.map((item) => {
              const isActive = activePage === item.name
              const Icon = isActive ? item.iconSolid : item.icon
              return (
                <motion.a
                  key={item.name}
                  href={item.href}
                  className={`sidebar-item ${isActive ? 'active' : ''}`}
                  whileHover={{ x: 4 }}
                  whileTap={{ scale: 0.98 }}
                >
                  <Icon className="mr-3 h-5 w-5" />
                  {item.name}
                </motion.a>
              )
            })}
          </nav>
        </div>
      </div>

      {/* Main content */}
      <div className="lg:pl-64">
        {/* Header */}
        <header className="bg-white shadow-sm border-b border-gray-200">
          <div className="flex h-16 items-center justify-between px-4 sm:px-6 lg:px-8">
            <div className="flex items-center">
              <button
                onClick={() => setSidebarOpen(true)}
                className="lg:hidden p-2 text-gray-400 hover:text-gray-500"
              >
                <Bars3Icon className="h-6 w-6" />
              </button>
              <div className="ml-4 lg:ml-0">
                <h2 className="text-xl font-semibold text-gray-900">{title}</h2>
                {description && (
                  <p className="text-sm text-gray-600">{description}</p>
                )}
              </div>
            </div>
            <div className="flex items-center space-x-4">
              <button className="p-2 text-gray-400 hover:text-gray-500">
                <BellIcon className="h-6 w-6" />
              </button>
              <div className="flex items-center space-x-2">
                <div className="w-8 h-8 bg-byk-600 rounded-full flex items-center justify-center">
                  <span className="text-white text-sm font-medium">А</span>
                </div>
                <span className="text-sm font-medium text-gray-700">Администратор</span>
              </div>
            </div>
          </div>
        </header>

        {/* Page content */}
        <main className="p-4 sm:p-6 lg:p-8">
          <div className="max-w-7xl mx-auto">
            {children}
          </div>
        </main>
      </div>
    </div>
  )
} 