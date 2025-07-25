import SwiftUI

struct PostDetailView: View {
    let post: Post
    @ObservedObject var postService: PostService
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingComments = false
    @State private var showingShare = false
    @State private var showingAnalytics = false
    @State private var currentMediaIndex = 0
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color) {
        if let restaurant = post.taggedRestaurant {
            return Colors.brandColors(for: restaurant.brand)
        } else {
            return (Colors.bykPrimary, Colors.bykSecondary, Colors.bykAccent)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Анимированный фон
                PostDetailBackgroundView()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Медиа галерея
                        PostDetailMediaGallery(
                            media: post.media,
                            currentIndex: $currentMediaIndex
                        )
                        
                        VStack(spacing: 20) {
                            // Заголовок с автором
                            PostDetailHeaderView(post: post, brandColors: brandColors)
                            
                            // Контент
                            PostDetailContentView(post: post, brandColors: brandColors)
                            
                            // Статистика
                            PostDetailStatsView(post: post, brandColors: brandColors)
                            
                            // Действия
                            PostDetailActionsView(
                                post: post,
                                postService: postService,
                                brandColors: brandColors,
                                showingComments: $showingComments,
                                showingShare: $showingShare,
                                showingAnalytics: $showingAnalytics
                            )
                            
                            // Отмеченный ресторан
                            if let restaurant = post.taggedRestaurant {
                                PostDetailRestaurantView(
                                    restaurant: restaurant,
                                    brandColors: brandColors
                                )
                            }
                            
                            // Хештеги
                            if !post.hashtags.isEmpty {
                                PostDetailHashtagsView(
                                    hashtags: post.hashtags,
                                    brandColors: brandColors
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.7))
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingAnalytics = true }) {
                            Label("Аналитика", systemImage: "chart.bar")
                        }
                        
                        Button(action: { showingShare = true }) {
                            Label("Поделиться", systemImage: "square.and.arrow.up")
                        }
                        
                        if post.authorName == User.mock.fullName {
                            Button(role: .destructive, action: deletePost) {
                                Label("Удалить", systemImage: "trash")
                            }
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.7))
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: "ellipsis")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingComments) {
            CommentsView(postId: post.id, postService: postService)
        }
        .sheet(isPresented: $showingShare) {
            SharePostView(post: post)
        }
        .sheet(isPresented: $showingAnalytics) {
            PostAnalyticsView(post: post, postService: postService)
        }
    }
    
    private func deletePost() {
        Task {
            await postService.deletePost(post.id)
            dismiss()
        }
    }
}

// MARK: - Post Detail Background View
struct PostDetailBackgroundView: View {
    var body: some View {
        ZStack {
            Color.black
            
            // Плавающие элементы фона
            ForEach(0..<5, id: \.self) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Colors.bykAccent.opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 60
                        )
                    )
                    .frame(width: CGFloat.random(in: 40...80))
                    .offset(
                        x: CGFloat.random(in: -200...200),
                        y: CGFloat.random(in: -400...400)
                    )
                    .animation(
                        .easeInOut(duration: Double.random(in: 8...12))
                        .repeatForever(autoreverses: true)
                        .delay(Double.random(in: 0...6)),
                        value: UUID()
                    )
            }
        }
    }
}

// MARK: - Post Detail Media Gallery
struct PostDetailMediaGallery: View {
    let media: [PostMedia]
    @Binding var currentIndex: Int
    
    var body: some View {
        if !media.isEmpty {
            TabView(selection: $currentIndex) {
                ForEach(Array(media.enumerated()), id: \.element.id) { index, mediaItem in
                    ZStack(alignment: .topTrailing) {
                        Image(mediaItem.url)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity)
                            .frame(height: 400)
                            .clipped()
                        
                        // Индикатор типа медиа
                        if mediaItem.type == .video {
                            HStack(spacing: 4) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 12, weight: .medium))
                                if let duration = mediaItem.duration {
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
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: media.count > 1 ? .automatic : .never))
            .frame(height: 400)
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Post Detail Header View
struct PostDetailHeaderView: View {
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
                    .frame(width: 48, height: 48)
                
                if let avatar = post.authorAvatar {
                    AsyncImage(url: URL(string: avatar)) { image in
                        image.resizable()
                            .clipShape(Circle())
                    } placeholder: {
                        Text(post.authorName.prefix(1).uppercased())
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                } else {
                    Text(post.authorName.prefix(1).uppercased())
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(post.authorName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    if post.authorName == User.mock.fullName {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 14))
                            .foregroundColor(brandColors.accent)
                    }
                }
                
                Text(post.formattedDate)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
        }
    }
}

// MARK: - Post Detail Content View
struct PostDetailContentView: View {
    let post: Post
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(post.content)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .lineSpacing(4)
                .multilineTextAlignment(.leading)
        }
    }
}

// MARK: - Post Detail Stats View
struct PostDetailStatsView: View {
    let post: Post
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        HStack(spacing: 24) {
            StatItem(
                icon: "heart.fill",
                value: "\(post.likes)",
                color: .red
            )
            
            StatItem(
                icon: "bubble.left.fill",
                value: "\(post.comments)",
                color: brandColors.accent
            )
            
            StatItem(
                icon: "eye.fill",
                value: "\(Int.random(in: post.likes * 3...post.likes * 10))",
                color: .blue
            )
            
            Spacer()
        }
    }
}

// MARK: - Stat Item
struct StatItem: View {
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Post Detail Actions View
struct PostDetailActionsView: View {
    let post: Post
    @ObservedObject var postService: PostService
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    @Binding var showingComments: Bool
    @Binding var showingShare: Bool
    @Binding var showingAnalytics: Bool
    
    @State private var likePressed = false
    @State private var commentPressed = false
    @State private var sharePressed = false
    
    var body: some View {
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
                HStack(spacing: 8) {
                    Image(systemName: post.isLiked ? "heart.fill" : "heart")
                        .font(.system(size: 20))
                        .foregroundColor(post.isLiked ? .red : .white)
                        .scaleEffect(likePressed ? 1.3 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: likePressed)
                    
                    Text("\(post.likes)")
                        .font(.system(size: 16, weight: .medium))
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
                HStack(spacing: 8) {
                    Image(systemName: "bubble.left")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .scaleEffect(commentPressed ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: commentPressed)
                    
                    Text("\(post.comments)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            // Кнопка поделиться
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    sharePressed = true
                    showingShare = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    sharePressed = false
                }
            }) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .scaleEffect(sharePressed ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: sharePressed)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Post Detail Restaurant View
struct PostDetailRestaurantView: View {
    let restaurant: Restaurant
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Отмеченный ресторан")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            HStack(spacing: 12) {
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
                    
                    Text("🐂")
                        .font(.system(size: 20))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(restaurant.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(restaurant.address)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                Button("Открыть") {
                    // Открыть детали ресторана
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(brandColors.accent)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(brandColors.accent.opacity(0.15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(brandColors.accent.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - Post Detail Hashtags View
struct PostDetailHashtagsView: View {
    let hashtags: [String]
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Хештеги")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 100))
            ], spacing: 8) {
                ForEach(hashtags, id: \.self) { hashtag in
                    Text("#\(hashtag)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(brandColors.accent)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(brandColors.accent.opacity(0.15))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(brandColors.accent.opacity(0.3), lineWidth: 1)
                                )
                        )
                }
            }
        }
    }
}

#Preview {
    PostDetailView(post: Post.mock, postService: PostService())
} 