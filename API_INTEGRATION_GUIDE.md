# 🚀 API Интеграция для iOS Приложения БЫК

## 📋 Обзор

Этот документ содержит полную информацию для интеграции iOS приложения с backend API ресторанной сети БЫК.

**Base URL:** `https://bulladmin.ru/api`

---

## 🔐 Аутентификация

### Регистрация пользователя
```http
POST /users
Content-Type: application/json

{
  "username": "user123",
  "fullName": "Иван Иванов",
  "email": "ivan@example.com",
  "password": "password123"
}
```

### Авторизация пользователя
```http
POST /auth/login
Content-Type: application/json

{
  "email": "ivan@example.com",
  "password": "password123"
}
```

**Ответ:**
```json
{
  "success": true,
  "user": {
    "_id": "68cd3d3147622f283828f498",
    "username": "user123",
    "fullName": "Иван Иванов",
    "email": "ivan@example.com",
    "isVerified": true,
    "createdAt": "2025-09-19T11:23:29.830Z"
  },
  "token": "jwt_token_here"
}
```

---

## 🏢 Бренды

### Получить все бренды
```http
GET /brands
```

**Ответ:**
```json
[
  {
    "_id": "68cd3d1d47622f283828f494",
    "name": "The Бык",
    "description": "Премиальный стейк-хаус",
    "logo": "https://bulladmin.ru/api/upload/uploads/logo_byk.png",
    "color": "#8B4513",
    "isActive": true,
    "createdAt": "2025-09-19T11:23:09.685Z",
    "updatedAt": "2025-09-19T11:23:09.685Z"
  },
  {
    "_id": "68cd3d2a47622f283828f496",
    "name": "The Pivo",
    "description": "Крафтовый пивной ресторан",
    "logo": "https://bulladmin.ru/api/upload/uploads/logo_pivo.png",
    "color": "#FFD700",
    "isActive": true,
    "createdAt": "2025-09-19T11:23:22.362Z",
    "updatedAt": "2025-09-19T11:23:22.362Z"
  },
  {
    "_id": "68cd3d3147622f283828f498",
    "name": "Mosca",
    "description": "Аутентичная итальянская кухня",
    "logo": "https://bulladmin.ru/api/upload/uploads/logo_mosca.png",
    "color": "#228B22",
    "isActive": true,
    "createdAt": "2025-09-19T11:23:29.830Z",
    "updatedAt": "2025-09-19T11:23:29.830Z"
  }
]
```

---

## 🏙️ Города

### Получить все города
```http
GET /cities
```

**Ответ:**
```json
[
  {
    "_id": "68cd3da047622f283828f4a6",
    "name": "Москва",
    "country": "Россия",
    "isActive": true,
    "createdAt": "2025-09-19T11:23:44.123Z",
    "updatedAt": "2025-09-19T11:23:44.123Z"
  },
  {
    "_id": "68cd3da847622f283828f4a8",
    "name": "Санкт-Петербург",
    "country": "Россия",
    "isActive": true,
    "createdAt": "2025-09-19T11:23:52.456Z",
    "updatedAt": "2025-09-19T11:23:52.456Z"
  },
  {
    "_id": "68cd3db047622f283828f4aa",
    "name": "Калуга",
    "country": "Россия",
    "isActive": true,
    "createdAt": "2025-09-19T11:24:00.789Z",
    "updatedAt": "2025-09-19T11:24:00.789Z"
  },
  {
    "_id": "68cd3db847622f283828f4ac",
    "name": "Ереван",
    "country": "Армения",
    "isActive": true,
    "createdAt": "2025-09-19T11:24:08.012Z",
    "updatedAt": "2025-09-19T11:24:08.012Z"
  }
]
```

---

## 🍽️ Категории блюд

### Получить все категории
```http
GET /categories
```

