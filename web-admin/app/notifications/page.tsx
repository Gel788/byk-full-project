'use client'

import { useState } from 'react'
import { motion } from 'framer-motion'
import { 
  PlusIcon, 
  MagnifyingGlassIcon,
  BellIcon,
  EyeIcon,
  PencilIcon,
  TrashIcon,
  CheckIcon,
  XMarkIcon
} from '@heroicons/react/24/outline'
import { NotificationType, NotificationPriority } from '@/types'
import Layout from '@/components/Layout'
import Modal from '@/components/Modal'

const mockNotifications = [
  {
    id: '1',
    title: 'Новое блюдо добавлено в меню',
    message: 'В ресторане THE БЫК добавлено новое блюдо "Рибай стейк"',
    type: NotificationType.MENU_UPDATE,
    priority: NotificationPriority.MEDIUM,
    isRead: false,
    createdAt: '2024-01-15T10:00:00Z',
    expiresAt: '2024-01-22T10:00:00Z',
    targetAudience: 'all',
    restaurantId: '1'
  },
  {
    id: '2',
    title: 'Система бронирования недоступна',
    message: 'Плановые работы по обновлению системы бронирования',
    type: NotificationType.SYSTEM_ALERT,
    priority: NotificationPriority.HIGH,
    isRead: true,
    createdAt: '2024-01-14T15:30:00Z',
    expiresAt: '2024-01-16T15:30:00Z',
    targetAudience: 'all',
    restaurantId: null
  },
  {
    id: '3',
    title: 'Специальное предложение',
    message: 'Скидка 20% на все блюда в ресторане THE ПИВО до конца недели',
    type: NotificationType.PROMOTION,
    priority: NotificationPriority.LOW,
    isRead: false,
    createdAt: '2024-01-13T12:00:00Z',
    expiresAt: '2024-01-20T12:00:00Z',
    targetAudience: 'customers',
    restaurantId: '2'
  },
  {
    id: '4',
    title: 'Новый заказ требует внимания',
    message: 'Заказ #12345 требует подтверждения от администратора',
    type: NotificationType.ORDER_ALERT,
    priority: NotificationPriority.HIGH,
    isRead: false,
    createdAt: '2024-01-12T09:15:00Z',
    expiresAt: '2024-01-13T09:15:00Z',
    targetAudience: 'staff',
    restaurantId: '1'
  }
]

const notificationTypes = {
  [NotificationType.MENU_UPDATE]: { name: 'Обновление меню', color: 'bg-blue-100 text-blue-800', icon: '🍽️' },
  [NotificationType.SYSTEM_ALERT]: { name: 'Системное уведомление', color: 'bg-red-100 text-red-800', icon: '⚠️' },
  [NotificationType.PROMOTION]: { name: 'Акция', color: 'bg-green-100 text-green-800', icon: '🎉' },
  [NotificationType.ORDER_ALERT]: { name: 'Заказ', color: 'bg-orange-100 text-orange-800', icon: '📦' },
  [NotificationType.RESERVATION_ALERT]: { name: 'Бронирование', color: 'bg-purple-100 text-purple-800', icon: '📅' },
  [NotificationType.REVIEW_ALERT]: { name: 'Отзыв', color: 'bg-yellow-100 text-yellow-800', icon: '⭐' }
} as const

const priorityColors = {
  [NotificationPriority.LOW]: 'bg-gray-100 text-gray-800',
  [NotificationPriority.MEDIUM]: 'bg-blue-100 text-blue-800',
  [NotificationPriority.HIGH]: 'bg-red-100 text-red-800',
  [NotificationPriority.URGENT]: 'bg-red-200 text-red-900'
} as const

const priorityNames = {
  [NotificationPriority.LOW]: 'Низкий',
  [NotificationPriority.MEDIUM]: 'Средний',
  [NotificationPriority.HIGH]: 'Высокий',
  [NotificationPriority.URGENT]: 'Срочный'
} as const

