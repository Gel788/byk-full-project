# 🚀 ПЛАН БЕКЕНДА - БЫК HOLDING

## 📋 ОБЗОР ПРОЕКТА

**БЫК Holding** - сеть премиальных ресторанов с мобильным приложением, веб-клиентом и админ-панелью.

### 🏗️ Архитектура системы:
- **iOS App** (SwiftUI) - мобильное приложение
- **Web Client** (Next.js) - веб-версия для клиентов  
- **Web Admin** (Next.js) - админ-панель
- **Backend API** (Node.js/Python) - серверная часть
- **Database** (PostgreSQL) - основная БД
- **Redis** - кэширование и сессии
- **File Storage** (AWS S3) - медиафайлы

---

## 🎯 ОСНОВНЫЕ СУЩНОСТИ

### 👤 **Пользователи (Users)**
```typescript
interface User {
  id: UUID
  username: string
  fullName: string
  email: string
  phone: string
  avatar?: string
  isVerified: boolean
  membershipLevel: 'bronze' | 'silver' | 'gold' | 'platinum'
  loyaltyPoints: number
  preferences: UserPreferences
  createdAt: Date
  updatedAt: Date
}
```

### 🏪 **Рестораны (Restaurants)**
```typescript
interface Restaurant {
  id: UUID
  name: string
  description: string
  brand: 'byk' | 'pivo' | 'mosca' | 'georgia'
  address: string
  city: string
  location: { lat: number, lng: number }
  rating: number
  cuisine: string
  deliveryTime: number
  averageCheck: number
  workingHours: WorkingHours
  features: string[]
  gallery: string[]
  contacts: ContactInfo
  tables: Table[]
  isActive: boolean
  createdAt: Date
  updatedAt: Date
}
```

### 🍽️ **Блюда (Dishes)**
```typescript
interface Dish {
  id: UUID
  restaurantId: UUID
  name: string
  description: string
  price: number
  category: string
  imageURL: string
  model3DURL?: string
  ingredients: string[]
  calories: number
  preparationTime: number
  isSpicy: boolean
  isVegetarian: boolean
  isAvailable: boolean
  createdAt: Date
  updatedAt: Date
}
```

### 🛒 **Заказы (Orders)**
```typescript
interface Order {
  id: UUID
  userId: UUID
  restaurantId: UUID
  orderNumber: string
  items: OrderItem[]
  totalAmount: number
  deliveryMethod: 'delivery' | 'pickup'
  deliveryAddress?: string
  status: 'pending' | 'confirmed' | 'preparing' | 'ready' | 'delivered' | 'cancelled'
  paymentMethod: 'card' | 'cash' | 'apple_pay'
  paymentStatus: 'pending' | 'paid' | 'failed' | 'refunded'
  estimatedDeliveryTime?: Date
  actualDeliveryTime?: Date
  specialRequests?: string
  createdAt: Date
  updatedAt: Date
}
```

### 📅 **Бронирования (Reservations)**
```typescript
interface Reservation {
  id: UUID
  userId: UUID
  restaurantId: UUID
  tableId: UUID
  date: Date
  guestCount: number
  status: 'pending' | 'confirmed' | 'cancelled' | 'completed'
  specialRequests?: string
  createdAt: Date
  updatedAt: Date
}
```

### 📝 **Посты (Posts)**
```typescript
interface Post {
  id: UUID
  authorId: UUID
  content: string
  media: PostMedia[]
  taggedRestaurantId?: UUID
  hashtags: string[]
  location?: { lat: number, lng: number }
  likes: number
  comments: number
  isLiked: boolean
  createdAt: Date
  updatedAt: Date
}
```

### 📰 **Новости (News)**
```typescript
interface News {
  id: UUID
  title: string
  content: string
  imageURL: string
  author: string
  category: string
  isPublished: boolean
  publishedAt?: Date
  createdAt: Date
  updatedAt: Date
}
```

---

## 🔌 API ЭНДПОИНТЫ

### 🔐 **Аутентификация**
```
POST /api/auth/register
POST /api/auth/login
POST /api/auth/logout
POST /api/auth/refresh
GET  /api/auth/me
PUT  /api/auth/profile
POST /api/auth/forgot-password
POST /api/auth/reset-password
```

### 👤 **Пользователи**
```
GET    /api/users
GET    /api/users/:id
PUT    /api/users/:id
DELETE /api/users/:id
GET    /api/users/:id/orders
GET    /api/users/:id/reservations
GET    /api/users/:id/posts
```

### 🏪 **Рестораны**
```
GET    /api/restaurants
GET    /api/restaurants/:id
POST   /api/restaurants
PUT    /api/restaurants/:id
DELETE /api/restaurants/:id
GET    /api/restaurants/:id/menu
GET    /api/restaurants/:id/reviews
GET    /api/restaurants/nearby
```

### 🍽️ **Меню и блюда**
```
GET    /api/dishes
GET    /api/dishes/:id
POST   /api/dishes
PUT    /api/dishes/:id
DELETE /api/dishes/:id
GET    /api/dishes/categories
GET    /api/dishes/search
```

