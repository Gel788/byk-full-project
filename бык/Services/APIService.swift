import Foundation
import Combine

// MARK: - API Models
struct RestaurantAPI: Codable, Identifiable {
    let id: String
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
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, description, address, phone, email
        case workingHours, rating, photos, videos, isActive
        case brandId, cityId, createdAt, updatedAt
    }
}

struct BrandInfo: Codable {
    let id: String
    let name: String
    let logo: String
    let color: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, logo, color
    }
}

struct CityInfo: Codable {
    let id: String
    let name: String
    let country: String
    let timezone: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, country, timezone
    }
}

struct BrandAPI: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let logo: String
    let color: String
    let isActive: Bool
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, description, logo, color, isActive
        case createdAt, updatedAt
    }
}

struct CityAPI: Codable, Identifiable {
    let id: String
    let name: String
    let country: String
    let timezone: String
    let isActive: Bool
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, country, timezone, isActive
        case createdAt, updatedAt
    }
}

// MARK: - User API Models
struct UserAPI: Codable, Identifiable {
    let id: String
    let phoneNumber: String
    let fullName: String
    let email: String?
    let avatar: String?
    let isVerified: Bool
    let followersCount: Int
    let followingCount: Int
    let postsCount: Int
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case phoneNumber, fullName, email, avatar, isVerified
        case followersCount, followingCount, postsCount
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

// MARK: - API Service
class APIService: ObservableObject {
    static let shared = APIService()
    
    let baseURL = "https://bulladmin.ru/api"
    private let session = URLSession.shared
    
    private init() {}
    
