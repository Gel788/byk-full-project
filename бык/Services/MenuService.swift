import Foundation
import Combine

@MainActor
class MenuService: ObservableObject {
    @Published var dishes: [Dish] = []
    @Published var categories: [CategoryAPI] = []
    @Published var loadingState: LoadingState = .idle
    @Published var error: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let apiService = APIService.shared
    
    init() {
        print("MenuService: Инициализация")
        loadMenuFromAPI()
    }
    
    @MainActor
    func loadMenuFromAPI() {
        print("MenuService: Начинаем загрузку меню из API...")
        loadingState = .loading
        error = nil
        
        // Загружаем блюда и категории параллельно
        let dishesPublisher = apiService.fetchDishes()
        let categoriesPublisher = apiService.fetchCategories()
        
        Publishers.Zip(dishesPublisher, categoriesPublisher)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.loadingState = .error(error.localizedDescription)
                        self?.error = error.localizedDescription
                        print("MenuService: Ошибка загрузки меню - \(error)")
                        // Если API не работает, загружаем mock данные
                        self?.loadMockData()
                    }
                },
                receiveValue: { [weak self] (apiDishes, apiCategories) in
                    print("MenuService: Получены данные с сервера:")
                    print("  - Блюд: \(apiDishes.count)")
                    print("  - Категорий: \(apiCategories.count)")
                    
                    self?.dishes = apiDishes.map { $0.toLocalDish() }
                    self?.categories = apiCategories
                    self?.loadingState = .loaded
                    
                    print("MenuService: Преобразовано в локальные модели:")
                    print("  - Локальных блюд: \(self?.dishes.count ?? 0)")
                    print("  - Локальных категорий: \(self?.categories.count ?? 0)")
                    
                    // Логируем ID всех блюд
                    if let dishes = self?.dishes {
                        print("MenuService: ID блюд:")
                        for (index, dish) in dishes.enumerated() {
                            print("  [\(index)] ID: \(dish.id), Name: \(dish.name)")
                        }
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    @MainActor
    private func loadMockData() {
        loadingState = .loading
        
        // Имитация загрузки данных
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 секунда
            await loadMockDishes()
        }
    }
    
    @MainActor
    private func loadMockDishes() {
        // Mock данные для демонстрации
        let mockDishes = [
            Dish(
                name: "Стейк Рибай",
                description: "Сочный стейк из мраморной говядины, прожаренный до совершенства",
                price: 2500,
                image: "https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=400",
                category: "Стейки",
                restaurantBrand: .theByk,
                isAvailable: true,
                preparationTime: 25,
                calories: 650,
                allergens: ["Глютен"]
            ),
            Dish(
                name: "Цезарь с креветками",
                description: "Классический салат Цезарь с тигровыми креветками и пармезаном",
                price: 890,
                image: "https://images.unsplash.com/photo-1546793665-c74683f339c1?w=400",
                category: "Салаты",
                restaurantBrand: .theByk,
                isAvailable: true,
                preparationTime: 15,
                calories: 420,
                allergens: ["Морепродукты", "Молочные продукты"]
            ),
            Dish(
                name: "Паста Карбонара",
                description: "Классическая итальянская паста с беконом, яйцом и пармезаном",
                price: 1200,
                image: "https://images.unsplash.com/photo-1621996346565-e3dbc353d2e5?w=400",
                category: "Паста",
                restaurantBrand: .theByk,
                isAvailable: true,
                preparationTime: 20,
                calories: 580,
                allergens: ["Глютен", "Молочные продукты", "Яйца"]
            ),
            Dish(
                name: "Тирамису",
                description: "Классический итальянский десерт с кофе и маскарпоне",
                price: 650,
                image: "https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=400",
                category: "Десерты",
                restaurantBrand: .theByk,
                isAvailable: true,
                preparationTime: 10,
                calories: 320,
                allergens: ["Молочные продукты", "Яйца", "Глютен"]
            )
        ]
        
        self.dishes = mockDishes
        self.loadingState = .loaded
        print("MenuService: Загружены mock данные - \(mockDishes.count) блюд")
    }
    
    func getDishesByCategory(_ category: String) -> [Dish] {
        return dishes.filter { $0.category == category }
    }
    
    func getDishesByBrand(_ brand: Restaurant.Brand) -> [Dish] {
        return dishes.filter { $0.restaurantBrand == brand }
    }
    
    func getAvailableCategories() -> [String] {
        let categories = Set(dishes.map { $0.category })
        return Array(categories).sorted()
    }
    
    func searchDishes(query: String) -> [Dish] {
        if query.isEmpty {
            return dishes
        }
        
        return dishes.filter { dish in
            dish.name.localizedCaseInsensitiveContains(query) ||
            dish.description.localizedCaseInsensitiveContains(query)
        }
    }
}

