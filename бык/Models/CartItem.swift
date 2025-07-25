import Foundation

struct CartItem: Identifiable {
    let id: UUID
    let dish: Dish
    var quantity: Int
    var specialInstructions: String?
    
    var totalPrice: Double {
        return dish.price * Double(quantity)
    }
    
    init(id: UUID = UUID(), dish: Dish, quantity: Int = 1, specialInstructions: String? = nil) {
        self.id = id
        self.dish = dish
        self.quantity = quantity
        self.specialInstructions = specialInstructions
    }
} 