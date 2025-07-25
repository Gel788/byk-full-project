import SwiftUI
import Combine
import UIKit

// MARK: - Cart Error
enum CartError: LocalizedError {
    case dishNotFound
    case restaurantNotFound
    case invalidQuantity
    case maxQuantityExceeded
    case mixedRestaurants
    
    var errorDescription: String? {
        switch self {
        case .dishNotFound:
            return "Блюдо не найдено"
        case .restaurantNotFound:
            return "Ресторан не найден"
        case .invalidQuantity:
            return "Некорректное количество"
        case .maxQuantityExceeded:
            return "Превышено максимальное количество"
        case .mixedRestaurants:
            return "Нельзя добавлять блюда из разных ресторанов"
        }
    }
}

// MARK: - Cart Grouped Item
struct CartGroupedItem: Identifiable {
    let id = UUID()
    let dish: Dish
    let quantity: Int
    let restaurant: Restaurant?
    
    var totalPrice: Double {
        dish.price * Double(quantity)
    }
}

// MARK: - Cart View Model
@MainActor
class CartViewModel: ObservableObject {
    @Published private(set) var cartItems: [UUID: Int] = [:]
    @Published private(set) var restaurantItems: [UUID: Restaurant] = [:]
    @Published private(set) var loadingState: LoadingState = .idle
    @Published var error: String?
    @Published var showMixedRestaurantAlert = false
    @Published var pendingDish: (dish: Dish, restaurant: Restaurant, quantity: Int)?
    
    private let restaurantService: RestaurantService
    private let maxQuantityPerDish = 99
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    var hasItems: Bool {
        !cartItems.isEmpty
    }
    
    var totalItems: Int {
        let total = cartItems.values.reduce(0, +)
        print("🛒 Total items in cart: \(total)")
        return total
    }
    
    var totalAmount: Double {
        restaurantService.restaurants
            .flatMap { restaurant in
                restaurant.menu
                    .filter { cartItems[$0.id] ?? 0 > 0 }
                    .map { $0.price * Double(cartItems[$0.id] ?? 0) }
            }
            .reduce(0, +)
    }
    
    var currentRestaurant: Restaurant? {
        let restaurants = Set(restaurantItems.values)
        return restaurants.count == 1 ? restaurants.first : nil
    }
    
    var currentRestaurantBrand: Restaurant.Brand? {
        let brands = Set(restaurantItems.values.compactMap { $0.brand })
        return brands.count == 1 ? brands.first : nil
    }
    
    var canAddFromDifferentRestaurant: Bool {
        return cartItems.isEmpty
    }
    
    // MARK: - Initialization
    init(restaurantService: RestaurantService) {
        self.restaurantService = restaurantService
        setupErrorHandling()
    }
    
    // MARK: - Public Methods
    func addToCart(_ dish: Dish, from restaurant: Restaurant, quantity: Int = 1) -> Result<Void, CartError> {
        // Валидация
        guard quantity > 0 && quantity <= maxQuantityPerDish else {
            return .failure(.invalidQuantity)
        }
        
        // Проверка на смешивание ресторанов
        if !canAddFromDifferentRestaurant {
            if let currentBrand = currentRestaurantBrand {
                if currentBrand != restaurant.brand {
                    // Показываем предупреждение вместо возврата ошибки
                    pendingDish = (dish: dish, restaurant: restaurant, quantity: quantity)
                    showMixedRestaurantAlert = true
                    return .success(())
                }
            }
        }
        
        // Добавление в корзину
        let currentQuantity = cartItems[dish.id] ?? 0
        let newQuantity = currentQuantity + quantity
        
        guard newQuantity <= maxQuantityPerDish else {
            return .failure(.maxQuantityExceeded)
        }
        
        cartItems[dish.id] = newQuantity
        restaurantItems[dish.id] = restaurant
        
        // Явно уведомляем об изменении для обновления UI
        objectWillChange.send()
        
        // Haptic feedback
        HapticManager.shared.impact(.light)
        
        return .success(())
    }
    
    func updateQuantity(for dishId: UUID, increment: Bool) -> Result<Void, CartError> {
        guard let currentQuantity = cartItems[dishId] else {
            return .failure(.dishNotFound)
        }
        
        if increment {
            guard currentQuantity < maxQuantityPerDish else {
                return .failure(.maxQuantityExceeded)
            }
            cartItems[dishId] = currentQuantity + 1
        } else {
            let newQuantity = currentQuantity - 1
            if newQuantity > 0 {
                cartItems[dishId] = newQuantity
            } else {
                removeFromCart(dishId: dishId)
            }
        }
        
        // Явно уведомляем об изменении для обновления UI
        objectWillChange.send()
        
        // Haptic feedback
        HapticManager.shared.impact(.light)
        
        return .success(())
    }
    
