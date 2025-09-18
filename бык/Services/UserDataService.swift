import Foundation
import SwiftUI

class UserDataService: ObservableObject {
    @Published var userOrders: [UserOrder] = []
    @Published var userReservations: [UserReservation] = []
    @Published var isLoading: Bool = false
    
    private var authService: AuthService?
    
    init() {
        generateTestData()
    }
    
    func setAuthService(_ authService: AuthService) {
        self.authService = authService
    }
    
    private func generateTestData() {
        // Генерируем тестовые заказы
        userOrders = [
            UserOrder(
                orderNumber: "BY-2024-001",
                restaurantName: "The Бык",
                items: [
                    OrderItem(dishName: "Стейк Рибай", quantity: 1, price: 2500, image: "ribai_steak"),
                    OrderItem(dishName: "Цезарь салат", quantity: 2, price: 450, image: "caesar_salad")
                ],
                totalAmount: 3400,
                orderDate: Date().addingTimeInterval(-3600),
                status: OrderStatus.delivered,
                deliveryAddress: "ул. Тверская, 15, кв. 42",
                estimatedDeliveryTime: Date().addingTimeInterval(-1800)
            ),
            UserOrder(
                orderNumber: "BY-2024-002",
                restaurantName: "The Бык",
                items: [
                    OrderItem(dishName: "Пицца Маргарита", quantity: 1, price: 800, image: "pizza_margherita"),
                    OrderItem(dishName: "Паста Карбонара", quantity: 1, price: 650, image: "pasta_carbonara")
                ],
                totalAmount: 1650,
                orderDate: Date().addingTimeInterval(-86400),
                status: OrderStatus.delivered,
                deliveryAddress: "Ленинский пр-т, 45, кв. 12",
                estimatedDeliveryTime: Date().addingTimeInterval(-86400)
            ),
            UserOrder(
                orderNumber: "BY-2024-003",
                restaurantName: "Mosca",
                items: [
                    OrderItem(dishName: "Сосиски с горчицей", quantity: 2, price: 350, image: "sausages"),
                    OrderItem(dishName: "Крендель", quantity: 3, price: 120, image: "pretzel")
                ],
                totalAmount: 1260,
                orderDate: Date().addingTimeInterval(-172800),
                status: OrderStatus.cancelled,
                deliveryAddress: "ул. Арбат, 8, кв. 7",
                estimatedDeliveryTime: Date().addingTimeInterval(-172800)
            ),
            UserOrder(
                orderNumber: "BY-2024-004",
                restaurantName: "The Pivo",
                items: [
                    OrderItem(dishName: "Бургер Классик", quantity: 1, price: 1200, image: "ribai_steak"),
                    OrderItem(dishName: "Картофель фри", quantity: 1, price: 300, image: "caesar_salad")
                ],
                totalAmount: 1500,
                orderDate: Date().addingTimeInterval(-259200),
                status: OrderStatus.delivered,
                deliveryAddress: "Кутузовский пр-т, 12, кв. 25",
                estimatedDeliveryTime: Date().addingTimeInterval(-259200)
            ),
            UserOrder(
                orderNumber: "BY-2024-005",
                restaurantName: "The Бык",
                items: [
                    OrderItem(dishName: "Стейк Рибай", quantity: 2, price: 2500, image: "ribai_steak"),
                    OrderItem(dishName: "Вино красное", quantity: 1, price: 800, image: "pizza_margherita")
                ],
                totalAmount: 5800,
                orderDate: Date().addingTimeInterval(-345600),
                status: OrderStatus.delivered,
                deliveryAddress: "Новый Арбат, 32, кв. 8",
                estimatedDeliveryTime: Date().addingTimeInterval(-345600)
            )
        ]
        
        // Генерируем тестовые бронирования
        userReservations = [
            UserReservation(
                reservationNumber: "BR-2024-001",
                restaurantName: "The Бык",
                date: Date().addingTimeInterval(86400), // Завтра
                time: "19:00",
                guests: 4,
                status: .confirmed,
                specialRequests: "Стол у окна"
            ),
            UserReservation(
                reservationNumber: "BR-2024-002",
                restaurantName: "Mosca",
                date: Date().addingTimeInterval(172800), // Послезавтра
                time: "20:30",
                guests: 2,
                status: .pending,
                specialRequests: nil
            ),
            UserReservation(
                reservationNumber: "BR-2024-003",
                restaurantName: "The Pivo",
                date: Date().addingTimeInterval(-86400), // Вчера
                time: "18:00",
                guests: 6,
                status: .completed,
                specialRequests: "День рождения"
            ),
            UserReservation(
                reservationNumber: "BR-2024-004",
                restaurantName: "The Бык",
                date: Date().addingTimeInterval(-172800), // Позавчера
                time: "21:00",
                guests: 3,
                status: .cancelled,
                specialRequests: nil
            )
        ]
    }
    
