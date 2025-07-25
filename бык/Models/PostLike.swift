import Foundation

struct PostLike: Identifiable, Codable, Hashable {
    let id: UUID
    let postId: UUID
    let userId: UUID
    let username: String
    let userAvatar: String?
    let createdAt: Date
    
    init(
        id: UUID = UUID(),
        postId: UUID,
        userId: UUID,
        username: String,
        userAvatar: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.postId = postId
        self.userId = userId
        self.username = username
        self.userAvatar = userAvatar
        self.createdAt = createdAt
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: PostLike, rhs: PostLike) -> Bool {
        lhs.id == rhs.id
    }
    
    // MARK: - Mock Data
    static let mock = PostLike(
        postId: UUID(),
        userId: User.mock.id,
        username: User.mock.username,
        userAvatar: User.mock.avatar
    )
} 