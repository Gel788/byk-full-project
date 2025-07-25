import Foundation
import CoreLocation

struct Post: Identifiable, Codable, Hashable {
    let id: UUID
    let authorId: UUID
    let authorName: String
    let authorAvatar: String?
    let content: String
    let media: [PostMedia]
    let taggedRestaurant: Restaurant?
    let hashtags: [String]
    let location: Location?
    let likes: Int
    let comments: Int
    let isLiked: Bool
    let createdAt: Date
    
    init(
        id: UUID = UUID(),
        authorId: UUID,
        authorName: String,
        authorAvatar: String? = nil,
        content: String,
        media: [PostMedia] = [],
        taggedRestaurant: Restaurant? = nil,
        hashtags: [String] = [],
        location: Location? = nil,
        likes: Int = 0,
        comments: Int = 0,
        isLiked: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.authorId = authorId
        self.authorName = authorName
        self.authorAvatar = authorAvatar
        self.content = content
        self.media = media
        self.taggedRestaurant = taggedRestaurant
        self.hashtags = hashtags
        self.location = location
        self.likes = likes
        self.comments = comments
        self.isLiked = isLiked
        self.createdAt = createdAt
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Post, rhs: Post) -> Bool {
        lhs.id == rhs.id
    }
    
    // MARK: - Computed Properties
    var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
    
    var hashtagString: String {
        hashtags.map { "#\($0)" }.joined(separator: " ")
    }
    
    // MARK: - Mock Data
    static let mock = Post(
        authorId: User.mock.id,
        authorName: User.mock.fullName,
        authorAvatar: User.mock.avatar,
        content: "Попробовал новый стейк в The Бык! 🔥 Невероятный вкус и идеальное приготовление. Рекомендую всем любителям мяса! 🐂 #thebyk #steak #foodie",
        media: [PostMedia.mockImage],
        taggedRestaurant: Restaurant.mock,
        hashtags: ["thebyk", "steak", "foodie"],
        likes: 42,
        comments: 8,
        isLiked: false
    )
    
    static let mockWithVideo = Post(
        authorId: User.mock.id,
        authorName: User.mock.fullName,
        authorAvatar: User.mock.avatar,
        content: "Процесс приготовления стейка в The Бык! 👨‍🍳 Смотрите, как наш шеф создает кулинарное искусство! 🎨 #cooking #thebyk #chef",
        media: [PostMedia.mockVideo],
        taggedRestaurant: Restaurant.mock,
        hashtags: ["cooking", "thebyk", "chef"],
        likes: 156,
        comments: 23,
        isLiked: true
    )
    
    static let mockMultiple = [
        Post(
            authorId: User.mock.id,
            authorName: User.mock.fullName,
            authorAvatar: User.mock.avatar,
            content: "Лучший бургер в городе! 🍔 The Бык не подводит! #burger #thebyk",
            media: [PostMedia.mockImage],
            taggedRestaurant: Restaurant.mock,
            hashtags: ["burger", "thebyk"],
            likes: 89,
            comments: 12,
            isLiked: true
        ),
        Post(
            authorId: UUID(),
            authorName: "Мария Иванова",
            authorAvatar: nil,
            content: "Романтический ужин в Mosca 💕 Идеальная атмосфера и потрясающая паста! #mosca #pasta #romance",
            media: [PostMedia.mockImage],
            taggedRestaurant: Restaurant.mock,
            hashtags: ["mosca", "pasta", "romance"],
            likes: 67,
            comments: 5,
            isLiked: false
        ),
        Post(
            authorId: UUID(),
            authorName: "Дмитрий Сидоров",
            authorAvatar: nil,
            content: "Пиво и закуски в The Pivo 🍺 Отличное место для встречи с друзьями! #thepivo #beer #friends",
            media: [PostMedia.mockImage],
            taggedRestaurant: Restaurant.mock,
            hashtags: ["thepivo", "beer", "friends"],
            likes: 34,
            comments: 7,
            isLiked: false
        )
    ]
} 