    // MARK: - Generic Request Method
    private func request<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        body: Data? = nil
    ) -> AnyPublisher<T, Error> {
        
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            return Fail(error: APIError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Добавляем токен авторизации если есть
        if let accessToken = AuthService.shared.accessToken {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = body
        }
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Restaurants
    func fetchRestaurants() -> AnyPublisher<[RestaurantAPI], Error> {
        return request<[RestaurantAPI]>(endpoint: "/restaurants", method: .GET, body: nil)
    }
    
    func fetchRestaurant(id: String) -> AnyPublisher<RestaurantAPI, Error> {
        return request<RestaurantAPI>(endpoint: "/restaurants/\(id)", method: .GET, body: nil)
    }
    
    func fetchRestaurantsByBrand(brandId: String) -> AnyPublisher<[RestaurantAPI], Error> {
        return request<[RestaurantAPI]>(endpoint: "/restaurants?brandId=\(brandId)", method: .GET, body: nil)
    }
    
    func fetchRestaurantsByCity(cityId: String) -> AnyPublisher<[RestaurantAPI], Error> {
        return request<[RestaurantAPI]>(endpoint: "/restaurants?cityId=\(cityId)", method: .GET, body: nil)
    }
    
    // MARK: - Brands
    func fetchBrands() -> AnyPublisher<[BrandAPI], Error> {
        return request<[BrandAPI]>(endpoint: "/brands", method: .GET, body: nil)
    }
    
    func fetchBrand(id: String) -> AnyPublisher<BrandAPI, Error> {
        return request<BrandAPI>(endpoint: "/brands/\(id)", method: .GET, body: nil)
    }
    
    // MARK: - Cities
    func fetchCities() -> AnyPublisher<[CityAPI], Error> {
        return request<[CityAPI]>(endpoint: "/cities", method: .GET, body: nil)
    }
    
    func fetchCity(id: String) -> AnyPublisher<CityAPI, Error> {
        return request<CityAPI>(endpoint: "/cities/\(id)", method: .GET, body: nil)
    }
    
    // MARK: - Categories
    func fetchCategories() -> AnyPublisher<[CategoryAPI], Error> {
        return request<[CategoryAPI]>(endpoint: "/categories", method: .GET, body: nil)
    }
    
    func fetchCategoriesByBrand(brandId: String) -> AnyPublisher<[CategoryAPI], Error> {
        return request<[CategoryAPI]>(endpoint: "/categories/brand/\(brandId)", method: .GET, body: nil)
    }
    
    func createCategory(_ category: CategoryAPI) -> AnyPublisher<CategoryAPI, Error> {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(category) else {
            return Fail(error: APIError.encodingError)
                .eraseToAnyPublisher()
        }
        return request<CategoryAPI>(endpoint: "/categories", method: .POST, body: data)
    }
    
    func updateCategory(_ category: CategoryAPI) -> AnyPublisher<CategoryAPI, Error> {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(category) else {
            return Fail(error: APIError.encodingError)
                .eraseToAnyPublisher()
        }
        return request<CategoryAPI>(endpoint: "/categories/\(category.id)", method: .PUT, body: data)
    }
    
    func deleteCategory(id: String) -> AnyPublisher<[String: String], Error> {
        return request<[String: String]>(endpoint: "/categories/\(id)", method: .DELETE, body: nil)
    }
    
    // MARK: - Dishes
    func fetchDishes() -> AnyPublisher<[DishAPI], Error> {
        return request<[DishAPI]>(endpoint: "/dishes", method: .GET, body: nil)
    }
    
    func fetchDishesByRestaurant(restaurantId: String) -> AnyPublisher<[DishAPI], Error> {
        return request<[DishAPI]>(endpoint: "/dishes?restaurantId=\(restaurantId)", method: .GET, body: nil)
    }
    
    func fetchDishesByCategory(categoryId: String) -> AnyPublisher<[DishAPI], Error> {
        return request<[DishAPI]>(endpoint: "/dishes?categoryId=\(categoryId)", method: .GET, body: nil)
    }
    
    func createDish(_ dish: DishAPI) -> AnyPublisher<DishAPI, Error> {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(dish) else {
            return Fail(error: APIError.encodingError)
                .eraseToAnyPublisher()
        }
        return request<DishAPI>(endpoint: "/dishes", method: .POST, body: data)
    }
    
    func updateDish(_ dish: DishAPI) -> AnyPublisher<DishAPI, Error> {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(dish) else {
            return Fail(error: APIError.encodingError)
                .eraseToAnyPublisher()
        }
        return request<DishAPI>(endpoint: "/dishes/\(dish.id)", method: .PUT, body: data)
    }
    
    func deleteDish(id: String) -> AnyPublisher<[String: String], Error> {
        return request<[String: String]>(endpoint: "/dishes/\(id)", method: .DELETE, body: nil)
    }
    
    // MARK: - News
    func fetchNews() -> AnyPublisher<[NewsAPI], Error> {
        return request<[NewsAPI]>(endpoint: "/news", method: .GET, body: nil)
    }
    
    // MARK: - Orders
    func fetchUserOrders(userId: String) -> AnyPublisher<[OrderAPI], Error> {
        return request<[OrderAPI]>(endpoint: "/orders/user/\(userId)", method: .GET, body: nil)
    }
    
    func createOrder(_ order: OrderAPI) -> AnyPublisher<OrderAPI, Error> {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(order) else {
            return Fail(error: APIError.encodingError)
                .eraseToAnyPublisher()
        }
        return request<OrderAPI>(endpoint: "/orders", method: .POST, body: data)
    }
    
    // MARK: - Reservations
    func fetchUserReservations(userId: String) -> AnyPublisher<ReservationsListResponse, Error> {
        return request<ReservationsListResponse>(endpoint: "/reservations/my?userId=\(userId)", method: .GET, body: nil)
    }
    
    func createReservation(_ reservationRequest: CreateReservationRequest) -> AnyPublisher<CreateReservationResponse, Error> {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(reservationRequest) else {
            return Fail(error: APIError.encodingError)
                .eraseToAnyPublisher()
        }
        return request<CreateReservationResponse>(endpoint: "/reservations", method: .POST, body: data)
    }
    
    func updateReservation(id: String, _ updateRequest: UpdateReservationRequest) -> AnyPublisher<UpdateReservationResponse, Error> {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(updateRequest) else {
            return Fail(error: APIError.encodingError)
                .eraseToAnyPublisher()
        }
        return request<UpdateReservationResponse>(endpoint: "/reservations/\(id)", method: .PUT, body: data)
    }
    
    func cancelReservation(id: String, _ cancelRequest: CancelReservationRequest) -> AnyPublisher<CancelReservationResponse, Error> {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(cancelRequest) else {
            return Fail(error: APIError.encodingError)
                .eraseToAnyPublisher()
        }
        return request<CancelReservationResponse>(endpoint: "/reservations/\(id)/cancel", method: .PUT, body: data)
    }
    
    func fetchAvailableTables(restaurantId: String, date: String) -> AnyPublisher<AvailableTablesResponse, Error> {
        return request<AvailableTablesResponse>(endpoint: "/reservations/available-tables/\(restaurantId)?date=\(date)", method: .GET, body: nil)
    }
    
    // MARK: - Authentication
    func register(_ registerRequest: RegisterRequest) -> AnyPublisher<AuthResponse, Error> {
        // Отправляем данные на сервер через /auth/register API
        let registerData: [String: Any] = [
            "phoneNumber": registerRequest.phoneNumber,
            "password": registerRequest.password,
            "fullName": registerRequest.fullName,
            "email": registerRequest.email
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: registerData) else {
            return Fail(error: APIError.encodingError)
                .eraseToAnyPublisher()
        }
        
        guard let url = URL(string: "\(baseURL)/auth/register") else {
            return Fail(error: APIError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: AuthResponse.self, decoder: JSONDecoder())
            .map { response in
                print("APIService: Регистрация на сервере - \(registerRequest.fullName), \(registerRequest.phoneNumber)")
                return response
            }
            .mapError { error in
                print("APIService: Ошибка регистрации - \(error)")
                return APIError.networkError(error)
            }
            .eraseToAnyPublisher()
    }
    
    func login(_ loginRequest: LoginRequest) -> AnyPublisher<AuthResponse, Error> {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(loginRequest) else {
            return Fail(error: APIError.encodingError)
                .eraseToAnyPublisher()
        }
        return request<AuthResponse>(endpoint: "/auth/login", method: .POST, body: data)
    }
    
    func logout(_ logoutRequest: LogoutRequest) -> AnyPublisher<AuthResponse, Error> {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(logoutRequest) else {
            return Fail(error: APIError.encodingError)
                .eraseToAnyPublisher()
        }
        return request<AuthResponse>(endpoint: "/auth/logout", method: .POST, body: data)
    }
    
    func refreshToken(_ refreshToken: String) -> AnyPublisher<AuthResponse, Error> {
        let body = ["refreshToken": refreshToken]
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(body) else {
            return Fail(error: APIError.encodingError)
                .eraseToAnyPublisher()
        }
        return request<AuthResponse>(endpoint: "/auth/refresh", method: .POST, body: data)
    }
    
    func getProfile(token: String) -> AnyPublisher<UserAPI, Error> {
        var request = URLRequest(url: URL(string: "\(baseURL)/auth/profile")!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: UserAPI.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func updateProfile(token: String, user: UserAPI) -> AnyPublisher<UserAPI, Error> {
        var request = URLRequest(url: URL(string: "\(baseURL)/auth/profile")!)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(user) else {
            return Fail(error: APIError.encodingError)
                .eraseToAnyPublisher()
        }
        request.httpBody = data
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: UserAPI.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

// MARK: - Supporting Types
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case encodingError
    case decodingError
    case networkError(Error)
    case serverError(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Неверный URL"
        case .encodingError:
            return "Ошибка кодирования данных"
        case .decodingError:
            return "Ошибка декодирования данных"
        case .networkError(let error):
            return "Ошибка сети: \(error.localizedDescription)"
        case .serverError(let code):
            return "Ошибка сервера: \(code)"
        }
    }
}

// MARK: - Additional API Models
struct CategoryAPI: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let isActive: Bool
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, description, isActive
        case createdAt, updatedAt
    }
}

struct DishAPI: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let price: Double
    let imageURL: String?
    let categoryId: CategoryInfo?
    let restaurantId: RestaurantInfo?
    let preparationTime: Int?
    let calories: Int?
    let allergens: [String]?
    let isAvailable: Bool
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, description, price
        case imageURL = "imageURL"
        case categoryId, restaurantId
        case preparationTime, calories, allergens
        case isAvailable
        case createdAt, updatedAt
    }
}

struct CategoryInfo: Codable {
    let id: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
    }
}

