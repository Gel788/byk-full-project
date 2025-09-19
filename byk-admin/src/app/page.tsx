'use client'

import { useState, useEffect } from 'react'
import { 
  ChartBarIcon, 
  BuildingOfficeIcon, 
  UserGroupIcon, 
  NewspaperIcon,
  PlusIcon,
  PencilIcon,
  TrashIcon,
  CalendarIcon
} from '@heroicons/react/24/outline'

interface DashboardStats {
  restaurants: number
  dishes: number
  news: number
  users: number
  totalRevenue: number
  activeOrders: number
}

interface Restaurant {
  _id: string
  name: string
  brand: string
  city: string
  rating: number
  createdAt: string
  description?: string
  address?: string
  phone?: string
  email?: string
  workingHours?: string
  photos?: string[]
  videos?: string[]
  isActive?: boolean
}

interface Dish {
  _id: string
  name: string
  description: string
  price: number
  category: string
  restaurantId: string
  restaurantName: string
  restaurantBrand: string
  imageURL: string
  isAvailable: boolean
  preparationTime: number
  calories: number
  allergens: string[]
  ingredients?: string[]
  createdAt: string
}

interface News {
  _id: string
  title: string
  content: string
  author: string
  imageURL: string
  videoURL?: string
  category: string
  tags: string[]
  isPublished: boolean
  publishedAt: string
  views: number
  likes: number
  createdAt: string
}

interface User {
  _id: string
  username: string
  fullName: string
  email: string
  phone: string
  role: 'admin' | 'user'
  membershipLevel: string
  loyaltyPoints: number
  createdAt: string
  updatedAt: string
  lastLogin: string
  isActive: boolean
}

interface Reservation {
  _id: string
  reservationNumber: string
  userId: string
  userName: string
  restaurantId: string
  restaurantName: string
  date: string
  time: string
  guests: number
  status: 'pending' | 'confirmed' | 'cancelled'
  specialRequests: string
  createdAt: string
  updatedAt: string
}

interface Order {
  _id: string
  orderNumber: string
  userId: string
  userName: string
  restaurantId: string
  restaurantName: string
  items: OrderItem[]
  totalAmount: number
  status: string
  deliveryMethod: string
  deliveryAddress?: string
  pickupRestaurantId?: string
  paymentMethod: string
  createdAt: string
  updatedAt: string
}

interface OrderItem {
  dishId: string
  dishName: string
  quantity: number
  price: number
}


