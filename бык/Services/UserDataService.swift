import Foundation
import SwiftUI

class UserDataService: ObservableObject {
    @Published var userOrders: [UserOrder] = []
    @Published var userReservations: [UserReservation] = []
    @Published var isLoading: Bool = false
    
    init() {
        generateTestData()
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
        // Если есть авторизованный пользователь, возвращаем его
        let authService = AuthService.shared
        if let currentUser = authService.getCurrentUser() {
            return currentUser
        }
        
        // Иначе возвращаем тестовые данные
        return User(
            username: "alex_petrov",
            fullName: "Александр Петров",
            email: "alex.petrov@email.com"
        )
    }
} 