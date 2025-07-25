import Foundation

struct User: Identifiable, Codable, Hashable {
    let id: UUID
    let username: String
    let fullName: String
    let avatar: String?
    let email: String
    let isVerified: Bool
    let followersCount: Int
    let followingCount: Int
    let postsCount: Int
    let createdAt: Date
    
    init(
        id: UUID = UUID(),
        username: String,
        fullName: String,
        avatar: String? = nil,
        email: String,
        isVerified: Bool = false,
        followersCount: Int = 0,
        followingCount: Int = 0,
        postsCount: Int = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.username = username
        self.fullName = fullName
        self.avatar = avatar
        self.email = email
        self.isVerified = isVerified
        self.followersCount = followersCount
        self.followingCount = followingCount
        self.postsCount = postsCount
        self.createdAt = createdAt
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
    
    // MARK: - Mock Data
    static let mock = User(
        username: "foodlover",
        fullName: "Алексей Петров",
        avatar: nil,
        email: "alex@example.com",
        isVerified: true,
        followersCount: 1250,
        followingCount: 340,
        postsCount: 45
    )
}

enum MembershipLevel: String, CaseIterable, Codable {
    case bronze = "Бронза"
    case silver = "Серебро"
    case gold = "Золото"
    case platinum = "Платина"
    
    static func random() -> MembershipLevel {
        let levels: [MembershipLevel] = [.bronze, .silver, .gold, .platinum]
        return levels.randomElement() ?? .bronze
    }
    
    var color: String {
        switch self {
        case .bronze: return "Bronze"
        case .silver: return "Silver"
        case .gold: return "Gold"
        case .platinum: return "Platinum"
        }
    }
    
    var icon: String {
        switch self {
        case .bronze: return "medal"
        case .silver: return "medal.fill"
        case .gold: return "crown"
        case .platinum: return "crown.fill"
        }
    }
}

struct AuthCredentials {
    let phoneNumber: String
    let password: String
}

struct RegistrationData {
    let phoneNumber: String
    let password: String
    let name: String
    let email: String?
}

// Модели для заказов
struct UserOrder: Identifiable, Codable {
    let id: String
    let orderNumber: String
    let restaurantName: String
    let items: [OrderItem]
    let totalAmount: Double
    let orderDate: Date
    let status: OrderStatus
    let deliveryAddress: String?
    let estimatedDeliveryTime: Date?
    
    init(orderNumber: String, restaurantName: String, items: [OrderItem], totalAmount: Double, orderDate: Date, status: OrderStatus, deliveryAddress: String? = nil, estimatedDeliveryTime: Date? = nil) {
        self.id = UUID().uuidString
        self.orderNumber = orderNumber
        self.restaurantName = restaurantName
        self.items = items
        self.totalAmount = totalAmount
        self.orderDate = orderDate
        self.status = status
        self.deliveryAddress = deliveryAddress
        self.estimatedDeliveryTime = estimatedDeliveryTime
    }
}

struct OrderItem: Identifiable, Codable {
    let id: String
    let dishName: String
    let quantity: Int
    let price: Double
    let image: String
    
    init(dishName: String, quantity: Int, price: Double, image: String) {
        self.id = UUID().uuidString
        self.dishName = dishName
        self.quantity = quantity
        self.price = price
        self.image = image
    }
}

enum OrderStatus: String, CaseIterable, Codable {
    case pending = "Ожидает подтверждения"
    case confirmed = "Подтвержден"
    case preparing = "Готовится"
    case ready = "Готов"
    case delivering = "Доставляется"
    case delivered = "Доставлен"
    case cancelled = "Отменен"
    
    var color: String {
        switch self {
        case .pending: return "Orange"
        case .confirmed: return "Blue"
        case .preparing: return "Purple"
        case .ready: return "Yellow"
        case .delivering: return "Green"
        case .delivered: return "Green"
        case .cancelled: return "Red"
        }
    }
    
    var icon: String {
        switch self {
        case .pending: return "clock"
        case .confirmed: return "checkmark.circle"
        case .preparing: return "flame"
        case .ready: return "checkmark.circle.fill"
        case .delivering: return "bicycle"
        case .delivered: return "checkmark.shield"
        case .cancelled: return "xmark.circle"
        }
    }
}

// Модели для бронирований
struct UserReservation: Identifiable, Codable {
    let id: String
    let reservationNumber: String
    let restaurantName: String
    let date: Date
    let time: String
    let guests: Int
    let status: ReservationStatus
    let specialRequests: String?
    
    init(reservationNumber: String, restaurantName: String, date: Date, time: String, guests: Int, status: ReservationStatus, specialRequests: String? = nil) {
        self.id = UUID().uuidString
        self.reservationNumber = reservationNumber
        self.restaurantName = restaurantName
        self.date = date
        self.time = time
        self.guests = guests
        self.status = status
        self.specialRequests = specialRequests
    }
}

enum ReservationStatus: String, CaseIterable, Codable {
    case confirmed = "Подтверждено"
    case pending = "Ожидает подтверждения"
    case cancelled = "Отменено"
    case completed = "Завершено"
    
    var color: String {
        switch self {
        case .confirmed: return "Green"
        case .pending: return "Orange"
        case .cancelled: return "Red"
        case .completed: return "Blue"
        }
    }
    
    var icon: String {
        switch self {
        case .confirmed: return "checkmark.circle.fill"
        case .pending: return "clock"
        case .cancelled: return "xmark.circle"
        case .completed: return "checkmark.shield"
        }
    }
} 