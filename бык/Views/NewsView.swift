import SwiftUI

struct NewsView: View {
    @StateObject private var newsService = NewsService()
    @State private var selectedBrand: Restaurant.Brand?
    @State private var selectedNewsId: UUID?
    @State private var showingNewsDetail = false
    @State private var searchText = ""
    @State private var showingSearch = false
    @State private var isLoading = false
    @State private var searchSuggestions: [String] = []
    @State private var selectedTab = 0 // 0 - Новости, 1 - Публикации
    @State private var showProfile = false
    
    var filteredNews: [NewsItem] {
        let brandFiltered = newsService.filterNews(by: selectedBrand)
        
        if searchText.isEmpty {
            return brandFiltered
        }
        
        return newsService.searchNews(query: searchText).filter { news in
            selectedBrand == nil || news.brand == selectedBrand
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Сегментированный контрол
            Picker("", selection: $selectedTab) {
                Text("🐂 Новости").tag(0)
                Text("📱 Публикации").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Поисковая строка с улучшенной анимацией
            if showingSearch {
                VStack(spacing: 8) {
                    SearchBar(text: $searchText, placeholder: "Поиск новостей...")
                        .onChange(of: searchText) { _, newValue in
                            updateSearchSuggestions(query: newValue)
                        }
                    
                    // Подсказки поиска
                    if !searchText.isEmpty && !searchSuggestions.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(searchSuggestions, id: \.self) { suggestion in
                                    Button(action: {
                                        searchText = suggestion
                                    }) {
                                        Text(suggestion)
                                            .font(.caption)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(
                                                Capsule()
                                                    .fill(Colors.bykAccent.opacity(0.2))
                                            )
                                            .foregroundColor(Colors.bykAccent)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
            }
            
            // Фильтр по брендам с улучшенной анимацией
            BrandsFilterView(
                selectedBrand: selectedBrand,
                onSelect: { brand in
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        selectedBrand = brand
                    }
                }
            )
            .padding(.horizontal)
            .padding(.top, showingSearch ? 8 : 8)
            .transition(.scale.combined(with: .opacity))
            
            // Основной контент
            if selectedTab == 0 {
                // Новости
                ZStack {
                    if isLoading {
                        NewsLoadingView()
                            .transition(.opacity)
                    } else if filteredNews.isEmpty {
                        EmptyNewsView(searchText: searchText, selectedBrand: selectedBrand)
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .scale.combined(with: .opacity)
                            ))
                    } else {
                        NewsListView(
                            news: filteredNews,
                            selectedNewsId: $selectedNewsId,
                            showingNewsDetail: $showingNewsDetail
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .move(edge: .bottom).combined(with: .opacity)
                        ))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: selectedTab)
                    }
                }
            } else {
                // Публикации
                PostsView()
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: selectedTab)
            }
        }
        .navigationTitle(selectedTab == 0 ? "🐂 Новости" : "📱 Публикации")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    HapticManager.shared.buttonPress()
                    showProfile = true
                }) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color("BykAccent"), Color("BykPrimary")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
        }
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 12) {
                    // Кнопка поиска
                    Button(action: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            showingSearch.toggle()
                            if !showingSearch {
                                searchText = ""
                                searchSuggestions = []
                            }
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
                                .frame(width: 36, height: 36)
                                .scaleEffect(showingSearch ? 1.1 : 1.0)
                            
                            Image(systemName: showingSearch ? "xmark" : "magnifyingglass")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .medium))
                        }
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showingSearch)
                    }
                }
            }
        }
        .background(
            ZStack {
                Color.black
                
                // Плавающие элементы фона
                ForEach(0..<5, id: \.self) { index in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Colors.bykAccent.opacity(0.2),
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
                            .easeInOut(duration: Double.random(in: 4...8))
                            .repeatForever(autoreverses: true)
                            .delay(Double.random(in: 0...3)),
                            value: UUID()
                        )
                }
            }
        )
        .sheet(isPresented: $showingNewsDetail) {
            if let newsId = selectedNewsId {
                NewsDetailView(newsId: newsId, newsService: newsService)
            }
        }
        .onAppear {
            // Загрузка при первом открытии
            if newsService.news.isEmpty {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    isLoading = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        isLoading = false
                    }
                }
            }
            
            // Отладочная информация
            print("DEBUG: NewsView.onAppear - news count: \(newsService.news.count)")
            for (index, news) in newsService.news.enumerated() {
                print("DEBUG: NewsView.onAppear - news[\(index)] ID: \(news.id), title: \(news.title)")
            }
        }
        .sheet(isPresented: $showProfile) {
            ProfileView()
        }
    }
    
    private func updateSearchSuggestions(query: String) {
        guard !query.isEmpty else {
            searchSuggestions = []
            return
        }
        
        let allTitles = newsService.news.map { $0.title }
        let suggestions = allTitles.filter { title in
            title.localizedCaseInsensitiveContains(query)
        }.prefix(5)
        
        searchSuggestions = Array(suggestions)
    }
}

// Компонент списка новостей
struct NewsListView: View {
    let news: [NewsItem]
    @Binding var selectedNewsId: UUID?
    @Binding var showingNewsDetail: Bool
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(Array(news.enumerated()), id: \.element.id) { index, item in
                    NewsCard(item: item)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            print("DEBUG: News tapped with ID: \(item.id)")
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                selectedNewsId = item.id
                                showingNewsDetail = true
                            }
                        }
                        .scaleEffect(selectedNewsId == item.id ? 0.98 : 1.0)
                        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: selectedNewsId)
                        .padding(.horizontal)
                        .offset(y: 0)
                        .opacity(1.0)
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.8)
                            .delay(Double(index) * 0.1),
                            value: news.count
                        )
                }
            }
            .padding(.vertical, 20)
        }
        .refreshable {
            // Обновление при pull-to-refresh
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 секунда
        }
    }
}

// Компонент загрузки новостей
struct NewsLoadingView: View {
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
                Text("Загрузка новостей...")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Text("Подготавливаем для вас свежие новости")
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

struct EmptyNewsView: View {
    let searchText: String
    let selectedBrand: Restaurant.Brand?
    
    var body: some View {
        VStack(spacing: 20) {
            // Анимированная иконка
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
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var iconName: String {
        if !searchText.isEmpty {
            return "magnifyingglass"
        } else if selectedBrand != nil {
            return "tag"
        } else {
            return "newspaper"
        }
    }
    
    private var title: String {
        if !searchText.isEmpty {
            return "Ничего не найдено"
        } else if selectedBrand != nil {
            return "Нет новостей для \(selectedBrand?.rawValue ?? "")"
        } else {
            return "Нет доступных новостей"
        }
    }
    
    private var subtitle: String {
        if !searchText.isEmpty {
            return "Попробуйте изменить поисковый запрос или фильтры"
        } else if selectedBrand != nil {
            return "Попробуйте выбрать другой бренд или загляните позже"
        } else {
            return "Попробуйте изменить фильтры или загляните позже"
        }
    }
}

extension NewsType {
    var title: String {
        switch self {
        case .news: return "Новость"
        case .event: return "Событие"
        case .promotion: return "Акция"
        case .announcement: return "Анонс"
        case .update: return "Обновление"
        }
    }
}

#Preview {
    NewsView()
} 