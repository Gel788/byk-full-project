import Foundation
import SwiftUI
import Combine

@MainActor
class NewsViewModel: ObservableObject {
    @Published var news: [NewsItem] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var searchText = ""
    @Published var selectedCategory: NewsType? = nil
    
    private var cancellables = Set<AnyCancellable>()
    private let newsService = NewsService()
    
    init() {
        print("DEBUG: NewsViewModel init called")
        loadNews()
        setupSearch()
    }
    
    func loadNews() {
        isLoading = true
        error = nil
        
        // Подписываемся на изменения в NewsService
        newsService.$news
            .receive(on: DispatchQueue.main)
            .sink { [weak self] news in
                self?.news = news
                self?.isLoading = false
            }
            .store(in: &cancellables)
        
        newsService.$isLoading
            .receive(on: DispatchQueue.main)
            .assign(to: &$isLoading)
        
        newsService.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.error = error
            }
            .store(in: &cancellables)
    }
    
    func refreshNews() async {
        await MainActor.run {
            isLoading = true
            error = nil
        }
        
        newsService.loadNewsFromAPI()
    }
    
    private func setupSearch() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.filterNews()
            }
            .store(in: &cancellables)
        
        $selectedCategory
            .sink { [weak self] _ in
                self?.filterNews()
            }
            .store(in: &cancellables)
    }
    
    private func filterNews() {
        // Фильтрация будет происходить в computed property filteredNews
        objectWillChange.send()
    }
    
    var filteredNews: [NewsItem] {
        var filtered = news
        
        // Фильтр по тексту поиска
        if !searchText.isEmpty {
            filtered = filtered.filter { newsItem in
                newsItem.title.localizedCaseInsensitiveContains(searchText) ||
                newsItem.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Фильтр по категории
        if let selectedCategory = selectedCategory {
            filtered = filtered.filter { newsItem in
                newsItem.type == selectedCategory
            }
        }
        return filtered
    }
    
    func toggleLike(for newsItem: NewsItem) {
        if let index = news.firstIndex(where: { $0.id == newsItem.id }) {
            news[index].isLiked.toggle()
            if news[index].isLiked {
                news[index].likes += 1
            } else {
                news[index].likes = max(0, news[index].likes - 1)
            }
        }
    }
    
    func markAsRead(_ newsItem: NewsItem) {
        if let index = news.firstIndex(where: { $0.id == newsItem.id }) {
            news[index].isRead = true
        }
    }
    
    var availableCategories: [NewsType] {
        let categories = Set(news.map { $0.type })
        return Array(categories).sorted { $0.rawValue < $1.rawValue }
    }
    
    var hasVideoNews: Bool {
        news.contains { $0.videoURL != nil && !$0.videoURL!.isEmpty }
    }
    
    var videoNewsCount: Int {
        news.filter { $0.videoURL != nil && !$0.videoURL!.isEmpty }.count
    }
}
