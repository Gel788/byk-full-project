import Foundation
import SwiftUI

// MARK: - Restaurant Adapters
extension RestaurantAPI {
    func toLocalRestaurant() -> Restaurant {
        let brand = Restaurant.Brand(rawValue: brandId.name) ?? .theByk
        
        return Restaurant(
            name: name,
            description: description,
            address: address,
            city: cityId.name,
            imageURL: photos.first ?? "",
            rating: rating,
            cuisine: "Стейк-хаус", // По умолчанию
            deliveryTime: 45, // По умолчанию
            brand: brand,
            menu: [], // Будет загружено отдельно
            features: [], // По умолчанию
            workingHours: WorkingHours(
                openTime: workingHours.isEmpty ? "10:00" : workingHours.components(separatedBy: " - ").first ?? "10:00",
                closeTime: workingHours.isEmpty ? "23:00" : workingHours.components(separatedBy: " - ").last ?? "23:00",
                weekdays: Set(WorkingHours.Weekday.allCases)
            ),
            location: Location(latitude: 55.7558, longitude: 37.6173), // По умолчанию для Москвы
            tables: [], // Будет загружено отдельно
            gallery: photos.map { GalleryImage(imageURL: $0, description: "") }
        )
    }
}

// MARK: - Brand Adapters
extension BrandAPI {
    func toLocalBrand() -> Restaurant.Brand {
        switch name.lowercased() {
        case "the бык":
            return .theByk
        case "the pivo":
            return .thePivo
        case "mosca":
            return .mosca
        case "the грузия":
            return .theGeorgia
        default:
            return .theByk
        }
    }
}

// MARK: - User API Adapters
extension UserAPI {
    func toLocalUser() -> User {
        return User(
            id: UUID(uuidString: id) ?? UUID(),
            username: phoneNumber,
            fullName: fullName,
            avatar: avatar ?? "",
            email: email ?? "",
            isVerified: isVerified ?? false,
            followersCount: followersCount ?? 0,
            followingCount: followingCount ?? 0,
            postsCount: postsCount ?? 0,
            createdAt: DateFormatter.iso8601.date(from: createdAt ?? "") ?? Date()
        )
    }
}

// MARK: - City Adapters
extension CityAPI {
    func toLocalCity() -> String {
        return name
    }
}

// MARK: - Category Adapters
extension CategoryAPI {
    func toLocalCategory() -> String {
        return name
    }
}

// MARK: - Dish Adapters
extension DishAPI {
    func toLocalDish() -> Dish {
        print("DishAPI: Конвертируем блюдо:")
        print("  - API ID: \(id)")
        print("  - Название: \(name)")
        
        let restaurantBrand = restaurantId?.name ?? "THE БЫК"
        let brand: Restaurant.Brand
        
        switch restaurantBrand.lowercased() {
        case "the бык":
            brand = .theByk
        case "the pivo":
            brand = .thePivo
        case "mosca":
            brand = .mosca
        case "the грузия":
            brand = .theGeorgia
        default:
            brand = .theByk
        }
        
        // Конвертируем String ID в UUID
        let dishUUID: UUID
        if let uuid = UUID(uuidString: id) {
            dishUUID = uuid
        } else {
            // Если не удается создать UUID из строки, создаем новый
            dishUUID = UUID()
            print("DishAPI: Не удалось создать UUID из строки '\(id)', создан новый UUID: \(dishUUID)")
        }
        
        let result = Dish(
            id: dishUUID,
            name: name,
            description: description,
            price: price,
            image: imageURL ?? "",
            category: categoryId?.name ?? "Без категории",
            restaurantBrand: brand,
            isAvailable: isAvailable,
            preparationTime: preparationTime ?? 20,
            calories: calories ?? 0,
            allergens: allergens ?? []
        )
        
        print("DishAPI: Результат конвертации:")
        print("  - Локальный UUID: \(result.id)")
        print("  - Название: \(result.name)")
        
        return result
    }
}

// MARK: - Category Adapters
extension CategoryAPI {
    func toLocalCategory() -> DishCategory {
        switch name.lowercased() {
        case "закуски":
            return .starters
        case "супы":
            return .soups
        case "салаты":
            return .salads
        case "основные блюда":
            return .mainCourse
        case "стейки":
            return .steaks
        case "морепродукты":
            return .seafood
        case "паста":
            return .pasta
        case "пицца":
            return .pizza
        case "гарниры":
            return .sides
        case "десерты":
            return .desserts
        case "напитки":
            return .drinks
        case "алкоголь":
            return .alcohol
        default:
            return .mainCourse
        }
    }
}

// MARK: - News Adapters
extension NewsAPI {
    func toLocalNews() -> NewsItem {
        return NewsItem(
            id: UUID(uuidString: id) ?? UUID(),
            title: title,
            description: content,
            image: imageURL ?? "",
            videoURL: videoURL,
            date: DateFormatter.iso8601.date(from: createdAt) ?? Date(),
            brand: .theByk, // По умолчанию
            type: NewsType.fromString(category ?? "news"),
            likes: likes ?? 0,
            isLiked: false,
            comments: [],
            isRead: false,
            views: views ?? 0
        )
    }
}

