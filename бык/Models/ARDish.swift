import Foundation
import SwiftUI

struct ARDish: Identifiable, Codable, Equatable {
    var id = UUID()
    let name: String
    let description: String
    let price: Double
    let category: String
    let imageURL: String
    let model3DURL: String? // URL для 3D модели
    let scale: Float // Масштаб 3D модели
    let rotation: Float // Поворот модели
    let position: ARPosition // Позиция в AR
    let ingredients: [String]
    let calories: Int
    let preparationTime: Int
    let isSpicy: Bool
    let isVegetarian: Bool
    
    struct ARPosition: Codable, Equatable {
        let x: Float
        let y: Float
        let z: Float
    }
    
    // Тестовые данные для AR-блюд
    static let sampleDishes: [ARDish] = [
        ARDish(
            name: "Стейк Рибай",
            description: "Сочный стейк из мраморной говядины с хрустящей корочкой",
            price: 2500,
            category: "Стейки",
            imageURL: "steak_ribeye",
            model3DURL: nil,
            scale: 0.8,
            rotation: 0.0,
            position: ARPosition(x: 0, y: 0, z: -0.5),
            ingredients: ["Говядина", "Соль", "Перец", "Травы"],
            calories: 450,
            preparationTime: 15,
            isSpicy: false,
            isVegetarian: false
        ),
        ARDish(
            name: "Бургер Классический",
            description: "Сочный бургер с говяжьей котлетой и свежими овощами",
            price: 800,
            category: "Бургеры",
            imageURL: "burger_classic",
            model3DURL: nil,
            scale: 1.0,
            rotation: 0.0,
            position: ARPosition(x: 0, y: 0, z: -0.4),
            ingredients: ["Булочка", "Котлета", "Сыр", "Салат", "Помидор"],
            calories: 650,
            preparationTime: 10,
            isSpicy: false,
            isVegetarian: false
        ),
        ARDish(
            name: "Пицца Маргарита",
            description: "Классическая итальянская пицца с томатами и моцареллой",
            price: 1200,
            category: "Пицца",
            imageURL: "pizza_margherita",
            model3DURL: nil,
            scale: 1.2,
            rotation: 0.0,
            position: ARPosition(x: 0, y: 0, z: -0.6),
            ingredients: ["Тесто", "Томатный соус", "Моцарелла", "Базилик"],
            calories: 850,
            preparationTime: 20,
            isSpicy: false,
            isVegetarian: true
        ),
        ARDish(
            name: "Салат Цезарь",
            description: "Свежий салат с куриным филе и соусом Цезарь",
            price: 600,
            category: "Салаты",
            imageURL: "caesar_salad",
            model3DURL: nil,
            scale: 0.9,
            rotation: 0.0,
            position: ARPosition(x: 0, y: 0, z: -0.3),
            ingredients: ["Салат", "Курица", "Сыр", "Сухарики", "Соус Цезарь"],
            calories: 320,
            preparationTime: 8,
            isSpicy: false,
            isVegetarian: false
        ),
        ARDish(
            name: "Паста Карбонара",
            description: "Итальянская паста с беконом, яйцом и сыром",
            price: 900,
            category: "Паста",
            imageURL: "pasta_carbonara",
            model3DURL: nil,
            scale: 1.1,
            rotation: 0.0,
            position: ARPosition(x: 0, y: 0, z: -0.5),
            ingredients: ["Спагетти", "Бекон", "Яйцо", "Пармезан", "Черный перец"],
            calories: 580,
            preparationTime: 12,
            isSpicy: false,
            isVegetarian: false
        )
    ]
    
    var formattedPrice: String {
        return "\(Int(price)) ₽"
    }
    
    var formattedCalories: String {
        return "\(calories) ккал"
    }
    
    var formattedTime: String {
        return "\(preparationTime) мин"
    }
} 