**Ответ:**
```json
[
  {
    "_id": "68cd3d6247622f283828f49f",
    "name": "Стейки",
    "description": "Премиальные стейки из мраморной говядины",
    "isActive": true,
    "createdAt": "2025-09-19T11:23:38.123Z",
    "updatedAt": "2025-09-19T11:23:38.123Z"
  },
  {
    "_id": "68cd3d6a47622f283828f4a1",
    "name": "Пиво",
    "description": "Крафтовое пиво и закуски",
    "isActive": true,
    "createdAt": "2025-09-19T11:23:44.456Z",
    "updatedAt": "2025-09-19T11:23:44.456Z"
  },
  {
    "_id": "68cd3d7047622f283828f4a3",
    "name": "Пицца",
    "description": "Итальянская пицца",
    "isActive": true,
    "createdAt": "2025-09-19T11:23:50.789Z",
    "updatedAt": "2025-09-19T11:23:50.789Z"
  }
]
```

---

## 🏪 Рестораны

### Получить все рестораны
```http
GET /restaurants
```

**Ответ:**
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

### Получить рестораны по бренду
```http
GET /restaurants?brandId=68cd3d1d47622f283828f494
```

### Получить рестораны по городу
```http
GET /restaurants?cityId=68cd3da047622f283828f4a6
```

---

## 🍽️ Блюда

### Получить все блюда
```http
GET /dishes
```

**Ответ:**
```json
[
  {
    "_id": "68cd8a8c33f686eb1b56d87a",
    "name": "Рибай стейк",
    "description": "Премиальный стейк из мраморной говядины",
    "price": 3200,
    "imageURL": "https://bulladmin.ru/api/upload/uploads/file-1758302996529-58816949.jpeg",
    "preparationTime": 15,
    "calories": 650,
    "allergens": ["глютен"],
    "isAvailable": true,
    "categoryId": {
      "_id": "68cd3d6247622f283828f49f",
      "name": "Стейки",
      "description": "Премиальные стейки из мраморной говядины"
    },
    "restaurantId": {
      "_id": "68cd92fcef4e2d022348468e",
      "name": "THE БЫК на Тверской",
      "brandId": {
        "_id": "68cd3d1d47622f283828f494",
        "name": "The Бык"
      }
    },
    "createdAt": "2025-09-19T16:53:32.022Z",
    "updatedAt": "2025-09-19T17:30:12.756Z"
  }
]
```

### Получить блюда по ресторану
```http
GET /dishes?restaurantId=68cd92fcef4e2d022348468e
```

### Получить блюда по категории
```http
GET /dishes?categoryId=68cd3d6247622f283828f49f
```

---

## 📰 Новости

### Получить все новости
```http
GET /news
```

**Ответ:**
```json
[
  {
    "_id": "68cd944dcc05675b31f3261f",
    "title": "Новое меню в THE БЫК",
    "content": "Представляем новые блюда в нашем меню...",
    "author": "Шеф-повар",
    "imageURL": "https://bulladmin.ru/api/upload/uploads/file-1758303306377-535852281.jpg",
    "videoURL": "https://bulladmin.ru/api/upload/uploads/file-1758303297736-773836964.mp4",
    "category": "Новости",
    "tags": ["меню", "новинки"],
    "isPublished": true,
    "views": 1250,
    "likes": 89,
    "createdAt": "2025-09-19T17:35:09.054Z",
    "updatedAt": "2025-09-19T17:35:09.054Z"
  }
]
```

---

## 🛒 Заказы

### Создать заказ
```http
POST /orders
Content-Type: application/json

{
  "userId": "68cd3d3147622f283828f498",
  "restaurantId": "68cd92fcef4e2d022348468e",
  "items": [
    {
      "dishId": "68cd8a8c33f686eb1b56d87a",
      "quantity": 2,
      "price": 3200
    }
  ],
  "totalAmount": 6400,
  "deliveryAddress": "ул. Тверская, 15, кв. 10",
  "deliveryMethod": "delivery",
  "paymentMethod": "card",
  "specialInstructions": "Без лука"
}
```

### Получить заказы пользователя
```http
GET /orders?userId=68cd3d3147622f283828f498
```

---

## 📅 Бронирования

