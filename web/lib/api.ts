import { Restaurant, Dish, News, User, AuthUser, LoginForm, RegisterForm } from '../types';
import { adaptRestaurants, adaptDishes, adaptNewsArray, adaptRestaurant, adaptDish, adaptNews } from './adapters';

const API_BASE_URL = process.env.NODE_ENV === 'production' 
  ? 'https://bulladmin.ru/api' 
  : 'http://45.12.75.59:5001/api';

class ApiClient {
  private baseURL: string;

  constructor(baseURL: string) {
    this.baseURL = baseURL;
  }

  private async request<T>(
    endpoint: string,
    options: RequestInit = {}
  ): Promise<T> {
    const url = `${this.baseURL}${endpoint}`;
    
    const config: RequestInit = {
      headers: {
        'Content-Type': 'application/json',
        ...options.headers,
      },
      ...options,
    };

    // Добавляем токен авторизации если есть
    const token = localStorage.getItem('byk_token');
    if (token) {
      config.headers = {
        ...config.headers,
        'Authorization': `Bearer ${token}`,
      };
    }

    try {
      const response = await fetch(url, config);
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();
      
      // Проверяем структуру ответа API
      if (data.success === false) {
        throw new Error(data.message || 'API request failed');
      }

      return data.data || data;
    } catch (error) {
      console.error('API request failed:', error);
      throw error;
    }
  }

  // RESTAURANTS API
  async getRestaurants(): Promise<Restaurant[]> {
    const serverData = await this.request<any[]>('/restaurants');
    return adaptRestaurants(serverData);
  }

  async getRestaurant(id: string): Promise<Restaurant> {
    const serverData = await this.request<any>(`/restaurants/${id}`);
    return adaptRestaurant(serverData);
  }

  async getRestaurantsByBrand(brand: string): Promise<Restaurant[]> {
    const serverData = await this.request<any[]>(`/restaurants/brand/${brand}`);
    return adaptRestaurants(serverData);
  }

  // DISHES API
  async getDishes(): Promise<Dish[]> {
    const serverData = await this.request<any[]>('/dishes');
    return adaptDishes(serverData);
  }

  async getDishesByRestaurant(restaurantId: string): Promise<Dish[]> {
    const serverData = await this.request<any[]>(`/dishes/restaurant/${restaurantId}`);
    return adaptDishes(serverData);
  }

  async getDish(id: string): Promise<Dish> {
    const serverData = await this.request<any>(`/dishes/${id}`);
    return adaptDish(serverData);
  }

  // NEWS API
  async getNews(): Promise<News[]> {
    const serverData = await this.request<any[]>('/news');
    return adaptNewsArray(serverData);
  }

  async getNewsById(id: string): Promise<News> {
    const serverData = await this.request<any>(`/news/${id}`);
    return adaptNews(serverData);
  }

  // BRANDS API
  async getBrands(): Promise<any[]> {
    return this.request<any[]>('/brands');
  }

  // CITIES API
  async getCities(): Promise<any[]> {
    return this.request<any[]>('/cities');
  }

  // AUTH API
  async login(credentials: LoginForm): Promise<{ user: AuthUser; token: string }> {
    try {
      // Получаем всех пользователей
      const users = await this.request<any[]>('/users');
      
      // Ищем пользователя по телефону или email
      let user = null;
      if (credentials.phone) {
        user = users.find(u => u.phoneNumber === credentials.phone || u.phone === credentials.phone);
      } else if (credentials.email) {
        user = users.find(u => u.email === credentials.email);
      }

      if (!user) {
        throw new Error('Пользователь не найден');
      }

      // Простая проверка пароля (в реальном приложении нужно использовать bcrypt)
      // Для демонстрации принимаем любой пароль
      const token = `token_${user._id}_${Date.now()}`;
      
      // Преобразуем данные пользователя в нужный формат
      const userData: AuthUser = {
        id: user._id,
        name: user.fullName,
        email: user.email,
        phone: user.phoneNumber || user.phone || '',
        token: token,
        avatar: user.avatar
      };

      // Сохраняем токен и данные пользователя
      localStorage.setItem('byk_token', token);
      localStorage.setItem('byk_user', JSON.stringify(userData));
      
      return { user: userData, token: token };
    } catch (error) {
      console.error('Login error:', error);
      throw new Error('Ошибка авторизации');
    }
  }

