import Foundation

struct Dish: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let description: String
    let price: Double
    let image: String
    let category: String
    let restaurantBrand: Restaurant.Brand
    let isAvailable: Bool
    let preparationTime: Int // в минутах
    let calories: Int
    let allergens: [String]
    
    init(name: String, description: String, price: Double, image: String, category: String, restaurantBrand: Restaurant.Brand, isAvailable: Bool = true, preparationTime: Int = 20, calories: Int = 0, allergens: [String] = []) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.price = price
        self.image = image
        self.category = category
        self.restaurantBrand = restaurantBrand
        self.isAvailable = isAvailable
        self.preparationTime = preparationTime
        self.calories = calories
        self.allergens = allergens
    }
    
    // Инициализатор с указанным UUID (для API данных)
    init(id: UUID, name: String, description: String, price: Double, image: String, category: String, restaurantBrand: Restaurant.Brand, isAvailable: Bool = true, preparationTime: Int = 20, calories: Int = 0, allergens: [String] = []) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.image = image
        self.category = category
        self.restaurantBrand = restaurantBrand
        self.isAvailable = isAvailable
        self.preparationTime = preparationTime
        self.calories = calories
        self.allergens = allergens
    }
}

// MARK: - Delivery Order Model
struct DeliveryOrder: Identifiable, Codable {
    let id: UUID
    let orderNumber: String
    let items: [DeliveryOrderItem]
    let totalAmount: Double
    let deliveryAddress: String
    let deliveryTime: Date
    let orderDate: Date
    let status: DeliveryOrderStatus
    let restaurantBrand: Restaurant.Brand
    let deliveryFee: Double
    let tip: Double?
    let estimatedDeliveryTime: Date?
    let actualDeliveryTime: Date?
    let courierName: String?
    let courierPhone: String?
    let paymentMethod: DeliveryPaymentMethod
    let specialInstructions: String?
    
    init(orderNumber: String, items: [DeliveryOrderItem], totalAmount: Double, deliveryAddress: String, deliveryTime: Date, orderDate: Date, status: DeliveryOrderStatus, restaurantBrand: Restaurant.Brand, deliveryFee: Double, tip: Double? = nil, estimatedDeliveryTime: Date? = nil, actualDeliveryTime: Date? = nil, courierName: String? = nil, courierPhone: String? = nil, paymentMethod: DeliveryPaymentMethod, specialInstructions: String? = nil) {
        self.id = UUID()
        self.orderNumber = orderNumber
        self.items = items
        self.totalAmount = totalAmount
        self.deliveryAddress = deliveryAddress
        self.deliveryTime = deliveryTime
        self.orderDate = orderDate
        self.status = status
        self.restaurantBrand = restaurantBrand
        self.deliveryFee = deliveryFee
        self.tip = tip
        self.estimatedDeliveryTime = estimatedDeliveryTime
        self.actualDeliveryTime = actualDeliveryTime
        self.courierName = courierName
        self.courierPhone = courierPhone
        self.paymentMethod = paymentMethod
        self.specialInstructions = specialInstructions
    }
}

struct DeliveryOrderItem: Identifiable, Codable {
    let id: UUID
    let dish: Dish
    let quantity: Int
    let price: Double
    let specialInstructions: String?
    
    init(dish: Dish, quantity: Int, price: Double, specialInstructions: String? = nil) {
        self.id = UUID()
        self.dish = dish
        self.quantity = quantity
        self.price = price
        self.specialInstructions = specialInstructions
    }
}

enum DeliveryOrderStatus: String, CaseIterable, Codable {
    case pending = "Ожидает подтверждения"
    case confirmed = "Подтвержден"
    case preparing = "Готовится"
    case ready = "Готов к доставке"
    case delivering = "В пути"
    case delivered = "Доставлен"
    case cancelled = "Отменен"
    
    var color: String {
        switch self {
        case .pending: return "orange"
        case .confirmed: return "blue"
        case .preparing: return "purple"
        case .ready: return "yellow"
        case .delivering: return "green"
        case .delivered: return "green"
        case .cancelled: return "red"
        }
    }
    
    var icon: String {
        switch self {
        case .pending: return "clock"
        case .confirmed: return "checkmark.circle"
        case .preparing: return "flame"
        case .ready: return "bag"
        case .delivering: return "bicycle"
        case .delivered: return "checkmark.shield"
        case .cancelled: return "xmark.circle"
        }
    }
}

enum DeliveryPaymentMethod: String, CaseIterable, Codable {
    case card = "Карта"
    case cash = "Наличные"
    case online = "Онлайн"
    
    var icon: String {
        switch self {
        case .card: return "creditcard"
        case .cash: return "banknote"
        case .online: return "globe"
        }
    }
}

struct NutritionFacts: Equatable {
    let calories: Double
    let proteins: Double
    let fats: Double
    let carbs: Double
}

enum DishCategory: String, CaseIterable {
    case starters = "Закуски"
    case soups = "Супы"
    case salads = "Салаты"
    case mainCourse = "Основные блюда"
    case steaks = "Стейки"
    case seafood = "Морепродукты"
    case pasta = "Паста"
    case pizza = "Пицца"
    case sides = "Гарниры"
    case desserts = "Десерты"
    case drinks = "Напитки"
    case alcohol = "Алкоголь"
}

enum DishTag: String, CaseIterable {
    case vegetarian = "Вегетарианское"
    case vegan = "Веганское"
    case glutenFree = "Без глютена"
    case lactoseFree = "Без лактозы"
    case spicy = "Острое"
    case halal = "Халяль"
    case kosher = "Кошерное"
    case chefSpecial = "Выбор шефа"
    case seasonal = "Сезонное"
    case bestseller = "Хит продаж"
}

enum SpicyLevel: Int, CaseIterable {
    case none = 0
    case mild = 1
    case medium = 2
    case hot = 3
    case extraHot = 4
    
    var description: String {
        switch self {
        case .none: return "Не острое"
        case .mild: return "Слабо острое"
        case .medium: return "Умеренно острое"
        case .hot: return "Острое"
        case .extraHot: return "Очень острое"
        }
    }
    
    var icon: String {
        switch self {
        case .none: return ""
        case .mild: return "🌶"
        case .medium: return "🌶🌶"
        case .hot: return "🌶🌶🌶"
        case .extraHot: return "🌶🌶🌶🌶"
        }
    }
} 