### 🛒 **Заказы**
```
GET    /api/orders
GET    /api/orders/:id
POST   /api/orders
PUT    /api/orders/:id/status
DELETE /api/orders/:id
GET    /api/orders/user/:userId
GET    /api/orders/restaurant/:restaurantId
```

### 📅 **Бронирования**
```
GET    /api/reservations
GET    /api/reservations/:id
POST   /api/reservations
PUT    /api/reservations/:id
DELETE /api/reservations/:id
GET    /api/reservations/user/:userId
GET    /api/reservations/restaurant/:restaurantId
GET    /api/reservations/availability
```

### 📝 **Социальные функции**
```
GET    /api/posts
GET    /api/posts/:id
POST   /api/posts
PUT    /api/posts/:id
DELETE /api/posts/:id
POST   /api/posts/:id/like
DELETE /api/posts/:id/like
GET    /api/posts/:id/comments
POST   /api/posts/:id/comments
```

### 📰 **Новости**
```
GET    /api/news
GET    /api/news/:id
POST   /api/news
PUT    /api/news/:id
DELETE /api/news/:id
GET    /api/news/categories
```

### 📊 **Аналитика (Админ)**
```
GET    /api/admin/stats
GET    /api/admin/revenue
GET    /api/admin/orders-stats
GET    /api/admin/users-stats
GET    /api/admin/restaurants-stats
```

---

## 🗄️ СХЕМА БАЗЫ ДАННЫХ