// MARK: - Order Adapters
extension OrderAPI {
    func toLocalOrder() -> DeliveryOrder {
        let items = dishes.map { item in
            DeliveryOrderItem(
                dish: Dish(
                    name: item.dishName,
                    description: "",
                    price: item.price,
                    image: "",
                    category: "",
                    restaurantBrand: .theByk
                ),
                quantity: item.quantity,
                price: item.price
            )
        }
        
        let brand: Restaurant.Brand
        switch deliveryMethod.lowercased() {
        case "delivery":
            brand = .theByk // По умолчанию
        case "pickup":
            brand = .theByk
        default:
            brand = .theByk
        }
        
        return DeliveryOrder(
            orderNumber: id,
            items: items,
            totalAmount: totalAmount,
            deliveryAddress: "", // Нет в API
            deliveryTime: DateFormatter.iso8601.date(from: createdAt) ?? Date(),
            orderDate: DateFormatter.iso8601.date(from: createdAt) ?? Date(),
            status: DeliveryOrderStatus.fromString(status),
            restaurantBrand: brand,
            deliveryFee: 0,
            paymentMethod: DeliveryPaymentMethod.fromString(paymentMethod)
        )
    }
}

// MARK: - Reservation Adapters
extension ReservationAPI {
    func toLocalReservation() -> Reservation {
        // Создаем объект ресторана из данных API
        let restaurant = Restaurant(
            id: UUID(uuidString: restaurantId) ?? UUID(),
            name: restaurantName ?? "Ресторан",
            description: "", // Нет в API
            address: "", // Нет в API
            city: "", // Нет в API
            imageURL: "", // Нет в API
            rating: 0, // Нет в API
            cuisine: "", // Нет в API
            deliveryTime: 0, // Нет в API
            brand: .theByk, // По умолчанию
            menu: [], // Нет в API
            features: [], // Нет в API
            workingHours: WorkingHours.default,
            location: Location(latitude: 0, longitude: 0), // Нет в API
            tables: [] // Нет в API
        )
        
        return Reservation(
            restaurant: restaurant,
            date: DateFormatter.iso8601.date(from: date) ?? Date(),
            guestCount: guests,
            status: Reservation.Status.fromString(status),
            tableNumber: Int(tableNumber) ?? 1,
            specialRequests: specialRequests,
            createdAt: DateFormatter.iso8601.date(from: createdAt) ?? Date()
        )
    }
}

// MARK: - Supporting Extensions
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension DateFormatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter
    }()
}

// MARK: - Enum Extensions
extension DeliveryOrderStatus {
    static func fromString(_ status: String) -> DeliveryOrderStatus {
        switch status.lowercased() {
        case "pending":
            return .pending
        case "confirmed":
            return .confirmed
        case "preparing":
            return .preparing
        case "ready":
            return .ready
        case "delivering":
            return .delivering
        case "delivered":
            return .delivered
        case "cancelled":
            return .cancelled
        default:
            return .pending
        }
    }
}

extension DeliveryPaymentMethod {
    static func fromString(_ method: String) -> DeliveryPaymentMethod {
        switch method.lowercased() {
        case "card":
            return .card
        case "cash":
            return .cash
        case "online":
            return .online
        default:
            return .card
        }
    }
}

extension Reservation.Status {
    static func fromString(_ status: String) -> Reservation.Status {
        switch status.lowercased() {
        case "pending":
            return .pending
        case "confirmed":
            return .confirmed
        case "completed":
            return .completed
        case "cancelled":
            return .cancelled
        default:
            return .pending
        }
    }
}

// MARK: - Reservation API Extensions
extension ReservationResponse {
    func toLocalReservation() -> Reservation {
        let dateFormatter = ISO8601DateFormatter()
        let date = dateFormatter.date(from: self.date) ?? Date()
        
        // Создаем объект ресторана из данных API
        let restaurant = Restaurant(
            id: UUID(uuidString: restaurantId) ?? UUID(),
            name: restaurantName,
            description: "", // Нет в API
            address: "", // Нет в API
            city: "", // Нет в API
            imageURL: "", // Нет в API
            rating: 0, // Нет в API
            cuisine: "", // Нет в API
            deliveryTime: 0, // Нет в API
            brand: .theByk, // По умолчанию
            menu: [], // Нет в API
            features: [], // Нет в API
            workingHours: WorkingHours.default,
            location: Location(latitude: 0, longitude: 0), // Нет в API
            tables: [] // Нет в API
        )
        
        return Reservation(
            restaurant: restaurant,
            date: date,
            guestCount: guestCount,
            status: Reservation.Status(rawValue: status) ?? .pending,
            tableNumber: tableNumber,
            specialRequests: specialRequests
        )
    }
}

extension CreateReservationResponse {
    func toLocalReservation() -> Reservation {
        return data.toLocalReservation()
    }
}

extension UpdateReservationResponse {
    func toLocalReservation() -> Reservation {
        return data.toLocalReservation()
    }
}