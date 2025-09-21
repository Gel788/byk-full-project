# 🔐 ИНТЕГРАЦИЯ АУТЕНТИФИКАЦИИ С API - ДОКУМЕНТАЦИЯ

## 📋 ТЕКУЩЕЕ СОСТОЯНИЕ

### ✅ Что уже реализовано:

#### 1. **Локальная система аутентификации**
- **AuthService** - полный сервис аутентификации
- **Регистрация** - создание новых пользователей
- **Вход** - авторизация по номеру телефона и паролю
- **Выход** - завершение сессии
- **Хранение данных** - UserDefaults для локального хранения

#### 2. **UI компоненты**
- **AuthView** - главный экран аутентификации
- **LoginFormView** - форма входа
- **RegistrationFormView** - форма регистрации
- **PremiumLogoutButton** - красивая кнопка выхода
- **UnauthenticatedProfileView** - экран для неавторизованных пользователей

#### 3. **Модели данных**
- **User** - модель пользователя
- **AuthCredentials** - данные для входа
- **RegistrationData** - данные для регистрации
- **UserOrder** - заказы пользователя
- **UserReservation** - бронирования пользователя

---

## 🚀 ПЛАН ИНТЕГРАЦИИ С API

### Этап 1: Создание API эндпоинтов (Backend)

#### Необходимые эндпоинты:

```typescript
// Регистрация пользователя
POST /api/auth/register
{
  "phoneNumber": "+79991234567",
  "password": "password123",
  "fullName": "Иван Петров",
  "email": "ivan@example.com"
}

// Вход пользователя
POST /api/auth/login
{
  "phoneNumber": "+79991234567",
  "password": "password123"
}

// Выход пользователя
POST /api/auth/logout
{
  "token": "jwt_token_here"
}

// Обновление токена
POST /api/auth/refresh
{
  "refreshToken": "refresh_token_here"
}

// Получение профиля пользователя
GET /api/auth/profile
Headers: { "Authorization": "Bearer jwt_token" }

// Обновление профиля пользователя
PUT /api/auth/profile
Headers: { "Authorization": "Bearer jwt_token" }
{
  "fullName": "Иван Петров",
  "email": "ivan@example.com"
}
```

### Этап 2: Создание API моделей (iOS)

#### Новые модели для API:

```swift
// API модели для аутентификации
struct UserAPI: Codable, Identifiable {
    let id: String
    let phoneNumber: String
    let fullName: String
    let email: String?
    let avatar: String?
    let isVerified: Bool
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case phoneNumber, fullName, email, avatar, isVerified
        case createdAt, updatedAt
    }
}

struct AuthResponse: Codable {
    let success: Bool
    let message: String
    let user: UserAPI?
    let token: String?
    let refreshToken: String?
}

struct LoginRequest: Codable {
    let phoneNumber: String
    let password: String
}

struct RegisterRequest: Codable {
    let phoneNumber: String
    let password: String
    let fullName: String
    let email: String?
}

struct LogoutRequest: Codable {
    let token: String
}
```

### Этап 3: Расширение APIService

#### Новые методы в APIService:

```swift
// MARK: - Authentication
func register(_ request: RegisterRequest) -> AnyPublisher<AuthResponse, Error>
func login(_ request: LoginRequest) -> AnyPublisher<AuthResponse, Error>
func logout(_ request: LogoutRequest) -> AnyPublisher<AuthResponse, Error>
func refreshToken(_ refreshToken: String) -> AnyPublisher<AuthResponse, Error>
func getProfile(token: String) -> AnyPublisher<UserAPI, Error>
func updateProfile(token: String, user: UserAPI) -> AnyPublisher<UserAPI, Error>
```

### Этап 4: Обновление AuthService

#### Интеграция с API:

```swift
class AuthService: ObservableObject {
    // Добавить свойства для токенов
    @Published var accessToken: String?
    @Published var refreshToken: String?
    
    // Обновить методы для работы с API
    func register(with data: RegistrationData) async {
        // Отправка запроса на API
        // Сохранение токенов
        // Обновление состояния
    }
    
    func login(with credentials: AuthCredentials) async {
        // Отправка запроса на API
        // Сохранение токенов
        // Обновление состояния
    }
    
    func logout() async {
        // Отправка запроса на API для инвалидации токена
        // Очистка локальных данных
        // Обновление состояния
    }
    
    // Новые методы
    func refreshAccessToken() async -> Bool
    func updateUserProfile(_ user: User) async
    func validateToken() async -> Bool
}
```

---

## 🔧 ТЕХНИЧЕСКИЕ ДЕТАЛИ

### Безопасность:

1. **JWT токены** - для аутентификации
2. **Refresh токены** - для обновления доступа
3. **Хеширование паролей** - на сервере
4. **HTTPS** - для всех запросов
5. **Keychain** - для безопасного хранения токенов

### Хранение данных:

1. **Keychain** - токены и пароли
2. **UserDefaults** - настройки пользователя
3. **Core Data** - кэш данных пользователя

### Обработка ошибок:

1. **Сетевые ошибки** - таймауты, отсутствие интернета
2. **Ошибки авторизации** - неверные данные, истекший токен
3. **Ошибки сервера** - 500, 503, etc.
4. **Валидация** - проверка данных на клиенте

---

## 📱 ПОЛЬЗОВАТЕЛЬСКИЙ ОПЫТ

### Потоки пользователя:

1. **Регистрация**:
   - Ввод данных → Валидация → API запрос → Успех/Ошибка
   
2. **Вход**:
   - Ввод данных → API запрос → Сохранение токенов → Переход в приложение
   
3. **Выход**:
   - Подтверждение → API запрос → Очистка данных → Переход на экран входа
   
4. **Автоматический вход**:
   - Проверка токенов → Валидация → Обновление при необходимости

### Состояния интерфейса:

1. **Загрузка** - индикаторы прогресса
2. **Ошибки** - понятные сообщения об ошибках
3. **Успех** - плавные переходы
4. **Офлайн** - работа с кэшированными данными

---

## 🎯 ПРИОРИТЕТЫ РЕАЛИЗАЦИИ

### Высокий приоритет:
1. ✅ Создание API эндпоинтов на сервере
2. ✅ Создание API моделей в iOS
3. ✅ Расширение APIService
4. ✅ Обновление AuthService

### Средний приоритет:
1. ⏳ Интеграция с Keychain
2. ⏳ Автоматическое обновление токенов
3. ⏳ Обработка офлайн режима
4. ⏳ Валидация данных

### Низкий приоритет:
1. ⏳ Биометрическая аутентификация
2. ⏳ Социальные сети (Google, Apple)
3. ⏳ Двухфакторная аутентификация
4. ⏳ Аналитика пользователей

---

## 🚀 СЛЕДУЮЩИЕ ШАГИ

1. **Создать API эндпоинты** на сервере
2. **Добавить API модели** в iOS проект
3. **Расширить APIService** новыми методами
4. **Обновить AuthService** для работы с API
5. **Протестировать интеграцию**

---

**Готово к началу интеграции!** 🎉
