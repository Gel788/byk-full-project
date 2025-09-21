# 🏪 API Документация - Рестораны

## 📋 Обзор

API для управления ресторанами в системе БЫК Holding. Все эндпоинты доступны по базовому URL: `https://bulladmin.ru/api/restaurants`

---

## 🔗 Эндпоинты

### 1. Получить все рестораны

**GET** `/api/restaurants`

**Описание:** Возвращает список всех активных ресторанов с информацией о брендах и городах.

**Параметры запроса:**
- `brandId` (опционально) - фильтр по ID бренда
- `cityId` (опционально) - фильтр по ID города
- `isActive` (опционально) - фильтр по активности (true/false)

**Пример запроса:**
```http
GET /api/restaurants?brandId=68cd3d1d47622f283828f494&cityId=68cd3da047622f283828f4a6
```

**Пример ответа:**
```json
[
  {
    "_id": "68cd92fcef4e2d022348468e",
    "name": "THE БЫК на Тверской",
    "description": "Премиальный стейк-хаус в самом сердце Москвы",
    "address": "ул. Тверская, 15",
    "phone": "+7 (495) 123-45-67",
    "email": "info@thebyk.ru",
    "workingHours": "10:00 - 23:00",
    "rating": 4.8,
    "photos": [
      "https://bulladmin.ru/api/upload/uploads/file-1758302966408-55399533.jpeg"
    ],
    "videos": [],
    "isActive": true,
    "brandId": {
      "_id": "68cd3d1d47622f283828f494",
      "name": "The Бык",
      "logo": "",
      "color": "#000000"
    },
    "cityId": {
      "_id": "68cd3da047622f283828f4a6",
      "name": "Москва",
      "country": "Россия"
    },
    "createdAt": "2025-09-19T17:29:32.085Z",
    "updatedAt": "2025-09-19T17:29:32.085Z"
  }
]
```

---

### 2. Получить ресторан по ID

**GET** `/api/restaurants/:id`

**Описание:** Возвращает детальную информацию о конкретном ресторане.

**Параметры:**
- `id` (обязательно) - ID ресторана

**Пример запроса:**
```http
GET /api/restaurants/68cd92fcef4e2d022348468e
```

**Пример ответа:**
```json
{
  "_id": "68cd92fcef4e2d022348468e",
  "name": "THE БЫК на Тверской",
  "description": "Премиальный стейк-хаус в самом сердце Москвы",
  "address": "ул. Тверская, 15",
  "phone": "+7 (495) 123-45-67",
  "email": "info@thebyk.ru",
  "workingHours": "10:00 - 23:00",
  "rating": 4.8,
  "photos": [
    "https://bulladmin.ru/api/upload/uploads/file-1758302966408-55399533.jpeg"
  ],
  "videos": [],
  "isActive": true,
  "brandId": {
    "_id": "68cd3d1d47622f283828f494",
    "name": "The Бык",
    "logo": "",
    "color": "#000000"
  },
  "cityId": {
    "_id": "68cd3da047622f283828f4a6",
    "name": "Москва",
    "country": "Россия"
  },
  "createdAt": "2025-09-19T17:29:32.085Z",
  "updatedAt": "2025-09-19T17:29:32.085Z"
}
```

**Ошибки:**
- `404` - Ресторан не найден

---

### 3. Создать новый ресторан

**POST** `/api/restaurants`

**Описание:** Создает новый ресторан в системе.

**Тело запроса:**
```json
{
  "name": "THE БЫК на Арбате",
  "brandId": "68cd3d1d47622f283828f494",
  "cityId": "68cd3da047622f283828f4a6",
  "address": "ул. Арбат, 25",
  "phone": "+7 (495) 987-65-43",
  "email": "arbat@thebyk.ru",
  "description": "Современный стейк-хаус в историческом центре",
  "workingHours": "11:00 - 24:00",
  "rating": 0,
  "photos": [],
  "videos": [],
  "isActive": true
}
```

**Пример ответа:**
```json
{
  "_id": "68cd92fcef4e2d0223484690",
  "name": "THE БЫК на Арбате",
  "description": "Современный стейк-хаус в историческом центре",
  "address": "ул. Арбат, 25",
  "phone": "+7 (495) 987-65-43",
  "email": "arbat@thebyk.ru",
  "workingHours": "11:00 - 24:00",
  "rating": 0,
  "photos": [],
  "videos": [],
  "isActive": true,
  "brandId": "68cd3d1d47622f283828f494",
  "cityId": "68cd3da047622f283828f4a6",
  "createdAt": "2025-09-20T12:30:00.000Z",
  "updatedAt": "2025-09-20T12:30:00.000Z"
}
```

---

### 4. Обновить ресторан

**PUT** `/api/restaurants/:id`

**Описание:** Обновляет информацию о существующем ресторане.

**Параметры:**
- `id` (обязательно) - ID ресторана

**Тело запроса:**
```json
{
  "name": "THE БЫК на Тверской (обновлено)",
  "description": "Обновленное описание ресторана",
  "workingHours": "10:00 - 23:30",
  "rating": 4.9
}
```

