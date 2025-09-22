'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import LoginForm from '../../components/LoginForm'

export default function LoginPage() {
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const router = useRouter()

  const handleLogin = async (email: string, password: string) => {
    setIsLoading(true)
    setError(null)

    try {
      // Простая проверка для демонстрации
      // В реальном приложении здесь будет запрос к API
      if (email === 'albgel@yandex.ru' && password === '123456') {
        // Сохраняем токен авторизации в localStorage
        localStorage.setItem('admin_token', 'demo-token-123')
        localStorage.setItem('admin_user', JSON.stringify({
          email: email,
          name: 'Mekhak Galstyan',
          role: 'admin'
        }))
        
        // Перенаправляем на главную страницу
        router.push('/')
      } else {
        setError('Неверный email или пароль')
      }
    } catch (err) {
      setError('Произошла ошибка при входе')
      console.error('Login error:', err)
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <LoginForm 
      onLogin={handleLogin}
      isLoading={isLoading}
      error={error}
    />
  )
}
