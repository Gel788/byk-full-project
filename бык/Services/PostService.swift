import Foundation
import SwiftUI

@MainActor
class PostService: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let currentUser = User.mock // Временно используем мок пользователя
    
    init() {
        loadPosts()
    }
    
    // MARK: - Posts Management
    func loadPosts() {
        isLoading = true
        error = nil
        
        // Имитация загрузки
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.posts = Post.mockMultiple
            self.isLoading = false
        }
    }
    
    func createPost(_ post: Post) async {
        isLoading = true
        error = nil
        
        // Имитация создания поста
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.posts.insert(post, at: 0)
            self.isLoading = false
        }
    }
    
    func deletePost(_ postId: UUID) async {
        posts.removeAll { $0.id == postId }
    }
    
    // MARK: - Likes Management
    func likePost(_ postId: UUID) async {
        guard let index = posts.firstIndex(where: { $0.id == postId }) else { return }
        
        var updatedPost = posts[index]
        updatedPost = Post(
            id: updatedPost.id,
            authorId: updatedPost.authorId,
            authorName: updatedPost.authorName,
            authorAvatar: updatedPost.authorAvatar,
            content: updatedPost.content,
            media: updatedPost.media,
            taggedRestaurant: updatedPost.taggedRestaurant,
            hashtags: updatedPost.hashtags,
            location: updatedPost.location,
            likes: updatedPost.likes + 1,
            comments: updatedPost.comments,
            isLiked: true,
            createdAt: updatedPost.createdAt
        )
        
        posts[index] = updatedPost
    }
    
    func unlikePost(_ postId: UUID) async {
        guard let index = posts.firstIndex(where: { $0.id == postId }) else { return }
        
        var updatedPost = posts[index]
        updatedPost = Post(
            id: updatedPost.id,
            authorId: updatedPost.authorId,
            authorName: updatedPost.authorName,
            authorAvatar: updatedPost.authorAvatar,
            content: updatedPost.content,
            media: updatedPost.media,
            taggedRestaurant: updatedPost.taggedRestaurant,
            hashtags: updatedPost.hashtags,
            location: updatedPost.location,
            likes: max(0, updatedPost.likes - 1),
            comments: updatedPost.comments,
            isLiked: false,
            createdAt: updatedPost.createdAt
        )
        
        posts[index] = updatedPost
    }
    
    // MARK: - Comments Management
    func addComment(_ comment: PostComment, to postId: UUID) async {
        guard let index = posts.firstIndex(where: { $0.id == postId }) else { return }
        
        var updatedPost = posts[index]
        updatedPost = Post(
            id: updatedPost.id,
            authorId: updatedPost.authorId,
            authorName: updatedPost.authorName,
            authorAvatar: updatedPost.authorAvatar,
            content: updatedPost.content,
            media: updatedPost.media,
            taggedRestaurant: updatedPost.taggedRestaurant,
            hashtags: updatedPost.hashtags,
            location: updatedPost.location,
            likes: updatedPost.likes,
            comments: updatedPost.comments + 1,
            isLiked: updatedPost.isLiked,
            createdAt: updatedPost.createdAt
        )
        
        posts[index] = updatedPost
    }
    
    // MARK: - Search and Filter
    func searchPosts(query: String) -> [Post] {
        guard !query.isEmpty else { return posts }
        
        return posts.filter { post in
            post.content.localizedCaseInsensitiveContains(query) ||
            post.hashtags.contains { $0.localizedCaseInsensitiveContains(query) } ||
            post.taggedRestaurant?.name.localizedCaseInsensitiveContains(query) == true
        }
    }
    
    func filterPosts(by restaurant: Restaurant?) -> [Post] {
        guard let restaurant = restaurant else { return posts }
        
        return posts.filter { post in
            post.taggedRestaurant?.id == restaurant.id
        }
    }
    
    func filterPosts(by hashtag: String) -> [Post] {
        return posts.filter { post in
            post.hashtags.contains { $0.localizedCaseInsensitiveContains(hashtag) }
        }
    }
    
    // MARK: - Analytics
    func getPostAnalytics(for postId: UUID) -> PostAnalytics? {
        guard let post = posts.first(where: { $0.id == postId }) else { return nil }
        
        let engagement = Double(post.likes + post.comments) / 100.0 // Простая формула
        
        return PostAnalytics(
            views: Int.random(in: post.likes * 3...post.likes * 10),
            likes: post.likes,
            comments: post.comments,
            shares: Int.random(in: 0...post.likes / 5),
            reach: Int.random(in: post.likes * 5...post.likes * 20),
            engagement: engagement
        )
    }
}

// MARK: - Post Analytics
struct PostAnalytics {
    let views: Int
    let likes: Int
    let comments: Int
    let shares: Int
    let reach: Int
    let engagement: Double
} 