### Создать бронирование
```http
POST /reservations
Content-Type: application/json

{
  "userId": "68cd3d3147622f283828f498",
  "restaurantId": "68cd92fcef4e2d022348468e",
  "date": "2025-09-25",
  "time": "19:00",
  "guests": 4,
  "specialRequests": "Стол у окна"
}
```

### Получить бронирования пользователя
```http
GET /reservations?userId=68cd3d3147622f283828f498
```

---

## 📁 Загрузка файлов

### Загрузить файл
```http
POST /upload/upload
Content-Type: multipart/form-data

file: [файл]
```

**Ответ:**
```json
{
  "success": true,
  "message": "Файл успешно загружен",
  "data": {
    "filename": "file-1758302996529-58816949.jpeg",
    "originalName": "steak.jpg",
    "size": 1024000,
    "url": "https://bulladmin.ru/api/upload/uploads/file-1758302996529-58816949.jpeg"
  }
}
```

### Получить список файлов
```http
GET /upload/files
```

---

## 🔧 Настройки iOS приложения

### 1. Обновить модели данных

#### Restaurant.swift
```swift
struct Restaurant: Identifiable, Hashable, Codable {
    let id: String  // Изменить с UUID на String
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
    let brandId: String
    let cityId: String
    let createdAt: String
    let updatedAt: String
    
    // Добавить вычисляемые свойства
    var brand: Restaurant.Brand {
        // Маппинг по brandId
    }
    
    var city: String {
        // Получать из API по cityId
    }
}
```

#### Dish.swift
```swift
struct Dish: Identifiable, Codable {
    let id: String  // Изменить с UUID на String
    let name: String
    let description: String
    let price: Double
    let imageURL: String  // Изменить с image на imageURL
    let preparationTime: Int
    let calories: Int
    let allergens: [String]
    let isAvailable: Bool
    let categoryId: String
    let restaurantId: String
    let createdAt: String
    let updatedAt: String
}
```

### 2. Создать API Service

#### APIService.swift
```swift
import Foundation
import Combine

class APIService: ObservableObject {
    static let shared = APIService()
    private let baseURL = "https://bulladmin.ru/api"
    
    private init() {}
    
    // MARK: - Brands
    func fetchBrands() -> AnyPublisher<[Brand], Error> {
        guard let url = URL(string: "\(baseURL)/brands") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Brand].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Cities
    func fetchCities() -> AnyPublisher<[City], Error> {
        guard let url = URL(string: "\(baseURL)/cities") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [City].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Restaurants
    func fetchRestaurants() -> AnyPublisher<[Restaurant], Error> {
        guard let url = URL(string: "\(baseURL)/restaurants") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Restaurant].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Dishes
    func fetchDishes() -> AnyPublisher<[Dish], Error> {
        guard let url = URL(string: "\(baseURL)/dishes") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Dish].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - News
    func fetchNews() -> AnyPublisher<[NewsItem], Error> {
        guard let url = URL(string: "\(baseURL)/news") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [NewsItem].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Orders
    func createOrder(_ order: OrderRequest) -> AnyPublisher<Order, Error> {
        guard let url = URL(string: "\(baseURL)/orders") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(order)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: Order.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Reservations
    func createReservation(_ reservation: ReservationRequest) -> AnyPublisher<Reservation, Error> {
        guard let url = URL(string: "\(baseURL)/reservations") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(reservation)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: Reservation.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
```

### 3. Обновить ViewModels

#### RestaurantViewModel.swift
```swift
import Foundation
import Combine

@MainActor
class RestaurantViewModel: ObservableObject {
    @Published var restaurants: [Restaurant] = []
    @Published var brands: [Brand] = []
    @Published var cities: [City] = []
    @Published var loadingState: LoadingState = .idle
    @Published var error: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let apiService = APIService.shared
    
    init() {
        loadData()
    }
    
    func loadData() {
        loadingState = .loading
        
        // Загружаем все данные параллельно
        Publishers.Zip3(
            apiService.fetchBrands(),
            apiService.fetchCities(),
            apiService.fetchRestaurants()
        )
        .sink(
            receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                    self?.loadingState = .error
                }
            },
            receiveValue: { [weak self] brands, cities, restaurants in
                self?.brands = brands
                self?.cities = cities
                self?.restaurants = restaurants
                self?.loadingState = .loaded
            }
        )
        .store(in: &cancellables)
    }
    
    func getRestaurantsByBrand(_ brandId: String) -> [Restaurant] {
        return restaurants.filter { $0.brandId == brandId }
    }
    
    func getRestaurantsByCity(_ cityId: String) -> [Restaurant] {
        return restaurants.filter { $0.cityId == cityId }
    }
}
```

