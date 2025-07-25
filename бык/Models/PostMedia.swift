import Foundation

enum MediaType: String, Codable, CaseIterable {
    case image = "image"
    case video = "video"
    
    var icon: String {
        switch self {
        case .image: return "photo"
        case .video: return "video"
        }
    }
}

struct PostMedia: Identifiable, Codable, Hashable {
    let id: UUID
    let type: MediaType
    let url: String
    let thumbnail: String?
    let duration: TimeInterval? // для видео
    let width: Int?
    let height: Int?
    
    init(
        id: UUID = UUID(),
        type: MediaType,
        url: String,
        thumbnail: String? = nil,
        duration: TimeInterval? = nil,
        width: Int? = nil,
        height: Int? = nil
    ) {
        self.id = id
        self.type = type
        self.url = url
        self.thumbnail = thumbnail
        self.duration = duration
        self.width = width
        self.height = height
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: PostMedia, rhs: PostMedia) -> Bool {
        lhs.id == rhs.id
    }
    
    // MARK: - Mock Data
    static let mockImage = PostMedia(
        type: .image,
        url: "XXL_height",
        width: 1080,
        height: 1080
    )
    
    static let mockVideo = PostMedia(
        type: .video,
        url: "video_url",
        thumbnail: "XXL_height",
        duration: 15.0,
        width: 1080,
        height: 1920
    )
} 