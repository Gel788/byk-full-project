import Foundation
import SwiftUI

@MainActor
class NewsService: ObservableObject {
    @Published var news: [NewsItem] = []
    @Published var isLoading = false
    @Published var error: String?
    
    init() {
        loadNews()
    }
    
    func loadNews() {
        isLoading = true
        error = nil
        
        // Загружаем данные сразу для тестирования
        self.news = [
            NewsItem(
                id: UUID(uuidString: "DABC5A12-68FF-464C-9809-0EF73C00CD54")!,
                title: "Новое сезонное меню в THE БЫК",
                description: "Мы рады представить вам наше новое сезонное меню, созданное специально для летнего сезона. Наши шеф-повара подготовили уникальные блюда, которые подчеркивают вкус и качество ингредиентов.",
                image: "XXL_height",
                date: Date().addingTimeInterval(-86400 * 2),
                brand: .theByk,
                type: .news,
                likes: 42,
                isLiked: false,
                comments: [
                    NewsComment(author: "Алексей", text: "Отличное меню! Обязательно попробую."),
                    NewsComment(author: "Мария", text: "Когда будет доступно в моем городе?")
                ],
                isRead: false
            ),
            NewsItem(
                id: UUID(uuidString: "27DCC686-1E0F-4CF9-9AEC-1E97C7DEB6FF")!,
                title: "Специальное предложение в THE ПИВО",
                description: "Только в эти выходные скидка 20% на все сорта крафтового пива! Приходите и насладитесь уникальными вкусами.",
                image: "XXL_heightw",
                date: Date().addingTimeInterval(-86400 * 5),
                brand: .thePivo,
                type: .promotion,
                likes: 28,
                isLiked: true,
                comments: [
                    NewsComment(author: "Дмитрий", text: "Выглядит аппетитно! 👍"),
                    NewsComment(author: "Анна", text: "Какие сорта пива будут в акции?")
                ],
                isRead: true
            ),
            NewsItem(
                id: UUID(uuidString: "66DBDD38-9474-471B-901F-4805D2B75858")!,
                title: "Открытие нового ресторана MOSCA",
                description: "Мы рады объявить об открытии нашего нового ресторана MOSCA в центре города. Современный интерьер и изысканная кухня ждут вас!",
                image: "XXL_heightww",
                date: Date().addingTimeInterval(-86400 * 7),
                brand: .mosca,
                type: .announcement,
                likes: 156,
                isLiked: false,
                comments: [
                    NewsComment(author: "Елена", text: "Ура! Наконец-то MOSCA в нашем городе!"),
                    NewsComment(author: "Сергей", text: "Какой адрес? Хочу прийти на открытие."),
                    NewsComment(author: "Ольга", text: "Будут ли специальные предложения на открытие?")
                ],
                isRead: false
            ),
            NewsItem(
                id: UUID(uuidString: "B8CBB911-508B-4547-AE6A-927FC6D62FF7")!,
                title: "Кулинарный мастер-класс",
                description: "Приглашаем всех желающих на кулинарный мастер-класс от наших шеф-поваров. Научитесь готовить фирменные блюда!",
                image: "XXL_heightwww",
                date: Date().addingTimeInterval(-86400 * 10),
                brand: .theByk,
                type: .event,
                likes: 89,
                isLiked: false,
                comments: [
                    NewsComment(author: "Ирина", text: "Очень интересно! Как записаться?"),
                    NewsComment(author: "Павел", text: "Сколько стоит участие?"),
                    NewsComment(author: "Татьяна", text: "Будут ли вегетарианские блюда?")
                ],
                isRead: true
            )
        ]
        self.isLoading = false
    }
    
    func refreshNews() {
        loadNews()
    }
    
    func filterNews(by brand: Restaurant.Brand?) -> [NewsItem] {
        guard let brand = brand else { return news }
        return news.filter { $0.brand == brand }
    }
    
    func searchNews(query: String) -> [NewsItem] {
        guard !query.isEmpty else { return news }
        return news.filter { news in
            news.title.localizedCaseInsensitiveContains(query) ||
            news.description.localizedCaseInsensitiveContains(query)
        }
    }
    
    // MARK: - Лайки и комментарии
    
    func likeNews(id: UUID) {
        if let index = news.firstIndex(where: { $0.id == id }) {
            news[index].isLiked.toggle()
            if news[index].isLiked {
                news[index].likes += 1
            } else {
                news[index].likes = max(0, news[index].likes - 1)
            }
        }
    }
    
    func addComment(newsId: UUID, comment: NewsComment) {
        if let index = news.firstIndex(where: { $0.id == newsId }) {
            news[index].comments.append(comment)
        }
    }
    
    func getNews(by id: UUID) -> NewsItem? {
        print("DEBUG: NewsService.getNews - searching for ID: \(id)")
        print("DEBUG: NewsService.getNews - available news count: \(news.count)")
        let item = news.first { $0.id == id }
        print("DEBUG: NewsService.getNews - found item: \(item != nil)")
        return item
    }
    
    // MARK: - Отслеживание прочтения
    
    func markAsRead(id: UUID) {
        if let index = news.firstIndex(where: { $0.id == id }) {
            news[index].isRead = true
        }
    }
    
    func getUnreadCount() -> Int {
        return news.filter { !$0.isRead }.count
    }
} 