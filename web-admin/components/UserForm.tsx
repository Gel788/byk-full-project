'use client'

import { useState, useEffect } from 'react'
import { motion } from 'framer-motion'
import { XMarkIcon, UserIcon, EnvelopeIcon, PhoneIcon, LockClosedIcon } from '@heroicons/react/24/outline'

interface User {
  _id?: string
  username: string
  email: string
  fullName: string
  phone?: string
  role: 'admin' | 'user'
  isActive: boolean
}

interface UserFormProps {
  user?: User | null
  isOpen: boolean
  onClose: () => void
  onSubmit: (userData: Partial<User> & { password?: string }) => Promise<void>
  title?: string
}

export default function UserForm({ user, isOpen, onClose, onSubmit, title }: UserFormProps) {
  const [formData, setFormData] = useState({
    username: '',
    email: '',
    fullName: '',
    phone: '',
    password: '',
    role: 'user' as 'admin' | 'user',
    isActive: true
  })
  const [errors, setErrors] = useState<Record<string, string>>({})
  const [isSubmitting, setIsSubmitting] = useState(false)

  useEffect(() => {
    if (user) {
      setFormData({
        username: user.username || '',
        email: user.email || '',
        fullName: user.fullName || '',
        phone: user.phone || '',
        password: '',
        role: user.role || 'user',
        isActive: user.isActive !== undefined ? user.isActive : true
      })
    } else {
      setFormData({
        username: '',
        email: '',
        fullName: '',
        phone: '',
        password: '',
        role: 'user',
        isActive: true
      })
    }
    setErrors({})
  }, [user, isOpen])

  const validateForm = () => {
    const newErrors: Record<string, string> = {}

    if (!formData.username.trim()) {
      newErrors.username = 'Имя пользователя обязательно'
    } else if (formData.username.length < 3) {
      newErrors.username = 'Имя пользователя должно содержать минимум 3 символа'
    }

    if (!formData.email.trim()) {
      newErrors.email = 'Email обязателен'
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)) {
      newErrors.email = 'Некорректный email'
    }

    if (!formData.fullName.trim()) {
      newErrors.fullName = 'Полное имя обязательно'
    }

    if (!user && !formData.password.trim()) {
      newErrors.password = 'Пароль обязателен для нового пользователя'
    } else if (formData.password && formData.password.length < 6) {
      newErrors.password = 'Пароль должен содержать минимум 6 символов'
    }

    if (formData.phone && !/^[\+]?[0-9\s\-\(\)]{10,}$/.test(formData.phone)) {
      newErrors.phone = 'Некорректный номер телефона'
    }

    setErrors(newErrors)
    return Object.keys(newErrors).length === 0
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    
    if (!validateForm()) return

    setIsSubmitting(true)
    try {
      const submitData = { ...formData }
      if (!submitData.password) {
        delete submitData.password
      }
      
      await onSubmit(submitData)
      onClose()
    } catch (error) {
      console.error('Ошибка при сохранении пользователя:', error)
    } finally {
      setIsSubmitting(false)
    }
  }

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value, type } = e.target
    setFormData(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? (e.target as HTMLInputElement).checked : value
    }))
    
    // Clear error when user starts typing
    if (errors[name]) {
      setErrors(prev => ({ ...prev, [name]: '' }))
    }
  }

  if (!isOpen) return null

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <motion.div
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        exit={{ opacity: 0, scale: 0.95 }}
        className="bg-white rounded-lg shadow-xl max-w-md w-full max-h-[90vh] overflow-y-auto"
      >
        <div className="flex items-center justify-between p-6 border-b border-gray-200">
          <h2 className="text-xl font-semibold text-gray-900">
            {title || (user ? 'Редактировать пользователя' : 'Создать пользователя')}
          </h2>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600 transition-colors"
          >
            <XMarkIcon className="h-6 w-6" />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          {/* Username */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Имя пользователя *
            </label>
            <div className="relative">
              <UserIcon className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
              <input
                type="text"
                name="username"
                value={formData.username}
                onChange={handleChange}
                className={`input-field pl-10 ${errors.username ? 'border-red-500' : ''}`}
                placeholder="Введите имя пользователя"
              />
            </div>
            {errors.username && (
              <p className="mt-1 text-sm text-red-600">{errors.username}</p>
            )}
          </div>

          {/* Full Name */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Полное имя *
            </label>
            <input
              type="text"
              name="fullName"
              value={formData.fullName}
              onChange={handleChange}
              className={`input-field ${errors.fullName ? 'border-red-500' : ''}`}
              placeholder="Введите полное имя"
            />
            {errors.fullName && (
              <p className="mt-1 text-sm text-red-600">{errors.fullName}</p>
            )}
          </div>

          {/* Email */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Email *
            </label>
            <div className="relative">
              <EnvelopeIcon className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
              <input
                type="email"
                name="email"
                value={formData.email}
                onChange={handleChange}
                className={`input-field pl-10 ${errors.email ? 'border-red-500' : ''}`}
                placeholder="Введите email"
              />
            </div>
            {errors.email && (
              <p className="mt-1 text-sm text-red-600">{errors.email}</p>
            )}
          </div>

          {/* Phone */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Телефон
            </label>
            <div className="relative">
              <PhoneIcon className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
              <input
                type="tel"
                name="phone"
                value={formData.phone}
                onChange={handleChange}
                className={`input-field pl-10 ${errors.phone ? 'border-red-500' : ''}`}
                placeholder="+7 (999) 123-45-67"
              />
            </div>
            {errors.phone && (
              <p className="mt-1 text-sm text-red-600">{errors.phone}</p>
            )}
          </div>

          {/* Password */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Пароль {!user && '*'}
            </label>
            <div className="relative">
              <LockClosedIcon className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
              <input
                type="password"
                name="password"
                value={formData.password}
                onChange={handleChange}
                className={`input-field pl-10 ${errors.password ? 'border-red-500' : ''}`}
                placeholder={user ? "Оставьте пустым, чтобы не менять" : "Введите пароль"}
              />
            </div>
            {errors.password && (
              <p className="mt-1 text-sm text-red-600">{errors.password}</p>
            )}
          </div>

          {/* Role */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Роль
            </label>
            <select
              name="role"
              value={formData.role}
              onChange={handleChange}
              className="input-field"
            >
              <option value="user">Пользователь</option>
              <option value="admin">Администратор</option>
            </select>
          </div>

          {/* Active Status */}
          <div className="flex items-center">
            <input
              type="checkbox"
              name="isActive"
              checked={formData.isActive}
              onChange={handleChange}
              className="h-4 w-4 text-byk-600 focus:ring-byk-500 border-gray-300 rounded"
            />
            <label className="ml-2 block text-sm text-gray-700">
              Активный пользователь
            </label>
          </div>

          {/* Actions */}
          <div className="flex space-x-3 pt-4">
            <button
              type="button"
              onClick={onClose}
              className="flex-1 px-4 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50 transition-colors"
            >
              Отмена
            </button>
            <button
              type="submit"
              disabled={isSubmitting}
              className="flex-1 px-4 py-2 bg-byk-600 text-white rounded-md hover:bg-byk-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              {isSubmitting ? 'Сохранение...' : (user ? 'Обновить' : 'Создать')}
            </button>
          </div>
        </form>
      </motion.div>
    </div>
  )
}