    func removeFromCart(dishId: UUID) {
        cartItems.removeValue(forKey: dishId)
        restaurantItems.removeValue(forKey: dishId)
        
        // Явно уведомляем об изменении для обновления UI
        objectWillChange.send()
        
        // Haptic feedback
        HapticManager.shared.impact(.medium)
    }
    
    func clearCart() {
        cartItems.removeAll()
        restaurantItems.removeAll()
        
        // Явно уведомляем об изменении для обновления UI
        objectWillChange.send()
        
        // Haptic feedback
        HapticManager.shared.impact(.heavy)
    }
    
    func confirmAddFromDifferentRestaurant() {
        guard let pending = pendingDish else { return }
        
        // Очищаем корзину и добавляем новое блюдо
        clearCart()
        _ = addToCart(pending.dish, from: pending.restaurant, quantity: pending.quantity)
        
        // Скрываем предупреждение
        showMixedRestaurantAlert = false
        pendingDish = nil
    }
    
    func cancelAddFromDifferentRestaurant() {
        // Просто скрываем предупреждение
        showMixedRestaurantAlert = false
        pendingDish = nil
    }
    
    func groupedCartItems() -> [CartGroupedItem] {
        return cartItems.compactMap { (dishId, quantity) in
            guard let dish = findDish(by: dishId) else { return nil }
            let restaurant = restaurantItems[dishId]
            return CartGroupedItem(dish: dish, quantity: quantity, restaurant: restaurant)
        }.sorted { $0.dish.name < $1.dish.name }
    }
    
    func getRestaurant(for dishId: UUID) -> Restaurant? {
        return restaurantItems[dishId] ?? findRestaurant(for: dishId)
    }
    
    func getQuantity(for dish: Dish) -> Int {
        return cartItems[dish.id] ?? 0
    }
    
    func removeFromCart(_ dish: Dish) {
        removeFromCart(dishId: dish.id)
    }
    
    func validateCart() -> Result<Void, CartError> {
        // Проверяем, что все блюда существуют
        for dishId in cartItems.keys {
            guard findDish(by: dishId) != nil else {
                return .failure(.dishNotFound)
            }
        }
        
        return .success(())
    }
    
    // MARK: - Private Methods
    private func findDish(by id: UUID) -> Dish? {
        return restaurantService.restaurants
            .flatMap { $0.menu }
            .first { $0.id == id }
    }
    
    private func findRestaurant(for dishId: UUID) -> Restaurant? {
        return restaurantService.restaurants.first { restaurant in
            restaurant.menu.contains { $0.id == dishId }
        }
    }
    
    private func setupErrorHandling() {
        $error
            .compactMap { $0 }
            .sink { [weak self] errorMessage in
                // Логирование ошибок
                print("Cart Error: \(errorMessage)")
            }
            .store(in: &cancellables)
    }
}

// MARK: - Haptic Manager
class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    // MARK: - Impact Feedback
    
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let impactFeedback = UIImpactFeedbackGenerator(style: style)
        impactFeedback.prepare()
        impactFeedback.impactOccurred()
    }
    
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle, intensity: CGFloat) {
        let impactFeedback = UIImpactFeedbackGenerator(style: style)
        impactFeedback.prepare()
        impactFeedback.impactOccurred(intensity: intensity)
    }
    
    // MARK: - Notification Feedback
    
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.prepare()
        notificationFeedback.notificationOccurred(type)
    }
    
    // MARK: - Selection Feedback
    
    func selection() {
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.prepare()
        selectionFeedback.selectionChanged()
    }
    
    // MARK: - Custom Patterns
    
    func successPattern() {
        impact(.medium)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.notification(.success)
        }
    }
    
    func errorPattern() {
        impact(.heavy)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.notification(.error)
        }
    }
    
    func warningPattern() {
        impact(.light)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.notification(.warning)
        }
    }
    
    // MARK: - Swipe Feedback
    
    func swipeFeedback(progress: CGFloat) {
        if progress > 0.5 {
            impact(.medium, intensity: min(progress, 1.0))
        } else {
            impact(.light, intensity: progress)
        }
    }
    
    // MARK: - Button Press Feedback
    
    func buttonPress() {
        impact(.light)
    }
    
    func buttonPressHeavy() {
        impact(.medium)
    }
    
    // MARK: - Navigation Feedback
    
    func navigationTransition() {
        selection()
    }
    
    func tabSwitch() {
        impact(.light)
    }
    
    // MARK: - Cart Feedback
    
    func addToCart() {
        successPattern()
    }
    
    func removeFromCart() {
        impact(.light)
    }
    
    func cartUpdate() {
        selection()
    }
    
    // MARK: - Restaurant Feedback
    
    func restaurantSelect() {
        impact(.medium)
    }
    
    func reservationSuccess() {
        successPattern()
    }
    
    func reservationError() {
        errorPattern()
    }
} 