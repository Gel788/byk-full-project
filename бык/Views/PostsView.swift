import SwiftUI

struct PostsView: View {
    @StateObject private var postService = PostService()
    @State private var selectedPost: Post?
    @State private var showingPostDetail = false
    @State private var showingCreatePost = false
    @State private var searchText = ""
    @State private var selectedRestaurant: Restaurant?
    @State private var showFilters = false
    
    private var filteredPosts: [Post] {
        var posts = postService.posts
        
        if !searchText.isEmpty {
            posts = postService.searchPosts(query: searchText)
        }
        
        if let restaurant = selectedRestaurant {
            posts = postService.filterPosts(by: restaurant)
        }
        
        return posts
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Анимированный фон
                PostsBackgroundView()
                
                VStack(spacing: 0) {
                    // Поисковая панель
                    PostsSearchBar(
                        searchText: $searchText,
                        selectedRestaurant: $selectedRestaurant,
                        showFilters: $showFilters
                    )
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Фильтры
                    if showFilters {
                        PostsFiltersView(
                            selectedRestaurant: $selectedRestaurant,
                            onClose: { showFilters = false }
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    // Основной контент
                    ZStack {
                        if postService.isLoading {
                            PostsLoadingView()
                                .transition(.opacity)
                        } else if filteredPosts.isEmpty {
                            PostsEmptyView(
                                searchText: searchText,
                                selectedRestaurant: selectedRestaurant
                            )
                            .transition(.scale.combined(with: .opacity))
                        } else {
                            PostsListView(
                                posts: filteredPosts,
                                selectedPost: $selectedPost,
                                showingPostDetail: $showingPostDetail,
                                postService: postService
                            )
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .move(edge: .bottom).combined(with: .opacity)
                            ))
                        }
                    }
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: filteredPosts.count)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: postService.isLoading)
                }
            }
            .navigationTitle("🐂 Публикации")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingCreatePost = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Colors.bykAccent,
                                            Colors.bykPrimary
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 36, height: 36)
                                .shadow(color: Colors.bykAccent.opacity(0.5), radius: 8, x: 0, y: 4)
                            
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingPostDetail) {
            if let post = selectedPost {
                PostDetailView(post: post, postService: postService)
            }
        }
        .sheet(isPresented: $showingCreatePost) {
            CreatePostView(postService: postService)
        }
        .refreshable {
            await Task {
                postService.loadPosts()
            }.value
        }
    }
}

// MARK: - Posts Background View
struct PostsBackgroundView: View {
    var body: some View {
        ZStack {
            Color.black
            
            // Плавающие элементы фона
            ForEach(0..<6, id: \.self) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Colors.bykAccent.opacity(0.15),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(width: CGFloat.random(in: 60...120))
                    .offset(
                        x: CGFloat.random(in: -250...250),
                        y: CGFloat.random(in: -500...500)
                    )
                    .animation(
                        .easeInOut(duration: Double.random(in: 6...10))
                        .repeatForever(autoreverses: true)
                        .delay(Double.random(in: 0...4)),
                        value: UUID()
                    )
            }
        }
    }
}

// MARK: - Posts Search Bar
struct PostsSearchBar: View {
    @Binding var searchText: String
    @Binding var selectedRestaurant: Restaurant?
    @Binding var showFilters: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Colors.bykAccent)
                
                TextField("Поиск публикаций...", text: $searchText)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Colors.bykAccent)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Colors.bykPrimary.opacity(0.2),
                                Colors.bykSecondary.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Colors.bykAccent.opacity(0.5),
                                        Colors.bykPrimary.opacity(0.3)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            
            Button(action: {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    showFilters.toggle()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Colors.bykAccent.opacity(0.3),
                                    Colors.bykPrimary.opacity(0.2)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Colors.bykAccent.opacity(0.5),
                                            Colors.bykPrimary.opacity(0.3)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                    
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - Posts Loading View
struct PostsLoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Colors.bykAccent.opacity(0.3),
                                Colors.bykPrimary.opacity(0.2)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 4
                    )
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Colors.bykAccent,
                                Colors.bykPrimary
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(.linear(duration: 1.2).repeatForever(autoreverses: false), value: isAnimating)
                
                Text("🐂")
                    .font(.system(size: 20))
                    .opacity(0.8)
            }
            
            VStack(spacing: 8) {
                Text("Загрузка публикаций...")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Text("Подготавливаем для вас свежие посты")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Posts Empty View
struct PostsEmptyView: View {
    let searchText: String
    let selectedRestaurant: Restaurant?
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Colors.bykAccent.opacity(0.2),
                                Colors.bykPrimary.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Colors.bykAccent.opacity(0.5),
                                        Colors.bykPrimary.opacity(0.3)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                
                Text("🐂")
                    .font(.system(size: 50))
                    .scaleEffect(1.0)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: UUID())
            }
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var title: String {
        if !searchText.isEmpty {
            return "Ничего не найдено"
        } else if selectedRestaurant != nil {
            return "Нет публикаций для \(selectedRestaurant?.name ?? "")"
        } else {
            return "Нет публикаций"
        }
    }
    
    private var subtitle: String {
        if !searchText.isEmpty {
            return "Попробуйте изменить поисковый запрос или фильтры"
        } else if selectedRestaurant != nil {
            return "Попробуйте выбрать другой ресторан или создайте первую публикацию!"
        } else {
            return "Будьте первым, кто поделится своими впечатлениями! 🐂"
        }
    }
}

#Preview {
    PostsView()
} 