export default function AdminDashboard() {
  const [stats, setStats] = useState<DashboardStats | null>(null)
  const [restaurants, setRestaurants] = useState<Restaurant[]>([])
  const [dishes, setDishes] = useState<Dish[]>([])
  const [news, setNews] = useState<News[]>([])
  const [users, setUsers] = useState<User[]>([])
  const [orders, setOrders] = useState<Order[]>([])
  const [reservations, setReservations] = useState<Reservation[]>([])
  const [loading, setLoading] = useState(true)
  const [activeTab, setActiveTab] = useState('dashboard')
  const [showAddModal, setShowAddModal] = useState(false)
  const [showReservationModal, setShowReservationModal] = useState(false)
  const [showPreviewModal, setShowPreviewModal] = useState(false)
  const [previewNews, setPreviewNews] = useState<News | null>(null)
  
  // Предпросмотр ресторанов
  const [showRestaurantPreviewModal, setShowRestaurantPreviewModal] = useState(false)
  const [previewRestaurant, setPreviewRestaurant] = useState<Restaurant | null>(null)
  
  // Предпросмотр блюд
  const [showDishPreviewModal, setShowDishPreviewModal] = useState(false)
  const [previewDish, setPreviewDish] = useState<Dish | null>(null)
  const [editingRestaurant, setEditingRestaurant] = useState<Restaurant | null>(null)
  const [editingDish, setEditingDish] = useState<Dish | null>(null)
  const [editingNews, setEditingNews] = useState<News | null>(null)
  const [editingUser, setEditingUser] = useState<User | null>(null)
  const [previewUser, setPreviewUser] = useState<User | null>(null)
  const [previewOrder, setPreviewOrder] = useState<Order | null>(null)
  const [editingOrder, setEditingOrder] = useState<Order | null>(null)
  const [selectedDeliveryMethod, setSelectedDeliveryMethod] = useState<string>('delivery')
  const [selectedDishes, setSelectedDishes] = useState<Array<{dishId: string, dishName: string, quantity: number, price: number}>>([])
  const [editingReservation, setEditingReservation] = useState<Reservation | null>(null)
  const [files, setFiles] = useState<Array<{id: string, filename: string, url: string, originalName?: string, size?: number}>>([])
  const [uploading, setUploading] = useState(false)
  const [selectedFiles, setSelectedFiles] = useState<Array<{id: string, filename: string, url: string, originalName?: string, size?: number}>>([])
  const [isDarkMode, setIsDarkMode] = useState(false)
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false)
  const [selectedCategory, setSelectedCategory] = useState<string>('all')
  const [selectedBrand, setSelectedBrand] = useState<string>('all')
  const [categories, setCategories] = useState<string[]>([
    'Мясо', 'Пицца', 'Паста', 'Салаты', 'Супы', 'Десерты', 'Напитки', 'Закуски'
  ])
  const [newCategory, setNewCategory] = useState('')
  const [showCategoryModal, setShowCategoryModal] = useState(false)

  useEffect(() => {
    fetchStats()
    fetchRestaurants()
    fetchDishes()
    fetchNews()
    fetchUsers()
    fetchOrders()
    fetchReservations()
    fetchFiles()
  }, [])

  // Закрытие модального окна по ESC
  useEffect(() => {
    const handleEscape = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && showAddModal) {
        setShowAddModal(false)
        setEditingRestaurant(null)
      }
    }

    if (showAddModal) {
      document.addEventListener('keydown', handleEscape)
      document.body.style.overflow = 'hidden'
    } else {
      document.body.style.overflow = 'unset'
    }

    return () => {
      document.removeEventListener('keydown', handleEscape)
      document.body.style.overflow = 'unset'
    }
  }, [showAddModal])

  const fetchStats = async () => {
    try {
      const response = await fetch('https://bulladmin.ru/api/admin/dashboard')
      const data = await response.json()
      if (data.success) {
        setStats(data.data)
      }
    } catch (error) {
      console.error('Ошибка загрузки статистики:', error)
      // Fallback данные для демо
      setStats({
        restaurants: 3,
        dishes: 15,
        news: 5,
        users: 12,
        totalRevenue: 0,
        activeOrders: 0
      })
    }
  }

  const fetchRestaurants = async () => {
    try {
      const response = await fetch('https://bulladmin.ru/api/admin/restaurants')
      const data = await response.json()
      console.log('Загружены рестораны:', data)
      if (data.success) {
        setRestaurants(data.data)
      } else {
        // Fallback на обычный API
        const fallbackResponse = await fetch('https://bulladmin.ru/api/restaurants')
        const fallbackData = await fallbackResponse.json()
        console.log('Загружены рестораны (fallback):', fallbackData)
        setRestaurants(fallbackData)
      }
    } catch (error) {
      console.error('Ошибка загрузки ресторанов:', error)
      // Fallback данные для демо
      setRestaurants([
        {
          _id: '1',
          name: 'БЫК Steakhouse',
          brand: 'БЫК',
          city: 'Москва',
          rating: 4.8,
          createdAt: new Date().toISOString(),
          description: 'Премиальный стейкхаус с мраморным мясом и изысканной атмосферой',
          address: 'ул. Тверская, 15',
          phone: '+7 (495) 123-45-67',
          email: 'moscow@byk.ru',
          workingHours: 'Пн-Вс: 12:00 - 02:00',
          photos: [
            'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400',
            'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=400'
          ],
          videos: ['https://example.com/video1.mp4']
        },
        {
          _id: '2',
          name: 'Пиво & Мясо',
          brand: 'Пиво',
          city: 'Санкт-Петербург',
          rating: 4.6,
          createdAt: new Date().toISOString(),
          description: 'Уютный ресторан с крафтовым пивом и мясными деликатесами',
          address: 'Невский проспект, 28',
          phone: '+7 (812) 987-65-43',
          email: 'spb@pivo.ru',
          workingHours: 'Пн-Вс: 11:00 - 01:00',
          photos: [
            'https://images.unsplash.com/photo-1551218808-94e220e084d2?w=400'
          ],
          videos: []
        },
        {
          _id: '3',
          name: 'Моска',
          brand: 'Моска',
          city: 'Москва',
          rating: 4.7,
          createdAt: new Date().toISOString(),
          description: 'Современный ресторан с панорамным видом на город',
          address: 'Красная площадь, 1',
          phone: '+7 (495) 555-77-99',
          email: 'info@mosca.ru',
          workingHours: 'Пн-Вс: 10:00 - 24:00',
          photos: [
            'https://images.unsplash.com/photo-1571997478779-2adcbbe9ab2f?w=400',
            'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=400',
            'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400'
          ],
          videos: ['https://example.com/video2.mp4', 'https://example.com/video3.mp4']
        }
      ])
    } finally {
      setLoading(false)
    }
  }

  const fetchDishes = async () => {
    try {
      const response = await fetch('https://bulladmin.ru/api/dishes')
      const data = await response.json()
      console.log('Загружены блюда:', data)
      setDishes(data)
    } catch (error) {
      console.error('Ошибка загрузки блюд:', error)
      // Fallback данные для демо
      setDishes([
        {
          _id: '1',
          name: 'Стейк Рибай',
          description: 'Мраморное мясо высшего качества',
          price: 2500,
          category: 'Мясо',
          restaurantId: '1',
          restaurantName: 'БЫК Steakhouse',
          restaurantBrand: 'БЫК',
          imageURL: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=400',
          isAvailable: true,
          preparationTime: 25,
          calories: 800,
          allergens: ['Глютен'],
          createdAt: new Date().toISOString()
        },
        {
          _id: '2',
          name: 'Пицца Маргарита',
          description: 'Классическая итальянская пицца',
          price: 1200,
          category: 'Пицца',
          restaurantId: '3',
          restaurantName: 'Моска',
          restaurantBrand: 'Моска',
          imageURL: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=400',
          isAvailable: true,
          preparationTime: 15,
          calories: 600,
          allergens: ['Глютен', 'Молочные продукты'],
          createdAt: new Date().toISOString()
        },
        {
          _id: '3',
          name: 'Паста Карбонара',
          description: 'Спагетти с беконом и сливочным соусом',
          price: 800,
          category: 'Паста',
          restaurantId: '3',
          restaurantName: 'Моска',
          restaurantBrand: 'Моска',
          imageURL: 'https://images.unsplash.com/photo-1621996346565-e3dbc353d2e5?w=400',
          isAvailable: true,
          preparationTime: 12,
          calories: 450,
          allergens: ['Глютен', 'Молочные продукты', 'Яйца'],
          createdAt: new Date().toISOString()
        },
        {
          _id: '4',
          name: 'Цезарь с курицей',
          description: 'Свежий салат с курицей и пармезаном',
          price: 600,
          category: 'Салаты',
          restaurantId: '1',
          restaurantName: 'БЫК Steakhouse',
          restaurantBrand: 'БЫК',
          imageURL: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',
          isAvailable: true,
          preparationTime: 8,
          calories: 350,
          allergens: ['Глютен', 'Молочные продукты'],
          createdAt: new Date().toISOString()
        },
        {
          _id: '5',
          name: 'Томатный суп',
          description: 'Горячий томатный суп с базиликом',
          price: 400,
          category: 'Супы',
          restaurantId: '3',
          restaurantName: 'Моска',
          restaurantBrand: 'Моска',
          imageURL: 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=400',
          isAvailable: true,
          preparationTime: 10,
          calories: 200,
          allergens: ['Глютен'],
          createdAt: new Date().toISOString()
        },
        {
          _id: '6',
          name: 'Тирамису',
          description: 'Классический итальянский десерт',
          price: 500,
          category: 'Десерты',
          restaurantId: '3',
          restaurantName: 'Моска',
          restaurantBrand: 'Моска',
          imageURL: 'https://images.unsplash.com/photo-1571877227200-a63a8a6b5ef5?w=400',
          isAvailable: true,
          preparationTime: 5,
          calories: 300,
          allergens: ['Молочные продукты', 'Яйца', 'Кофеин'],
          createdAt: new Date().toISOString()
        },
        {
          _id: '7',
          name: 'Крафтовое пиво',
          description: 'Свежее крафтовое пиво местного производства',
          price: 300,
          category: 'Напитки',
          restaurantId: '2',
          restaurantName: 'Пиво & Мясо',
          restaurantBrand: 'Пиво',
          imageURL: 'https://images.unsplash.com/photo-1608270586620-248524c67de9?w=400',
          isAvailable: true,
          preparationTime: 2,
          calories: 150,
          allergens: ['Глютен'],
          createdAt: new Date().toISOString()
        },
        {
          _id: '8',
          name: 'Сырная тарелка',
          description: 'Ассорти из сыров с орехами и медом',
          price: 900,
          category: 'Закуски',
          restaurantId: '1',
          restaurantName: 'БЫК Steakhouse',
          restaurantBrand: 'БЫК',
          imageURL: 'https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?w=400',
          isAvailable: false,
          preparationTime: 5,
          calories: 400,
          allergens: ['Молочные продукты', 'Орехи'],
          createdAt: new Date().toISOString()
        }
      ])
    }
  }

  const fetchNews = async () => {
    try {
      const response = await fetch('https://bulladmin.ru/api/admin/news')
      const data = await response.json()
      if (data.success) {
        setNews(data.data)
      }
    } catch (error) {
      console.error('Ошибка загрузки новостей:', error)
      // Fallback данные для демо
      setNews([
        {
          _id: '1',
          title: 'Новое меню в БЫК Steakhouse',
          content: 'Представляем обновленное меню с новыми блюдами',
          author: 'Администратор',
          imageURL: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400',
          category: 'Меню',
          tags: ['меню', 'новинки'],
          isPublished: true,
          publishedAt: new Date().toISOString(),
          views: 150,
          likes: 25,
          createdAt: new Date().toISOString()
        }
      ])
    }
  }

  const fetchUsers = async () => {
    try {
      const response = await fetch('https://bulladmin.ru/api/admin/users')
      const data = await response.json()
      if (data.success) {
        setUsers(data.data)
      }
    } catch (error) {
      console.error('Ошибка загрузки пользователей:', error)
      // Fallback данные для демо
      setUsers([
        {
          _id: '1',
          username: 'user1',
          fullName: 'Иван Петров',
          email: 'ivan@example.com',
          phone: '+7 (999) 123-45-67',
          role: 'user',
          membershipLevel: 'Золото',
          loyaltyPoints: 1500,
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString(),
          lastLogin: new Date().toISOString(),
          isActive: true
        }
      ])
    }
  }

  const fetchOrders = async () => {
    try {
      const response = await fetch('https://bulladmin.ru/api/admin/orders')
      const data = await response.json()
      if (data.success) {
        setOrders(data.data)
      }
    } catch (error) {
      console.error('Ошибка загрузки заказов:', error)
      // Fallback данные для демо
      setOrders([
        {
          _id: '1',
          orderNumber: 'ORD-001',
          userId: '1',
          userName: 'Иван Петров',
          restaurantId: '1',
          restaurantName: 'БЫК Steakhouse',
          items: [
            {
              dishId: '1',
              dishName: 'Стейк Рибай',
              quantity: 1,
              price: 2500
            }
          ],
          totalAmount: 2500,
          status: 'confirmed',
          deliveryMethod: 'delivery',
          paymentMethod: 'card',
          createdAt: '2024-01-20T10:00:00Z',
          updatedAt: '2024-01-20T10:00:00Z'
        },
        {
          _id: '2',
          orderNumber: 'ORD-002',
          userId: '2',
          userName: 'Мария Сидорова',
          restaurantId: '2',
          restaurantName: 'Пиво & Мясо',
          items: [
            {
              dishId: '2',
              dishName: 'Пицца Маргарита',
              quantity: 2,
              price: 800
            }
          ],
          totalAmount: 1600,
          status: 'pending',
          deliveryMethod: 'pickup',
          paymentMethod: 'cash',
          createdAt: '2024-01-21T14:30:00Z',
          updatedAt: '2024-01-21T14:30:00Z'
        }
      ])
    }
  }

  const fetchFiles = async () => {
    try {
      console.log('Загружаем файлы...')
      const response = await fetch('https://bulladmin.ru/api/upload/files')
      const data = await response.json()
      console.log('Получены файлы:', data)
      if (data.success) {
        setFiles(data.data)
        console.log('Файлы установлены в состояние:', data.data)
      }
    } catch (error) {
      console.error('Ошибка загрузки файлов:', error)
      setFiles([])
    }
  }

  const handleFileUpload = async (file: File) => {
    setUploading(true)
    try {
      const formData = new FormData()
      formData.append('file', file)
      
      const response = await fetch('https://bulladmin.ru/api/upload/upload', {
        method: 'POST',
        body: formData
      })
      
      const data = await response.json()
      if (data.success) {
        setFiles([...files, data.data])
        alert('Файл загружен успешно!')
        // Обновляем список файлов
        fetchFiles()
      } else {
        alert('Ошибка загрузки файла: ' + data.message)
      }
    } catch (error) {
      console.error('Ошибка загрузки файла:', error)
      alert('Ошибка загрузки файла')
    } finally {
      setUploading(false)
    }
  }


  const handleMultipleFileUpload = async (files: FileList) => {
    setUploading(true)
    try {
      const formData = new FormData()
      Array.from(files).forEach(file => {
        formData.append('files', file)
      })
      
      const response = await fetch('https://bulladmin.ru/api/upload/upload-multiple', {
        method: 'POST',
        body: formData
      })
      
      const data = await response.json()
      if (data.success) {
        setFiles([...files, ...data.data])
        alert('Файлы загружены успешно!')
        // Обновляем список файлов
        fetchFiles()
      } else {
        alert('Ошибка загрузки файлов: ' + data.message)
      }
    } catch (error) {
      console.error('Ошибка загрузки файлов:', error)
      alert('Ошибка загрузки файлов')
    } finally {
      setUploading(false)
    }
  }

  const deleteFile = async (filename: string) => {
    try {
      const response = await fetch(`https://bulladmin.ru/api/upload/files/${filename}`, {
        method: 'DELETE'
      })
      
      const data = await response.json()
      if (data.success) {
        setFiles(files.filter(f => f.filename !== filename))
        setSelectedFiles(selectedFiles.filter(f => f.filename !== filename))
        alert('Файл удален успешно!')
        // Обновляем список файлов
        fetchFiles()
      } else {
        alert('Ошибка удаления файла: ' + data.message)
      }
    } catch (error) {
      console.error('Ошибка удаления файла:', error)
      alert('Ошибка удаления файла')
    }
  }

  const toggleFileSelection = (file: {id: string, filename: string, url: string, originalName?: string, size?: number}) => {
    setSelectedFiles(prev => {
      const isSelected = prev.some(f => f.filename === file.filename)
      if (isSelected) {
        return prev.filter(f => f.filename !== file.filename)
      } else {
        return [...prev, file]
      }
    })
  }

  const clearSelectedFiles = () => {
    setSelectedFiles([])
  }

  const fetchReservations = async () => {
    try {
      const response = await fetch('https://bulladmin.ru/api/admin/reservations')
      const data = await response.json()
      if (data.success) {
        setReservations(data.data)
      }
    } catch (error) {
      console.error('Ошибка загрузки бронирований:', error)
      // Fallback данные для демо
      setReservations([
        {
          _id: '1',
          reservationNumber: 'RES-001',
          userId: '1',
          userName: 'Иван Петров',
          restaurantId: '1',
          restaurantName: 'БЫК Steakhouse',
          date: '2024-01-25',
          time: '19:00',
          guests: 4,
          status: 'confirmed',
          specialRequests: 'Стол у окна',
          createdAt: '2024-01-20T10:00:00Z',
          updatedAt: '2024-01-20T10:00:00Z'
        },
        {
          _id: '2',
          reservationNumber: 'RES-002',
          userId: '2',
          userName: 'Мария Сидорова',
          restaurantId: '2',
          restaurantName: 'Пиво & Мясо',
          date: '2024-01-26',
          time: '20:30',
          guests: 2,
          status: 'pending',
          specialRequests: '',
          createdAt: '2024-01-21T14:30:00Z',
          updatedAt: '2024-01-21T14:30:00Z'
        },
        {
          _id: '3',
          reservationNumber: 'RES-003',
          userId: '3',
          userName: 'Алексей Козлов',
          restaurantId: '3',
          restaurantName: 'Моска',
          date: '2024-01-27',
          time: '18:00',
          guests: 6,
          status: 'cancelled',
          specialRequests: 'Детский стульчик',
          createdAt: '2024-01-22T09:15:00Z',
          updatedAt: '2024-01-22T09:15:00Z'
        }
      ])
    }
  }

  const handleAddRestaurant = () => {
    setEditingRestaurant({} as Restaurant)
    setEditingDish(null)
    setEditingNews(null)
    setEditingUser(null)
    setFiles([]) // Очищаем файлы при создании нового ресторана
    setShowAddModal(true)
  }

  const handleEditRestaurant = (restaurant: Restaurant) => {
    setEditingRestaurant(restaurant)
    setEditingDish(null)
    setEditingNews(null)
    setEditingUser(null)
    setShowAddModal(true)
  }

  const handleDeleteRestaurant = async (id: string) => {
    if (confirm('Удалить ресторан?')) {
      try {
        const response = await fetch(`https://bulladmin.ru/api/restaurants/${id}`, {
          method: 'DELETE'
        })
        
        if (response.ok) {
          setRestaurants(restaurants.filter(r => r._id !== id))
          alert('Ресторан удален')
        } else {
          alert('Ошибка удаления ресторана')
        }
      } catch (error) {
        console.error('Ошибка удаления ресторана:', error)
        alert('Ошибка удаления ресторана')
      }
    }
  }

  const handleSaveRestaurant = async (restaurantData: Partial<Restaurant>) => {
    try {
      // Получаем выбранные фото и видео, если нет выбранных - берем все загруженные
      const filesToUse = selectedFiles.length > 0 ? selectedFiles : files
      const imageFiles = filesToUse.filter(f => f.filename.includes('.jpg') || f.filename.includes('.png') || f.filename.includes('.gif') || f.filename.includes('.webp'))
      const videoFiles = filesToUse.filter(f => f.filename.includes('.mp4') || f.filename.includes('.mov') || f.filename.includes('.avi'))
      
      const restaurantWithFiles = {
        ...restaurantData,
        photos: imageFiles.map(f => f.url),
        videos: videoFiles.map(f => f.url)
      }
      
      console.log('Сохранение ресторана:', restaurantWithFiles)
      
      // Определяем метод и URL в зависимости от того, редактируем ли существующий ресторан
      const isEditing = editingRestaurant && editingRestaurant._id
      const url = isEditing 
        ? `https://bulladmin.ru/api/restaurants/${editingRestaurant._id}`
        : 'https://bulladmin.ru/api/restaurants'
      const method = isEditing ? 'PUT' : 'POST'
      
      // API вызов для сохранения
      const response = await fetch(url, {
        method,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(restaurantWithFiles)
      })
      
      if (response.ok) {
        const savedRestaurant = await response.json()
        console.log('Ресторан сохранен:', savedRestaurant)
        
        if (isEditing) {
          // Обновляем существующий ресторан в списке
          setRestaurants(restaurants.map(r => r._id === editingRestaurant._id ? savedRestaurant : r))
        } else {
        // Добавляем новый ресторан в список
        setRestaurants([savedRestaurant, ...restaurants])
        }
        
        // Очищаем файлы после сохранения
        setFiles([])
        setSelectedFiles([])
        
        setShowAddModal(false)
        setEditingRestaurant(null)
      } else {
        const errorData = await response.json()
        console.error('Ошибка сохранения ресторана:', errorData)
        alert(`Ошибка сохранения ресторана: ${errorData.message || response.statusText}`)
      }
    } catch (error) {
      console.error('Ошибка сохранения ресторана:', error)
      alert('Ошибка сохранения ресторана')
    }
  }

  const handleSaveDish = async (dishData: Partial<Dish>) => {
    try {
      // Получаем выбранные фото, если нет выбранных - берем последнее загруженное
      const filesToUse = selectedFiles.length > 0 ? selectedFiles : files
      const imageFiles = filesToUse.filter(f => f.filename.includes('.jpg') || f.filename.includes('.png') || f.filename.includes('.gif') || f.filename.includes('.webp'))
      
      const dishWithFiles = {
        ...dishData,
        imageURL: imageFiles.length > 0 ? imageFiles[imageFiles.length - 1].url : ''
      }
      
      console.log('Сохранение блюда:', dishWithFiles)
      
      // Определяем метод и URL в зависимости от того, редактируем ли существующее блюдо
      const isEditing = editingDish && editingDish._id
      const url = isEditing 
        ? `https://bulladmin.ru/api/dishes/${editingDish._id}`
        : 'https://bulladmin.ru/api/dishes'
      const method = isEditing ? 'PUT' : 'POST'
      
      // API вызов для сохранения
      const response = await fetch(url, {
        method,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(dishWithFiles)
      })
      
      if (response.ok) {
        const savedDish = await response.json()
        console.log('Блюдо сохранено:', savedDish)
        
        if (isEditing) {
          // Обновляем существующее блюдо в списке
          setDishes(dishes.map(d => d._id === editingDish._id ? savedDish : d))
        } else {
          // Добавляем новое блюдо в список
          setDishes([savedDish, ...dishes])
        }
        
        // Очищаем файлы после сохранения
        setFiles([])
        setSelectedFiles([])
        
        setShowAddModal(false)
        setEditingDish(null)
      } else {
        console.error('Ошибка сохранения блюда:', response.statusText)
        alert('Ошибка сохранения блюда')
      }
    } catch (error) {
      console.error('Ошибка сохранения блюда:', error)
      alert('Ошибка сохранения блюда')
    }
  }

  const handleDeleteDish = async (id: string) => {
    if (confirm('Удалить блюдо?')) {
      try {
        const response = await fetch(`https://bulladmin.ru/api/dishes/${id}`, {
          method: 'DELETE'
        })
        
        if (response.ok) {
          setDishes(dishes.filter(d => d._id !== id))
          alert('Блюдо удалено')
        } else {
          alert('Ошибка удаления блюда')
        }
      } catch (error) {
        console.error('Ошибка удаления блюда:', error)
        alert('Ошибка удаления блюда')
      }
    }
  }

  const handleAddCategory = () => {
    if (newCategory.trim() && !categories.includes(newCategory.trim())) {
      setCategories([...categories, newCategory.trim()])
      setNewCategory('')
      setShowCategoryModal(false)
    }
  }

  const handleDeleteCategory = (category: string) => {
    if (categories.length > 1) {
      setCategories(categories.filter(cat => cat !== category))
    }
  }

  const handleSaveNews = async (newsData: Partial<News>) => {
    try {
      // Получаем выбранные файлы, если нет выбранных - берем все загруженные
      const filesToUse = selectedFiles.length > 0 ? selectedFiles : files
      const imageFiles = filesToUse.filter(f => f.filename.includes('.jpg') || f.filename.includes('.png') || f.filename.includes('.gif') || f.filename.includes('.webp'))
      const videoFiles = filesToUse.filter(f => f.filename.includes('.mp4') || f.filename.includes('.mov') || f.filename.includes('.avi'))
      
      const newsWithFile = {
        ...newsData,
        imageURL: imageFiles.length > 0 ? imageFiles[imageFiles.length - 1].url : (newsData.imageURL || 'https://bulladmin.ru/uploads/default.jpg'),
        videoURL: videoFiles.length > 0 ? videoFiles[videoFiles.length - 1].url : (newsData.videoURL || '')
      }
      
      console.log('Сохранение новости:', newsWithFile)
      
      // API вызов для сохранения
      const response = await fetch('https://bulladmin.ru/api/news', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(newsWithFile)
      })
      
          if (response.ok) {
            const savedNews = await response.json()
            console.log('Новость сохранена:', savedNews)
            
            // Добавляем новую новость в список
            setNews([savedNews, ...news])
            
            // Очищаем список файлов после сохранения
            setFiles([])
            setSelectedFiles([])
            
            setShowAddModal(false)
            setEditingNews(null)
          } else {
            console.error('Ошибка сохранения новости:', response.statusText)
          }
    } catch (error) {
      console.error('Ошибка сохранения новости:', error)
    }
  }

  const handleDeleteNews = async (id: string) => {
    if (confirm('Удалить новость?')) {
      try {
        const response = await fetch(`https://bulladmin.ru/api/news/${id}`, {
          method: 'DELETE'
        })
        
        if (response.ok) {
          setNews(news.filter(n => n._id !== id))
          alert('Новость удалена')
        } else {
          alert('Ошибка удаления новости')
        }
      } catch (error) {
        console.error('Ошибка удаления новости:', error)
        alert('Ошибка удаления новости')
      }
    }
  }
 
  const handleSaveUser = async (userData: Partial<User>) => {
    try {
      console.log('Сохранение пользователя:', userData)
      console.log('JSON данные:', JSON.stringify(userData))
      
      const isEditing = editingUser && editingUser._id
      const url = isEditing 
        ? `https://bulladmin.ru/api/users/${editingUser._id}`
        : 'https://bulladmin.ru/api/users'
      
      console.log('URL:', url, 'Method:', isEditing ? 'PUT' : 'POST')
      
      // API вызов для сохранения
      const response = await fetch(url, {
        method: isEditing ? 'PUT' : 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(userData)
      })
      
      if (response.ok) {
        const savedUser = await response.json()
        console.log('Пользователь сохранен:', savedUser)
        
        if (isEditing) {
          // Обновляем существующего пользователя
          setUsers(users.map(u => u._id === editingUser._id ? savedUser : u))
        } else {
        // Добавляем нового пользователя в список
        setUsers([savedUser, ...users])
        }
        
        setShowAddModal(false)
        setEditingUser(null)
      } else {
        const errorData = await response.json()
        console.error('Ошибка сохранения пользователя:', errorData)
        alert(`Ошибка сохранения пользователя: ${errorData.message || response.statusText}`)
      }
    } catch (error) {
      console.error('Ошибка сохранения пользователя:', error)
      alert('Ошибка сохранения пользователя')
    }
  }

  const handleDeleteUser = async (id: string) => {
    if (confirm('Удалить пользователя?')) {
      try {
        const response = await fetch(`https://bulladmin.ru/api/users/${id}`, {
          method: 'DELETE'
        })
        
        if (response.ok) {
          setUsers(users.filter(u => u._id !== id))
          alert('Пользователь удален')
        } else {
          alert('Ошибка удаления пользователя')
        }
      } catch (error) {
        console.error('Ошибка удаления пользователя:', error)
        alert('Ошибка удаления пользователя')
      }
    }
  }

  const addDishToOrder = (dishId: string) => {
    const dish = dishes.find(d => d._id === dishId)
    if (!dish) return
    
    const existingDish = selectedDishes.find(d => d.dishId === dishId)
    if (existingDish) {
      setSelectedDishes(selectedDishes.map(d => 
        d.dishId === dishId 
          ? { ...d, quantity: d.quantity + 1 }
          : d
      ))
    } else {
      setSelectedDishes([...selectedDishes, {
        dishId: dish._id,
        dishName: dish.name,
        quantity: 1,
        price: dish.price
      }])
    }
  }

  const removeDishFromOrder = (dishId: string) => {
    setSelectedDishes(selectedDishes.filter(d => d.dishId !== dishId))
  }

  const updateDishQuantity = (dishId: string, quantity: number) => {
    if (quantity <= 0) {
      removeDishFromOrder(dishId)
    } else {
      setSelectedDishes(selectedDishes.map(d => 
        d.dishId === dishId ? { ...d, quantity } : d
      ))
    }
  }

  const calculateTotalAmount = () => {
    return selectedDishes.reduce((total, dish) => total + (dish.price * dish.quantity), 0)
  }

  const handleSaveOrder = async (orderData: Partial<Order>) => {
    try {
      console.log('Сохранение заказа:', orderData)
      
      const isEditing = editingOrder && editingOrder._id
      const url = isEditing 
        ? `https://bulladmin.ru/api/orders/${editingOrder._id}`
        : 'https://bulladmin.ru/api/orders'
      
      const response = await fetch(url, {
        method: isEditing ? 'PUT' : 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(orderData)
      })
      
      if (response.ok) {
        const result = await response.json()
        console.log('Заказ сохранен:', result)
        
        if (isEditing) {
          setOrders(orders.map(o => o._id === editingOrder._id ? result : o))
          alert('Заказ успешно обновлен!')
        } else {
          setOrders([result, ...orders])
          alert('Заказ успешно создан!')
        }
        setShowAddModal(false)
        setEditingOrder(null)
      } else {
        console.error('Ошибка сохранения заказа:', response.statusText)
        alert('Ошибка сохранения заказа')
      }
    } catch (error) {
      console.error('Ошибка сохранения заказа:', error)
      alert('Ошибка сохранения заказа')
    }
  }

  const handleDeleteOrder = async (id: string) => {
    if (confirm('Удалить заказ?')) {
      try {
        const response = await fetch(`https://bulladmin.ru/api/orders/${id}`, {
          method: 'DELETE'
        })
        
        if (response.ok) {
          setOrders(orders.filter(o => o._id !== id))
          alert('Заказ удален')
        } else {
          alert('Ошибка удаления заказа')
        }
      } catch (error) {
        console.error('Ошибка удаления заказа:', error)
        alert('Ошибка удаления заказа')
      }
    }
  }

  const handleSaveReservation = async (reservationData: Partial<Reservation>) => {
    try {
      console.log('Сохранение бронирования:', reservationData)

      const isEditing = editingReservation && editingReservation._id
      const url = isEditing
        ? `https://bulladmin.ru/api/reservations/${editingReservation._id}`
        : 'https://bulladmin.ru/api/reservations'

      const response = await fetch(url, {
        method: isEditing ? 'PUT' : 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(reservationData)
      })

      if (response.ok) {
        const result = await response.json()
        console.log('Бронирование сохранено:', result)

        // Проверяем, есть ли result.data (для стандартизированного ответа) или result напрямую
        const reservationData = result.data || result
        
        if (isEditing) {
          setReservations(reservations.map(r => r._id === editingReservation._id ? reservationData : r))
          alert('Бронирование успешно обновлено!')
        } else {
          setReservations([reservationData, ...reservations])
          alert('Бронирование успешно создано!')
        }
        setShowReservationModal(false)
        setEditingReservation(null)
      } else {
        const errorData = await response.json()
        console.error('Ошибка сохранения бронирования:', errorData)
        alert(`Ошибка сохранения бронирования: ${errorData.message || response.statusText}`)
      }
    } catch (error) {
      console.error('Ошибка сохранения бронирования:', error)
      alert('Ошибка сохранения бронирования')
    }
  }

  const handleDeleteReservation = async (id: string) => {
    if (confirm('Удалить бронирование?')) {
      try {
        const response = await fetch(`https://bulladmin.ru/api/reservations/${id}`, {
          method: 'DELETE'
        })
        
        if (response.ok) {
          setReservations(reservations.filter(r => r._id !== id))
          alert('Бронирование удалено')
        } else {
          alert('Ошибка удаления бронирования')
        }
      } catch (error) {
        console.error('Ошибка удаления бронирования:', error)
        alert('Ошибка удаления бронирования')
      }
    }
  }

  const statsCards = [
    {
      title: 'Рестораны',
      value: stats?.restaurants || 0,
      icon: BuildingOfficeIcon,
      color: 'bg-blue-500'
    },
    {
      title: 'Блюда',
      value: stats?.dishes || 0,
      icon: ChartBarIcon,
      color: 'bg-green-500'
    },
    {
      title: 'Новости',
      value: stats?.news || 0,
      icon: NewspaperIcon,
      color: 'bg-purple-500'
    },
    {
      title: 'Пользователи',
      value: stats?.users || 0,
      icon: UserGroupIcon,
      color: 'bg-orange-500'
    }
  ]

  return (
    <div className={`min-h-screen transition-colors duration-300 ${
      isDarkMode 
        ? 'bg-gray-900' 
        : 'bg-gray-50'
    }`}>
      {/* Mobile Menu Button */}
      <button
        onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
        className={`fixed top-4 left-4 z-50 md:hidden p-2 rounded-md transition-colors duration-300 ${
          isDarkMode 
            ? 'bg-gray-800 text-white border border-gray-700' 
            : 'bg-white text-gray-900 border border-gray-200'
        }`}
      >
        <svg className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
        </svg>
      </button>

      {/* Sidebar */}
      <div className={`fixed inset-y-0 left-0 z-40 w-64 transition-all duration-300 ${
        mobileMenuOpen ? 'translate-x-0' : '-translate-x-full'
      } md:translate-x-0 ${
        isDarkMode 
          ? 'bg-gray-800 border-r border-gray-700' 
          : 'bg-white border-r border-gray-200'
      }`}>
        {/* Logo */}
        <div className="flex items-center justify-center h-16 px-4 border-b border-gray-200 dark:border-gray-700">
          <div className="flex items-center space-x-3">
            <div className="w-8 h-8 bg-gradient-to-r from-blue-600 to-purple-600 rounded-lg flex items-center justify-center">
              <span className="text-white font-bold text-sm">Б</span>
            </div>
            <div>
              <h1 className={`text-xl font-bold transition-colors duration-300 ${
                isDarkMode ? 'text-white' : 'text-gray-900'
              }`}>БЫК Holding</h1>
              <p className={`text-xs transition-colors duration-300 ${
                isDarkMode ? 'text-gray-400' : 'text-gray-500'
              }`}>Админ Панель</p>
            </div>
          </div>
        </div>

        {/* Navigation */}
        <nav className="mt-8 px-4">
          <div className="space-y-2">
            {[
              { id: 'dashboard', name: 'Дашборд', icon: '📊', color: 'from-blue-500 to-blue-600' },
              { id: 'restaurants', name: 'Рестораны', icon: '🏢', color: 'from-green-500 to-green-600' },
              { id: 'dishes', name: 'Блюда', icon: '🍽️', color: 'from-orange-500 to-orange-600' },
              { id: 'news', name: 'Новости', icon: '📰', color: 'from-purple-500 to-purple-600' },
              { id: 'users', name: 'Пользователи', icon: '👥', color: 'from-pink-500 to-pink-600' },
              { id: 'orders', name: 'Заказы', icon: '📦', color: 'from-indigo-500 to-indigo-600' },
              { id: 'reservations', name: 'Бронирования', icon: '📅', color: 'from-teal-500 to-teal-600' },
              { id: 'files', name: 'Файлы', icon: '📁', color: 'from-gray-500 to-gray-600' }
            ].map((tab) => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`w-full flex items-center space-x-3 px-4 py-3 rounded-xl transition-all duration-300 group ${
                  activeTab === tab.id
                    ? `bg-gradient-to-r ${tab.color} text-white shadow-lg transform scale-105`
                    : isDarkMode 
                      ? 'text-gray-300 hover:text-white hover:bg-gray-700' 
                      : 'text-gray-600 hover:text-gray-900 hover:bg-gray-100'
                }`}
              >
                <span className="text-lg">{tab.icon}</span>
                <span className="font-medium">{tab.name}</span>
                {activeTab === tab.id && (
                  <div className="ml-auto w-2 h-2 bg-white rounded-full"></div>
                )}
              </button>
            ))}
          </div>
        </nav>

        {/* User Profile */}
        <div className="absolute bottom-0 left-0 right-0 p-4 border-t border-gray-200 dark:border-gray-700">
          <div className="flex items-center space-x-3">
            <div className="w-10 h-10 bg-gradient-to-r from-blue-600 to-purple-600 rounded-full flex items-center justify-center">
              <span className="text-white font-bold">A</span>
            </div>
            <div className="flex-1">
              <p className={`text-sm font-medium transition-colors duration-300 ${
                isDarkMode ? 'text-white' : 'text-gray-900'
              }`}>Администратор</p>
              <p className={`text-xs transition-colors duration-300 ${
                isDarkMode ? 'text-gray-400' : 'text-gray-500'
              }`}>admin@byk.ru</p>
            </div>
            <button
              onClick={() => setIsDarkMode(!isDarkMode)}
              className={`p-2 rounded-lg transition-all duration-300 ${
                isDarkMode 
                  ? 'bg-gray-700 text-yellow-400 hover:bg-gray-600' 
                  : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
              }`}
              title={isDarkMode ? 'Светлая тема' : 'Темная тема'}
            >
              {isDarkMode ? '☀️' : '🌙'}
            </button>
          </div>
        </div>
      </div>

      {/* Mobile Overlay */}
      {mobileMenuOpen && (
        <div 
          className="fixed inset-0 z-30 bg-black bg-opacity-50 md:hidden"
          onClick={() => setMobileMenuOpen(false)}
        />
      )}

      {/* Main Content */}
      <div className="md:ml-64 min-h-screen pt-16 md:pt-0">
        {/* Header */}
        <header className={`h-16 flex items-center justify-between px-4 sm:px-6 border-b transition-colors duration-300 ${
          isDarkMode 
            ? 'bg-gray-800 border-gray-700' 
            : 'bg-white border-gray-200'
        }`}>
          <div>
            <h2 className={`text-lg sm:text-xl lg:text-2xl font-bold transition-colors duration-300 ${
              isDarkMode ? 'text-white' : 'text-gray-900'
            }`}>
              {activeTab === 'dashboard' && '📊 Дашборд'}
              {activeTab === 'restaurants' && '🏢 Рестораны'}
              {activeTab === 'dishes' && '🍽️ Блюда'}
              {activeTab === 'news' && '📰 Новости'}
              {activeTab === 'users' && '👥 Пользователи'}
              {activeTab === 'orders' && '📦 Заказы'}
              {activeTab === 'reservations' && '📅 Бронирования'}
              {activeTab === 'files' && '📁 Файлы'}
            </h2>
          </div>
          <div className="flex items-center space-x-2 sm:space-x-4">
            <div className={`hidden sm:block px-3 py-2 rounded-lg transition-colors duration-300 ${
              isDarkMode ? 'bg-gray-700 text-gray-300' : 'bg-gray-100 text-gray-600'
            }`}>
              <span className="text-sm">Добро пожаловать!</span>
            </div>
            <button
              onClick={() => setIsDarkMode(!isDarkMode)}
              className={`p-2 rounded-md transition-colors duration-300 ${
                isDarkMode 
                  ? 'text-gray-300 hover:text-white hover:bg-gray-700' 
                  : 'text-gray-600 hover:text-gray-900 hover:bg-gray-100'
              }`}
            >
              {isDarkMode ? '☀️' : '🌙'}
            </button>
          </div>
        </header>

        {/* Content */}
        <div className="p-4 sm:p-6">
          {/* Dashboard Tab */}
          {activeTab === 'dashboard' && (
            <div>
            
            {/* Stats Cards */}
            <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6 mb-6 sm:mb-8">
              {statsCards.map((card) => (
                <div 
                  key={card.title} 
                  className={`group relative overflow-hidden rounded-2xl shadow-lg hover:shadow-2xl transition-all duration-500 p-4 sm:p-6 border ${
                    isDarkMode 
                      ? 'bg-gradient-to-br from-gray-800 to-gray-900 border-gray-700 hover:border-blue-500' 
                      : 'bg-gradient-to-br from-white to-gray-50 border-gray-200 hover:border-blue-300'
                  } hover:scale-105`}
                >
                  <div className="flex items-center justify-between">
                    <div className="flex items-center space-x-2 sm:space-x-4">
                      <div className={`p-2 sm:p-4 rounded-xl sm:rounded-2xl ${card.color} shadow-lg group-hover:scale-110 transition-transform duration-300`}>
                        <card.icon className="h-6 w-6 sm:h-8 sm:w-8 text-white" />
                      </div>
                      <div>
                        <p className={`text-xs sm:text-sm font-medium transition-colors duration-300 ${
                          isDarkMode ? 'text-gray-400' : 'text-gray-500'
                        }`}>{card.title}</p>
                        <p className={`text-xl sm:text-2xl lg:text-3xl font-bold transition-colors duration-300 ${
                          isDarkMode ? 'text-white' : 'text-gray-900'
                        }`}>{card.value}</p>
                      </div>
                    </div>
                    <div className={`w-3 h-3 rounded-full transition-colors duration-300 ${
                      isDarkMode ? 'bg-blue-500' : 'bg-blue-400'
                    }`}></div>
                  </div>
                  <div className={`absolute inset-0 bg-gradient-to-r ${card.color} opacity-0 group-hover:opacity-10 transition-opacity duration-300`}></div>
                </div>
              ))}
            </div>

            {/* Recent Restaurants */}
            <div className="bg-white rounded-lg shadow">
              <div className="px-6 py-4 border-b border-gray-200">
                <h3 className="text-lg font-medium text-gray-900">Последние рестораны</h3>
              </div>
              <div className="p-6">
                {loading ? (
                  <div className="text-center py-4">
                    <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500 mx-auto"></div>
                    <p className="mt-2 text-gray-500">Загрузка...</p>
                  </div>
                ) : restaurants.length > 0 ? (
                  <div className="space-y-4">
                    {restaurants.slice(0, 5).map((restaurant) => (
                      <div key={restaurant._id} className="flex items-center justify-between p-4 border rounded-lg">
                        <div>
                          <h4 className="font-medium text-gray-900">{restaurant.name}</h4>
                          <p className="text-sm text-gray-500">{restaurant.brand} • {restaurant.city}</p>
                        </div>
                        <div className="flex items-center space-x-2">
                          <span className="text-sm text-gray-500">⭐ {restaurant.rating}</span>
                          <button 
                            onClick={() => handleEditRestaurant(restaurant)}
                            className="p-2 text-gray-400 hover:text-blue-500 hover:bg-blue-50 rounded-md transition-colors"
                            title="Редактировать"
                          >
                            <PencilIcon className="h-4 w-4" />
                          </button>
                          <button 
                            onClick={() => handleDeleteRestaurant(restaurant._id)}
                            className="p-2 text-gray-400 hover:text-red-500 hover:bg-red-50 rounded-md transition-colors"
                            title="Удалить"
                          >
                            <TrashIcon className="h-4 w-4" />
                          </button>
                        </div>
                      </div>
                    ))}
                  </div>
                ) : (
                  <div className="text-center py-8">
                    <BuildingOfficeIcon className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                    <p className="text-gray-500">Нет ресторанов</p>
                    <button className="mt-4 bg-blue-500 text-white px-4 py-2 rounded-md hover:bg-blue-600">
                      <PlusIcon className="h-4 w-4 inline mr-2" />
                      Добавить ресторан
                    </button>
                  </div>
                )}
              </div>
            </div>
            </div>
          )}

        {/* Restaurants Tab */}
        {activeTab === 'restaurants' && (
          <div>
            <div className="flex flex-col sm:flex-row sm:justify-between sm:items-center mb-6 gap-4">
              <h2 className="text-2xl sm:text-3xl font-bold text-gray-900">
                🏢 Рестораны
              </h2>
              <button 
                onClick={handleAddRestaurant}
                className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-all duration-300 shadow-lg hover:shadow-xl flex items-center"
              >
                <PlusIcon className="h-4 w-4 mr-2" />
                Добавить ресторан
              </button>
            </div>
            
            <div className="bg-white rounded-lg shadow">
              <div className="p-6">
                {loading ? (
                  <div className="text-center py-8">
                    <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500 mx-auto"></div>
                    <p className="mt-2 text-gray-500">Загрузка ресторанов...</p>
                  </div>
                ) : restaurants.length > 0 ? (
                  <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-6">
                    {restaurants.map((restaurant) => (
                      <div key={restaurant._id} className={`group relative overflow-hidden rounded-2xl shadow-lg hover:shadow-2xl transition-all duration-500 border ${
                        isDarkMode 
                          ? 'bg-gradient-to-br from-gray-800 to-gray-900 border-gray-700 hover:border-green-500' 
                          : 'bg-gradient-to-br from-white to-gray-50 border-gray-200 hover:border-green-300'
                      } hover:scale-105`}>
                        {/* Фото ресторана */}
                        <div className="h-48 bg-gray-200 relative">
                          {restaurant.photos && restaurant.photos.length > 0 ? (
                            <img 
                              src={restaurant.photos[0]} 
                              alt={restaurant.name}
                              className="w-full h-full object-cover"
                            />
                          ) : (
                            <div className="flex items-center justify-center h-full text-gray-400">
                              <svg className="h-12 w-12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                              </svg>
                            </div>
                          )}
                          {/* Бренд бейдж */}
                          <div className="absolute top-2 left-2">
                            <span className="bg-blue-500 text-white px-2 py-1 rounded-full text-xs font-medium">
                              {restaurant.brand}
                            </span>
                          </div>
                          {/* Рейтинг бейдж */}
                          <div className="absolute top-2 right-2">
                            <span className="bg-yellow-400 text-black px-2 py-1 rounded-full text-xs font-medium flex items-center">
                              ⭐ {restaurant.rating}
                            </span>
                          </div>
                        </div>
                        
                        {/* Информация о ресторане */}
                        <div className="p-4">
                          <h3 className="font-medium text-gray-900 mb-1">{restaurant.name}</h3>
                          <p className="text-sm text-gray-500 mb-2">{restaurant.city}</p>
                          {restaurant.description && (
                            <p className="text-sm text-gray-600 mb-3 line-clamp-2">{restaurant.description}</p>
                          )}
                          
                          {/* Контактная информация */}
                          <div className="space-y-1 mb-3">
                            {restaurant.address && (
                              <p className="text-xs text-gray-500 flex items-center">
                                <svg className="h-3 w-3 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                                </svg>
                                {restaurant.address}
                              </p>
                            )}
                            {restaurant.phone && (
                              <p className="text-xs text-gray-500 flex items-center">
                                <svg className="h-3 w-3 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
                                </svg>
                                {restaurant.phone}
                              </p>
                            )}
                          </div>
                          
                          {/* Кнопки действий */}
                          <div className="flex items-center justify-between">
                            <div className="flex items-center space-x-2">
                              {restaurant.photos && restaurant.photos.length > 0 && (
                                <span className="text-xs text-gray-500 flex items-center">
                                  <svg className="h-3 w-3 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                                  </svg>
                                  {restaurant.photos.length} фото
                                </span>
                              )}
                              {restaurant.videos && restaurant.videos.length > 0 && (
                                <span className="text-xs text-gray-500 flex items-center">
                                  <svg className="h-3 w-3 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z" />
                                  </svg>
                                  {restaurant.videos.length} видео
                                </span>
                              )}
                            </div>
                            
                            <div className="flex space-x-2">
                              <button 
                                onClick={() => {
                                  setPreviewRestaurant(restaurant)
                                  setShowRestaurantPreviewModal(true)
                                }}
                                className="p-2 text-gray-400 hover:text-green-500 hover:bg-green-50 rounded-md transition-colors"
                                title="Предпросмотр"
                              >
                                <svg className="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                                </svg>
                              </button>
                              <button 
                                onClick={() => handleEditRestaurant(restaurant)}
                                className="p-2 text-gray-400 hover:text-blue-500 hover:bg-blue-50 rounded-md transition-colors"
                                title="Редактировать"
                              >
                                <PencilIcon className="h-4 w-4" />
                              </button>
                              <button 
                                onClick={() => handleDeleteRestaurant(restaurant._id)}
                                className="p-2 text-gray-400 hover:text-red-500 hover:bg-red-50 rounded-md transition-colors"
                                title="Удалить"
                              >
                                <TrashIcon className="h-4 w-4" />
                              </button>
                            </div>
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                ) : (
                  <div className="text-center py-8">
                    <BuildingOfficeIcon className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                    <p className="text-gray-500">Нет ресторанов</p>
                    <button 
                      onClick={() => {
                        setEditingRestaurant({} as Restaurant)
                        setEditingDish(null)
                        setEditingNews(null)
                        setEditingUser(null)
                        setShowAddModal(true)
                      }}
                      className="mt-4 bg-blue-500 text-white px-4 py-2 rounded-md hover:bg-blue-600"
                    >
                      <PlusIcon className="h-4 w-4 inline mr-2" />
                      Добавить ресторан
                    </button>
                  </div>
                )}
              </div>
            </div>
          </div>
        )}

        {/* Dishes Tab */}
        {activeTab === 'dishes' && (
          <div>
            <div className="flex flex-col sm:flex-row sm:justify-between sm:items-center mb-6 gap-4">
              <h2 className="text-2xl sm:text-3xl font-bold text-gray-900">
                🍽️ Блюда
              </h2>
              <div className="flex space-x-3">
                <button
                  onClick={() => setShowCategoryModal(true)}
                  className="bg-purple-600 text-white px-4 py-2 rounded-lg hover:bg-purple-700 transition-all duration-300 shadow-lg hover:shadow-xl flex items-center"
                >
                  <span>Управление категориями</span>
                </button>
              <button 
                onClick={() => {
                  setEditingDish({} as Dish)
                  setEditingRestaurant(null)
                  setEditingNews(null)
                  setEditingUser(null)
                  setFiles([]) // Очищаем файлы при создании нового блюда
                  setShowAddModal(true)
                }}
                className="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 transition-all duration-300 shadow-lg hover:shadow-xl flex items-center"
              >
                <PlusIcon className="h-4 w-4 mr-2" />
                Добавить блюдо
              </button>
              </div>
            </div>
            
            {/* Фильтры для блюд */}
            <div className="bg-white rounded-lg shadow p-4 mb-6">
              <div className="flex flex-col sm:flex-row sm:flex-wrap gap-4 items-start sm:items-center">
                <div className="flex flex-col sm:flex-row sm:items-center space-y-2 sm:space-y-0 sm:space-x-2 w-full sm:w-auto">
                  <label className="text-sm font-medium text-gray-700 whitespace-nowrap">Категория:</label>
                  <select
                    value={selectedCategory}
                    onChange={(e) => setSelectedCategory(e.target.value)}
                    className="px-3 py-1 border border-gray-300 rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-green-500 w-full sm:w-auto"
                  >
                    <option value="all">Все категории</option>
                    <option value="Мясо">Мясо</option>
                    <option value="Пицца">Пицца</option>
                    <option value="Паста">Паста</option>
                    <option value="Салаты">Салаты</option>
                    <option value="Супы">Супы</option>
                    <option value="Десерты">Десерты</option>
                    <option value="Напитки">Напитки</option>
                    <option value="Закуски">Закуски</option>
                  </select>
                </div>
                
                <div className="flex flex-col sm:flex-row sm:items-center space-y-2 sm:space-y-0 sm:space-x-2 w-full sm:w-auto">
                  <label className="text-sm font-medium text-gray-700 whitespace-nowrap">Бренд:</label>
                  <select
                    value={selectedBrand}
                    onChange={(e) => setSelectedBrand(e.target.value)}
                    className="px-3 py-1 border border-gray-300 rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-green-500 w-full sm:w-auto"
                  >
                    <option value="all">Все бренды</option>
                    <option value="БЫК">БЫК</option>
                    <option value="Пиво">Пиво</option>
                    <option value="Моска">Моска</option>
                    <option value="Грузия">Грузия</option>
                  </select>
                </div>
                
                <div className="flex flex-col sm:flex-row sm:items-center space-y-2 sm:space-y-0 sm:space-x-2 w-full sm:w-auto">
                  <label className="text-sm font-medium text-gray-700 whitespace-nowrap">Статус:</label>
                  <select className="px-3 py-1 border border-gray-300 rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-green-500 w-full sm:w-auto">
                    <option value="all">Все</option>
                    <option value="available">В наличии</option>
                    <option value="unavailable">Нет в наличии</option>
                  </select>
                </div>
                
                <button 
                  onClick={() => {
                    setSelectedCategory('all')
                    setSelectedBrand('all')
                  }}
                  className="px-3 py-1 text-sm text-gray-600 hover:text-gray-800 hover:bg-gray-100 rounded-md transition-colors"
                >
                  Сбросить фильтры
                </button>
              </div>
            </div>
            
            {/* Статистика по категориям */}
            <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-8 gap-4 mb-6">
              {['Мясо', 'Пицца', 'Паста', 'Салаты', 'Супы', 'Десерты', 'Напитки', 'Закуски'].map(category => {
                const count = dishes.filter(dish => dish.category === category).length
                return (
                  <div key={category} className="bg-white rounded-lg shadow p-3 text-center">
                    <div className="text-2xl font-bold text-gray-900">{count}</div>
                    <div className="text-xs text-gray-500">{category}</div>
                  </div>
                )
              })}
            </div>
            
            <div className="bg-white rounded-lg shadow">
              <div className="p-6">
                {loading ? (
                  <div className="text-center py-8">
                    <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-green-500 mx-auto"></div>
                    <p className="mt-2 text-gray-500">Загрузка блюд...</p>
                  </div>
                ) : dishes.length > 0 ? (
                  <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-6">
                    {dishes
                      .filter(dish => {
                        const categoryMatch = selectedCategory === 'all' || dish.category === selectedCategory
                        const brandMatch = selectedBrand === 'all' || dish.restaurantBrand === selectedBrand
                        return categoryMatch && brandMatch
                      })
                      .map((dish) => (
                      <div key={dish._id} className="border rounded-lg overflow-hidden hover:shadow-md transition-shadow">
                        <div className="h-48 bg-gray-200 relative">
                          {dish.imageURL && dish.imageURL.trim() !== '' ? (
                          <img 
                            src={dish.imageURL} 
                            alt={dish.name}
                            className="w-full h-full object-cover"
                          />
                          ) : (
                            <div className="w-full h-full flex items-center justify-center bg-gray-200">
                              <div className="text-center text-gray-500">
                                <svg className="w-12 h-12 mx-auto mb-2" fill="currentColor" viewBox="0 0 20 20">
                                  <path fillRule="evenodd" d="M4 3a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V5a2 2 0 00-2-2H4zm12 12H4l4-8 3 6 2-4 3 6z" clipRule="evenodd" />
                                </svg>
                                <p className="text-sm">Нет фото</p>
                              </div>
                            </div>
                          )}
                          <div className="absolute top-2 left-2">
                            <span className="bg-green-500 text-white px-2 py-1 rounded-full text-xs font-medium">
                              {dish.category}
                            </span>
                          </div>
                          <div className="absolute top-2 right-2">
                            <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                              dish.isAvailable ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                            }`}>
                              {dish.isAvailable ? 'В наличии' : 'Нет в наличии'}
                            </span>
                          </div>
                        </div>
                        
                        <div className="p-4">
                          <h3 className="font-medium text-gray-900 mb-1">{dish.name}</h3>
                          <p className="text-sm text-gray-500 mb-2">{dish.restaurantName}</p>
                          <p className="text-sm text-gray-600 mb-3 line-clamp-2">{dish.description}</p>
                          
                          <div className="flex items-center justify-between mb-3">
                            <span className="text-lg font-bold text-gray-900">{dish.price} ₽</span>
                            <div className="flex items-center space-x-2 text-xs text-gray-500">
                              <span>⏱️ {dish.preparationTime} мин</span>
                              <span>🔥 {dish.calories} ккал</span>
                            </div>
                          </div>
                          
                          {dish.allergens.length > 0 && (
                            <div className="mb-3">
                              <p className="text-xs text-gray-500 mb-1">Аллергены:</p>
                              <div className="flex flex-wrap gap-1">
                                {dish.allergens.map((allergen, index) => (
                                  <span key={index} className="bg-yellow-100 text-yellow-800 px-2 py-1 rounded text-xs">
                                    {allergen}
                                  </span>
                                ))}
                              </div>
                            </div>
                          )}
                          
                          <div className="flex items-center justify-between">
                            <span className="text-xs text-gray-500">{dish.restaurantBrand}</span>
                            <div className="flex space-x-2">
                              <button 
                                onClick={() => {
                                  setPreviewDish(dish)
                                  setShowDishPreviewModal(true)
                                }}
                                className="p-2 text-gray-400 hover:text-green-500 hover:bg-green-50 rounded-md transition-colors"
                                title="Предпросмотр"
                              >
                                <svg className="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                                </svg>
                              </button>
                              <button 
                                onClick={() => {
                                  setEditingDish(dish)
                                  setFiles([]) // Очищаем файлы при редактировании блюда
                                  setShowAddModal(true)
                                }}
                                className="p-2 text-gray-400 hover:text-blue-500 hover:bg-blue-50 rounded-md transition-colors"
                                title="Редактировать"
                              >
                                <PencilIcon className="h-4 w-4" />
                              </button>
                              <button 
                                onClick={() => handleDeleteDish(dish._id)}
                                className="p-2 text-gray-400 hover:text-red-500 hover:bg-red-50 rounded-md transition-colors"
                                title="Удалить"
                              >
                                <TrashIcon className="h-4 w-4" />
                              </button>
                            </div>
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                ) : (
                  <div className="text-center py-8">
                    <svg className="h-12 w-12 text-gray-400 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.746 0 3.332.477 4.5 1.253v13C19.832 18.477 18.246 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
                    </svg>
                    <p className="text-gray-500">Нет блюд</p>
                    <button 
                      onClick={() => {
                        setEditingDish({} as Dish)
                        setEditingRestaurant(null)
                        setEditingNews(null)
                        setEditingUser(null)
                        setFiles([]) // Очищаем файлы при создании нового блюда
                        setShowAddModal(true)
                      }}
                      className="mt-4 bg-green-500 text-white px-4 py-2 rounded-md hover:bg-green-600 transition-colors"
                    >
                      <PlusIcon className="h-4 w-4 inline mr-2" />
                      Добавить блюдо
                    </button>
                  </div>
                )}
              </div>
            </div>
          </div>
        )}

        {/* News Tab */}
        {activeTab === 'news' && (
          <div>
            <div className="flex flex-col sm:flex-row sm:justify-between sm:items-center mb-6 gap-4">
              <h2 className="text-2xl sm:text-3xl font-bold text-gray-900">
                📰 Новости
              </h2>
              <button 
                onClick={() => {
                  setEditingNews({} as News)
                  setEditingRestaurant(null)
                  setEditingDish(null)
                  setEditingUser(null)
                  setFiles([]) // Очищаем файлы при создании новой новости
                  setShowAddModal(true)
                }}
                className="bg-purple-600 text-white px-4 py-2 rounded-lg hover:bg-purple-700 transition-all duration-300 shadow-lg hover:shadow-xl flex items-center"
              >
                <PlusIcon className="h-4 w-4 mr-2" />
                Добавить новость
              </button>
            </div>
            
            <div className="bg-white rounded-lg shadow">
              <div className="p-6">
                {loading ? (
                  <div className="text-center py-8">
                    <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-purple-500 mx-auto"></div>
                    <p className="mt-2 text-gray-500">Загрузка новостей...</p>
                  </div>
                ) : news.length > 0 ? (
                  <div className="space-y-4">
                    {news.map((article) => (
                      <div key={article._id} className="border rounded-lg p-4 hover:shadow-md transition-shadow">
                        <div className="flex items-start space-x-4">
                          {article.imageURL && article.imageURL.trim() !== '' ? (
                          <img 
                            src={article.imageURL} 
                            alt={article.title}
                            className="w-20 h-20 object-cover rounded-lg"
                          />
                          ) : (
                            <div className="w-20 h-20 bg-gray-200 rounded-lg flex items-center justify-center">
                              <svg className="w-8 h-8 text-gray-400" fill="currentColor" viewBox="0 0 20 20">
                                <path fillRule="evenodd" d="M4 3a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V5a2 2 0 00-2-2H4zm12 12H4l4-8 3 6 2-4 3 6z" clipRule="evenodd" />
                              </svg>
                            </div>
                          )}
                          <div className="flex-1">
                            <div className="flex items-center justify-between mb-2">
                              <h3 className="font-medium text-gray-900">{article.title}</h3>
                              <div className="flex items-center space-x-2">
                                <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                                  article.isPublished ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'
                                }`}>
                                  {article.isPublished ? 'Опубликовано' : 'Черновик'}
                                </span>
                                <button 
                                  onClick={() => {
                                    setPreviewNews(article)
                                    setShowPreviewModal(true)
                                  }}
                                  className="p-2 text-gray-400 hover:text-green-500 hover:bg-green-50 rounded-md transition-colors"
                                  title="Предпросмотр"
                                >
                                  <svg className="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                                  </svg>
                                </button>
                                <button 
                                  onClick={() => {
                                    setEditingNews(article)
                                    setShowAddModal(true)
                                  }}
                                  className="p-2 text-gray-400 hover:text-blue-500 hover:bg-blue-50 rounded-md transition-colors"
                                  title="Редактировать"
                                >
                                  <PencilIcon className="h-4 w-4" />
                                </button>
                                <button 
                                  onClick={async () => {
                                    if (confirm('Удалить новость?')) {
                                      try {
                                        const response = await fetch(`https://bulladmin.ru/api/news/${article._id}`, {
                                          method: 'DELETE'
                                        })
                                        
                                        if (response.ok) {
                                          setNews(news.filter(n => n._id !== article._id))
                                          alert('Новость удалена успешно!')
                                        } else {
                                          alert('Ошибка удаления новости')
                                        }
                                      } catch (error) {
                                        console.error('Ошибка удаления новости:', error)
                                        alert('Ошибка удаления новости')
                                      }
                                    }
                                  }}
                                  className="p-2 text-gray-400 hover:text-red-500 hover:bg-red-50 rounded-md transition-colors"
                                  title="Удалить"
                                >
                                  <TrashIcon className="h-4 w-4" />
                                </button>
                              </div>
                            </div>
                            <p className="text-sm text-gray-600 mb-2 line-clamp-2">{article.content}</p>
                            <div className="flex items-center justify-between text-xs text-gray-500">
                              <div className="flex items-center space-x-4">
                                <span>👤 {article.author}</span>
                                <span>📅 {new Date(article.createdAt).toLocaleDateString()}</span>
                                <span>👁️ {article.views}</span>
                                <span>❤️ {article.likes}</span>
                              </div>
                              <span className="bg-gray-100 px-2 py-1 rounded">{article.category}</span>
                            </div>
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                ) : (
                  <div className="text-center py-8">
                    <NewspaperIcon className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                    <p className="text-gray-500">Нет новостей</p>
                    <button 
                      onClick={() => {
                        setEditingNews({} as News)
                        setEditingRestaurant(null)
                        setEditingDish(null)
                        setEditingUser(null)
                        setFiles([]) // Очищаем файлы при создании новой новости
                        setShowAddModal(true)
                      }}
                      className="mt-4 bg-purple-500 text-white px-4 py-2 rounded-md hover:bg-purple-600 transition-colors"
                    >
                      <PlusIcon className="h-4 w-4 inline mr-2" />
                      Добавить новость
                    </button>
                  </div>
                )}
              </div>
            </div>
          </div>
        )}

        {/* Users Tab */}
        {activeTab === 'users' && (
          <div>
            <div className="flex flex-col sm:flex-row sm:justify-between sm:items-center mb-6 gap-4">
              <h2 className="text-2xl sm:text-3xl font-bold text-gray-900">
                👥 Пользователи
              </h2>
              <button 
                onClick={() => {
                  setEditingUser({} as User)
                  setEditingRestaurant(null)
                  setEditingDish(null)
                  setEditingNews(null)
                  setShowAddModal(true)
                }}
                className="bg-orange-600 text-white px-4 py-2 rounded-lg hover:bg-orange-700 transition-all duration-300 shadow-lg hover:shadow-xl flex items-center"
              >
                <PlusIcon className="h-4 w-4 mr-2" />
                Добавить пользователя
              </button>
            </div>
            
            <div className="bg-white rounded-lg shadow">
              <div className="p-6">
                {loading ? (
                  <div className="text-center py-8">
                    <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-orange-500 mx-auto"></div>
                    <p className="mt-2 text-gray-500">Загрузка пользователей...</p>
                  </div>
                ) : users.length > 0 ? (
                  <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
                    {users.map((user) => (
                      <div key={user._id} className="border rounded-lg p-4 hover:shadow-md transition-shadow">
                        <div className="flex flex-col sm:flex-row sm:items-start sm:justify-between mb-3">
                          <div className="flex items-center space-x-3 mb-3 sm:mb-0">
                            <div className="w-10 h-10 sm:w-12 sm:h-12 bg-gray-200 rounded-full flex items-center justify-center flex-shrink-0">
                              <span className="text-sm sm:text-lg font-medium text-gray-600">
                                {user.fullName.split(' ').map(n => n[0]).join('')}
                              </span>
                            </div>
                            <div className="min-w-0 flex-1">
                              <h3 className="font-medium text-gray-900 text-sm sm:text-base truncate">{user.fullName}</h3>
                              <p className="text-xs sm:text-sm text-gray-500 truncate">{user.email}</p>
                              <p className="text-xs sm:text-sm text-gray-500">{user.phone}</p>
                            </div>
                          </div>
                          
                          <div className="flex items-center justify-between sm:flex-col sm:items-end">
                            <div className="text-right">
                              <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                                user.membershipLevel === 'Платина' ? 'bg-purple-100 text-purple-800' :
                                user.membershipLevel === 'Золото' ? 'bg-yellow-100 text-yellow-800' :
                                user.membershipLevel === 'Серебро' ? 'bg-gray-100 text-gray-800' :
                                'bg-orange-100 text-orange-800'
                              }`}>
                                {user.membershipLevel}
                              </span>
                              <p className="text-xs text-gray-500 mt-1">{user.loyaltyPoints} баллов</p>
                            </div>
                            
                            <div className="flex items-center space-x-2 ml-2 sm:ml-0 sm:mt-2">
                              <button 
                                onClick={() => setPreviewUser(user)}
                                className="p-2 text-gray-400 hover:text-green-500 hover:bg-green-50 rounded-md transition-colors"
                                title="Предпросмотр"
                              >
                                <svg className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                                </svg>
                              </button>
                              <button 
                                onClick={() => {
                                  setEditingUser(user)
                                  setShowAddModal(true)
                                }}
                                className="p-2 text-gray-400 hover:text-blue-500 hover:bg-blue-50 rounded-md transition-colors"
                                title="Редактировать"
                              >
                                <PencilIcon className="h-4 w-4" />
                              </button>
                              <button 
                                onClick={() => handleDeleteUser(user._id)}
                                className="p-2 text-gray-400 hover:text-red-500 hover:bg-red-50 rounded-md transition-colors"
                                title="Удалить"
                              >
                                <TrashIcon className="h-4 w-4" />
                              </button>
                            </div>
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                ) : (
                  <div className="text-center py-8">
                    <UserGroupIcon className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                    <p className="text-gray-500">Нет пользователей</p>
                    <button 
                      onClick={() => {
                        setEditingUser({} as User)
                        setEditingRestaurant(null)
                        setEditingDish(null)
                        setEditingNews(null)
                        setShowAddModal(true)
                      }}
                      className="mt-4 bg-orange-500 text-white px-4 py-2 rounded-md hover:bg-orange-600 transition-colors"
                    >
                      <PlusIcon className="h-4 w-4 inline mr-2" />
                      Добавить пользователя
                    </button>
                  </div>
                )}
              </div>
            </div>
          </div>
        )}

        {/* Orders Tab */}
        {activeTab === 'orders' && (
          <div>
            <div className="flex flex-col sm:flex-row sm:justify-between sm:items-center mb-6 gap-4">
              <h2 className="text-2xl sm:text-3xl font-bold text-gray-900">
                📦 Заказы
              </h2>
              <button 
                onClick={() => {
                  if (users.length === 0) {
                    alert('Сначала создайте пользователей! Заказы могут делать только зарегистрированные пользователи.')
                    return
                  }
                  setEditingOrder({} as Order)
                  setSelectedDeliveryMethod('delivery')
                  setSelectedDishes([])
                  setEditingRestaurant(null)
                    setEditingDish(null)
                    setEditingNews(null)
                    setEditingUser(null)
                    setEditingReservation(null)
                  setShowAddModal(true)
                }}
                className="bg-indigo-600 text-white px-3 sm:px-4 py-2 rounded-lg hover:bg-indigo-700 transition-all duration-300 shadow-lg hover:shadow-xl flex items-center text-sm sm:text-base"
              >
                <PlusIcon className="h-4 w-4 mr-1 sm:mr-2" />
                <span className="hidden sm:inline">Добавить заказ</span>
                <span className="sm:hidden">Добавить</span>
              </button>
            </div>
            
            <div className="bg-white rounded-lg shadow">
              <div className="p-6">
                {loading ? (
                  <div className="text-center py-8">
                    <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-indigo-500 mx-auto"></div>
                    <p className="mt-2 text-gray-500">Загрузка заказов...</p>
                  </div>
                ) : orders.length > 0 ? (
                  <div className="grid grid-cols-1 lg:grid-cols-2 xl:grid-cols-3 gap-4">
                    {orders.map((order) => (
                      <div key={order._id} className="border rounded-lg p-4 hover:shadow-md transition-shadow">
                        <div className="flex flex-col space-y-3">
                          <div className="flex items-start justify-between">
                            <div className="flex items-center space-x-3">
                              <div className="w-10 h-10 sm:w-12 sm:h-12 bg-indigo-100 rounded-full flex items-center justify-center flex-shrink-0">
                                <span className="text-sm sm:text-lg font-medium text-indigo-600">
                                📦
                              </span>
                            </div>
                              <div className="min-w-0 flex-1">
                                <h3 className="font-medium text-gray-900 text-sm sm:text-base truncate">{order.orderNumber}</h3>
                                <p className="text-xs sm:text-sm text-gray-500 truncate">{order.userName}</p>
                                <p className="text-xs sm:text-sm text-gray-500 truncate">{order.restaurantName}</p>
                              </div>
                            </div>
                            
                            <div className="text-right">
                              <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                                order.status === 'pending' ? 'bg-yellow-100 text-yellow-800' :
                                order.status === 'confirmed' ? 'bg-blue-100 text-blue-800' :
                                order.status === 'preparing' ? 'bg-orange-100 text-orange-800' :
                                order.status === 'ready' ? 'bg-green-100 text-green-800' :
                                order.status === 'delivered' ? 'bg-gray-100 text-gray-800' :
                                'bg-red-100 text-red-800'
                              }`}>
                                {order.status === 'pending' ? 'Ожидает' :
                                 order.status === 'confirmed' ? 'Подтвержден' :
                                 order.status === 'preparing' ? 'Готовится' :
                                 order.status === 'ready' ? 'Готов' :
                                 order.status === 'delivered' ? 'Доставлен' : 'Отменен'}
                              </span>
                              <p className="text-xs text-gray-500 mt-1">{new Date(order.createdAt).toLocaleDateString()}</p>
                            </div>
                          </div>
                          
                          <div className="space-y-2">
                            <p className="text-xs sm:text-sm text-gray-500">{order.items.length} позиций • {order.totalAmount} ₽</p>
                            {order.deliveryMethod === 'delivery' && order.deliveryAddress && (
                              <p className="text-xs sm:text-sm text-gray-500">📍 {order.deliveryAddress}</p>
                            )}
                            {order.deliveryMethod === 'pickup' && order.pickupRestaurantId && (
                              <p className="text-xs sm:text-sm text-gray-500">🏪 Самовывоз из ресторана</p>
                            )}
                            <div className="flex flex-wrap items-center gap-2">
                                <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                                  order.deliveryMethod === 'delivery' ? 'bg-blue-100 text-blue-800' : 'bg-green-100 text-green-800'
                                }`}>
                                  {order.deliveryMethod === 'delivery' ? '🚚 Доставка' : '🏪 Самовывоз'}
                                </span>
                                <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                                  order.paymentMethod === 'card' ? 'bg-purple-100 text-purple-800' : 'bg-yellow-100 text-yellow-800'
                                }`}>
                                  {order.paymentMethod === 'card' ? '💳 Карта' : '💵 Наличные'}
                                </span>
                            </div>
                          </div>
                          
                          <div className="flex items-center justify-between pt-2 border-t border-gray-100">
                            <div className="flex items-center space-x-2">
                              <button 
                                onClick={() => setPreviewOrder(order)}
                                className="p-2 text-gray-400 hover:text-green-500 hover:bg-green-50 rounded-md transition-colors"
                                title="Предпросмотр"
                              >
                                <svg className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                                </svg>
                              </button>
                              <button 
                                onClick={() => {
                                  setEditingOrder(order)
                                  setSelectedDeliveryMethod(order.deliveryMethod)
                                  setSelectedDishes(order.items || [])
                                  setShowAddModal(true)
                                }}
                                className="p-2 text-gray-400 hover:text-blue-500 hover:bg-blue-50 rounded-md transition-colors"
                                title="Редактировать"
                              >
                                <PencilIcon className="h-4 w-4" />
                              </button>
                              <button 
                                onClick={() => handleDeleteOrder(order._id)}
                                className="p-2 text-gray-400 hover:text-red-500 hover:bg-red-50 rounded-md transition-colors"
                                title="Удалить"
                              >
                                <TrashIcon className="h-4 w-4" />
                              </button>
                            </div>
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                ) : (
                  <div className="text-center py-8">
                    <div className="w-12 h-12 bg-indigo-100 rounded-full flex items-center justify-center mx-auto mb-4">
                      <span className="text-2xl">📦</span>
                    </div>
                    <p className="text-gray-500">Нет заказов</p>
                    <button 
                      onClick={() => {
                        if (users.length === 0) {
                          alert('Сначала создайте пользователей! Заказы могут делать только зарегистрированные пользователи.')
                          return
                        }
                        setEditingOrder({} as Order)
                        setSelectedDeliveryMethod('delivery')
                        setSelectedDishes([])
                        setEditingRestaurant(null)
                    setEditingDish(null)
                    setEditingNews(null)
                    setEditingUser(null)
                    setEditingReservation(null)
                        setShowAddModal(true)
                      }}
                      className="mt-4 bg-indigo-500 text-white px-3 sm:px-4 py-2 rounded-md hover:bg-indigo-600 transition-colors text-sm sm:text-base"
                    >
                      <PlusIcon className="h-4 w-4 inline mr-1 sm:mr-2" />
                      <span className="hidden sm:inline">Добавить заказ</span>
                      <span className="sm:hidden">Добавить</span>
                    </button>
                  </div>
                )}
              </div>
            </div>
          </div>
        )}

        {/* Files Tab */}
        {activeTab === 'files' && (
          <div>
            <div className="flex flex-col sm:flex-row sm:justify-between sm:items-center mb-6 gap-4">
              <h2 className="text-2xl sm:text-3xl font-bold text-gray-900">
                📁 Файлы
              </h2>
              <div className="flex space-x-4">
                <input
                  type="file"
                  id="single-file"
                  onChange={(e) => e.target.files?.[0] && handleFileUpload(e.target.files[0])}
                  className="hidden"
                  accept="image/*,video/*,.pdf,.doc,.docx"
                />
                <label
                  htmlFor="single-file"
                  className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-all duration-300 shadow-lg hover:shadow-xl flex items-center cursor-pointer"
                >
                  <PlusIcon className="h-4 w-4 mr-2" />
                  Загрузить файл
                </label>
                <input
                  type="file"
                  id="multiple-files"
                  onChange={(e) => e.target.files && handleMultipleFileUpload(e.target.files)}
                  className="hidden"
                  multiple
                  accept="image/*,video/*,.pdf,.doc,.docx"
                />
                <label
                  htmlFor="multiple-files"
                  className="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 transition-all duration-300 shadow-lg hover:shadow-xl flex items-center cursor-pointer"
                >
                  <PlusIcon className="h-4 w-4 mr-2" />
                  Загрузить несколько
                </label>
              </div>
            </div>
            
            <div className="bg-white rounded-lg shadow">
              <div className="p-6">
                {uploading ? (
                  <div className="text-center py-8">
                    <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500 mx-auto"></div>
                    <p className="mt-2 text-gray-500">Загрузка файлов...</p>
                  </div>
                ) : files.length > 0 ? (
                  <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                    {files.map((file, index) => (
                      <div key={index} className="border rounded-lg p-4 hover:shadow-md transition-shadow">
                        <div className="flex items-center justify-between">
                          <div className="flex items-center space-x-3">
                            <div className="w-10 h-10 bg-gray-100 rounded-full flex items-center justify-center">
                              <span className="text-lg">
                                {file.filename.includes('.jpg') || file.filename.includes('.png') ? '🖼️' :
                                 file.filename.includes('.mp4') || file.filename.includes('.mov') ? '🎥' :
                                 file.filename.includes('.pdf') ? '📄' : '📁'}
                              </span>
                            </div>
                            <div>
                              <h3 className="font-medium text-gray-900 truncate max-w-32">
                                {file.originalName || file.filename}
                              </h3>
                              <p className="text-sm text-gray-500">
                                {file.size ? (file.size / 1024 / 1024).toFixed(2) : '0.00'} MB
                              </p>
                            </div>
                          </div>
                          
                          <div className="flex items-center space-x-2">
                            <a
                              href={file.url}
            target="_blank"
            rel="noopener noreferrer"
                              className="p-2 text-gray-400 hover:text-blue-500 hover:bg-blue-50 rounded-md transition-colors"
                              title="Открыть"
                            >
                              <svg className="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
                              </svg>
                            </a>
                            <button 
                              onClick={() => {
                                if (confirm('Удалить файл?')) {
                                  deleteFile(file.filename)
                                }
                              }}
                              className="p-2 text-gray-400 hover:text-red-500 hover:bg-red-50 rounded-md transition-colors"
                              title="Удалить"
                            >
                              <TrashIcon className="h-4 w-4" />
                            </button>
        </div>
                        </div>
                      </div>
                    ))}
                  </div>
                ) : (
                  <div className="text-center py-8">
                    <div className="w-12 h-12 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
                      <span className="text-2xl">📁</span>
                    </div>
                    <p className="text-gray-500">Нет файлов</p>
                    <p className="text-sm text-gray-400 mt-1">Загрузите файлы для начала работы</p>
                    <p className="text-xs text-gray-300 mt-2">Состояние: {files.length} файлов</p>
                  </div>
                )}
              </div>
            </div>
          </div>
        )}

        {/* Reservations Tab */}
        {activeTab === 'reservations' && (
          <div>
            <div className="flex flex-col sm:flex-row sm:justify-between sm:items-center mb-6 gap-4">
              <h2 className="text-2xl sm:text-3xl font-bold text-gray-900">
                📅 Бронирования
              </h2>
              <button 
                onClick={() => {
                  if (users.length === 0) {
                    alert('Сначала создайте пользователей! Бронирования могут делать только зарегистрированные пользователи.')
                    return
                  }
                  setEditingReservation({
                  _id: '',
                  userId: '',
                  userName: '',
                  restaurantId: '',
                  date: '',
                  time: '',
                  guests: 1,
                  status: 'pending',
                  specialRequests: '',
                  createdAt: '',
                  updatedAt: ''
                } as Reservation)
                  setEditingRestaurant(null)
                    setEditingDish(null)
                    setEditingNews(null)
                    setEditingUser(null)
                    setEditingOrder(null)
                  setShowReservationModal(true)
                }}
                className="bg-purple-600 text-white px-4 py-2 rounded-lg hover:bg-purple-700 transition-all duration-300 shadow-lg hover:shadow-xl flex items-center"
              >
                <PlusIcon className="h-4 w-4 mr-2" />
                Добавить бронирование
              </button>
            </div>
            
            <div className="bg-white rounded-lg shadow">
              <div className="p-6">
                {loading ? (
                  <div className="text-center py-8">
                    <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-purple-500 mx-auto"></div>
                    <p className="mt-2 text-gray-500">Загрузка бронирований...</p>
                  </div>
                ) : reservations.length > 0 ? (
                  <div className="space-y-4">
                    {reservations.map((reservation) => (
                      <div key={reservation._id} className="border rounded-lg p-4 hover:shadow-md transition-shadow">
                        <div className="flex items-center justify-between">
                          <div className="flex items-center space-x-4">
                            <div className="w-12 h-12 bg-purple-100 rounded-full flex items-center justify-center">
                              <span className="text-lg font-medium text-purple-600">
                                📅
                              </span>
                            </div>
                            <div>
                              <h3 className="font-medium text-gray-900">{reservation.reservationNumber}</h3>
                              <p className="text-sm text-gray-500">{reservation.userName}</p>
                              <p className="text-sm text-gray-500">{reservation.restaurantName}</p>
                              <p className="text-sm text-gray-500">{reservation.date} в {reservation.time}</p>
                              <p className="text-sm text-gray-500">{reservation.guests} гостей</p>
                            </div>
                          </div>
                          
                          <div className="flex items-center space-x-4">
                            <div className="text-right">
                              <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                                reservation.status === 'confirmed' ? 'bg-green-100 text-green-800' :
                                reservation.status === 'pending' ? 'bg-yellow-100 text-yellow-800' :
                                'bg-red-100 text-red-800'
                              }`}>
                                {reservation.status === 'confirmed' ? 'Подтверждено' :
                                 reservation.status === 'pending' ? 'Ожидает' : 'Отменено'}
                              </span>
                              {reservation.specialRequests && (
                                <p className="text-xs text-gray-500 mt-1">{reservation.specialRequests}</p>
                              )}
                            </div>
                            
                            <div className="flex items-center space-x-2">
                              <button 
                                onClick={() => {
                                  setEditingReservation(reservation)
                                  setShowReservationModal(true)
                                }}
                                className="p-2 text-gray-400 hover:text-blue-500 hover:bg-blue-50 rounded-md transition-colors"
                                title="Редактировать"
                              >
                                <PencilIcon className="h-4 w-4" />
                              </button>
                              <button 
                                onClick={() => handleDeleteReservation(reservation._id)}
                                className="p-2 text-gray-400 hover:text-red-500 hover:bg-red-50 rounded-md transition-colors"
                                title="Удалить"
                              >
                                <TrashIcon className="h-4 w-4" />
                              </button>
                            </div>
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                ) : (
                  <div className="text-center py-8">
                    <CalendarIcon className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                    <p className="text-gray-500">Нет бронирований</p>
                    <button 
                      onClick={() => {
                        if (users.length === 0) {
                          alert('Сначала создайте пользователей! Бронирования могут делать только зарегистрированные пользователи.')
                          return
                        }
                        setEditingReservation({
                  _id: '',
                  userId: '',
                  userName: '',
                  restaurantId: '',
                  date: '',
                  time: '',
                  guests: 1,
                  status: 'pending',
                  specialRequests: '',
                  createdAt: '',
                  updatedAt: ''
                } as Reservation)
                        setEditingRestaurant(null)
                        setEditingDish(null)
                        setEditingNews(null)
                        setEditingUser(null)
                        setShowReservationModal(true)
                      }}
                      className="mt-4 bg-purple-500 text-white px-4 py-2 rounded-md hover:bg-purple-600 transition-colors"
                    >
                      <PlusIcon className="h-4 w-4 inline mr-2" />
                      Добавить бронирование
                    </button>
                  </div>
                )}
              </div>
            </div>
          </div>
        )}

        {/* Modal для добавления/редактирования ресторана */}
        {showAddModal && (
          <div 
            className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4"
            onClick={(e) => {
              if (e.target === e.currentTarget) {
                setShowAddModal(false)
                setEditingRestaurant(null)
                setEditingDish(null)
                setEditingNews(null)
                setEditingUser(null)
                setEditingOrder(null)
              }
            }}
          >
            <div className="bg-white rounded-lg p-4 sm:p-6 w-full max-w-2xl max-h-[90vh] overflow-y-auto">
              <div className="flex justify-between items-center mb-4">
                <h3 className="text-lg font-semibold">
                  {editingRestaurant && editingRestaurant._id ? 'Редактировать ресторан' : 
                 editingDish ? 'Редактировать блюдо' :
                 editingNews ? 'Редактировать новость' :
                 editingUser ? 'Редактировать пользователя' :
                 editingOrder ? 'Редактировать заказ' :
                 'Добавить ресторан'}
                </h3>
                <button
                  type="button"
                  onClick={() => {
                    setShowAddModal(false)
                    setEditingRestaurant(null)
                    setEditingDish(null)
                    setEditingNews(null)
                    setEditingUser(null)
                    setEditingOrder(null)
                  }}
                  className="text-gray-400 hover:text-gray-600 transition-colors"
                >
                  <svg className="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>
              
              <form onSubmit={(e) => {
                e.preventDefault()
                const formData = new FormData(e.currentTarget)
                
                if (editingDish) {
                  // Форма для блюд
                  const data = {
                    name: formData.get('dishName') as string || '',
                    description: formData.get('dishDescription') as string || '',
                    price: parseFloat(formData.get('dishPrice') as string || '0'),
                    category: formData.get('dishCategory') as string || '',
                    restaurantId: formData.get('dishRestaurant') as string || '',
                    imageURL: formData.get('dishImage') as string || '',
                    isAvailable: formData.get('dishAvailable') === 'true',
                    preparationTime: parseInt(formData.get('dishPreparationTime') as string || '0'),
                    calories: parseInt(formData.get('dishCalories') as string || '0'),
                    allergens: (formData.get('dishAllergens') as string)?.split(',').map(a => a.trim()).filter(a => a) || []
                  }
                  handleSaveDish(data)
                } else if (editingOrder) {
                  // Форма для заказов
                  const data = {
                    userId: (formData.get('userId') as string) || editingOrder?.userId || 'default-user-id',
                    userName: (formData.get('userName') as string) || '',
                    restaurantId: (formData.get('restaurantId') as string) || '',
                    deliveryMethod: (formData.get('deliveryMethod') as string) || 'delivery',
                    deliveryAddress: (formData.get('deliveryAddress') as string) || undefined,
                    pickupRestaurantId: (formData.get('pickupRestaurantId') as string) || undefined,
                    paymentMethod: (formData.get('paymentMethod') as string) || 'cash',
                    totalAmount: calculateTotalAmount(),
                    status: (formData.get('status') as string) || 'pending',
                    items: selectedDishes
                  }
                  handleSaveOrder(data)
                } else if (false && editingReservation) {
                  // Форма для бронирований - отключена в общем модале
                  const data = {
                    userId: (formData.get('userId') as string) || editingReservation?.userId || 'default-user-id',
                    userName: (formData.get('userName') as string) || editingReservation?.userName || '',
                    restaurantId: (formData.get('restaurantId') as string) || '',
                    date: (formData.get('date') as string) || '',
                    time: (formData.get('time') as string) || '',
                    guests: parseInt(formData.get('guests') as string || '1'),
                    status: (formData.get('status') as 'pending' | 'confirmed' | 'cancelled') || 'pending',
                    specialRequests: (formData.get('specialRequests') as string) || ''
                  }
                  handleSaveReservation(data)
                } else if (editingRestaurant) {
                  // Форма для ресторанов
                  const data = {
                    name: (formData.get('name') as string) || '',
                    brand: (formData.get('brand') as string) || '',
                    city: (formData.get('city') as string) || '',
                    rating: parseFloat(formData.get('rating') as string || '0'),
                    description: (formData.get('description') as string) || '',
                    address: (formData.get('address') as string) || '',
                    phone: (formData.get('phone') as string) || '',
                    email: (formData.get('email') as string) || '',
                    workingHours: (formData.get('workingHours') as string) || ''
                  }
                  handleSaveRestaurant(data)
                } else if (editingNews) {
                  // Форма для новостей
                  const data = {
                    title: (formData.get('newsTitle') as string) || '',
                    content: (formData.get('newsContent') as string) || '',
                    author: (formData.get('newsAuthor') as string) || '',
                    category: (formData.get('newsCategory') as string) || '',
                    tags: (formData.get('newsTags') as string)?.split(',').map(t => t.trim()).filter(t => t) || [],
                    isPublished: formData.get('newsPublished') === 'true'
                  }
                  handleSaveNews(data)
                } else if (editingUser) {
                  // Форма для пользователей
                  const fullName = (formData.get('userName') as string) || ''
                  const username = (formData.get('userUsername') as string) || ''
                  const email = (formData.get('userEmail') as string) || ''
                  const password = (formData.get('userPassword') as string) || ''
                  
                  // Проверяем обязательные поля
                  if (!fullName.trim()) {
                    alert('Полное имя обязательно для заполнения')
                    return
                  }
                  if (!username.trim()) {
                    alert('Логин обязателен для заполнения')
                    return
                  }
                  if (!email.trim()) {
                    alert('Email обязателен для заполнения')
                    return
                  }
                  if (!password.trim()) {
                    alert('Пароль обязателен для заполнения')
                    return
                  }
                  
                  const data = {
                    fullName: fullName.trim(),
                    username: username.trim(),
                    email: email.trim(),
                    password: password.trim(),
                    phone: (formData.get('userPhone') as string) || '',
                    role: 'user' as const,
                    isActive: formData.get('userActive') === 'true'
                  }
                  handleSaveUser(data)
                }
              }}>
                <div className="space-y-4">
                  {/* Поля для блюд */}
                  {editingDish && (
                    <>
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Название блюда
                        </label>
                        <input
                          type="text"
                          name="dishName"
                          defaultValue={editingDish?.name || ''}
                          className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500"
                          required
                        />
                      </div>
                      
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Описание
                        </label>
                        <textarea
                          name="dishDescription"
                          rows={3}
                          defaultValue={editingDish?.description || ''}
                          className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500"
                          placeholder="Описание блюда..."
                        />
                      </div>
                      
                      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Цена (₽)
                          </label>
                          <input
                            type="number"
                            name="dishPrice"
                            step="0.01"
                            min="0"
                            defaultValue={editingDish?.price || 0}
                            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500"
                            required
                          />
                        </div>
                        
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Категория
                          </label>
                        <select
                          name="dishCategory"
                          value={editingDish?.category || ''}
                          onChange={(e) => setEditingDish({...editingDish, category: e.target.value})}
                          className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500"
                          required
                        >
                            <option value="">Выберите категорию</option>
                            <option value="Мясо">Мясо</option>
                            <option value="Пицца">Пицца</option>
                            <option value="Паста">Паста</option>
                            <option value="Салаты">Салаты</option>
                            <option value="Супы">Супы</option>
                            <option value="Десерты">Десерты</option>
                            <option value="Напитки">Напитки</option>
                            <option value="Закуски">Закуски</option>
                          </select>
                        </div>
                      </div>
                      
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Ресторан
                        </label>
                        <select
                          name="dishRestaurant"
                          defaultValue={editingDish?.restaurantId || ''}
                          className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500"
                          required
                        >
                          <option value="">Выберите ресторан</option>
                          {restaurants.map(restaurant => (
                            <option key={restaurant._id} value={restaurant._id}>
                              {restaurant.name} ({restaurant.brand})
                            </option>
                          ))}
                        </select>
                      </div>
                      
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Фото блюда
                        </label>
                        <input
                          type="file"
                          accept="image/*"
                          onChange={(e) => {
                            const file = e.target.files?.[0]
                            if (file) {
                              handleFileUpload(file)
                            }
                          }}
                          className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500"
                        />
                        {uploading && (
                          <p className="text-sm text-green-600 mt-1">Загрузка...</p>
                        )}
                      </div>
                      
                      {/* Отображение загруженных фото для блюд */}
                      {files.filter(f => f.filename.includes('.jpg') || f.filename.includes('.png') || f.filename.includes('.gif')).length > 0 && (
                        <div className="mt-4">
                          <p className="text-sm font-medium text-gray-700 mb-2">Загруженные фото:</p>
                          <div className="grid grid-cols-2 gap-2">
                            {files.filter(f => f.filename.includes('.jpg') || f.filename.includes('.png') || f.filename.includes('.gif')).map((file, index) => (
                              <div key={index} className="relative group">
                                <img 
                                  src={file.url} 
                                  alt={file.originalName}
                                  className="w-full h-20 object-cover rounded border"
                                />
                                <button
                                  type="button"
                                  onClick={() => {
                                    if (confirm('Удалить фото?')) {
                                      deleteFile(file.filename)
                                    }
                                  }}
                                  className="absolute top-1 right-1 bg-red-500 text-white rounded-full w-6 h-6 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity hover:bg-red-600"
                                  title="Удалить фото"
                                >
                                  <svg className="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                                  </svg>
                                </button>
                                <p className="text-xs text-gray-500 truncate mt-1">{file.originalName}</p>
                              </div>
                            ))}
                          </div>
                        </div>
                      )}
                      
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          URL изображения (альтернатива)
                        </label>
                        <input
                          type="url"
                          name="dishImage"
                          defaultValue={editingDish?.imageURL || ''}
                          className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500"
                          placeholder="https://example.com/image.jpg"
                        />
                      </div>
                      
                      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Время приготовления (мин)
                          </label>
                          <input
                            type="number"
                            name="dishPreparationTime"
                            min="1"
                            defaultValue={editingDish?.preparationTime || 15}
                            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500"
                          />
                        </div>
                        
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Калории
                          </label>
                          <input
                            type="number"
                            name="dishCalories"
                            min="0"
                            defaultValue={editingDish?.calories || 0}
                            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500"
                          />
                        </div>
                      </div>
                      
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Аллергены (через запятую)
                        </label>
                        <input
                          type="text"
                          name="dishAllergens"
                          defaultValue={editingDish?.allergens?.join(', ') || ''}
                          className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500"
                          placeholder="Глютен, Молочные продукты, Орехи"
                        />
                      </div>
                      
                      <div>
                        <label className="flex items-center">
                          <input
                            type="checkbox"
                            name="dishAvailable"
                            value="true"
                            defaultChecked={editingDish?.isAvailable ?? true}
                            className="mr-2"
                          />
                          <span className="text-sm font-medium text-gray-700">В наличии</span>
                        </label>
                      </div>
                      
                      {/* Секция выбора файлов для блюда */}
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Выбрать фото для блюда
                        </label>
                        <div className="mt-2 p-4 border rounded-lg bg-gray-50">
                          <div className="flex items-center justify-between mb-3">
                            <span className="text-sm font-medium text-gray-700">
                              Выбрано файлов: {selectedFiles.length}
                            </span>
                            <button
                              type="button"
                              onClick={clearSelectedFiles}
                              className="text-xs text-red-600 hover:text-red-800"
                            >
                              Очистить выбор
                            </button>
                          </div>
                          
                          {files.filter(f => f.filename.includes('.jpg') || f.filename.includes('.png') || f.filename.includes('.webp')).length > 0 ? (
                            <div className="grid grid-cols-2 gap-2 max-h-32 overflow-y-auto">
                              {files.filter(f => f.filename.includes('.jpg') || f.filename.includes('.png') || f.filename.includes('.webp')).map((file, index) => {
                                const isSelected = selectedFiles.some(f => f.filename === file.filename)
                                return (
                                  <div
                                    key={index}
                                    onClick={() => toggleFileSelection(file)}
                                    className={`p-2 rounded border cursor-pointer transition-colors ${
                                      isSelected 
                                        ? 'bg-green-100 border-green-300' 
                                        : 'bg-white border-gray-200 hover:bg-gray-50'
                                    }`}
                                  >
                                    <div className="flex items-center space-x-2">
                                      <span className="text-sm">🖼️</span>
                                      <span className="text-xs truncate flex-1">
                                        {file.originalName || file.filename}
                                      </span>
                                      {isSelected && <span className="text-green-600">✓</span>}
                                    </div>
                                  </div>
                                )
                              })}
                            </div>
                          ) : (
                            <p className="text-sm text-gray-500">Нет загруженных изображений</p>
                          )}
                        </div>
                      </div>
                    </>
                  )}
                  
                  {/* Поля для новостей */}
                  {editingNews && (
                    <>
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Заголовок новости
                        </label>
                        <input
                          type="text"
                          name="newsTitle"
                          defaultValue={editingNews?.title || ''}
                          className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                          required
                        />
                      </div>
                      
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Содержание
                        </label>
                        <textarea
                          name="newsContent"
                          rows={6}
                          defaultValue={editingNews?.content || ''}
                          className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                          placeholder="Текст новости..."
                          required
                        />
                      </div>
                      
                      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Автор
                          </label>
                          <input
                            type="text"
                            name="newsAuthor"
                            defaultValue={editingNews?.author || ''}
                            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                            required
                          />
                        </div>
                        
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Категория
                          </label>
                          <select
                            name="newsCategory"
                            defaultValue={editingNews?.category || ''}
                            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                            required
                          >
                            <option value="">Выберите категорию</option>
                            <option value="Новости">Новости</option>
                            <option value="События">События</option>
                            <option value="Акции">Акции</option>
                            <option value="Объявления">Объявления</option>
                          </select>
                        </div>
                      </div>
                      
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Теги (через запятую)
                        </label>
                        <input
                          type="text"
                          name="newsTags"
                          defaultValue={editingNews?.tags?.join(', ') || ''}
                          className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                          placeholder="новости, события, акции"
                        />
                      </div>
                      
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Фото новости
                        </label>
                        <div className="mt-1 flex justify-center px-6 pt-5 pb-6 border-2 border-gray-300 border-dashed rounded-md hover:border-purple-400 hover:bg-purple-50 transition-colors">
                          <div className="space-y-1 text-center">
                            <svg
                              className="mx-auto h-12 w-12 text-gray-400"
                              stroke="currentColor"
                              fill="none"
                              viewBox="0 0 48 48"
                            >
                              <path
                                d="M28 8H12a4 4 0 00-4 4v20m32-12v8m0 0v8a4 4 0 01-4 4H12a4 4 0 01-4-4v-4m32-4l-3.172-3.172a4 4 0 00-5.656 0L28 28M8 32l9.172-9.172a4 4 0 015.656 0L28 28m0 0l4 4m4-24h8m-4-4v8m-12 4h.02"
                                strokeWidth={2}
                                strokeLinecap="round"
                                strokeLinejoin="round"
                              />
                            </svg>
                            <div className="flex text-sm text-gray-600">
                              <label
                                htmlFor="news-photo-upload"
                                className="relative cursor-pointer bg-white rounded-md font-medium text-purple-600 hover:text-purple-500 focus-within:outline-none focus-within:ring-2 focus-within:ring-offset-2 focus-within:ring-purple-500"
                              >
                                <span>Загрузить фото</span>
                                <input
                                  id="news-photo-upload"
                                  name="newsPhoto"
                                  type="file"
                                  accept="image/*"
                                  className="sr-only"
                                  onChange={async (e) => {
                                    const file = e.target.files?.[0]
                                    if (file) {
                                      await handleFileUpload(file)
                                    }
                                  }}
                                />
                              </label>
                              <p className="pl-1">или перетащите сюда</p>
                            </div>
                            <p className="text-xs text-gray-500">PNG, JPG, GIF до 10MB</p>
                          </div>
                        </div>
                        
                        {/* Показать загруженные изображения */}
                        {files.filter(f => f.filename.includes('.jpg') || f.filename.includes('.png') || f.filename.includes('.gif')).length > 0 && (
                          <div className="mt-4">
                            <p className="text-sm font-medium text-gray-700 mb-2">Загруженные изображения:</p>
                            <div className="grid grid-cols-2 gap-2">
                              {files.filter(f => f.filename.includes('.jpg') || f.filename.includes('.png') || f.filename.includes('.gif')).map((file, index) => (
                                <div key={index} className="relative group">
                                  <img 
                                    src={file.url} 
                                    alt={file.originalName}
                                    className="w-full h-20 object-cover rounded border"
                                  />
                                  <button
                                    type="button"
                                    onClick={() => {
                                      if (confirm('Удалить изображение?')) {
                                        deleteFile(file.filename)
                                      }
                                    }}
                                    className="absolute top-1 right-1 bg-red-500 text-white rounded-full w-6 h-6 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity hover:bg-red-600"
                                    title="Удалить изображение"
                                  >
                                    <svg className="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                                    </svg>
                                  </button>
                                  <p className="text-xs text-gray-500 truncate mt-1">{file.originalName}</p>
                                </div>
                              ))}
                            </div>
                          </div>
                        )}
                      </div>
                      
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Видео новости
                        </label>
                        <div className="mt-1 flex justify-center px-6 pt-5 pb-6 border-2 border-gray-300 border-dashed rounded-md hover:border-purple-400 hover:bg-purple-50 transition-colors">
                          <div className="space-y-1 text-center">
                            <svg
                              className="mx-auto h-12 w-12 text-gray-400"
                              fill="none"
                              stroke="currentColor"
                              viewBox="0 0 48 48"
                            >
                              <path
                                d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z"
                                strokeWidth={2}
                                strokeLinecap="round"
                                strokeLinejoin="round"
                              />
                            </svg>
                            <div className="flex text-sm text-gray-600">
                              <label
                                htmlFor="news-video-upload"
                                className="relative cursor-pointer bg-white rounded-md font-medium text-purple-600 hover:text-purple-500 focus-within:outline-none focus-within:ring-2 focus-within:ring-offset-2 focus-within:ring-purple-500"
                              >
                                <span>Загрузить видео</span>
                                <input
                                  id="news-video-upload"
                                  name="newsVideo"
                                  type="file"
                                  accept="video/*"
                                  className="sr-only"
                                  onChange={async (e) => {
                                    const file = e.target.files?.[0]
                                    if (file) {
                                      await handleFileUpload(file)
                                    }
                                  }}
                                />
                              </label>
                              <p className="pl-1">или перетащите сюда</p>
                            </div>
                            <p className="text-xs text-gray-500">MP4, MOV, AVI до 100MB</p>
                          </div>
                        </div>
                        
                        {/* Показать загруженные видео */}
                        {files.filter(f => f.filename.includes('.mp4') || f.filename.includes('.mov') || f.filename.includes('.avi')).length > 0 && (
                          <div className="mt-4">
                            <p className="text-sm font-medium text-gray-700 mb-2">Загруженные видео:</p>
                            <div className="space-y-2">
                              {files.filter(f => f.filename.includes('.mp4') || f.filename.includes('.mov') || f.filename.includes('.avi')).map((file, index) => (
                                <div key={index} className="flex items-center space-x-3 p-2 border rounded">
                                  <div className="w-12 h-12 bg-gray-100 rounded flex items-center justify-center">
                                    <span className="text-lg">🎥</span>
                                  </div>
                                  <div className="flex-1">
                                    <p className="text-sm font-medium text-gray-900">{file.originalName}</p>
                                    <p className="text-xs text-gray-500">{file.size ? (file.size / 1024 / 1024).toFixed(2) : '0.00'} MB</p>
                                  </div>
                                  <a 
                                    href={file.url} 
          target="_blank"
          rel="noopener noreferrer"
                                    className="text-blue-600 hover:text-blue-800 text-sm"
                                  >
                                    Открыть
                                  </a>
    </div>
                              ))}
                            </div>
                          </div>
                        )}
                      </div>
                      
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          URL изображения (альтернатива)
                        </label>
                        <input
                          type="url"
                          name="newsImageURL"
                          defaultValue={editingNews?.imageURL || ''}
                          className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                          placeholder="https://example.com/image.jpg"
                        />
                      </div>
                      
                      <div>
                        <label className="flex items-center">
                          <input
                            type="checkbox"
                            name="newsPublished"
                            value="true"
                            defaultChecked={editingNews?.isPublished ?? false}
                            className="mr-2"
                          />
                          <span className="text-sm font-medium text-gray-700">Опубликовать сразу</span>
                        </label>
                      </div>
                      
                      {/* Секция выбора файлов для новости */}
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Выбрать медиа для новости
                        </label>
                        <div className="mt-2 p-4 border rounded-lg bg-gray-50">
                          <div className="flex items-center justify-between mb-3">
                            <span className="text-sm font-medium text-gray-700">
                              Выбрано файлов: {selectedFiles.length}
                            </span>
                            <button
                              type="button"
                              onClick={clearSelectedFiles}
                              className="text-xs text-red-600 hover:text-red-800"
                            >
                              Очистить выбор
                            </button>
                          </div>
                          
                          {files.length > 0 ? (
                            <div className="grid grid-cols-2 gap-2 max-h-32 overflow-y-auto">
                              {files.map((file, index) => {
                                const isSelected = selectedFiles.some(f => f.filename === file.filename)
                                return (
                                  <div
                                    key={index}
                                    onClick={() => toggleFileSelection(file)}
                                    className={`p-2 rounded border cursor-pointer transition-colors ${
                                      isSelected 
                                        ? 'bg-purple-100 border-purple-300' 
                                        : 'bg-white border-gray-200 hover:bg-gray-50'
                                    }`}
                                  >
                                    <div className="flex items-center space-x-2">
                                      <span className="text-sm">
                                        {file.filename.includes('.jpg') || file.filename.includes('.png') || file.filename.includes('.webp') ? '🖼️' :
                                         file.filename.includes('.mp4') || file.filename.includes('.mov') ? '🎥' :
                                         file.filename.includes('.pdf') ? '📄' : '📁'}
                                      </span>
                                      <span className="text-xs truncate flex-1">
                                        {file.originalName || file.filename}
                                      </span>
                                      {isSelected && <span className="text-purple-600">✓</span>}
                                    </div>
                                  </div>
                                )
                              })}
                            </div>
                          ) : (
                            <p className="text-sm text-gray-500">Нет загруженных файлов</p>
                          )}
                        </div>
                      </div>
                    </>
                  )}
                  
                  {/* Поля для пользователей */}
                  {editingUser && (
                    <>
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Полное имя
                        </label>
                        <input
                          type="text"
                          name="userName"
                          defaultValue={editingUser?.fullName || ''}
                          className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-pink-500"
                          required
                        />
                      </div>
                      
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Логин
                        </label>
                        <input
                          type="text"
                          name="userUsername"
                          defaultValue={editingUser?.username || ''}
                          className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-pink-500"
                          required
                        />
                      </div>
                      
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Email
                        </label>
                        <input
                          type="email"
                          name="userEmail"
                          defaultValue={editingUser?.email || ''}
                          className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-pink-500"
                          required
                        />
                      </div>
                      
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Пароль
                        </label>
                        <input
                          type="password"
                          name="userPassword"
                          defaultValue=""
                          className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-pink-500"
                          required
                        />
                      </div>
                      
                      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Телефон
                          </label>
                          <input
                            type="tel"
                            name="userPhone"
                            defaultValue={editingUser?.phone || ''}
                            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-pink-500"
                          />
                        </div>
                        
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Уровень членства
                          </label>
                          <select
                            name="userMembershipLevel"
                            defaultValue={editingUser?.membershipLevel || 'Бронза'}
                            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-pink-500"
                          >
                            <option value="Бронза">Бронза</option>
                            <option value="Серебро">Серебро</option>
                            <option value="Золото">Золото</option>
                            <option value="Платина">Платина</option>
                          </select>
                        </div>
                        
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Баллы лояльности
                          </label>
                          <input
                            type="number"
                            name="userLoyaltyPoints"
                            defaultValue={editingUser?.loyaltyPoints || 0}
                            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-pink-500"
                            min="0"
                          />
                        </div>
                      </div>
                      
                      <div>
                        <label className="flex items-center">
                          <input
                            type="checkbox"
                            name="userActive"
                            value="true"
                            defaultChecked={editingUser?.isActive ?? true}
                            className="mr-2"
                          />
                          <span className="text-sm font-medium text-gray-700">Активный пользователь</span>
                        </label>
                      </div>
                    </>
                  )}
                  
                  {/* Поля для ресторанов */}
                  {editingRestaurant && (
                    <>
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Название
                        </label>
                        <input
                          type="text"
                          name="name"
                          defaultValue={editingRestaurant?.name || ''}
                          className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                          required
                        />
                      </div>
                      
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Бренд
                        </label>
                        <select
                          name="brand"
                          value={editingRestaurant?.brand || ''}
                          onChange={(e) => setEditingRestaurant({...editingRestaurant, brand: e.target.value})}
                          className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                          required
                        >
                          <option value="">Выберите бренд</option>
                          <option value="БЫК">БЫК</option>
                          <option value="Пиво">Пиво</option>
                          <option value="Моска">Моска</option>
                        </select>
                      </div>
                      
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Город
                        </label>
                        <input
                          type="text"
                          name="city"
                          defaultValue={editingRestaurant?.city || ''}
                          className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                          required
                        />
                      </div>
                      
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Рейтинг
                        </label>
                        <input
                          type="number"
                          name="rating"
                          step="0.1"
                          min="0"
                          max="5"
                          defaultValue={editingRestaurant?.rating || 0}
                          className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                          required
                        />
                      </div>
                      
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Описание
                        </label>
                        <textarea
                          name="description"
                          rows={3}
                          defaultValue={editingRestaurant?.description || ''}
                          className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                          placeholder="Описание ресторана..."
                        />
                      </div>
                      
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Фото ресторана
                        </label>
                        <div className="mt-1 flex justify-center px-6 pt-5 pb-6 border-2 border-gray-300 border-dashed rounded-md hover:border-blue-400 hover:bg-blue-50 transition-colors">
                          <div className="space-y-1 text-center">
                            <svg
                              className="mx-auto h-12 w-12 text-gray-400"
                              stroke="currentColor"
                              fill="none"
                              viewBox="0 0 48 48"
                            >
                              <path
                                d="M28 8H12a4 4 0 00-4 4v20m32-12v8m0 0v8a4 4 0 01-4 4H12a4 4 0 01-4-4v-4m32-4l-3.172-3.172a4 4 0 00-5.656 0L28 28M8 32l9.172-9.172a4 4 0 015.656 0L28 28m0 0l4 4m4-24h8m-4-4v8m-12 4h.02"
                                strokeWidth={2}
                                    strokeLinecap="round"
                                strokeLinejoin="round"
                              />
                            </svg>
                            <div className="flex text-sm text-gray-600">
                              <label
                                htmlFor="photo-upload"
                                className="relative cursor-pointer bg-white rounded-md font-medium text-blue-600 hover:text-blue-500 focus-within:outline-none focus-within:ring-2 focus-within:ring-offset-2 focus-within:ring-blue-500"
                              >
                                <span>Загрузить фото</span>
                                <input
                                  id="photo-upload"
                                  name="photo"
                                  type="file"
                                  accept="image/*"
                                  className="sr-only"
                                  multiple
                                  onChange={(e) => {
                                    const file = e.target.files?.[0]
                                    if (file) {
                                      handleFileUpload(file)
                                    }
                                  }}
                                />
                              </label>
                              <p className="pl-1">или перетащите сюда</p>
                            </div>
                            <p className="text-xs text-gray-500">PNG, JPG, GIF до 10MB</p>
                          </div>
                        </div>
                        
                        {/* Отображение загруженных фото для ресторана */}
                        {files.filter(f => f.filename.includes('.jpg') || f.filename.includes('.png') || f.filename.includes('.gif')).length > 0 && (
                          <div className="mt-4">
                            <p className="text-sm font-medium text-gray-700 mb-2">Загруженные фото ресторана:</p>
                            <div className="grid grid-cols-2 gap-2">
                              {files.filter(f => f.filename.includes('.jpg') || f.filename.includes('.png') || f.filename.includes('.gif')).map((file, index) => (
                                <div key={index} className="relative group">
                                  <img 
                                    src={file.url} 
                                    alt={file.originalName}
                                    className="w-full h-20 object-cover rounded border"
                                  />
                                  <button
                                    type="button"
                                    onClick={() => {
                                      if (confirm('Удалить фото?')) {
                                        deleteFile(file.filename)
                                      }
                                    }}
                                    className="absolute top-1 right-1 bg-red-500 text-white rounded-full w-6 h-6 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity hover:bg-red-600"
                                    title="Удалить фото"
                                  >
                                    <svg className="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                                    </svg>
                                  </button>
                                  <p className="text-xs text-gray-500 truncate mt-1">{file.originalName}</p>
                                </div>
                              ))}
                            </div>
                          </div>
                        )}
                      </div>
                      
                      {/* Секция выбора файлов */}
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Выбрать файлы для ресторана
                        </label>
                        <div className="mt-2 p-4 border rounded-lg bg-gray-50">
                          <div className="flex items-center justify-between mb-3">
                            <span className="text-sm font-medium text-gray-700">
                              Выбрано файлов: {selectedFiles.length}
                            </span>
                            <button
                              type="button"
                              onClick={clearSelectedFiles}
                              className="text-xs text-red-600 hover:text-red-800"
                            >
                              Очистить выбор
                            </button>
                          </div>
                          
                          {files.length > 0 ? (
                            <div className="grid grid-cols-2 gap-2 max-h-32 overflow-y-auto">
                              {files.map((file, index) => {
                                const isSelected = selectedFiles.some(f => f.filename === file.filename)
                                return (
                                  <div
                                    key={index}
                                    onClick={() => toggleFileSelection(file)}
                                    className={`p-2 rounded border cursor-pointer transition-colors ${
                                      isSelected 
                                        ? 'bg-blue-100 border-blue-300' 
                                        : 'bg-white border-gray-200 hover:bg-gray-50'
                                    }`}
                                  >
                                    <div className="flex items-center space-x-2">
                                      <span className="text-sm">
                                        {file.filename.includes('.jpg') || file.filename.includes('.png') || file.filename.includes('.webp') ? '🖼️' :
                                         file.filename.includes('.mp4') || file.filename.includes('.mov') ? '🎥' :
                                         file.filename.includes('.pdf') ? '📄' : '📁'}
                                      </span>
                                      <span className="text-xs truncate flex-1">
                                        {file.originalName || file.filename}
                                      </span>
                                      {isSelected && <span className="text-blue-600">✓</span>}
                                    </div>
                                  </div>
                                )
                              })}
                            </div>
                          ) : (
                            <p className="text-sm text-gray-500">Нет загруженных файлов</p>
                          )}
                        </div>
                      </div>
                      
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Видео ресторана
                        </label>
                        <div className="mt-1 flex justify-center px-6 pt-5 pb-6 border-2 border-gray-300 border-dashed rounded-md hover:border-purple-400 hover:bg-purple-50 transition-colors">
                          <div className="space-y-1 text-center">
                            <svg
                              className="mx-auto h-12 w-12 text-gray-400"
                              fill="none"
                              stroke="currentColor"
                              viewBox="0 0 48 48"
                            >
                              <path
                                d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z"
                                strokeWidth={2}
                                strokeLinecap="round"
                                strokeLinejoin="round"
                              />
                            </svg>
                            <div className="flex text-sm text-gray-600">
                              <label
                                htmlFor="video-upload"
                                className="relative cursor-pointer bg-white rounded-md font-medium text-purple-600 hover:text-purple-500 focus-within:outline-none focus-within:ring-2 focus-within:ring-offset-2 focus-within:ring-purple-500"
                              >
                                <span>Загрузить видео</span>
                                <input
                                  id="video-upload"
                                  name="video"
                                  type="file"
                                  accept="video/*"
                                  className="sr-only"
                                  multiple
                                />
                              </label>
                              <p className="pl-1">или перетащите сюда</p>
                            </div>
                            <p className="text-xs text-gray-500">MP4, MOV, AVI до 100MB</p>
                          </div>
                        </div>
                      </div>
                      
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Адрес
                        </label>
                        <input
                          type="text"
                          name="address"
                          defaultValue={editingRestaurant?.address || ''}
                          className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                          placeholder="Полный адрес ресторана"
                        />
                      </div>
                      
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Телефон
                        </label>
                        <input
                          type="tel"
                          name="phone"
                          defaultValue={editingRestaurant?.phone || ''}
                          className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                          placeholder="+7 (999) 123-45-67"
                        />
                      </div>
                      
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Email
                        </label>
                        <input
                          type="email"
                          name="email"
                          defaultValue={editingRestaurant?.email || ''}
                          className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                          placeholder="restaurant@byk.ru"
                        />
                      </div>
                      
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Время работы
                        </label>
                        <input
                          type="text"
                          name="workingHours"
                          defaultValue={editingRestaurant?.workingHours || ''}
                          className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                          placeholder="Пн-Вс: 10:00 - 23:00"
                        />
                      </div>
                    </>
                  )}
                  
                  {/* Поля для бронирований - убрано из общего модала */}
                  {false && editingReservation && (
                    <>
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Имя клиента
                        </label>
                        <input
                          type="text"
                          name="userName"
                          defaultValue={editingReservation?.userName || ''}
                          className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                          placeholder="Иван Петров"
                          required
                        />
                      </div>
                      
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Выберите пользователя
                        </label>
                        <select
                          name="userId"
                          value={editingReservation?.userId || ''}
                          onChange={(e) => {
                            const selectedUser = users.find(u => u._id === e.target.value)
                            if (selectedUser && editingReservation) {
                              setEditingReservation({
                                ...editingReservation,
                                userId: selectedUser._id,
                                userName: selectedUser.fullName
                              })
                            }
                          }}
                          className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                          required
                        >
                          <option value="">Выберите пользователя</option>
                          {users.map((user) => (
                            <option key={user._id} value={user._id}>
                              {user.fullName} ({user.email})
                            </option>
                          ))}
                        </select>
                      </div>
                      
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Ресторан
                        </label>
                        <select
                          name="restaurantId"
                          value={editingReservation?.restaurantId || ''}
                          onChange={(e) => editingReservation && setEditingReservation({...editingReservation, restaurantId: e.target.value})}
                          className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                          required
                        >
                          <option value="">Выберите ресторан</option>
                          {restaurants.map((restaurant) => (
                            <option key={restaurant._id} value={restaurant._id}>
                              {restaurant.name} ({restaurant.brand})
                            </option>
                          ))}
                        </select>
                      </div>
                      
                      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Дата
                          </label>
                          <input
                            type="date"
                            name="date"
                            defaultValue={editingReservation?.date || ''}
                            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                            required
                          />
                        </div>
                        
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Время
                          </label>
                          <input
                            type="time"
                            name="time"
                            defaultValue={editingReservation?.time || ''}
                            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                            required
                          />
                        </div>
                      </div>
                      
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Количество гостей
                        </label>
                        <input
                          type="number"
                          name="guests"
                          min="1"
                          max="20"
                          defaultValue={editingReservation?.guests || 2}
                          className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                          required
                        />
                      </div>
                      
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Статус
                        </label>
                        <select
                          name="status"
                          defaultValue={editingReservation?.status || 'pending'}
                          className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                          required
                        >
                          <option value="pending">Ожидает подтверждения</option>
                          <option value="confirmed">Подтверждено</option>
                          <option value="cancelled">Отменено</option>
                        </select>
                      </div>
                      
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Особые пожелания
                        </label>
                        <textarea
                          name="specialRequests"
                          rows={3}
                          defaultValue={editingReservation?.specialRequests || ''}
                          className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                          placeholder="Стол у окна, детский стульчик и т.д."
                        />
                      </div>
                    </>
                  )}
                  
                <div className="flex justify-end space-x-3 mt-6">
                  <button
                    type="button"
                    onClick={() => {
                      setShowAddModal(false)
                      setEditingRestaurant(null)
                      setEditingDish(null)
                      setEditingNews(null)
                      setEditingUser(null)
                      setEditingOrder(null)
                    }}
                    className="px-4 py-2 text-gray-700 bg-gray-200 rounded-md hover:bg-gray-300 transition-colors"
                  >
                    Отмена
                  </button>
                  <button
                    type="submit"
                    className="px-4 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-600 transition-colors"
                  >
                    {editingRestaurant && editingRestaurant._id ? 'Сохранить' : 'Добавить'}
                  </button>
                </div>
              </div>
              </form>
            </div>
          </div>
        )}

        {/* Отдельный модал для заказов */}
        {editingOrder && (
          <div 
            className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4"
            onClick={(e) => {
              if (e.target === e.currentTarget) {
                setEditingOrder(null)
                setSelectedDeliveryMethod('delivery')
                setSelectedDishes([])
              }
            }}
          >
            <div className="bg-white rounded-lg p-4 sm:p-6 w-full max-w-4xl max-h-[90vh] overflow-y-auto">
              <div className="flex justify-between items-center mb-4">
                <h3 className="text-lg font-semibold">
                  {editingOrder._id ? 'Редактировать заказ' : 'Добавить заказ'}
                </h3>
                <button
                  type="button"
                  onClick={() => {
                    setEditingOrder(null)
                    setSelectedDeliveryMethod('delivery')
                    setSelectedDishes([])
                  }}
                  className="text-gray-500 hover:text-gray-700"
                >
                  <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>

              <form onSubmit={async (e) => {
                e.preventDefault()
                const formData = new FormData(e.currentTarget)
                
                const orderData = {
                  userId: formData.get('userId') as string,
                  userName: formData.get('userName') as string,
                  restaurantId: formData.get('restaurantId') as string,
                  deliveryMethod: formData.get('deliveryMethod') as string,
                  paymentMethod: formData.get('paymentMethod') as string,
                  totalAmount: calculateTotalAmount(),
                  status: formData.get('status') as string,
                  items: selectedDishes,
                  deliveryAddress: formData.get('deliveryAddress') as string || undefined,
                  pickupRestaurantId: formData.get('pickupRestaurantId') as string || undefined,
                }

                await handleSaveOrder(orderData)
              }}>
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                      Выберите пользователя
                        </label>
                    <select
                      name="userId"
                      defaultValue={editingOrder?.userId || ''}
                      onChange={(e) => {
                        const selectedUser = users.find(u => u._id === e.target.value)
                        if (selectedUser && editingOrder) {
                          setEditingOrder({
                            ...editingOrder,
                            _id: editingOrder._id || '',
                            userId: selectedUser._id,
                            userName: selectedUser.fullName
                          } as Order)
                        }
                      }}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
                          required
                    >
                      <option value="">Выберите пользователя</option>
                      {users.map((user) => (
                        <option key={user._id} value={user._id}>
                          {user.fullName} ({user.email})
                        </option>
                      ))}
                    </select>
                      </div>
                      
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Имя клиента
                        </label>
                        <input
                          type="text"
                          name="userName"
                      value={editingOrder?.userName || ''}
                      readOnly
                      className="w-full px-3 py-2 border border-gray-300 rounded-md bg-gray-50 focus:outline-none focus:ring-2 focus:ring-indigo-500"
                      placeholder="Автоматически заполнится при выборе пользователя"
                        />
                      </div>
                      
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Ресторан
                        </label>
                        <select
                          name="restaurantId"
                      value={editingOrder?.restaurantId || ''}
                      onChange={(e) => {
                        if (editingOrder) {
                          setEditingOrder({
                            ...editingOrder,
                            _id: editingOrder._id || '',
                            restaurantId: e.target.value
                          } as Order)
                          setSelectedDishes([])
                        }
                      }}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
                          required
                        >
                          <option value="">Выберите ресторан</option>
                          {restaurants.map((restaurant) => (
                            <option key={restaurant._id} value={restaurant._id}>
                              {restaurant.name} ({restaurant.brand})
                            </option>
                          ))}
                        </select>
                      </div>
                      
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                        Способ доставки
                          </label>
                      <select
                        name="deliveryMethod"
                        value={selectedDeliveryMethod}
                        onChange={(e) => {
                          setSelectedDeliveryMethod(e.target.value)
                          if (editingOrder) {
                            setEditingOrder({
                              ...editingOrder,
                              _id: editingOrder._id || '',
                              deliveryMethod: e.target.value
                            } as Order)
                          }
                        }}
                        className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
                            required
                      >
                        <option value="delivery">🚚 Доставка</option>
                        <option value="pickup">🏪 Самовывоз</option>
                      </select>
                        </div>
                        
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                        Способ оплаты
                          </label>
                      <select
                        name="paymentMethod"
                        defaultValue={editingOrder?.paymentMethod || 'card'}
                        className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
                            required
                      >
                        <option value="card">💳 Карта</option>
                        <option value="cash">💵 Наличные</option>
                      </select>
                        </div>
                      </div>
                      
                  {selectedDeliveryMethod === 'delivery' && (
                    <div className="col-span-full">
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                        Адрес доставки
                        </label>
                        <input
                        type="text"
                        name="deliveryAddress"
                        defaultValue={editingOrder?.deliveryAddress || ''}
                        className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
                        placeholder="Улица, дом, квартира"
                        required={selectedDeliveryMethod === 'delivery'}
                        />
                      </div>
                  )}
                      
                  {selectedDeliveryMethod === 'pickup' && (
                    <div className="col-span-full">
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                        Ресторан для самовывоза
                        </label>
                        <select
                        name="pickupRestaurantId"
                        defaultValue={editingOrder?.pickupRestaurantId || ''}
                        className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
                        required={selectedDeliveryMethod === 'pickup'}
                      >
                        <option value="">Выберите ресторан для самовывоза</option>
                        {restaurants.map((restaurant) => (
                          <option key={restaurant._id} value={restaurant._id}>
                            {restaurant.name} ({restaurant.brand})
                          </option>
                        ))}
                        </select>
                    </div>
                  )}

                  {/* Выбор блюд */}
                  <div className="col-span-full">
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Выберите блюда
                    </label>
                    {!editingOrder?.restaurantId ? (
                      <div className="border border-gray-200 rounded-lg p-6 text-center text-gray-500">
                        <div className="text-sm">Сначала выберите ресторан, чтобы увидеть меню</div>
                      </div>
                    ) : (
                    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3 max-h-64 overflow-y-auto border border-gray-200 rounded-lg p-3">
                      {dishes.length === 0 ? (
                        <div className="col-span-full text-center text-gray-500 py-4">
                          <div className="text-sm">Блюда не загружены</div>
                        </div>
                      ) : dishes
                        .filter(dish => {
                          const dishRestaurantId = typeof dish.restaurantId === 'string' 
                            ? dish.restaurantId 
                            : (dish.restaurantId as {_id: string})?._id
                          return dishRestaurantId === editingOrder?.restaurantId
                        })
                        .length === 0 ? (
                        <div className="col-span-full text-center text-gray-500 py-4">
                          <div className="text-sm">В этом ресторане пока нет блюд</div>
                          <div className="text-xs text-gray-400 mt-1">
                            Всего блюд: {dishes.length}, ID ресторана: {editingOrder?.restaurantId}
                          </div>
                          <div className="text-xs text-gray-400 mt-1">
                            Блюда в базе: {dishes.map(d => `${d.name} (${typeof d.restaurantId === 'string' ? d.restaurantId : (d.restaurantId as {_id: string})?._id})`).join(', ')}
                          </div>
                        </div>
                      ) : (
                        dishes
                        .filter(dish => {
                          const dishRestaurantId = typeof dish.restaurantId === 'string' 
                            ? dish.restaurantId 
                            : (dish.restaurantId as {_id: string})?._id
                          return dishRestaurantId === editingOrder?.restaurantId
                        })
                        .map((dish) => (
                        <div key={dish._id} className="flex items-center justify-between p-2 border border-gray-200 rounded-lg hover:bg-gray-50">
                          <div className="flex-1">
                            <div className="font-medium text-sm">{dish.name}</div>
                            <div className="text-xs text-gray-500">{dish.price}₽</div>
                          </div>
                          <div className="flex items-center space-x-2">
                            <button
                              type="button"
                              onClick={() => removeDishFromOrder(dish._id)}
                              className="text-red-500 hover:text-red-700 text-sm"
                            >
                              -
                            </button>
                            <span className="text-sm font-medium min-w-[20px] text-center">
                              {selectedDishes.find(d => d.dishId === dish._id)?.quantity || 0}
                            </span>
                            <button
                              type="button"
                              onClick={() => addDishToOrder(dish._id)}
                              className="text-green-500 hover:text-green-700 text-sm"
                            >
                              +
                            </button>
                          </div>
                        </div>
                        ))
                      )}
                    </div>
                    )}
                    
                    {selectedDishes.length > 0 && (
                      <div className="mt-4 p-4 bg-gray-50 rounded-lg">
                        <h4 className="font-medium text-gray-900 mb-2">Выбранные блюда:</h4>
                        <div className="space-y-2">
                          {selectedDishes.map((dish) => (
                            <div key={dish.dishId} className="flex justify-between items-center text-sm">
                              <span>{dish.dishName} x{dish.quantity}</span>
                              <div className="flex items-center space-x-2">
                                <button
                                  type="button"
                                  onClick={() => updateDishQuantity(dish.dishId, dish.quantity - 1)}
                                  className="text-red-500 hover:text-red-700"
                                >
                                  -
                                </button>
                                <span className="font-medium">{dish.quantity}</span>
                                <button
                                  type="button"
                                  onClick={() => updateDishQuantity(dish.dishId, dish.quantity + 1)}
                                  className="text-green-500 hover:text-green-700"
                                >
                                  +
                                </button>
                                <span className="font-medium">{dish.price * dish.quantity}₽</span>
                              </div>
                            </div>
                          ))}
                        </div>
                        <div className="mt-3 pt-3 border-t border-gray-200">
                          <div className="flex justify-between items-center font-medium text-lg">
                            <span>Итого:</span>
                            <span>{calculateTotalAmount()}₽</span>
                          </div>
                        </div>
                      </div>
                    )}
                      </div>
                      
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                      Статус заказа
                        </label>
                    <select
                      name="status"
                      defaultValue={editingOrder?.status || 'pending'}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
                      required
                    >
                      <option value="pending">Ожидает подтверждения</option>
                      <option value="confirmed">Подтвержден</option>
                      <option value="preparing">Готовится</option>
                      <option value="ready">Готов к выдаче</option>
                      <option value="delivered">Доставлен</option>
                      <option value="cancelled">Отменен</option>
                    </select>
                      </div>
                </div>
                
                <div className="flex justify-end space-x-3 mt-6">
                  <button
                    type="button"
                    onClick={() => {
                    setEditingOrder(null)
                      setSelectedDeliveryMethod('delivery')
                      setSelectedDishes([])
                    }}
                    className="px-4 py-2 text-gray-700 bg-gray-200 rounded-md hover:bg-gray-300 transition-colors"
                  >
                    Отмена
                  </button>
                  <button
                    type="submit"
                    className="px-4 py-2 bg-indigo-500 text-white rounded-md hover:bg-indigo-600 transition-colors"
                  >
                    {editingOrder._id ? 'Сохранить' : 'Добавить заказ'}
                  </button>
                </div>
              </form>
            </div>
          </div>
        )}

        {/* Модальное окно управления категориями */}
        {showCategoryModal && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
            <div className="bg-white rounded-lg p-6 max-w-md w-full mx-4">
              <div className="flex justify-between items-center mb-4">
                <h3 className="text-lg font-semibold text-gray-900">Управление категориями</h3>
                <button
                  onClick={() => setShowCategoryModal(false)}
                  className="text-gray-400 hover:text-gray-600"
                >
                  <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>
              
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Добавить новую категорию
                  </label>
                  <div className="flex space-x-2">
                    <input
                      type="text"
                      value={newCategory}
                      onChange={(e) => setNewCategory(e.target.value)}
                      className="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                      placeholder="Название категории"
                    />
                    <button
                      onClick={handleAddCategory}
                      className="bg-purple-500 text-white px-4 py-2 rounded-md hover:bg-purple-600 transition-colors"
                    >
                      Добавить
                    </button>
                  </div>
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Существующие категории
                  </label>
                  <div className="space-y-2 max-h-60 overflow-y-auto">
                    {categories.map((category, index) => (
                      <div key={index} className="flex items-center justify-between bg-gray-50 p-3 rounded-md">
                        <span className="text-gray-900">{category}</span>
                        <button
                          onClick={() => handleDeleteCategory(category)}
                          disabled={categories.length <= 1}
                          className="text-red-500 hover:text-red-700 disabled:text-gray-400 disabled:cursor-not-allowed"
                        >
                          <TrashIcon className="h-4 w-4" />
                        </button>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
              
              <div className="flex justify-end mt-6">
                <button
                  onClick={() => setShowCategoryModal(false)}
                  className="px-4 py-2 text-gray-700 bg-gray-200 rounded-md hover:bg-gray-300 transition-colors"
                >
                  Закрыть
                </button>
              </div>
            </div>
          </div>
        )}

        {/* Модал предпросмотра новости */}
        {showPreviewModal && previewNews && (
          <div 
            className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4"
            onClick={(e) => {
              if (e.target === e.currentTarget) {
                setShowPreviewModal(false)
                setPreviewNews(null)
              }
            }}
          >
            <div className="bg-white rounded-lg p-6 w-full max-w-4xl mx-4 max-h-[90vh] overflow-y-auto">
              <div className="flex justify-between items-center mb-4">
                <h3 className="text-2xl font-bold text-gray-900">Предпросмотр новости</h3>
                <button
                  type="button"
                  onClick={() => {
                    setShowPreviewModal(false)
                    setPreviewNews(null)
                  }}
                  className="text-gray-400 hover:text-gray-600 transition-colors"
                >
                  <svg className="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>
              
              <div className="space-y-6">
                {/* Заголовок */}
                <div>
                  <h1 className="text-3xl font-bold text-gray-900 mb-2">{previewNews.title}</h1>
                  <div className="flex items-center space-x-4 text-sm text-gray-500">
                    <span>👤 {previewNews.author}</span>
                    <span>📅 {new Date(previewNews.createdAt).toLocaleDateString()}</span>
                    <span>👁️ {previewNews.views}</span>
                    <span>❤️ {previewNews.likes}</span>
                    <span className="bg-gray-100 px-2 py-1 rounded">{previewNews.category}</span>
                    <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                      previewNews.isPublished ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'
                    }`}>
                      {previewNews.isPublished ? 'Опубликовано' : 'Черновик'}
                    </span>
                  </div>
                </div>

                {/* Изображение */}
                {previewNews.imageURL && previewNews.imageURL.trim() !== '' ? (
                  <div>
                    <img 
                      src={previewNews.imageURL} 
                      alt={previewNews.title}
                      className="w-full h-64 object-cover rounded-lg"
                    />
                  </div>
                ) : (
                  <div className="w-full h-64 bg-gray-200 rounded-lg flex items-center justify-center">
                    <div className="text-center text-gray-500">
                      <svg className="w-16 h-16 mx-auto mb-2" fill="currentColor" viewBox="0 0 20 20">
                        <path fillRule="evenodd" d="M4 3a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V5a2 2 0 00-2-2H4zm12 12H4l4-8 3 6 2-4 3 6z" clipRule="evenodd" />
                      </svg>
                      <p className="text-sm">Нет изображения</p>
                    </div>
                  </div>
                )}

                {/* Содержание */}
                <div>
                  <h2 className="text-xl font-semibold text-gray-900 mb-3">Содержание</h2>
                  <div className="prose max-w-none">
                    <p className="text-gray-700 leading-relaxed whitespace-pre-wrap">{previewNews.content}</p>
                  </div>
                </div>

                {/* Видео */}
                {previewNews.videoURL && (
                  <div>
                    <h2 className="text-xl font-semibold text-gray-900 mb-3">Видео</h2>
                    <video 
                      src={previewNews.videoURL} 
                      controls
                      className="w-full rounded-lg"
                    >
                      Ваш браузер не поддерживает видео.
                    </video>
                  </div>
                )}

                {/* Теги */}
                {previewNews.tags && previewNews.tags.length > 0 && (
                  <div>
                    <h2 className="text-xl font-semibold text-gray-900 mb-3">Теги</h2>
                    <div className="flex flex-wrap gap-2">
                      {previewNews.tags.map((tag, index) => (
                        <span key={index} className="bg-blue-100 text-blue-800 px-3 py-1 rounded-full text-sm">
                          #{tag}
                        </span>
                      ))}
                    </div>
                  </div>
                )}
              </div>
              
              <div className="flex justify-end mt-6">
                <button
                  onClick={() => {
                    setShowPreviewModal(false)
                    setPreviewNews(null)
                  }}
                  className="px-4 py-2 text-gray-700 bg-gray-200 rounded-md hover:bg-gray-300 transition-colors"
                >
                  Закрыть
                </button>
              </div>
            </div>
          </div>
        )}

        {/* Модал предпросмотра ресторана */}
        {showRestaurantPreviewModal && previewRestaurant && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
            <div className="bg-white rounded-lg max-w-4xl w-full mx-4 max-h-[90vh] overflow-y-auto">
              <div className="p-6">
                <div className="flex flex-col sm:flex-row sm:justify-between sm:items-center mb-6 gap-4">
                  <h2 className="text-2xl font-bold text-gray-900">Предпросмотр ресторана</h2>
                  <button
                    onClick={() => {
                      setShowRestaurantPreviewModal(false)
                      setPreviewRestaurant(null)
                    }}
                    className="text-gray-400 hover:text-gray-600"
                  >
                    <svg className="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                    </svg>
                  </button>
                </div>

                <div className="space-y-6">
                  {/* Основная информация */}
                  <div>
                    <h3 className="text-xl font-semibold text-gray-900 mb-2">{previewRestaurant.name}</h3>
                    <div className="flex items-center space-x-4 mb-4">
                      <span className="bg-blue-500 text-white px-3 py-1 rounded-full text-sm font-medium">
                        {previewRestaurant.brand}
                      </span>
                      <span className="bg-yellow-400 text-black px-3 py-1 rounded-full text-sm font-medium flex items-center">
                        ⭐ {previewRestaurant.rating}
                      </span>
                      <span className={`px-3 py-1 rounded-full text-sm font-medium ${previewRestaurant.isActive ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}`}>
                        {previewRestaurant.isActive ? 'Активен' : 'Неактивен'}
                      </span>
                    </div>
                  </div>

                  {/* Фото ресторана */}
                  {previewRestaurant.photos && previewRestaurant.photos.length > 0 && (
                    <div>
                      <h4 className="text-lg font-semibold text-gray-900 mb-3">Фотографии</h4>
                      <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
                        {previewRestaurant.photos.map((photo, index) => (
                          <img
                            key={index}
                            src={photo}
                            alt={`Фото ресторана ${index + 1}`}
                            className="w-full h-48 object-cover rounded-lg"
                          />
                        ))}
                      </div>
                    </div>
                  )}

                  {/* Видео ресторана */}
                  {previewRestaurant.videos && previewRestaurant.videos.length > 0 && (
                    <div>
                      <h4 className="text-lg font-semibold text-gray-900 mb-3">Видео</h4>
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                        {previewRestaurant.videos.map((video, index) => (
                          <video
                            key={index}
                            src={video}
                            controls
                            className="w-full rounded-lg"
                          >
                            Ваш браузер не поддерживает видео.
                          </video>
                        ))}
                      </div>
                    </div>
                  )}

                  {/* Описание */}
                  {previewRestaurant.description && (
                    <div>
                      <h4 className="text-lg font-semibold text-gray-900 mb-3">Описание</h4>
                      <p className="text-gray-700 leading-relaxed">{previewRestaurant.description}</p>
                    </div>
                  )}

                  {/* Контактная информация */}
                  <div>
                    <h4 className="text-lg font-semibold text-gray-900 mb-3">Контактная информация</h4>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      {previewRestaurant.city && (
                        <div>
                          <span className="font-medium text-gray-700">Город:</span>
                          <p className="text-gray-600">{previewRestaurant.city}</p>
                        </div>
                      )}
                      {previewRestaurant.address && (
                        <div>
                          <span className="font-medium text-gray-700">Адрес:</span>
                          <p className="text-gray-600">{previewRestaurant.address}</p>
                        </div>
                      )}
                      {previewRestaurant.phone && (
                        <div>
                          <span className="font-medium text-gray-700">Телефон:</span>
                          <p className="text-gray-600">{previewRestaurant.phone}</p>
                        </div>
                      )}
                      {previewRestaurant.email && (
                        <div>
                          <span className="font-medium text-gray-700">Email:</span>
                          <p className="text-gray-600">{previewRestaurant.email}</p>
                        </div>
                      )}
                      {previewRestaurant.workingHours && (
                        <div>
                          <span className="font-medium text-gray-700">Часы работы:</span>
                          <p className="text-gray-600">{previewRestaurant.workingHours}</p>
                        </div>
                      )}
                    </div>
                  </div>

                  {/* Статистика */}
                  <div>
                    <h4 className="text-lg font-semibold text-gray-900 mb-3">Статистика</h4>
                    <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                      <div className="text-center">
                        <p className="text-2xl font-bold text-blue-600">{previewRestaurant.photos?.length || 0}</p>
                        <p className="text-sm text-gray-600">Фотографий</p>
                      </div>
                      <div className="text-center">
                        <p className="text-2xl font-bold text-green-600">{previewRestaurant.videos?.length || 0}</p>
                        <p className="text-sm text-gray-600">Видео</p>
                      </div>
                      <div className="text-center">
                        <p className="text-2xl font-bold text-purple-600">{previewRestaurant.rating}</p>
                        <p className="text-sm text-gray-600">Рейтинг</p>
                      </div>
                      <div className="text-center">
                        <p className="text-2xl font-bold text-orange-600">{previewRestaurant.isActive ? 'Да' : 'Нет'}</p>
                        <p className="text-sm text-gray-600">Активен</p>
                      </div>
                    </div>
                  </div>
                </div>

                <div className="flex justify-end mt-6">
                  <button
                    onClick={() => {
                      setShowRestaurantPreviewModal(false)
                      setPreviewRestaurant(null)
                    }}
                    className="px-4 py-2 text-gray-700 bg-gray-200 rounded-md hover:bg-gray-300 transition-colors"
                  >
                    Закрыть
                  </button>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Модал предпросмотра блюда */}
        {showDishPreviewModal && previewDish && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
            <div className="bg-white rounded-lg max-w-4xl w-full mx-4 max-h-[90vh] overflow-y-auto">
              <div className="p-6">
                <div className="flex flex-col sm:flex-row sm:justify-between sm:items-center mb-6 gap-4">
                  <h2 className="text-2xl font-bold text-gray-900">Предпросмотр блюда</h2>
                  <button
                    onClick={() => {
                      setShowDishPreviewModal(false)
                      setPreviewDish(null)
                    }}
                    className="text-gray-400 hover:text-gray-600"
                  >
                    <svg className="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                    </svg>
                  </button>
                </div>

                <div className="space-y-6">
                  {/* Основная информация */}
                  <div>
                    <h3 className="text-xl font-semibold text-gray-900 mb-2">{previewDish.name}</h3>
                    <div className="flex items-center space-x-4 mb-4">
                      <span className="bg-green-500 text-white px-3 py-1 rounded-full text-sm font-medium">
                        {previewDish.category}
                      </span>
                      <span className="bg-blue-500 text-white px-3 py-1 rounded-full text-sm font-medium">
                        {previewDish.restaurantName}
                      </span>
                      <span className="bg-purple-500 text-white px-3 py-1 rounded-full text-sm font-medium">
                        {previewDish.restaurantBrand}
                      </span>
                    </div>
                  </div>

                  {/* Фото блюда */}
                  {previewDish.imageURL && (
                    <div>
                      <h4 className="text-lg font-semibold text-gray-900 mb-3">Фотография</h4>
                      {previewDish.imageURL && previewDish.imageURL.trim() !== '' ? (
                      <img
                        src={previewDish.imageURL}
                        alt={previewDish.name}
                        className="w-full h-64 object-cover rounded-lg"
                      />
                      ) : (
                        <div className="w-full h-64 bg-gray-200 rounded-lg flex items-center justify-center">
                          <div className="text-center text-gray-500">
                            <svg className="w-16 h-16 mx-auto mb-2" fill="currentColor" viewBox="0 0 20 20">
                              <path fillRule="evenodd" d="M4 3a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V5a2 2 0 00-2-2H4zm12 12H4l4-8 3 6 2-4 3 6z" clipRule="evenodd" />
                            </svg>
                            <p className="text-sm">Нет фотографии</p>
                          </div>
                        </div>
                      )}
                    </div>
                  )}

                  {/* Описание */}
                  {previewDish.description && (
                    <div>
                      <h4 className="text-lg font-semibold text-gray-900 mb-3">Описание</h4>
                      <p className="text-gray-700 leading-relaxed">{previewDish.description}</p>
                    </div>
                  )}

                  {/* Цена и характеристики */}
                  <div>
                    <h4 className="text-lg font-semibold text-gray-900 mb-3">Характеристики</h4>
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                      <div className="text-center p-4 bg-gray-50 rounded-lg">
                        <p className="text-2xl font-bold text-green-600">{previewDish.price} ₽</p>
                        <p className="text-sm text-gray-600">Цена</p>
                      </div>
                      <div className="text-center p-4 bg-gray-50 rounded-lg">
                        <p className="text-2xl font-bold text-blue-600">{previewDish.preparationTime} мин</p>
                        <p className="text-sm text-gray-600">Время приготовления</p>
                      </div>
                      <div className="text-center p-4 bg-gray-50 rounded-lg">
                        <p className="text-2xl font-bold text-orange-600">{previewDish.calories} ккал</p>
                        <p className="text-sm text-gray-600">Калории</p>
                      </div>
                    </div>
                  </div>

                  {/* Аллергены */}
                  {previewDish.allergens && previewDish.allergens.length > 0 && (
                    <div>
                      <h4 className="text-lg font-semibold text-gray-900 mb-3">Аллергены</h4>
                      <div className="flex flex-wrap gap-2">
                        {previewDish.allergens.map((allergen, index) => (
                          <span key={index} className="bg-yellow-100 text-yellow-800 px-3 py-1 rounded-full text-sm">
                            {allergen}
                          </span>
                        ))}
                      </div>
                    </div>
                  )}

                  {/* Ингредиенты */}
                  {previewDish.ingredients && previewDish.ingredients.length > 0 && (
                    <div>
                      <h4 className="text-lg font-semibold text-gray-900 mb-3">Ингредиенты</h4>
                      <div className="flex flex-wrap gap-2">
                        {previewDish.ingredients.map((ingredient, index) => (
                          <span key={index} className="bg-blue-100 text-blue-800 px-3 py-1 rounded-full text-sm">
                            {ingredient}
                          </span>
                        ))}
                      </div>
                    </div>
                  )}

                  {/* Статистика */}
                  <div>
                    <h4 className="text-lg font-semibold text-gray-900 mb-3">Статистика</h4>
                    <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                      <div className="text-center">
                        <p className="text-2xl font-bold text-green-600">{previewDish.price} ₽</p>
                        <p className="text-sm text-gray-600">Цена</p>
                      </div>
                      <div className="text-center">
                        <p className="text-2xl font-bold text-blue-600">{previewDish.preparationTime} мин</p>
                        <p className="text-sm text-gray-600">Время</p>
                      </div>
                      <div className="text-center">
                        <p className="text-2xl font-bold text-orange-600">{previewDish.calories}</p>
                        <p className="text-sm text-gray-600">Ккал</p>
                      </div>
                      <div className="text-center">
                        <p className="text-2xl font-bold text-purple-600">{previewDish.allergens?.length || 0}</p>
                        <p className="text-sm text-gray-600">Аллергенов</p>
                      </div>
                    </div>
                  </div>
                </div>

                <div className="flex justify-end mt-6">
                  <button
                    onClick={() => {
                      setShowDishPreviewModal(false)
                      setPreviewDish(null)
                    }}
                    className="px-4 py-2 text-gray-700 bg-gray-200 rounded-md hover:bg-gray-300 transition-colors"
                  >
                    Закрыть
                  </button>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Modal предпросмотра пользователя */}
        {previewUser && (
          <div 
            className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4"
            onClick={(e) => {
              if (e.target === e.currentTarget) {
                setPreviewUser(null)
              }
            }}
          >
            <div className="bg-white rounded-lg p-4 sm:p-6 w-full max-w-lg max-h-[90vh] overflow-y-auto">
              <div className="flex justify-between items-center mb-6">
                <h3 className="text-xl font-bold text-gray-900">👤 Предпросмотр пользователя</h3>
                <button
                  onClick={() => setPreviewUser(null)}
                  className="p-2 text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded-md transition-colors"
                >
                  <svg className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
        </div>

              <div className="space-y-6">
                {/* Аватар и основная информация */}
                <div className="flex flex-col sm:flex-row items-center sm:items-start space-y-4 sm:space-y-0 sm:space-x-6">
                  <div className="w-20 h-20 sm:w-24 sm:h-24 bg-gradient-to-r from-blue-500 to-purple-600 rounded-full flex items-center justify-center flex-shrink-0">
                    <span className="text-white font-bold text-2xl sm:text-3xl">
                      {previewUser.fullName.split(' ').map(n => n[0]).join('')}
                    </span>
      </div>
                  <div className="text-center sm:text-left flex-1">
                    <h4 className="text-xl sm:text-2xl font-bold text-gray-900 mb-1">{previewUser.fullName}</h4>
                    <p className="text-gray-600 mb-2">{previewUser.email}</p>
                    <div className="flex flex-wrap justify-center sm:justify-start gap-2">
                      <span className={`px-3 py-1 rounded-full text-sm font-medium ${
                        previewUser.isActive 
                          ? 'bg-green-100 text-green-800' 
                          : 'bg-red-100 text-red-800'
                      }`}>
                        {previewUser.isActive ? '✅ Активен' : '❌ Неактивен'}
                      </span>
                      <span className={`px-3 py-1 rounded-full text-sm font-medium ${
                        previewUser.role === 'admin' ? 'bg-purple-100 text-purple-800' : 'bg-blue-100 text-blue-800'
                      }`}>
                        {previewUser.role === 'admin' ? '👑 Администратор' : '👤 Пользователь'}
                      </span>
    </div>
                  </div>
                </div>

                {/* Детальная информация */}
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div className="bg-gray-50 rounded-lg p-4">
                    <h5 className="font-semibold text-gray-900 mb-3 flex items-center">
                      <svg className="h-4 w-4 mr-2 text-blue-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                      </svg>
                      Личная информация
                    </h5>
                    <div className="space-y-2 text-sm">
                      <div className="flex justify-between">
                        <span className="text-gray-600">Имя пользователя:</span>
                        <span className="font-medium">{previewUser.username}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-600">Полное имя:</span>
                        <span className="font-medium">{previewUser.fullName}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-600">Email:</span>
                        <span className="font-medium">{previewUser.email}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-600">Телефон:</span>
                        <span className="font-medium">{previewUser.phone || 'Не указан'}</span>
                      </div>
                    </div>
                  </div>

                  <div className="bg-gray-50 rounded-lg p-4">
                    <h5 className="font-semibold text-gray-900 mb-3 flex items-center">
                      <svg className="h-4 w-4 mr-2 text-green-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1" />
                      </svg>
                      Статистика
                    </h5>
                    <div className="space-y-2 text-sm">
                      <div className="flex justify-between">
                        <span className="text-gray-600">Уровень:</span>
                        <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                          previewUser.membershipLevel === 'Платина' ? 'bg-purple-100 text-purple-800' :
                          previewUser.membershipLevel === 'Золото' ? 'bg-yellow-100 text-yellow-800' :
                          previewUser.membershipLevel === 'Серебро' ? 'bg-gray-100 text-gray-800' :
                          'bg-orange-100 text-orange-800'
                        }`}>
                          {previewUser.membershipLevel}
                        </span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-600">Баллы лояльности:</span>
                        <span className="font-medium">{previewUser.loyaltyPoints}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-600">Дата регистрации:</span>
                        <span className="font-medium">{new Date(previewUser.createdAt).toLocaleDateString()}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-600">Последнее обновление:</span>
                        <span className="font-medium">{new Date(previewUser.updatedAt).toLocaleDateString()}</span>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Действия */}
                <div className="flex flex-col sm:flex-row gap-3 pt-4 border-t border-gray-200">
                  <button
                    onClick={() => {
                      setPreviewUser(null)
                      setEditingUser(previewUser)
                      setShowAddModal(true)
                    }}
                    className="flex-1 bg-blue-500 text-white px-4 py-2 rounded-md hover:bg-blue-600 transition-colors flex items-center justify-center"
                  >
                    <PencilIcon className="h-4 w-4 mr-2" />
                    Редактировать
                  </button>
                  <button
                    onClick={() => {
                      if (confirm(`Вы уверены, что хотите удалить пользователя "${previewUser.fullName}"?`)) {
                        handleDeleteUser(previewUser._id)
                        setPreviewUser(null)
                      }
                    }}
                    className="flex-1 bg-red-500 text-white px-4 py-2 rounded-md hover:bg-red-600 transition-colors flex items-center justify-center"
                  >
                    <svg className="h-4 w-4 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                    </svg>
                    Удалить
                  </button>
                  <button
                    onClick={() => setPreviewUser(null)}
                    className="flex-1 bg-gray-500 text-white px-4 py-2 rounded-md hover:bg-gray-600 transition-colors"
                  >
                    Закрыть
                  </button>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Модал предпросмотра заказа */}
        {previewOrder && (
          <div
            className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4"
            onClick={(e) => {
              if (e.target === e.currentTarget) {
                setPreviewOrder(null)
              }
            }}
          >
            <div className="bg-white rounded-lg p-6 w-full max-w-2xl max-h-[90vh] overflow-y-auto">
              <div className="flex justify-between items-center mb-6">
                <h3 className="text-xl font-semibold text-gray-900">📋 Предпросмотр заказа</h3>
                <button
                  onClick={() => setPreviewOrder(null)}
                  className="text-gray-500 hover:text-gray-700 transition-colors"
                >
                  <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>

              <div className="space-y-6">
                {/* Основная информация */}
                <div className="bg-gray-50 rounded-lg p-4">
                  <h4 className="font-semibold text-gray-900 mb-3">📊 Основная информация</h4>
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div>
                      <span className="text-sm font-medium text-gray-600">Номер заказа:</span>
                      <p className="text-sm text-gray-900 font-mono">{previewOrder.orderNumber}</p>
                    </div>
                    <div>
                      <span className="text-sm font-medium text-gray-600">Статус:</span>
                      <p className="text-sm text-gray-900">{previewOrder.status}</p>
                    </div>
                    <div>
                      <span className="text-sm font-medium text-gray-600">Клиент:</span>
                      <p className="text-sm text-gray-900">{previewOrder.userName}</p>
                    </div>
                    <div>
                      <span className="text-sm font-medium text-gray-600">Ресторан:</span>
                      <p className="text-sm text-gray-900">{previewOrder.restaurantName}</p>
                    </div>
                    <div>
                      <span className="text-sm font-medium text-gray-600">Способ доставки:</span>
                      <p className="text-sm text-gray-900">
                        {previewOrder.deliveryMethod === 'delivery' ? '🚚 Доставка' : '🏪 Самовывоз'}
                      </p>
                    </div>
                    <div>
                      <span className="text-sm font-medium text-gray-600">Способ оплаты:</span>
                      <p className="text-sm text-gray-900">
                        {previewOrder.paymentMethod === 'card' ? '💳 Карта' : '💵 Наличные'}
                      </p>
                    </div>
                  </div>
                </div>

                {/* Адрес доставки */}
                {previewOrder.deliveryMethod === 'delivery' && previewOrder.deliveryAddress && (
                  <div className="bg-blue-50 rounded-lg p-4">
                    <h4 className="font-semibold text-gray-900 mb-2">🏠 Адрес доставки</h4>
                    <p className="text-sm text-gray-700">{previewOrder.deliveryAddress}</p>
                  </div>
                )}

                {/* Ресторан для самовывоза */}
                {previewOrder.deliveryMethod === 'pickup' && previewOrder.pickupRestaurantId && (
                  <div className="bg-green-50 rounded-lg p-4">
                    <h4 className="font-semibold text-gray-900 mb-2">🏪 Ресторан для самовывоза</h4>
                    <p className="text-sm text-gray-700">
                      {restaurants.find(r => r._id === previewOrder.pickupRestaurantId)?.name}
                    </p>
                  </div>
                )}

                {/* Состав заказа */}
                <div className="bg-white border border-gray-200 rounded-lg p-4">
                  <h4 className="font-semibold text-gray-900 mb-3">🍽️ Состав заказа</h4>
                  {previewOrder && Array.isArray(previewOrder.items) && previewOrder.items.length > 0 ? (
                    <div className="space-y-2">
                      {previewOrder.items.map((item: {dishName: string, quantity: number, price: number}, index: number) => (
                        <div key={index} className="flex justify-between items-center py-2 border-b border-gray-100 last:border-b-0">
                          <div className="flex-1">
                            <p className="text-sm font-medium text-gray-900">{item.dishName}</p>
                            <p className="text-xs text-gray-500">Количество: {item.quantity}</p>
                          </div>
                          <div className="text-right">
                            <p className="text-sm font-medium text-gray-900">{item.price}₽</p>
                            <p className="text-xs text-gray-500">За шт.</p>
                          </div>
                        </div>
                      ))}
                      <div className="pt-3 border-t border-gray-200">
                        <div className="flex justify-between items-center">
                          <span className="text-lg font-semibold text-gray-900">Итого:</span>
                          <span className="text-lg font-semibold text-gray-900">
                            {(previewOrder.items?.reduce((sum: number, item: {price: number, quantity: number}) => sum + (item.price * item.quantity), 0) || 0)}₽
                          </span>
                        </div>
                      </div>
                    </div>
                  ) : (
                    <p className="text-sm text-gray-500">Заказ пуст</p>
                  )}
                </div>

                {/* Временные метки */}
                <div className="bg-gray-50 rounded-lg p-4">
                  <h4 className="font-semibold text-gray-900 mb-3">⏰ Временные метки</h4>
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div>
                      <span className="text-sm font-medium text-gray-600">Создан:</span>
                      <p className="text-sm text-gray-900">
                        {new Date(previewOrder.createdAt).toLocaleString('ru-RU')}
                      </p>
                    </div>
                    <div>
                      <span className="text-sm font-medium text-gray-600">Обновлен:</span>
                      <p className="text-sm text-gray-900">
                        {new Date(previewOrder.updatedAt).toLocaleString('ru-RU')}
                      </p>
                    </div>
                  </div>
                </div>
              </div>

              <div className="flex justify-end mt-6">
                <button
                  onClick={() => setPreviewOrder(null)}
                  className="px-6 py-2 bg-gray-500 text-white rounded-md hover:bg-gray-600 transition-colors"
                >
                  Закрыть
                </button>
              </div>
            </div>
          </div>
        )}

        {/* Модал для бронирований */}
        {showReservationModal && (
          <div
            className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4"
            onClick={(e) => {
              if (e.target === e.currentTarget) {
                setShowReservationModal(false)
                setEditingReservation(null)
              }
            }}
          >
            <div className="bg-white rounded-lg p-6 w-full max-w-2xl max-h-[90vh] overflow-y-auto">
              <div className="flex justify-between items-center mb-6">
                <h3 className="text-xl font-semibold text-gray-900">
                  {editingReservation && editingReservation._id ? 'Редактировать бронирование' : 'Добавить бронирование'}
                </h3>
                <button
                  onClick={() => {
                    setShowReservationModal(false)
                    setEditingReservation(null)
                  }}
                  className="text-gray-500 hover:text-gray-700 transition-colors"
                >
                  <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>

              <form
                onSubmit={async (e) => {
                  e.preventDefault()
                  const formData = new FormData(e.target as HTMLFormElement)
                  
                  // Форма для бронирований
                  const data = {
                    userId: (formData.get('userId') as string) || editingReservation?.userId || 'default-user-id',
                    userName: (formData.get('userName') as string) || editingReservation?.userName || '',
                    restaurantId: (formData.get('restaurantId') as string) || '',
                    date: (formData.get('date') as string) || '',
                    time: (formData.get('time') as string) || '',
                    guests: parseInt(formData.get('guests') as string || '1'),
                    status: (formData.get('status') as 'pending' | 'confirmed' | 'cancelled') || 'pending',
                    specialRequests: (formData.get('specialRequests') as string) || ''
                  }
                  handleSaveReservation(data)
                }}
                className="space-y-4"
              >
                {/* Поля для бронирований */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Выберите пользователя
                  </label>
                  <select
                    name="userId"
                    value={editingReservation?.userId || ''}
                    onChange={(e) => {
                      const selectedUser = users.find(u => u._id === e.target.value)
                      if (selectedUser && editingReservation) {
                        setEditingReservation({
                          ...editingReservation,
                          userId: selectedUser._id,
                          userName: selectedUser.fullName
                        })
                      }
                    }}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                    required
                  >
                    <option value="">Выберите пользователя</option>
                    {users.map((user) => (
                      <option key={user._id} value={user._id}>
                        {user.fullName} ({user.email})
                      </option>
                    ))}
                  </select>
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Ресторан
                  </label>
                  <select
                    name="restaurantId"
                    value={editingReservation?.restaurantId || ''}
                    onChange={(e) => editingReservation && setEditingReservation({...editingReservation, restaurantId: e.target.value})}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                    required
                  >
                    <option value="">Выберите ресторан</option>
                    {restaurants.map((restaurant) => (
                      <option key={restaurant._id} value={restaurant._id}>
                        {restaurant.name} ({restaurant.brand})
                      </option>
                    ))}
                  </select>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Дата
                    </label>
                    <input
                      type="date"
                      name="date"
                      defaultValue={editingReservation?.date ? editingReservation.date.split('T')[0] : ''}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                      required
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Время
                    </label>
                    <input
                      type="time"
                      name="time"
                      defaultValue={editingReservation?.time || ''}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                      required
                    />
                  </div>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Количество гостей
                    </label>
                    <input
                      type="number"
                      name="guests"
                      min="1"
                      max="20"
                      defaultValue={editingReservation?.guests || 1}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                      required
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Статус
                    </label>
                    <select
                      name="status"
                      defaultValue={editingReservation?.status || 'pending'}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                    >
                      <option value="pending">Ожидает подтверждения</option>
                      <option value="confirmed">Подтверждено</option>
                      <option value="cancelled">Отменено</option>
                      <option value="completed">Завершено</option>
                    </select>
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Особые пожелания
                  </label>
                  <textarea
                    name="specialRequests"
                    rows={3}
                    defaultValue={editingReservation?.specialRequests || ''}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500"
                    placeholder="Укажите особые пожелания..."
                  />
                </div>

                <div className="flex justify-end space-x-3 pt-4">
                  <button
                    type="button"
                    onClick={() => {
                      setShowReservationModal(false)
                      setEditingReservation(null)
                    }}
                    className="px-4 py-2 text-gray-700 bg-gray-200 rounded-md hover:bg-gray-300 transition-colors"
                  >
                    Отмена
                  </button>
                  <button
                    type="submit"
                    className="px-4 py-2 bg-purple-600 text-white rounded-md hover:bg-purple-700 transition-colors"
                  >
                    {editingReservation && editingReservation._id ? 'Обновить' : 'Создать'} бронирование
                  </button>
                </div>
              </form>
            </div>
          </div>
        )}
      </div>
      </div>
    </div>
  );
}