    // MARK: - Order Methods
    
    func getRecentOrders(limit: Int = 5) -> [UserOrder] {
        return Array(userOrders.prefix(limit))
    }
    
    func getOrdersByStatus(_ status: OrderStatus) -> [UserOrder] {
        return userOrders.filter { $0.status == status }
    }
    
    func getOrderStats() -> (total: Int, delivered: Int, pending: Int, cancelled: Int) {
        let total = userOrders.count
        let delivered = userOrders.filter { $0.status == OrderStatus.delivered }.count
        let pending = userOrders.filter { [OrderStatus.pending, .confirmed, .preparing, .ready, .delivering].contains($0.status) }.count
        let cancelled = userOrders.filter { $0.status == OrderStatus.cancelled }.count
        
        return (total, delivered, pending, cancelled)
    }
    
    func repeatOrder(_ order: UserOrder) {
        // Логика повторения заказа
        print("Повторяем заказ: \(order.orderNumber)")
    }
    
    // MARK: - Reservation Methods
    
    func getActiveReservations() -> [UserReservation] {
        return userReservations.filter { $0.status == .confirmed || $0.status == .pending }
    }
    
    func getCompletedReservations() -> [UserReservation] {
        return userReservations.filter { $0.status == .completed }
    }
    
    func cancelReservation(_ reservation: UserReservation) {
        if let index = userReservations.firstIndex(where: { $0.id == reservation.id }) {
            userReservations[index] = UserReservation(
                reservationNumber: reservation.reservationNumber,
                restaurantName: reservation.restaurantName,
                date: reservation.date,
                time: reservation.time,
                guests: reservation.guests,
                status: .cancelled,
                specialRequests: reservation.specialRequests
            )
        }
    }
    
    func getReservationStats() -> (active: Int, completed: Int, cancelled: Int) {
        let active = userReservations.filter { $0.status == .confirmed || $0.status == .pending }.count
        let completed = userReservations.filter { $0.status == .completed }.count
        let cancelled = userReservations.filter { $0.status == .cancelled }.count
        
        return (active, completed, cancelled)
    }
    
    // MARK: - Loyalty Methods
    
    func getLoyaltyProgress() -> (current: Int, next: Int, progress: Double) {
        let current = 2450 // Текущие баллы
        let next = 3000 // Следующий уровень
        let progress = Double(current) / Double(next)
        
        return (current, next, progress)
    }
    
    func getNextReward() -> String {
        return "Скидка 15% на следующий заказ"
    }
    
    // MARK: - User Methods
    
    func getCurrentUser() -> User {
        // Сначала пробуем получить из связанного authService
        if let authService = authService, let currentUser = authService.getCurrentUser() {
            print("UserDataService: Получены данные из связанного AuthService - \(currentUser.fullName)")
            return currentUser
        }
        
        // Если authService не установлен, пробуем AuthService.shared
        if let currentUser = AuthService.shared.getCurrentUser() {
            print("UserDataService: Получены данные из AuthService.shared - \(currentUser.fullName)")
            return currentUser
        }
        
        // В крайнем случае возвращаем тестовые данные (только для разработки)
        print("UserDataService: Используются тестовые данные - пользователь не авторизован")
        return User(
            username: "guest",
            fullName: "Гость",
            email: "guest@email.com"
        )
    }
    
    // MARK: - Profile Update Methods
    
    func updateUserProfile(name: String, email: String, phone: String) {
        // Получаем текущего пользователя
        guard let currentUser = authService?.getCurrentUser() ?? AuthService.shared.getCurrentUser() else {
            print("Ошибка: пользователь не авторизован")
            return
        }
        
        // Создаем обновленного пользователя
        let updatedUser = User(
            username: currentUser.username,
            fullName: name,
            email: email
        )
        
        // Обновляем в AuthService
        if let authService = authService {
            authService.updateCurrentUser(updatedUser)
        } else {
            AuthService.shared.updateCurrentUser(updatedUser)
        }
        
        print("Профиль обновлен: имя=\(name), email=\(email), телефон=\(phone)")
    }
    
    func updateUserPreferences(notifications: Bool, marketing: Bool, location: Bool) {
        // Обновление настроек пользователя
        print("Обновляем настройки: уведомления=\(notifications), маркетинг=\(marketing), геолокация=\(location)")
        // TODO: Сохранение в UserDefaults или API
    }
} 