export default function NotificationsPage() {
  const [searchTerm, setSearchTerm] = useState('')
  const [selectedType, setSelectedType] = useState<NotificationType | 'all'>('all')
  const [selectedPriority, setSelectedPriority] = useState<NotificationPriority | 'all'>('all')
  const [showRead, setShowRead] = useState<'all' | 'read' | 'unread'>('all')
  const [isAddModalOpen, setIsAddModalOpen] = useState(false)
  const [isViewModalOpen, setIsViewModalOpen] = useState(false)
  const [isEditModalOpen, setIsEditModalOpen] = useState(false)
  const [selectedNotification, setSelectedNotification] = useState<typeof mockNotifications[0] | null>(null)

  const filteredNotifications = mockNotifications.filter(notification => {
    const matchesSearch = notification.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         notification.message.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesType = selectedType === 'all' || notification.type === selectedType
    const matchesPriority = selectedPriority === 'all' || notification.priority === selectedPriority
    const matchesRead = showRead === 'all' || 
                       (showRead === 'read' && notification.isRead) ||
                       (showRead === 'unread' && !notification.isRead)
    
    return matchesSearch && matchesType && matchesPriority && matchesRead
  })

  const stats = {
    total: mockNotifications.length,
    unread: mockNotifications.filter(n => !n.isRead).length,
    highPriority: mockNotifications.filter(n => n.priority === NotificationPriority.HIGH || n.priority === NotificationPriority.URGENT).length,
    expired: mockNotifications.filter(n => new Date(n.expiresAt) < new Date()).length
  }

  const handleAddNotification = () => {
    setIsAddModalOpen(true)
  }

  const handleViewNotification = (notification: typeof mockNotifications[0]) => {
    setSelectedNotification(notification)
    setIsViewModalOpen(true)
  }

  const handleEditNotification = (notification: typeof mockNotifications[0]) => {
    setSelectedNotification(notification)
    setIsEditModalOpen(true)
  }

  const handleDeleteNotification = (id: string) => {
    if (confirm('Вы уверены, что хотите удалить это уведомление?')) {
      console.log('Delete notification:', id)
      // Здесь будет логика удаления
    }
  }

  const handleMarkAsRead = (id: string) => {
    console.log('Mark as read:', id)
    // Здесь будет логика отметки как прочитанное
  }

  const handleMarkAsUnread = (id: string) => {
    console.log('Mark as unread:', id)
    // Здесь будет логика отметки как непрочитанное
  }

  return (
    <Layout title="Уведомления" description="Управление системными уведомлениями">
      {/* Header */}
      <div className="flex justify-between items-center mb-6">
        <motion.button
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.95 }}
          onClick={handleAddNotification}
          className="btn-primary flex items-center space-x-2"
        >
          <PlusIcon className="h-5 w-5" />
          <span>Добавить уведомление</span>
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
              placeholder="Поиск уведомлений..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="input-field pl-10"
            />
          </div>

          {/* Type filter */}
          <select
            value={selectedType}
            onChange={(e) => setSelectedType(e.target.value as NotificationType | 'all')}
            className="input-field"
          >
            <option value="all">Все типы</option>
            {Object.entries(notificationTypes).map(([type, info]) => (
              <option key={type} value={type}>{info.name}</option>
            ))}
          </select>

          {/* Priority filter */}
          <select
            value={selectedPriority}
            onChange={(e) => setSelectedPriority(e.target.value as NotificationPriority | 'all')}
            className="input-field"
          >
            <option value="all">Все приоритеты</option>
            {Object.entries(priorityNames).map(([priority, name]) => (
              <option key={priority} value={priority}>{name}</option>
            ))}
          </select>

          {/* Read status filter */}
          <select
            value={showRead}
            onChange={(e) => setShowRead(e.target.value as 'all' | 'read' | 'unread')}
            className="input-field"
          >
            <option value="all">Все уведомления</option>
            <option value="unread">Непрочитанные</option>
            <option value="read">Прочитанные</option>
          </select>

          {/* Sort */}
          <select className="input-field">
            <option value="newest">Сначала новые</option>
            <option value="oldest">Сначала старые</option>
            <option value="priority">По приоритету</option>
          </select>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div className="card">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Всего уведомлений</p>
              <p className="text-2xl font-bold text-gray-900">{stats.total}</p>
            </div>
            <div className="p-3 bg-blue-100 rounded-lg">
              <BellIcon className="h-6 w-6 text-blue-600" />
            </div>
          </div>
        </div>

        <div className="card">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Непрочитанных</p>
              <p className="text-2xl font-bold text-gray-900">{stats.unread}</p>
            </div>
            <div className="p-3 bg-red-100 rounded-lg">
              <div className="h-6 w-6 bg-red-600 rounded-full"></div>
            </div>
          </div>
        </div>

        <div className="card">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Высокий приоритет</p>
              <p className="text-2xl font-bold text-gray-900">{stats.highPriority}</p>
            </div>
            <div className="p-3 bg-orange-100 rounded-lg">
              <div className="h-6 w-6 bg-orange-600 rounded-full"></div>
            </div>
          </div>
        </div>

        <div className="card">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Истекших</p>
              <p className="text-2xl font-bold text-gray-900">{stats.expired}</p>
            </div>
            <div className="p-3 bg-gray-100 rounded-lg">
              <XMarkIcon className="h-6 w-6 text-gray-600" />
            </div>
          </div>
        </div>
      </div>

      {/* Notifications list */}
      <div className="space-y-4">
        {filteredNotifications.map((notification, index) => (
          <motion.div
            key={notification.id}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: index * 0.1 }}
            className={`card ${!notification.isRead ? 'border-l-4 border-l-blue-500' : ''}`}
          >
            <div className="flex items-start justify-between">
              <div className="flex items-start space-x-4 flex-1">
                {/* Type icon */}
                <div className={`p-2 rounded-lg ${notificationTypes[notification.type].color}`}>
                  <span className="text-lg">{notificationTypes[notification.type].icon}</span>
                </div>

                {/* Content */}
                <div className="flex-1">
                  <div className="flex items-center space-x-2 mb-2">
                    <h3 className="text-lg font-semibold text-gray-900">{notification.title}</h3>
                    {!notification.isRead && (
                      <span className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                        Новое
                      </span>
                    )}
                  </div>
                  
                  <p className="text-gray-600 mb-3">{notification.message}</p>
                  
                  <div className="flex items-center space-x-4 text-sm text-gray-500">
                    <span>{notificationTypes[notification.type].name}</span>
                    <span className={`px-2 py-1 rounded-full text-xs font-medium ${priorityColors[notification.priority]}`}>
                      {priorityNames[notification.priority]}
                    </span>
                    <span>Создано: {new Date(notification.createdAt).toLocaleDateString('ru-RU')}</span>
                    <span>Истекает: {new Date(notification.expiresAt).toLocaleDateString('ru-RU')}</span>
                  </div>
                </div>
              </div>

              {/* Actions */}
              <div className="flex items-center space-x-2 ml-4">
                <button
                  onClick={() => handleViewNotification(notification)}
                  className="text-blue-600 hover:text-blue-900"
                  title="Просмотр"
                >
                  <EyeIcon className="h-4 w-4" />
                </button>
                <button
                  onClick={() => handleEditNotification(notification)}
                  className="text-green-600 hover:text-green-900"
                  title="Редактировать"
                >
                  <PencilIcon className="h-4 w-4" />
                </button>
                {notification.isRead ? (
                  <button
                    onClick={() => handleMarkAsUnread(notification.id)}
                    className="text-orange-600 hover:text-orange-900"
                    title="Отметить как непрочитанное"
                  >
                    <XMarkIcon className="h-4 w-4" />
                  </button>
                ) : (
                  <button
                    onClick={() => handleMarkAsRead(notification.id)}
                    className="text-green-600 hover:text-green-900"
                    title="Отметить как прочитанное"
                  >
                    <CheckIcon className="h-4 w-4" />
                  </button>
                )}
                <button
                  onClick={() => handleDeleteNotification(notification.id)}
                  className="text-red-600 hover:text-red-900"
                  title="Удалить"
                >
                  <TrashIcon className="h-4 w-4" />
                </button>
              </div>
            </div>
          </motion.div>
        ))}
      </div>

      {filteredNotifications.length === 0 && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          className="card text-center py-12"
        >
          <BellIcon className="h-12 w-12 text-gray-400 mx-auto mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">Нет уведомлений</h3>
          <p className="text-gray-500">По выбранным фильтрам уведомления не найдены</p>
        </motion.div>
      )}

      {/* Add Notification Modal */}
      <Modal
        isOpen={isAddModalOpen}
        onClose={() => setIsAddModalOpen(false)}
        title="Добавить уведомление"
        size="lg"
      >
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Заголовок
            </label>
            <input
              type="text"
              className="input-field w-full"
              placeholder="Введите заголовок уведомления"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Сообщение
            </label>
            <textarea
              className="input-field w-full"
              rows={3}
              placeholder="Введите текст уведомления"
            />
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Тип уведомления
              </label>
              <select className="input-field w-full">
                {Object.entries(notificationTypes).map(([type, info]) => (
                  <option key={type} value={type}>{info.name}</option>
                ))}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Приоритет
              </label>
              <select className="input-field w-full">
                {Object.entries(priorityNames).map(([priority, name]) => (
                  <option key={priority} value={priority}>{name}</option>
                ))}
              </select>
            </div>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Дата истечения
              </label>
              <input
                type="datetime-local"
                className="input-field w-full"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Целевая аудитория
              </label>
              <select className="input-field w-full">
                <option value="all">Все пользователи</option>
                <option value="customers">Клиенты</option>
                <option value="staff">Персонал</option>
                <option value="admins">Администраторы</option>
              </select>
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
              Добавить уведомление
            </button>
          </div>
        </div>
      </Modal>

      {/* View Notification Modal */}
      <Modal
        isOpen={isViewModalOpen}
        onClose={() => setIsViewModalOpen(false)}
        title={selectedNotification?.title || 'Просмотр уведомления'}
        size="lg"
      >
        {selectedNotification && (
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Тип</label>
                <p className="text-gray-900">{notificationTypes[selectedNotification.type].name}</p>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Приоритет</label>
                <p className="text-gray-900">{priorityNames[selectedNotification.priority]}</p>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Статус</label>
                <p className="text-gray-900">{selectedNotification.isRead ? 'Прочитано' : 'Непрочитано'}</p>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Целевая аудитория</label>
                <p className="text-gray-900">{selectedNotification.targetAudience}</p>
              </div>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Сообщение</label>
              <p className="text-gray-900">{selectedNotification.message}</p>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Создано</label>
                <p className="text-gray-900">{new Date(selectedNotification.createdAt).toLocaleString('ru-RU')}</p>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Истекает</label>
                <p className="text-gray-900">{new Date(selectedNotification.expiresAt).toLocaleString('ru-RU')}</p>
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

      {/* Edit Notification Modal */}
      <Modal
        isOpen={isEditModalOpen}
        onClose={() => setIsEditModalOpen(false)}
        title="Редактировать уведомление"
        size="lg"
      >
        {selectedNotification && (
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Заголовок
              </label>
              <input
                type="text"
                className="input-field w-full"
                defaultValue={selectedNotification.title}
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Сообщение
              </label>
              <textarea
                className="input-field w-full"
                rows={3}
                defaultValue={selectedNotification.message}
              />
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Тип уведомления
                </label>
                <select className="input-field w-full" defaultValue={selectedNotification.type}>
                  {Object.entries(notificationTypes).map(([type, info]) => (
                    <option key={type} value={type}>{info.name}</option>
                  ))}
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Приоритет
                </label>
                <select className="input-field w-full" defaultValue={selectedNotification.priority}>
                  {Object.entries(priorityNames).map(([priority, name]) => (
                    <option key={priority} value={priority}>{name}</option>
                  ))}
                </select>
              </div>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Дата истечения
                </label>
                <input
                  type="datetime-local"
                  className="input-field w-full"
                  defaultValue={selectedNotification.expiresAt.slice(0, 16)}
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Целевая аудитория
                </label>
                <select className="input-field w-full" defaultValue={selectedNotification.targetAudience}>
                  <option value="all">Все пользователи</option>
                  <option value="customers">Клиенты</option>
                  <option value="staff">Персонал</option>
                  <option value="admins">Администраторы</option>
                </select>
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