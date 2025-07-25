import Foundation
import SwiftUI

class DeliveryService: ObservableObject {
    @Published var deliveryOrders: [DeliveryOrder] = []
    
    init() {
        loadMockData()
    }
    
    private func loadMockData() {
        let mockDishes = [
            Dish(name: "Рибай стейк", description: "Премиальный стейк из мраморной говядины", price: 3200, image: "ribai_steak", category: "Стейки", restaurantBrand: .theByk, calories: 450),
            Dish(name: "Бургер Классик", description: "Сочный бургер с говяжьей котлетой", price: 850, image: "ribai_steak", category: "Бургеры", restaurantBrand: .theByk, calories: 650),
            Dish(name: "Пицца Маргарита", description: "Классическая пицца с томатами и моцареллой", price: 1200, image: "ribai_steak", category: "Пицца", restaurantBrand: .mosca, calories: 800),
            Dish(name: "Паста Карбонара", description: "Паста с беконом и сливочным соусом", price: 950, image: "ribai_steak", category: "Паста", restaurantBrand: .mosca, calories: 550),
            Dish(name: "Светлое пиво", description: "Свежее светлое пиво", price: 350, image: "ribai_steak", category: "Напитки", restaurantBrand: .thePivo, calories: 150),
            Dish(name: "Темное пиво", description: "Крепкое темное пиво", price: 400, image: "ribai_steak", category: "Напитки", restaurantBrand: .thePivo, calories: 180)
        ]
        
        let calendar = Calendar.current
        let now = Date()
        
        let mockOrders = [
            DeliveryOrder(
                orderNumber: "BY-2024-001",
                items: [
                    DeliveryOrderItem(dish: mockDishes[0], quantity: 1, price: 3200),
                    DeliveryOrderItem(dish: mockDishes[1], quantity: 2, price: 1700)
                ],
                totalAmount: 4900,
                deliveryAddress: "ул. Тверская, 15, кв. 45",
                deliveryTime: calendar.date(byAdding: .hour, value: -2, to: now) ?? now,
                orderDate: calendar.date(byAdding: .hour, value: -3, to: now) ?? now,
                status: .delivered,
                restaurantBrand: .theByk,
                deliveryFee: 200,
                tip: 500,
                estimatedDeliveryTime: calendar.date(byAdding: .hour, value: -1, to: now) ?? now,
                actualDeliveryTime: calendar.date(byAdding: .hour, value: -2, to: now),
                courierName: "Иван Петров",
                courierPhone: "+7 (999) 123-45-67",
                paymentMethod: .card,
                specialInstructions: "Позвонить за 5 минут до доставки"
            ),
            
            DeliveryOrder(
                orderNumber: "MO-2024-002",
                items: [
                    DeliveryOrderItem(dish: mockDishes[2], quantity: 1, price: 1200),
                    DeliveryOrderItem(dish: mockDishes[3], quantity: 1, price: 950)
                ],
                totalAmount: 2150,
                deliveryAddress: "Ленинский проспект, 78, кв. 12",
                deliveryTime: calendar.date(byAdding: .day, value: -1, to: now) ?? now,
                orderDate: calendar.date(byAdding: .day, value: -1, to: now) ?? now,
                status: .delivered,
                restaurantBrand: .mosca,
                deliveryFee: 150,
                tip: 200,
                estimatedDeliveryTime: calendar.date(byAdding: .hour, value: -25, to: now) ?? now,
                actualDeliveryTime: calendar.date(byAdding: .hour, value: -26, to: now),
                courierName: "Мария Сидорова",
                courierPhone: "+7 (999) 234-56-78",
                paymentMethod: .cash
            ),
            
            DeliveryOrder(
                orderNumber: "PI-2024-003",
                items: [
                    DeliveryOrderItem(dish: mockDishes[4], quantity: 3, price: 1050),
                    DeliveryOrderItem(dish: mockDishes[5], quantity: 2, price: 800)
                ],
                totalAmount: 1850,
                deliveryAddress: "Кутузовский проспект, 25, кв. 8",
                deliveryTime: calendar.date(byAdding: .minute, value: 30, to: now) ?? now,
                orderDate: now,
                status: .delivering,
                restaurantBrand: .thePivo,
                deliveryFee: 100,
                estimatedDeliveryTime: calendar.date(byAdding: .minute, value: 45, to: now) ?? now,
                courierName: "Алексей Козлов",
                courierPhone: "+7 (999) 345-67-89",
                paymentMethod: .online
            ),
            
            DeliveryOrder(
                orderNumber: "BY-2024-004",
                items: [
                    DeliveryOrderItem(dish: mockDishes[0], quantity: 2, price: 6400)
                ],
                totalAmount: 6600,
                deliveryAddress: "Арбат, 10, кв. 33",
                deliveryTime: calendar.date(byAdding: .hour, value: 2, to: now) ?? now,
                orderDate: now,
                status: .preparing,
                restaurantBrand: .theByk,
                deliveryFee: 200,
                estimatedDeliveryTime: calendar.date(byAdding: .hour, value: 2, to: now) ?? now,
                paymentMethod: .card,
                specialInstructions: "Стейк средней прожарки"
            ),
            
            DeliveryOrder(
                orderNumber: "MO-2024-005",
                items: [
                    DeliveryOrderItem(dish: mockDishes[2], quantity: 2, price: 2400),
                    DeliveryOrderItem(dish: mockDishes[3], quantity: 1, price: 950)
                ],
                totalAmount: 3350,
                deliveryAddress: "Новый Арбат, 15, кв. 67",
                deliveryTime: calendar.date(byAdding: .day, value: -3, to: now) ?? now,
                orderDate: calendar.date(byAdding: .day, value: -3, to: now) ?? now,
                status: .cancelled,
                restaurantBrand: .mosca,
                deliveryFee: 150,
                estimatedDeliveryTime: calendar.date(byAdding: .hour, value: -72, to: now) ?? now,
                paymentMethod: .card
            )
        ]
        
        self.deliveryOrders = mockOrders
    }
    
    func getOrdersByStatus(_ status: DeliveryOrderStatus? = nil) -> [DeliveryOrder] {
        if let status = status {
            return deliveryOrders.filter { $0.status == status }
        }
        return deliveryOrders
    }
    
    func getOrdersByBrand(_ brand: Restaurant.Brand? = nil) -> [DeliveryOrder] {
        if let brand = brand {
            return deliveryOrders.filter { $0.restaurantBrand == brand }
        }
        return deliveryOrders
    }
    
    func getRecentOrders(limit: Int = 5) -> [DeliveryOrder] {
        return Array(deliveryOrders.sorted { $0.orderDate > $1.orderDate }.prefix(limit))
    }
    
    func getTotalSpent() -> Double {
        return deliveryOrders
            .filter { $0.status == .delivered }
            .reduce(0) { $0 + $1.totalAmount }
    }
    
    func getAverageOrderValue() -> Double {
        let deliveredOrders = deliveryOrders.filter { $0.status == .delivered }
        guard !deliveredOrders.isEmpty else { return 0 }
        return deliveredOrders.reduce(0) { $0 + $1.totalAmount } / Double(deliveredOrders.count)
    }
} 