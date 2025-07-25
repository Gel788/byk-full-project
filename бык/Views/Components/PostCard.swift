import SwiftUI

struct PostCard: View {
    let post: Post
    @ObservedObject var postService: PostService
    @State private var isPressed = false
    @State private var isHovered = false
    @State private var imageScale: CGFloat = 1.0
    @State private var cardOffset: CGFloat = 0
    @State private var showingComments = false
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color) {
        if let restaurant = post.taggedRestaurant {
            return Colors.brandColors(for: restaurant.brand)
        } else {
            return (Colors.bykPrimary, Colors.bykSecondary, Colors.bykAccent)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Заголовок с автором
            PostHeaderView(post: post, brandColors: brandColors)
            
            // Медиа контент
            PostMediaView(
                media: post.media,
                imageScale: $imageScale,
                isHovered: $isHovered
            )
            
            // Действия
            PostActionsView(
                post: post,
                postService: postService,
                brandColors: brandColors,
                showingComments: $showingComments
            )
            
            // Контент и хештеги
            PostContentView(post: post, brandColors: brandColors)
        }
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.9),
                    Color.black.opacity(0.7)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            brandColors.accent.opacity(0.3),
                            brandColors.primary.opacity(0.2),
                            Color.clear
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(
            color: Color.black.opacity(isHovered ? 0.6 : 0.3),
            radius: isHovered ? 16 : 12,
            x: 0,
            y: isHovered ? 10 : 6
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .offset(y: cardOffset)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isHovered)
        .onHover { hovering in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isHovered = hovering
                imageScale = hovering ? 1.05 : 1.0
                cardOffset = hovering ? -4 : 0
            }
        }
        .sheet(isPresented: $showingComments) {
            CommentsView(postId: post.id, postService: postService)
        }
    }
}

// MARK: - Post Header View
struct PostHeaderView: View {
    let post: Post
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        HStack(spacing: 12) {
            // Аватар автора
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                brandColors.accent,
                                brandColors.primary
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                
                if let avatar = post.authorAvatar {
                    AsyncImage(url: URL(string: avatar)) { image in
                        image.resizable()
                            .clipShape(Circle())
                    } placeholder: {
                        Text(post.authorName.prefix(1).uppercased())
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                } else {
                    Text(post.authorName.prefix(1).uppercased())
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(post.authorName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    
                    if post.authorName == User.mock.fullName {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 12))
                            .foregroundColor(brandColors.accent)
                    }
                }
                
                Text(post.formattedDate)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            // Отмеченный ресторан
            if let restaurant = post.taggedRestaurant {
                HStack(spacing: 4) {
                    Text("🐂")
                        .font(.system(size: 12))
                    
                    Text(restaurant.name)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(brandColors.accent)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(brandColors.accent.opacity(0.15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(brandColors.accent.opacity(0.3), lineWidth: 1)
                        )
                )
            }
        }
        .padding(16)
    }
}

// MARK: - Post Media View
struct PostMediaView: View {
    let media: [PostMedia]
    @Binding var imageScale: CGFloat
    @Binding var isHovered: Bool
    
    var body: some View {
        if let firstMedia = media.first {
            ZStack(alignment: .topTrailing) {
                // Контейнер для центрирования изображения
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        // Основное изображение
                        if let image = loadImageFromDocuments(firstMedia.url) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity)
                                .frame(maxHeight: 300)
                                .background(Color.black.opacity(0.1))
                                .scaleEffect(imageScale)
                                .animation(.easeInOut(duration: 0.3), value: imageScale)
                        } else {
                            // Заглушка если изображение не найдено
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.3))
                                .frame(maxWidth: .infinity)
                                .frame(height: 200)
                                .overlay(
                                    VStack(spacing: 8) {
                                        Text("📷")
                                            .font(.system(size: 40))
                                            .opacity(0.6)
                                        
                                        Text("Изображение не найдено")
                                            .font(.system(size: 14))
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                )
                        }
                        Spacer()
                    }
                    Spacer()
                }
                
                // Индикатор типа медиа
                if media.count > 1 {
                    HStack(spacing: 4) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 12, weight: .medium))
                        Text("\(media.count)")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.7))
                    )
                    .padding(12)
                } else if firstMedia.type == .video {
                    HStack(spacing: 4) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 12, weight: .medium))
                        if let duration = firstMedia.duration {
                            Text(formatDuration(duration))
                                .font(.system(size: 12, weight: .medium))
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.7))
                    )
                    .padding(12)
                }
            }
        }
    }
    
    private func loadImageFromDocuments(_ fileName: String) -> UIImage? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        guard let imageData = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: imageData)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Post Actions View
struct PostActionsView: View {
    let post: Post
    @ObservedObject var postService: PostService
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    @Binding var showingComments: Bool
    
    @State private var likePressed = false
    @State private var commentPressed = false
    @State private var sharePressed = false
    
    var body: some View {
        HStack(spacing: 0) {
            // Левая группа кнопок
            HStack(spacing: 20) {
                // Кнопка лайка
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        likePressed = true
                    }
                    
                    Task {
                        if post.isLiked {
                            await postService.unlikePost(post.id)
                        } else {
                            await postService.likePost(post.id)
                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        likePressed = false
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 18))
                            .foregroundColor(post.isLiked ? .red : .white)
                            .scaleEffect(likePressed ? 1.3 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: likePressed)
                        
                        Text("\(post.likes)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                // Кнопка комментариев
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        commentPressed = true
                        showingComments = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        commentPressed = false
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.left")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .scaleEffect(commentPressed ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: commentPressed)
                        
                        Text("\(post.comments)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Spacer()
            
            // Правая группа кнопок
            HStack(spacing: 20) {
                // Кнопка поделиться
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        sharePressed = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        sharePressed = false
                    }
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .scaleEffect(sharePressed ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: sharePressed)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Post Content View
struct PostContentView: View {
    let post: Post
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Основной контент
            Text(post.content)
                .font(.system(size: 14))
                .foregroundColor(.white)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Хештеги
            if !post.hashtags.isEmpty {
                Text(post.hashtagString)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(brandColors.accent)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
}

#Preview {
    PostCard(post: Post.mock, postService: PostService())
        .padding()
        .background(Color.black)
} 