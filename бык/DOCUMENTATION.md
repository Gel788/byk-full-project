# 🐂 БЫК - iOS Приложение для Сети Ресторанов

## 📋 Содержание

1. [Обзор проекта](#обзор-проекта)
2. [Архитектура](#архитектура)
3. [Модели данных](#модели-данных)
4. [Сервисы](#сервисы)
5. [Экраны](#экраны)
6. [Компоненты](#компоненты)
7. [Дизайн-система](#дизайн-система)
8. [Функциональность](#функциональность)

---

## 🎯 Обзор проекта

**БЫК** - это iOS приложение для сети ресторанов, включающей три бренда:
- **THE БЫК** - Премиальные стейк-хаусы
- **THE ПИВО** - Крафтовые пивные рестораны  
- **MOSCA** - Итальянские рестораны

### Основные возможности:
- 📱 Просмотр ресторанов и меню
- 💕 Дейтинг-режим для выбора блюд
- 📝 Создание социальных постов
- 🗓️ Бронирование столов
- 🛒 Заказы с доставкой
- 📰 Новости и акции

---

## 🏗️ Архитектура

### Структура проекта:
```
бык/
├── Models/           # Модели данных
├── Views/            # Экраны приложения
├── Services/         # Бизнес-логика
├── Theme/            # Дизайн-система
├── Components/       # Переиспользуемые компоненты
├── Assets.xcassets/  # Ресурсы
└── BykApp.swift      # Точка входа
```

### Технологии:
- **SwiftUI** - UI фреймворк
- **Combine** - Реактивное программирование
- **Core Data** - Локальная база данных
- **PhotosUI** - Работа с медиа
- **Core Location** - Геолокация

---

## 📊 Модели данных

### 🏪 Restaurant (Ресторан)

```swift
struct Restaurant: Identifiable, Hashable, Codable {
    let id: UUID
    let name: String
    let description: String
    let address: String
    let city: String
    let imageURL: String
    let rating: Double
    let cuisine: String
    let deliveryTime: Int
    let brand: Brand
    let menu: [Dish]
    let features: Set<Feature>
    let workingHours: WorkingHours
    let location: Location
    let tables: [Table]
    let gallery: [GalleryImage]
    let contacts: ContactInfo
    let averageCheck: Int
    let atmosphere: [String]
}
```

**Бренды ресторанов:**
- `theByk` - THE БЫК (стейк-хаусы)
- `thePivo` - THE ПИВО (пивные рестораны)
- `mosca` - MOSCA (итальянские рестораны)

**Особенности ресторанов:**
- `parking` - Парковка
- `wifi` - Wi-Fi
- `reservation` - Бронирование
- `cardPayment` - Оплата картой
- `liveMusic` - Живая музыка
- `takeaway` - На вынос

### 🍽️ Dish (Блюдо)

```swift
struct Dish: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let price: Double
    let image: String
    let category: String
    let restaurantBrand: Restaurant.Brand
    let isAvailable: Bool
    let preparationTime: Int
    let calories: Int
    let allergens: [String]
}
```

**Категории блюд:**
- Стейки
- Салаты
- Паста
- Пицца
- Закуски
- Напитки
- Десерты

### 👤 User (Пользователь)

```swift
struct User: Identifiable, Codable {
    let id: UUID
    let email: String
    let fullName: String
    let phone: String?
    let avatar: String?
    let dateOfBirth: Date?
    let preferences: UserPreferences
    let loyaltyPoints: Int
    let membershipLevel: MembershipLevel
    let favoriteRestaurants: [UUID]
    let orderHistory: [OrderHistoryItem]
    let reservations: [Reservation]
}
```

**Уровни членства:**
- `bronze` - Бронза
- `silver` - Серебро
- `gold` - Золото
- `platinum` - Платина

### 📝 Post (Пост)

```swift
struct Post: Identifiable, Codable, Hashable {
    let id: UUID
    let authorId: UUID
    let authorName: String
    let authorAvatar: String?
    let content: String
    let media: [PostMedia]
    let taggedRestaurant: Restaurant?
    let hashtags: [String]
    let location: Location?
    let likes: Int
    let comments: Int
    let isLiked: Bool
    let createdAt: Date
}
```

**Типы медиа:**
- `image` - Изображения
- `video` - Видео

### 🛒 CartItem (Элемент корзины)

```swift
struct CartItem: Identifiable, Codable {
    let id: UUID
    let dish: Dish
    let quantity: Int
    let specialInstructions: String?
    let selectedOptions: [DishOption]
}
```

### 📅 Reservation (Бронирование)

```swift
struct Reservation: Identifiable, Codable {
    let id: UUID
    let restaurantId: UUID
    let tableId: UUID
    let userId: UUID
    let date: Date
    let time: Date
    let numberOfGuests: Int
    let status: ReservationStatus
    let specialRequests: String?
    let contactPhone: String
    let contactName: String
}
```

**Статусы бронирования:**
- `pending` - Ожидает подтверждения
- `confirmed` - Подтверждено
- `cancelled` - Отменено
- `completed` - Завершено

### 📰 News (Новости)

```swift
struct News: Identifiable, Codable {
    let id: UUID
    let title: String
    let content: String
    let imageURL: String?
    let publishedDate: Date
    let author: String
    let category: NewsCategory
    let tags: [String]
    let isFeatured: Bool
    let readTime: Int
}
```

---

## 🔧 Сервисы

### 🏪 RestaurantService

```swift
class RestaurantService: ObservableObject {
    @Published var restaurants: [Restaurant] = []
    
    func loadMockData()
    func getRestaurants(for brand: Restaurant.Brand) -> [Restaurant]
    func getRestaurant(by id: UUID) -> Restaurant?
    func searchRestaurants(query: String) -> [Restaurant]
}
```

**Функции:**
- Загрузка данных ресторанов
- Фильтрация по брендам
- Поиск ресторанов
- Управление меню

### 🛒 CartViewModel

```swift
class CartViewModel: ObservableObject {
    @Published var items: [CartItem] = []
    @Published var totalAmount: Double = 0
    @Published var totalItems: Int = 0
    
    func addItem(_ dish: Dish, quantity: Int)
    func removeItem(_ item: CartItem)
    func updateQuantity(for item: CartItem, quantity: Int)
    func clearCart()
    func calculateTotal()
}
```

**Функции:**
- Управление корзиной
- Расчет общей суммы
- Добавление/удаление товаров
- Очистка корзины

### 📝 PostService

```swift
class PostService: ObservableObject {
    @Published var posts: [Post] = []
    
    func createPost(_ post: Post)
    func likePost(_ postId: UUID)
    func unlikePost(_ postId: UUID)
    func addComment(to postId: UUID, comment: String)
    func getPosts(for restaurant: Restaurant?) -> [Post]
}
```

**Функции:**
- Создание постов
- Лайки и комментарии
- Фильтрация по ресторанам
- Управление медиа

### 🔐 AuthService

```swift
class AuthService: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    
    func signIn(email: String, password: String)
    func signUp(email: String, password: String, fullName: String)
    func signOut()
    func resetPassword(email: String)
}
```

**Функции:**
- Аутентификация пользователей
- Регистрация
- Восстановление пароля
- Управление сессией

### 📅 ReservationService

```swift
class ReservationService: ObservableObject {
    @Published var reservations: [Reservation] = []
    
    func createReservation(_ reservation: Reservation)
    func cancelReservation(_ reservationId: UUID)
    func getReservations(for userId: UUID) -> [Reservation]
    func getAvailableTables(for restaurantId: UUID, date: Date) -> [Table]
}
```

**Функции:**
- Создание бронирований
- Отмена бронирований
- Проверка доступности столов
- История бронирований

### 📰 NewsService

```swift
class NewsService: ObservableObject {
    @Published var news: [News] = []
    
    func loadNews()
    func getNews(for category: NewsCategory) -> [News]
    func getFeaturedNews() -> [News]
    func markAsRead(_ newsId: UUID)
}
```

**Функции:**
- Загрузка новостей
- Фильтрация по категориям
- Избранные новости
- Отметка о прочтении

---

## 📱 Экраны

### 🏠 RestaurantsView
- Список всех ресторанов
- Фильтрация по брендам
- Поиск ресторанов
- Карточки с рейтингами

### 🍽️ MenuListView
- Полный каталог блюд
- Фильтрация по брендам и категориям
- Поиск блюд
- Дейтинг-режим

### 💕 Дейтинг-режим
- Свайп влево/вправо для выбора блюд
- Анимированные карточки
- Лайк/дизлайк блюд
- Сохранение избранного

### 📝 CreatePostView
- Создание постов с фото/видео
- Выбор ресторана
- Добавление хештегов
- Предпросмотр поста

### 📱 PostsView
- Социальная лента
- Лайки и комментарии
- Фильтрация по ресторанам
- Создание новых постов

### 🗓️ ReservationsView
- Бронирование столов
- Выбор даты и времени
- Указание количества гостей
- История бронирований

### 🛒 CartView
- Корзина с товарами
- Изменение количества
- Оформление заказа
- Выбор способа доставки

### 📰 NewsView
- Лента новостей
- Детальные статьи
- Категории новостей
- Избранные новости

### 👤 ProfileView
- Профиль пользователя
- Настройки приложения
- История заказов
- Программа лояльности

---

## 🧩 Компоненты

### 🎨 AnimatedLogo
- Анимированный логотип быка
- Вращение и масштабирование
- Эффекты свечения

### 🏪 RestaurantCard
- Карточка ресторана
- Рейтинг и отзывы
- Быстрые действия

### 🍽️ DishCard
- Карточка блюда
- Цена и описание
- Кнопка добавления в корзину

### 📝 PostCard
- Карточка поста
- Медиа контент
- Лайки и комментарии

### 📰 NewsCard
- Карточка новости
- Изображение и заголовок
- Время чтения

### 🔍 SearchBar
- Поисковая строка
- Фильтры и автодополнение
- История поиска

---

## 🎨 Дизайн-система

### Цветовая палитра

**THE БЫК:**
- Primary: #8B4513 (Коричневый)
- Secondary: #D2691E (Оранжево-коричневый)
- Accent: #FFD700 (Золотой)

**THE ПИВО:**
- Primary: #DAA520 (Золотистый)
- Secondary: #B8860B (Темно-золотой)
- Accent: #FFD700 (Золотой)

**MOSCA:**
- Primary: #DC143C (Малиновый)
- Secondary: #8B0000 (Темно-красный)
- Accent: #FFD700 (Золотой)

### Типографика

**Заголовки:**
- H1: 32pt, Bold
- H2: 24pt, Bold
- H3: 20pt, Bold

**Текст:**
- Body: 16pt, Regular
- Caption: 14pt, Regular
- Small: 12pt, Regular

### Анимации

**Переходы:**
- `slideFromRight` - Слайд справа
- `slideFromBottom` - Слайд снизу
- `fade` - Плавное появление

**Интерактивные:**
- `tap` - Анимация нажатия
- `bounce` - Отскок
- `smooth` - Плавная анимация

**Эффекты:**
- `shimmer` - Эффект мерцания
- `fadeIn` - Появление
- `pressAnimation` - Анимация нажатия

---

## ⚡ Функциональность

### 🔍 Поиск и фильтрация
- Поиск ресторанов по названию и адресу
- Фильтрация блюд по категориям
- Поиск в меню по ингредиентам
- Фильтрация постов по ресторанам

### 📍 Геолокация
- Определение местоположения
- Поиск ближайших ресторанов
- Отображение на карте
- Расчет времени доставки

### 💳 Платежи
- Оплата картой
- Apple Pay
- Сохранение карт
- История платежей

### 🔔 Уведомления
- Push-уведомления
- Напоминания о бронировании
- Статус заказа
- Новости и акции

### 📊 Аналитика
- Статистика заказов
- Популярные блюда
- Время посещения
- Отзывы и рейтинги

### 🌐 Социальные функции
- Создание постов
- Лайки и комментарии
- Поделиться в соцсетях
- Отзывы о ресторанах

---

## 🚀 Технические особенности

### Производительность
- Ленивая загрузка изображений
- Кэширование данных
- Оптимизация анимаций
- Минимизация перерисовок

### Безопасность
- Шифрование данных
- Безопасная аутентификация
- Защита персональных данных
- Безопасные платежи

### Доступность
- Поддержка VoiceOver
- Динамические шрифты
- Высокий контраст
- Увеличение текста

### Локализация
- Поддержка русского языка
- Форматирование валют
- Локальные даты и время
- Адаптация под регион

---

## 📈 Планы развития

### Краткосрочные цели
- [ ] Улучшение UI/UX
- [ ] Добавление новых анимаций
- [ ] Оптимизация производительности
- [ ] Исправление багов

### Среднесрочные цели
- [ ] Интеграция с CRM
- [ ] Система лояльности
- [ ] Персонализация контента
- [ ] Аналитика пользователей

### Долгосрочные цели
- [ ] Web-версия
- [ ] Android приложение
- [ ] Интеграция с IoT
- [ ] AI-рекомендации

---

*Документация обновлена: 2024* 