### 4. Обновить Views

#### RestaurantsView.swift
```swift
import SwiftUI

struct RestaurantsView: View {
    @StateObject private var viewModel = RestaurantViewModel()
    @State private var selectedBrand: Brand?
    @State private var selectedCity: City?
    
    var filteredRestaurants: [Restaurant] {
        var restaurants = viewModel.restaurants
        
        if let brand = selectedBrand {
            restaurants = restaurants.filter { $0.brandId == brand.id }
        }
        
        if let city = selectedCity {
            restaurants = restaurants.filter { $0.cityId == city.id }
        }
        
        return restaurants
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Фильтры
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        // Фильтр по брендам
                        ForEach(viewModel.brands) { brand in
                            Button(action: {
                                selectedBrand = selectedBrand?.id == brand.id ? nil : brand
                            }) {
                                Text(brand.name)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedBrand?.id == brand.id ? Color.blue : Color.gray.opacity(0.2))
                                    .foregroundColor(selectedBrand?.id == brand.id ? .white : .primary)
                                    .cornerRadius(20)
                            }
                        }
                        
                        // Фильтр по городам
                        ForEach(viewModel.cities) { city in
                            Button(action: {
                                selectedCity = selectedCity?.id == city.id ? nil : city
                            }) {
                                Text(city.name)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedCity?.id == city.id ? Color.green : Color.gray.opacity(0.2))
                                    .foregroundColor(selectedCity?.id == city.id ? .white : .primary)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Список ресторанов
                switch viewModel.loadingState {
                case .loading:
                    ProgressView("Загрузка ресторанов...")
                case .loaded:
                    List(filteredRestaurants) { restaurant in
                        RestaurantRowView(restaurant: restaurant)
                    }
                case .error:
                    VStack {
                        Text("Ошибка загрузки")
                            .foregroundColor(.red)
                        Button("Повторить") {
                            viewModel.loadData()
                        }
                    }
                case .idle:
                    EmptyView()
                }
            }
            .navigationTitle("Рестораны")
        }
    }
}
```

---

## 🚀 План интеграции

### Этап 1: Подготовка (1-2 дня)
1. ✅ Обновить модели данных iOS приложения
2. ✅ Создать APIService
3. ✅ Настроить JSON декодирование

### Этап 2: Базовая интеграция (2-3 дня)
1. 🔄 Интеграция ресторанов и блюд
2. 🔄 Интеграция новостей
3. 🔄 Интеграция брендов и городов

### Этап 3: Функциональность (3-4 дня)
1. ⏳ Система заказов
2. ⏳ Система бронирований
3. ⏳ Аутентификация пользователей

### Этап 4: Тестирование и оптимизация (1-2 дня)
1. ⏳ Тестирование всех функций
2. ⏳ Оптимизация производительности
3. ⏳ Обработка ошибок

---

## 📱 Готово к интеграции!

Backend API полностью готов и протестирован. Все endpoints работают корректно:

- ✅ **Бренды**: 3 бренда (The Бык, The Pivo, Mosca)
- ✅ **Города**: 4 города (Москва, СПб, Калуга, Ереван)
- ✅ **Категории**: 3 категории блюд
- ✅ **Рестораны**: с фото и видео
- ✅ **Блюда**: с изображениями и деталями
- ✅ **Новости**: с фото и видео
- ✅ **Файлы**: загрузка до 100MB

**Следующий шаг**: Начать интеграцию с iOS приложением! 🚀