### **Основные таблицы:**
```sql
-- Пользователи
CREATE TABLE users (
  id UUID PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  full_name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  phone VARCHAR(20) UNIQUE NOT NULL,
  avatar_url TEXT,
  is_verified BOOLEAN DEFAULT FALSE,
  membership_level VARCHAR(20) DEFAULT 'bronze',
  loyalty_points INTEGER DEFAULT 0,
  preferences JSONB,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Рестораны
CREATE TABLE restaurants (
  id UUID PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  brand VARCHAR(20) NOT NULL,
  address TEXT NOT NULL,
  city VARCHAR(50) NOT NULL,
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  rating DECIMAL(3, 2) DEFAULT 0,
  cuisine VARCHAR(50),
  delivery_time INTEGER,
  average_check INTEGER,
  working_hours JSONB,
  features TEXT[],
  gallery TEXT[],
  contacts JSONB,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Блюда
CREATE TABLE dishes (
  id UUID PRIMARY KEY,
  restaurant_id UUID REFERENCES restaurants(id),
  name VARCHAR(100) NOT NULL,
  description TEXT,
  price DECIMAL(10, 2) NOT NULL,
  category VARCHAR(50),
  image_url TEXT,
  model_3d_url TEXT,
  ingredients TEXT[],
  calories INTEGER,
  preparation_time INTEGER,
  is_spicy BOOLEAN DEFAULT FALSE,
  is_vegetarian BOOLEAN DEFAULT FALSE,
  is_available BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Заказы
CREATE TABLE orders (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  restaurant_id UUID REFERENCES restaurants(id),
  order_number VARCHAR(20) UNIQUE NOT NULL,
  total_amount DECIMAL(10, 2) NOT NULL,
  delivery_method VARCHAR(20) NOT NULL,
  delivery_address TEXT,
  status VARCHAR(20) DEFAULT 'pending',
  payment_method VARCHAR(20),
  payment_status VARCHAR(20) DEFAULT 'pending',
  estimated_delivery_time TIMESTAMP,
  actual_delivery_time TIMESTAMP,
  special_requests TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Элементы заказа
CREATE TABLE order_items (
  id UUID PRIMARY KEY,
  order_id UUID REFERENCES orders(id),
  dish_id UUID REFERENCES dishes(id),
  quantity INTEGER NOT NULL,
  price DECIMAL(10, 2) NOT NULL,
  special_requests TEXT
);

-- Бронирования
CREATE TABLE reservations (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  restaurant_id UUID REFERENCES restaurants(id),
  table_id UUID,
  date TIMESTAMP NOT NULL,
  guest_count INTEGER NOT NULL,
  status VARCHAR(20) DEFAULT 'pending',
  special_requests TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Посты
CREATE TABLE posts (
  id UUID PRIMARY KEY,
  author_id UUID REFERENCES users(id),
  content TEXT NOT NULL,
  media JSONB,
  tagged_restaurant_id UUID REFERENCES restaurants(id),
  hashtags TEXT[],
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  likes INTEGER DEFAULT 0,
  comments INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Новости
CREATE TABLE news (
  id UUID PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  content TEXT NOT NULL,
  image_url TEXT,
  author VARCHAR(100),
  category VARCHAR(50),
  is_published BOOLEAN DEFAULT FALSE,
  published_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

---

## 🏗️ АРХИТЕКТУРА СИСТЕМЫ

### **Микросервисы:**

#### 1. **API Gateway** (Node.js/Express)
- Маршрутизация запросов
- Аутентификация и авторизация
- Rate limiting
- Логирование

#### 2. **Auth Service** (Node.js)
- Регистрация/авторизация
- JWT токены
- Управление сессиями
- Восстановление пароля

#### 3. **User Service** (Node.js)
- Управление пользователями
- Профили и настройки
- Лояльность и бонусы

#### 4. **Restaurant Service** (Node.js)
- Управление ресторанами
- Меню и блюда
- Рабочие часы
- Рейтинги

#### 5. **Order Service** (Node.js)
- Создание заказов
- Управление статусами
- Интеграция с платежами
- Уведомления

#### 6. **Reservation Service** (Node.js)
- Бронирование столиков
- Управление доступностью
- Календарь

#### 7. **Social Service** (Node.js)
- Посты и лента
- Лайки и комментарии
- Хештеги

#### 8. **Notification Service** (Node.js)
- Push уведомления
- Email рассылки
- SMS

#### 9. **Analytics Service** (Python)
- Сбор метрик
- Отчеты и аналитика
- ML рекомендации

---

## 🛠️ ТЕХНОЛОГИЧЕСКИЙ СТЕК

### **Backend:**
- **Node.js** - основной runtime
- **Express.js** - веб-фреймворк
- **TypeScript** - типизация
- **PostgreSQL** - основная БД
- **Redis** - кэш и сессии
- **Prisma** - ORM
- **JWT** - аутентификация
- **Socket.io** - real-time

### **Инфраструктура:**
- **Docker** - контейнеризация
- **Kubernetes** - оркестрация
- **AWS/GCP** - облако
- **Nginx** - reverse proxy
- **Prometheus** - мониторинг
- **Grafana** - дашборды

### **Интеграции:**
- **Stripe** - платежи
- **SendGrid** - email
- **Firebase** - push уведомления
- **Yandex Maps** - карты
- **AWS S3** - файлы

---

## 🚀 ПЛАН РАЗРАБОТКИ

### **Этап 1: Основа (2-3 недели)**
- [ ] Настройка инфраструктуры
- [ ] База данных и миграции
- [ ] API Gateway
- [ ] Auth Service
- [ ] User Service

### **Этап 2: Основной функционал (3-4 недели)**
- [ ] Restaurant Service
- [ ] Order Service
- [ ] Reservation Service
- [ ] Базовые API эндпоинты

### **Этап 3: Дополнительные функции (2-3 недели)**
- [ ] Social Service
- [ ] Notification Service
- [ ] File upload
- [ ] Real-time обновления

### **Этап 4: Аналитика и оптимизация (2 недели)**
- [ ] Analytics Service
- [ ] Мониторинг
- [ ] Оптимизация производительности
- [ ] Тестирование

### **Этап 5: Деплой и запуск (1 неделя)**
- [ ] Production деплой
- [ ] Мониторинг
- [ ] Документация
- [ ] Обучение команды

---

## 📊 МОНИТОРИНГ И МЕТРИКИ

### **Ключевые метрики:**
- Количество пользователей
- Заказы в день/месяц
- Выручка
- Время отклика API
- Доступность сервисов
- Ошибки и исключения

### **Алерты:**
- Высокая нагрузка на БД
- Медленные запросы
- Ошибки аутентификации
- Проблемы с платежами
- Недоступность сервисов

---

## 🔒 БЕЗОПАСНОСТЬ

### **Аутентификация:**
- JWT токены с коротким TTL
- Refresh токены
- Rate limiting
- CORS настройки

### **Данные:**
- Шифрование паролей (bcrypt)
- HTTPS везде
- Валидация входных данных
- SQL injection защита

### **API:**
- API ключи для внешних сервисов
- Логирование всех запросов
- Мониторинг подозрительной активности

---

## 📈 МАСШТАБИРОВАНИЕ

### **Горизонтальное:**
- Микросервисы в отдельных контейнерах
- Load balancer
- Database sharding
- CDN для статических файлов

### **Вертикальное:**
- Увеличение ресурсов серверов
- Оптимизация запросов к БД
- Кэширование на всех уровнях
- Асинхронная обработка

---

## 💰 ОЦЕНКА СТОИМОСТИ

### **Разработка:**
- Backend разработчик: 2-3 месяца
- DevOps инженер: 1 месяц
- Тестировщик: 2 недели

### **Инфраструктура (месячно):**
- AWS/GCP: $200-500
- База данных: $100-300
- CDN и файлы: $50-150
- Мониторинг: $50-100

**Общая стоимость: $15,000-25,000**

---

## 🎯 ЗАКЛЮЧЕНИЕ

Данный план обеспечивает:
- ✅ **Масштабируемость** - микросервисная архитектура
- ✅ **Надежность** - мониторинг и алерты
- ✅ **Безопасность** - современные практики
- ✅ **Производительность** - кэширование и оптимизация
- ✅ **Гибкость** - легкое добавление функций

**Готов к реализации!** 🚀
