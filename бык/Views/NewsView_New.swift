import SwiftUI

struct NewsView_New: View {
    @StateObject private var viewModel = NewsViewModel()
    @State private var showingProfile = false
    
    
    var body: some View {
        NavigationView {
            ZStack {
                // Фон
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        Color(.systemBackground).opacity(0.95),
                        Color(.systemGroupedBackground)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Отладочная информация (временно убираем)
                    /*
                    VStack {
                        Text("DEBUG: isLoading=\(viewModel.isLoading)")
                            .foregroundColor(.red)
                            .font(.caption)
                        Text("DEBUG: error=\(viewModel.error ?? "nil")")
                            .foregroundColor(.red)
                            .font(.caption)
                        Text("DEBUG: news.count=\(viewModel.news.count)")
                            .foregroundColor(.red)
                            .font(.caption)
                        Text("DEBUG: filteredNews.count=\(viewModel.filteredNews.count)")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    .padding()
                    */
                    
                    // Поиск и фильтры
                    SearchAndFiltersSection(viewModel: viewModel)
                    
                    // Список новостей
                    if viewModel.isLoading {
                        NewsLoadingViewNew()
                    } else if viewModel.error != nil {
                        NewsErrorView(error: viewModel.error ?? "Неизвестная ошибка") {
                            Task {
                                await viewModel.refreshNews()
                            }
                        }
                    } else if viewModel.filteredNews.isEmpty {
                        NewsEmptyStateView()
                    } else {
                        NewsListView_New(viewModel: viewModel)
                    }
                }
            }
            .navigationTitle("Новости")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingProfile = true
                    }) {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingProfile) {
                ProfileView_Simple()
            }
            .refreshable {
                await viewModel.refreshNews()
            }
        }
    }
}

struct SearchAndFiltersSection: View {
    @ObservedObject var viewModel: NewsViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            // Поиск
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .font(.system(size: 16))
                
                TextField("Поиск новостей...", text: $viewModel.searchText)
                    .font(.system(size: 16))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                
                if !viewModel.searchText.isEmpty {
                    Button(action: {
                        viewModel.searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 16))
                    }
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 16)
            
            // Фильтры по категориям
            if !viewModel.availableCategories.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        // Все новости
                        NewsFilterChip(
                            title: "Все",
                            isSelected: viewModel.selectedCategory == nil,
                            action: {
                                viewModel.selectedCategory = nil
                            }
                        )
                        
                        // Категории
                        ForEach(viewModel.availableCategories, id: \.self) { category in
                            NewsFilterChip(
                                title: category.rawValue,
                                isSelected: viewModel.selectedCategory == category,
                                action: {
                                    viewModel.selectedCategory = viewModel.selectedCategory == category ? nil : category
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            
            // Статистика
            if viewModel.hasVideoNews {
                HStack {
                    Image(systemName: "video.fill")
                        .foregroundColor(.blue)
                    Text("\(viewModel.videoNewsCount) видео")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Text("\(viewModel.filteredNews.count) новостей")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 8)
    }
}

struct NewsFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    isSelected ? Color.blue : Color(.systemGray6)
                )
                .cornerRadius(16)
        }
    }
}

struct NewsListView_New: View {
    @ObservedObject var viewModel: NewsViewModel
    
    var body: some View {
        VStack {
            // Отладочная информация (временно убираем)
            /*
            VStack {
                Text("DEBUG: NewsListView - filteredNews.count = \(viewModel.filteredNews.count)")
                    .foregroundColor(.green)
                    .font(.caption)
                Text("DEBUG: NewsListView - news.count = \(viewModel.news.count)")
                    .foregroundColor(.green)
                    .font(.caption)
            }
            .padding()
            */
            
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(viewModel.filteredNews) { newsItem in
                        NewsCardWithVideo(newsItem: newsItem)
                            .onAppear {
                                if !newsItem.isRead {
                                    viewModel.markAsRead(newsItem)
                                }
                            }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
    }
}

struct NewsLoadingViewNew: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Загрузка новостей...")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct NewsErrorView: View {
    let error: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("Ошибка загрузки")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(error)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button("Повторить", action: retryAction)
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct NewsEmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "newspaper")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("Новости не найдены")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Попробуйте изменить параметры поиска или фильтры")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NewsView_New()
}
