const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:5001/api'

interface ApiResponse<T> {
  success: boolean
  data?: T
  message?: string
  error?: string
}

class ApiClient {
  private baseURL: string

  constructor(baseURL: string) {
    this.baseURL = baseURL
  }

  private async request<T>(
    endpoint: string,
    options: RequestInit = {}
  ): Promise<ApiResponse<T>> {
    const url = `${this.baseURL}${endpoint}`
    
    const config: RequestInit = {
      headers: {
        'Content-Type': 'application/json',
        ...options.headers,
      },
      ...options,
    }

    try {
      const response = await fetch(url, config)
      const data = await response.json()

      if (!response.ok) {
        throw new Error(data.message || `HTTP error! status: ${response.status}`)
      }

      return data
    } catch (error) {
      console.error('API request failed:', error)
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Неизвестная ошибка'
      }
    }
  }

  async get<T>(endpoint: string): Promise<ApiResponse<T>> {
    return this.request<T>(endpoint, { method: 'GET' })
  }

  async post<T>(endpoint: string, data: any): Promise<ApiResponse<T>> {
    return this.request<T>(endpoint, {
      method: 'POST',
      body: JSON.stringify(data),
    })
  }

  async put<T>(endpoint: string, data: any): Promise<ApiResponse<T>> {
    return this.request<T>(endpoint, {
      method: 'PUT',
      body: JSON.stringify(data),
    })
  }

  async delete<T>(endpoint: string): Promise<ApiResponse<T>> {
    return this.request<T>(endpoint, { method: 'DELETE' })
  }
}

const apiClient = new ApiClient(API_BASE_URL)

// User API functions
export const userApi = {
  async getUsers() {
    return apiClient.get('/users')
  },

  async getUser(id: string) {
    return apiClient.get(`/users/${id}`)
  },

  async createUser(userData: {
    username: string
    email: string
    fullName: string
    phone?: string
    password: string
    role: 'admin' | 'user'
    isActive: boolean
  }) {
    return apiClient.post('/users', userData)
  },

  async updateUser(id: string, userData: {
    username?: string
    email?: string
    fullName?: string
    phone?: string
    password?: string
    role?: 'admin' | 'user'
    isActive?: boolean
  }) {
    return apiClient.put(`/users/${id}`, userData)
  },

  async deleteUser(id: string) {
    return apiClient.delete(`/users/${id}`)
  }
}

// Restaurant API functions
export const restaurantApi = {
  async getRestaurants() {
    return apiClient.get('/restaurants')
  },

  async getRestaurant(id: string) {
    return apiClient.get(`/restaurants/${id}`)
  },

  async createRestaurant(restaurantData: any) {
    return apiClient.post('/restaurants', restaurantData)
  },

  async updateRestaurant(id: string, restaurantData: any) {
    return apiClient.put(`/restaurants/${id}`, restaurantData)
  },

  async deleteRestaurant(id: string) {
    return apiClient.delete(`/restaurants/${id}`)
  }
}

// Dish API functions
export const dishApi = {
  async getDishes() {
    return apiClient.get('/dishes')
  },

  async getDish(id: string) {
    return apiClient.get(`/dishes/${id}`)
  },

  async createDish(dishData: any) {
    return apiClient.post('/dishes', dishData)
  },

  async updateDish(id: string, dishData: any) {
    return apiClient.put(`/dishes/${id}`, dishData)
  },

  async deleteDish(id: string) {
    return apiClient.delete(`/dishes/${id}`)
  }
}

// News API functions
export const newsApi = {
  async getNews() {
    return apiClient.get('/news')
  },

  async getNewsItem(id: string) {
    return apiClient.get(`/news/${id}`)
  },

  async createNews(newsData: any) {
    return apiClient.post('/news', newsData)
  },

  async updateNews(id: string, newsData: any) {
    return apiClient.put(`/news/${id}`, newsData)
  },

  async deleteNews(id: string) {
    return apiClient.delete(`/news/${id}`)
  }
}

// Order API functions
export const orderApi = {
  async getOrders() {
    return apiClient.get('/orders')
  },

  async getOrder(id: string) {
    return apiClient.get(`/orders/${id}`)
  },

  async updateOrder(id: string, orderData: any) {
    return apiClient.put(`/orders/${id}`, orderData)
  },

  async deleteOrder(id: string) {
    return apiClient.delete(`/orders/${id}`)
  }
}

// Reservation API functions
export const reservationApi = {
  async getReservations() {
    return apiClient.get('/reservations')
  },

  async getReservation(id: string) {
    return apiClient.get(`/reservations/${id}`)
  },

  async updateReservation(id: string, reservationData: any) {
    return apiClient.put(`/reservations/${id}`, reservationData)
  },

  async deleteReservation(id: string) {
    return apiClient.delete(`/reservations/${id}`)
  }
}

// Admin API functions
export const adminApi = {
  async getDashboardStats() {
    return apiClient.get('/admin/dashboard')
  },

  async getAdminRestaurants() {
    return apiClient.get('/admin/restaurants')
  },

  async getAdminDishes() {
    return apiClient.get('/admin/dishes')
  },

  async getAdminNews() {
    return apiClient.get('/admin/news')
  },

  async getAdminUsers() {
    return apiClient.get('/admin/users')
  },

  async getAdminOrders() {
    return apiClient.get('/admin/orders')
  },

  async getAdminReservations() {
    return apiClient.get('/admin/reservations')
  }
}

export default apiClient
