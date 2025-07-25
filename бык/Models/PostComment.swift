import Foundation

struct PostComment: Identifiable, Codable, Hashable {
    let id: UUID
    let postId: UUID
    let userId: UUID
    let username: String
    let userAvatar: String?
    let text: String
    let likes: Int
    let isLiked: Bool
    let replies: [PostComment]?
    let createdAt: Date
    
    init(
        id: UUID = UUID(),
        postId: UUID,
        userId: UUID,
        username: String,
        userAvatar: String? = nil,
        text: String,
        likes: Int = 0,
        isLiked: Bool = false,
        replies: [PostComment]? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.postId = postId
        self.userId = userId
        self.username = username
        self.userAvatar = userAvatar
        self.text = text
        self.likes = likes
        self.isLiked = isLiked
        self.replies = replies
        self.createdAt = createdAt
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: PostComment, rhs: PostComment) -> Bool {
        lhs.id == rhs.id
    }
    
    // MARK: - Mock Data
    static let mock = PostComment(
        postId: UUID(),
        userId: User.mock.id,
        username: User.mock.username,
        userAvatar: User.mock.avatar,
        text: "Отличное блюдо! Обязательно попробую! 🐂",
        likes: 5,
        isLiked: false
    )
    
    static let mockWithReplies = PostComment(
        postId: UUID(),
        userId: User.mock.id,
        username: User.mock.username,
        userAvatar: User.mock.avatar,
        text: "Какой ресторан?",
        likes: 2,
        isLiked: true,
        replies: [
            PostComment(
                postId: UUID(),
                userId: UUID(),
                username: "chef_mike",
                userAvatar: nil,
                text: "The Бык на Тверской! 🐂",
                likes: 1,
                isLiked: false
            )
        ]
    )
} 