struct RestaurantInfo: Codable {
    let id: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
    }
}

struct NewsAPI: Codable, Identifiable {
    let id: String
    let title: String
    let content: String
    let imageURL: String?
    let videoURL: String?
    let author: String?
    let category: String?
    let tags: [String]?
    let isPublished: Bool?
    let views: Int?
    let likes: Int?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title, content, imageURL, videoURL, author, category, tags
        case isPublished, views, likes
        case createdAt, updatedAt
    }
}

struct OrderAPI: Codable, Identifiable {
    let id: String
    let userId: String
    let userName: String
    let dishes: [OrderItemAPI]
    let totalAmount: Double
    let status: String
    let deliveryMethod: String
    let pickupRestaurantId: String?
    let paymentMethod: String
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId, userName, dishes, totalAmount, status
        case deliveryMethod, pickupRestaurantId, paymentMethod
        case createdAt, updatedAt
    }
}

struct OrderItemAPI: Codable {
    let id: String
    let dishName: String
    let quantity: Int
    let price: Double
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case dishName, quantity, price
    }
}

struct ReservationAPI: Codable, Identifiable {
    let id: String
    let userId: String
    let userName: String
    let restaurantId: String
    let restaurantName: String
    let date: String
    let guests: Int
    let tableNumber: String
    let specialRequests: String?
    let status: String
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId, userName, restaurantId, restaurantName
        case date, guests, tableNumber, specialRequests, status
        case createdAt, updatedAt
    }
}
