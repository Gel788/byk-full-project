import SwiftUI
import Combine

// MARK: - Cart Error
enum CartError: LocalizedError {
    case dishNotFound
    
    var errorDescription: String? {
        switch self {
        case .dishNotFound:
            return "Блюдо не найдено"
        }
    }
}

// MARK: - Cart Grouped Item
struct CartGroupedItem: Identifiable {
    let id = UUID()
    let dish: Dish
    let quantity: Int
    
    var totalPrice: Double {
        dish.price * Double(quantity)
    }
}

// MARK: - Cart View Model
@MainActor
class CartViewModel: ObservableObject {
    @Published private(set) var cartItems: [UUID: Int] = [:]
    @Published private(set) var restaurantItems: [UUID: Restaurant] = [:]
    @Published var error: String?
    
    private let restaurantService: RestaurantService
    private let menuService: MenuService
    
    init(restaurantService: RestaurantService, menuService: MenuService) {
        self.restaurantService = restaurantService
        self.menuService = menuService
    }
    
    var hasItems: Bool {
        !cartItems.isEmpty
    }
    
    var totalAmount: Double {
        cartItems.compactMap { (dishId, quantity) in
            guard let dish = findDish(by: dishId) else { return nil }
            return dish.price * Double(quantity)
        }.reduce(0, +)
    }
    
    var totalItems: Int {
        cartItems.values.reduce(0, +)
    }
    
    func addToCart(_ dish: Dish, from restaurant: Restaurant) -> Result<Void, CartError> {
        print("🛒 CartViewModel: addToCart вызван")
        print("🛒 CartViewModel: Блюдо ID = \(dish.id)")
        print("🛒 CartViewModel: Название = \(dish.name)")
        print("🛒 CartViewModel: Ресторан = \(restaurant.name)")
        
        let currentQuantity = cartItems[dish.id] ?? 0
        print("🛒 CartViewModel: Текущее количество = \(currentQuantity)")
        
        cartItems[dish.id] = currentQuantity + 1
        restaurantItems[dish.id] = restaurant
        error = nil // Сбрасываем ошибку при успешном добавлении
        
        print("🛒 CartViewModel: Новое количество = \(cartItems[dish.id] ?? 0)")
        print("🛒 CartViewModel: Общее количество в корзине = \(totalItems)")
        
        return .success(())
    }
    
    func updateQuantity(for dishId: UUID, increment: Bool) -> Result<Void, CartError> {
        guard let currentQuantity = cartItems[dishId] else {
            error = "Блюдо не найдено в корзине"
            return .failure(.dishNotFound)
        }
        
        if increment {
            cartItems[dishId] = currentQuantity + 1
        } else {
            let newQuantity = currentQuantity - 1
            if newQuantity <= 0 {
                cartItems.removeValue(forKey: dishId)
                restaurantItems.removeValue(forKey: dishId)
            } else {
                cartItems[dishId] = newQuantity
            }
        }
        
        error = nil // Сбрасываем ошибку при успешном обновлении
        return .success(())
    }
    
    func removeFromCart(dishId: UUID) {
        cartItems.removeValue(forKey: dishId)
        restaurantItems.removeValue(forKey: dishId)
    }
    
    func clearCart() {
        cartItems.removeAll()
        restaurantItems.removeAll()
    }
    
    func groupedCartItems() -> [CartGroupedItem] {
        cartItems.compactMap { (dishId: UUID, quantity: Int) -> CartGroupedItem? in
            guard let dish = findDish(by: dishId) else { return nil }
            return CartGroupedItem(dish: dish, quantity: quantity)
        }
    }
    
    func getQuantity(for dish: Dish) -> Int {
        return cartItems[dish.id] ?? 0
    }
    
    private func findDish(by id: UUID) -> Dish? {
        if let dish = menuService.dishes.first(where: { $0.id == id }) {
            return dish
        }
        
        let allRestaurantDishes = restaurantService.restaurants.flatMap { $0.menu }
        return allRestaurantDishes.first { $0.id == id }
    }
}