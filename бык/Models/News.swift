import Foundation
import SwiftUI

// Модель комментария к новости
struct NewsComment: Identifiable, Equatable {
    let id: UUID
    let author: String
    let text: String
    let date: Date
    
    init(
        id: UUID = UUID(),
        author: String,
        text: String,
        date: Date = Date()
    ) {
        self.id = id
        self.author = author
        self.text = text
        self.date = date
    }
}

struct NewsItem: Identifiable, Equatable {
    let id: UUID
    let title: String
    let description: String
    let image: String
    let date: Date
    let brand: Restaurant.Brand
    let type: NewsType
    var likes: Int
    var isLiked: Bool
    var comments: [NewsComment]
    var isRead: Bool
    
    static func == (lhs: NewsItem, rhs: NewsItem) -> Bool {
        lhs.id == rhs.id
    }
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        image: String,
        date: Date,
        brand: Restaurant.Brand,
        type: NewsType = .news,
        likes: Int = 0,
        isLiked: Bool = false,
        comments: [NewsComment] = [],
        isRead: Bool = false
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.image = image
        self.date = date
        self.brand = brand
        self.type = type
        self.likes = likes
        self.isLiked = isLiked
        self.comments = comments
        self.isRead = isRead
    }
    
    // Mock данные для превью
    static let mock = NewsItem(
        title: "Новое сезонное меню в THE БЫК",
        description: "Мы рады представить вам наше новое сезонное меню, созданное специально для летнего сезона. Наши шеф-повара подготовили уникальные блюда.",
        image: "XXL_height",
        date: Date(),
        brand: .theByk,
        type: .news,
        likes: 42,
        isLiked: false,
        comments: [
            NewsComment(author: "Алексей", text: "Отличное меню! Обязательно попробую."),
            NewsComment(author: "Мария", text: "Когда будет доступно в моем городе?"),
            NewsComment(author: "Дмитрий", text: "Выглядит аппетитно! 👍")
        ],
        isRead: false
    )
}

// Перечисление типа новостей
enum NewsType: String, CaseIterable {
    case news = "Новости"
    case event = "События"
    case promotion = "Акции"
    case announcement = "Анонсы"
    case update = "Обновления"
    
    var icon: String {
        switch self {
        case .news: return "newspaper"
        case .event: return "calendar"
        case .promotion: return "tag"
        case .announcement: return "megaphone"
        case .update: return "arrow.triangle.2.circlepath"
        }
    }
    
    var color: Color {
        switch self {
        case .news: return .blue
        case .event: return .purple
        case .promotion: return .orange
        case .announcement: return .green
        case .update: return .gray
        }
    }
} 