**Пример ответа:**
```json
{
  "_id": "68cd92fcef4e2d022348468e",
  "name": "THE БЫК на Тверской (обновлено)",
  "description": "Обновленное описание ресторана",
  "address": "ул. Тверская, 15",
  "phone": "+7 (495) 123-45-67",
  "email": "info@thebyk.ru",
  "workingHours": "10:00 - 23:30",
  "rating": 4.9,
  "photos": [
    "https://bulladmin.ru/api/upload/uploads/file-1758302966408-55399533.jpeg"
  ],
  "videos": [],
  "isActive": true,
  "brandId": {
    "_id": "68cd3d1d47622f283828f494",
    "name": "The Бык",
    "logo": "",
    "color": "#000000"
  },
  "cityId": {
    "_id": "68cd3da047622f283828f4a6",
    "name": "Москва",
    "country": "Россия"
  },
  "createdAt": "2025-09-19T17:29:32.085Z",
  "updatedAt": "2025-09-20T12:35:00.000Z"
}
```

---

### 5. Удалить ресторан

**DELETE** `/api/restaurants/:id`

**Описание:** Удаляет ресторан из системы.

**Параметры:**
- `id` (обязательно) - ID ресторана

**Пример запроса:**
```http
DELETE /api/restaurants/68cd92fcef4e2d022348468e
```

**Пример ответа:**
```json
{
  "message": "Restaurant deleted"
}
```

**Ошибки:**
- `404` - Ресторан не найден

---

## 📊 Схема данных

### Restaurant Model

```typescript
interface IRestaurant {
  _id: string;                    // Уникальный идентификатор
  name: string;                   // Название ресторана
  brandId: string;                // ID бренда (ObjectId)
  cityId: string;                 // ID города (ObjectId)
  address: string;                // Адрес
  phone: string;                  // Телефон
  email: string;                  // Email
  description: string;            // Описание
  workingHours: string;           // Часы работы
  rating: number;                 // Рейтинг (0-5)
  photos: string[];               // Массив URL фотографий
  videos: string[];               // Массив URL видео
  isActive: boolean;              // Активен ли ресторан
  createdAt: string;              // Дата создания (ISO)
  updatedAt: string;              // Дата обновления (ISO)
}
```

### Populated Fields

При запросах поля `brandId` и `cityId` автоматически заполняются данными:

```typescript
interface PopulatedRestaurant extends IRestaurant {
  brandId: {
    _id: string;
    name: string;
    logo: string;
    color: string;
  };
  cityId: {
    _id: string;
    name: string;
    country: string;
  };
}
```

---

## 🔧 Коды ответов

| Код | Описание |
|-----|----------|
| `200` | Успешный запрос |
| `201` | Ресурс создан |
| `400` | Неверные данные запроса |
| `404` | Ресурс не найден |
| `500` | Внутренняя ошибка сервера |

---

## 📝 Примеры использования

### Получить рестораны конкретного бренда

```http
GET /api/restaurants?brandId=68cd3d1d47622f283828f494
```

### Получить рестораны в конкретном городе

```http
GET /api/restaurants?cityId=68cd3da047622f283828f4a6
```

### Получить только активные рестораны

```http
GET /api/restaurants?isActive=true
```

### Комбинированный фильтр

```http
GET /api/restaurants?brandId=68cd3d1d47622f283828f494&cityId=68cd3da047622f283828f4a6&isActive=true
```

---

## 🚀 Интеграция с iOS

Для интеграции с iOS приложением используйте следующие рекомендации:

1. **Base URL:** `https://bulladmin.ru/api`
2. **Content-Type:** `application/json`
3. **CORS:** Настроен для всех доменов
4. **Timeout:** Рекомендуется 30 секунд для сетевых запросов

### Пример Swift кода:

```swift
struct RestaurantAPI: Codable {
    let _id: String
    let name: String
    let description: String
    let address: String
    let phone: String
    let email: String
    let workingHours: String
    let rating: Double
    let photos: [String]
    let videos: [String]
    let isActive: Bool
    let brandId: BrandInfo
    let cityId: CityInfo
    let createdAt: String
    let updatedAt: String
}

struct BrandInfo: Codable {
    let _id: String
    let name: String
    let logo: String
    let color: String
}

struct CityInfo: Codable {
    let _id: String
    let name: String
    let country: String
}
```

---

## ⚠️ Важные замечания

1. **Аутентификация:** В текущей версии аутентификация не требуется
2. **Валидация:** Все обязательные поля проверяются на сервере
3. **Файлы:** Загрузка фотографий происходит через отдельный эндпоинт `/api/upload`
4. **Лимиты:** Размер запроса ограничен 10MB
5. **CORS:** Настроен для локальной разработки и продакшена

---

## 🔄 Обновления

- **v1.0.0** - Базовая функциональность CRUD операций
- **v1.0.1** - Добавлена поддержка фильтрации по брендам и городам
- **v1.0.2** - Улучшена обработка ошибок и валидация данных

---

*Документация актуальна на: 20 сентября 2025*