  async register(userData: RegisterForm): Promise<{ user: AuthUser; token: string }> {
    try {
      // Отправляем данные на сервер через /auth/register API
      const response = await this.request<any>('/auth/register', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          phoneNumber: userData.phone, // Сервер ожидает phoneNumber
          password: userData.password,
          fullName: userData.name,
          email: userData.email
        })
      });

      if (!response.success) {
        throw new Error(response.message || 'Ошибка регистрации');
      }

      // Преобразуем данные пользователя в нужный формат
      const userDataFormatted: AuthUser = {
        id: response.user.id,
        name: response.user.fullName,
        email: response.user.email,
        phone: response.user.phoneNumber,
        token: response.token,
        avatar: response.user.avatar || ''
      };

      // Сохраняем токен и данные пользователя
      localStorage.setItem('byk_token', response.token);
      localStorage.setItem('byk_user', JSON.stringify(userDataFormatted));

      console.log('Регистрация прошла успешно через /auth/register API:', userDataFormatted);
      
      return { user: userDataFormatted, token: response.token };
    } catch (error) {
      console.error('Registration error:', error);
      throw new Error('Ошибка регистрации');
    }
  }

  async logout(): Promise<void> {
    // Простое удаление из localStorage (серверный logout пока не работает)
    localStorage.removeItem('byk_token');
    localStorage.removeItem('byk_user');
  }

  async getCurrentUser(): Promise<AuthUser> {
    return this.request<AuthUser>('/auth/me');
  }

  // RESERVATIONS API
  async getReservations(): Promise<any[]> {
    return this.request<any[]>('/reservations');
  }

  async createReservation(reservationData: any): Promise<any> {
    return this.request<any>('/reservations', {
      method: 'POST',
      body: JSON.stringify(reservationData),
    });
  }

  async updateReservation(id: string, reservationData: any): Promise<any> {
    return this.request<any>(`/reservations/${id}`, {
      method: 'PUT',
      body: JSON.stringify(reservationData),
    });
  }

  async deleteReservation(id: string): Promise<void> {
    return this.request<void>(`/reservations/${id}`, {
      method: 'DELETE',
    });
  }

  // ORDERS API
  async getOrders(): Promise<any[]> {
    return this.request<any[]>('/orders');
  }

  async createOrder(orderData: any): Promise<any> {
    return this.request<any>('/orders', {
      method: 'POST',
      body: JSON.stringify(orderData),
    });
  }

  async updateOrder(id: string, orderData: any): Promise<any> {
    return this.request<any>(`/orders/${id}`, {
      method: 'PUT',
      body: JSON.stringify(orderData),
    });
  }
}

// Создаем экземпляр API клиента
export const apiClient = new ApiClient(API_BASE_URL);

// Экспортируем отдельные методы для удобства
export const restaurantsApi = {
  getAll: () => apiClient.getRestaurants(),
  getById: (id: string) => apiClient.getRestaurant(id),
  getByBrand: (brand: string) => apiClient.getRestaurantsByBrand(brand),
};

export const dishesApi = {
  getAll: () => apiClient.getDishes(),
  getById: (id: string) => apiClient.getDish(id),
  getByRestaurant: (restaurantId: string) => apiClient.getDishesByRestaurant(restaurantId),
};

export const newsApi = {
  getAll: () => apiClient.getNews(),
  getById: (id: string) => apiClient.getNewsById(id),
};

export const authApi = {
  login: (credentials: LoginForm) => apiClient.login(credentials),
  register: (userData: RegisterForm) => apiClient.register(userData),
  logout: () => apiClient.logout(),
  getCurrentUser: () => apiClient.getCurrentUser(),
};

export const reservationsApi = {
  getAll: () => apiClient.getReservations(),
  create: (reservationData: any) => apiClient.createReservation(reservationData),
  update: (id: string, reservationData: any) => apiClient.updateReservation(id, reservationData),
  delete: (id: string) => apiClient.deleteReservation(id),
};

export const ordersApi = {
  getAll: () => apiClient.getOrders(),
  create: (orderData: any) => apiClient.createOrder(orderData),
  update: (id: string, orderData: any) => apiClient.updateOrder(id, orderData),
};

export const brandsApi = {
  getAll: () => apiClient.getBrands(),
};

export const citiesApi = {
  getAll: () => apiClient.getCities(),
};
