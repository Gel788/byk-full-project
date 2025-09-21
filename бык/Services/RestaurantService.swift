import Foundation
import Combine

@MainActor
class RestaurantService: ObservableObject {
    @Published var restaurants: [Restaurant] = []
    @Published var loadingState: LoadingState = .idle
    @Published var error: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let apiService = APIService.shared
    
    init() {
        loadRestaurantsFromAPI()
    }
    
    @MainActor
    private func loadRestaurantsFromAPI() {
        loadingState = .loading
        error = nil
        
        apiService.fetchRestaurants()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.loadingState = .idle
                    if case .failure(let error) = completion {
                        self?.error = error.localizedDescription
                        // Если API не работает, загружаем mock данные
                        self?.loadMockData()
                    }
                },
                receiveValue: { [weak self] apiRestaurants in
                    self?.restaurants = apiRestaurants.map { $0.toLocalRestaurant() }
                    self?.loadingState = .loaded
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
            await loadRestaurantsData()
        }
    }
    
    @MainActor
    private func loadRestaurantsData() {
        
    // MARK: - Public Methods
    
    func refreshData() {
        loadRestaurantsFromAPI()
    }
    
    func getAllDishes() -> [Dish] {
        return restaurants.flatMap { $0.menu }
    }
        // Функция для генерации блюд по бренду
        func generateMenu(for brand: Restaurant.Brand) -> [Dish] {
            switch brand {
            case .theByk:
                return [
                    Dish(name: "Рибай стейк", description: "Премиальный стейк из мраморной говядины", price: 3200, image: "ribai_steak", category: "Стейки", restaurantBrand: .theByk),
                    Dish(name: "Стриплойн стейк", description: "Стейк из поясничной части", price: 2800, image: "ribai_steak", category: "Стейки", restaurantBrand: .theByk),
                    Dish(name: "Цезарь с курицей", description: "Классический салат с куриным филе", price: 750, image: "caesar_salad", category: "Салаты", restaurantBrand: .theByk),
                    Dish(name: "Карбонара", description: "Паста с беконом, яйцом и пармезаном", price: 650, image: "pasta_carbonara", category: "Паста", restaurantBrand: .theByk)
                ]
            case .thePivo:
                return [
                    Dish(name: "Фирменные колбаски", description: "Ассорти из трех видов колбасок", price: 890, image: "sausages", category: "Закуски", restaurantBrand: .thePivo),
                    Dish(name: "Крафтовое пиво", description: "Свежее крафтовое пиво", price: 350, image: "pretzel", category: "Напитки", restaurantBrand: .thePivo),
                    Dish(name: "Брецель", description: "Немецкий крендель с солью", price: 250, image: "pretzel", category: "Закуски", restaurantBrand: .thePivo),
                    Dish(name: "Сырная тарелка", description: "Ассорти из европейских сыров", price: 650, image: "sausages", category: "Закуски", restaurantBrand: .thePivo)
                ]
            case .mosca:
                return [
                    Dish(name: "Пицца Маргарита", description: "Классическая итальянская пицца", price: 650, image: "pizza_margherita", category: "Пицца", restaurantBrand: .mosca),
                    Dish(name: "Паста Карбонара", description: "Спагетти с беконом и пармезаном", price: 750, image: "pasta_carbonara", category: "Паста", restaurantBrand: .mosca),
                    Dish(name: "Брускетта", description: "Тосты с томатами и базиликом", price: 350, image: "caesar_salad", category: "Закуски", restaurantBrand: .mosca),
                    Dish(name: "Тирамису", description: "Классический итальянский десерт", price: 450, image: "pizza_margherita", category: "Десерты", restaurantBrand: .mosca)
                ]
            case .theGeorgia:
                return [
                    Dish(name: "Хинкали", description: "Классические грузинские хинкали с мясом.", price: 490, image: "ribai_steak", category: "Горячее", restaurantBrand: .theGeorgia),
                    Dish(name: "Хачапури по-аджарски", description: "Лодочка с сыром и яйцом.", price: 550, image: "pizza_margherita", category: "Выпечка", restaurantBrand: .theGeorgia),
                    Dish(name: "Лобио", description: "Фасоль с пряностями и зеленью.", price: 350, image: "caesar_salad", category: "Закуски", restaurantBrand: .theGeorgia),
                    Dish(name: "Шашлык из баранины", description: "Сочный шашлык на углях.", price: 890, image: "ribai_steak", category: "Гриль", restaurantBrand: .theGeorgia),
                    Dish(name: "Сациви", description: "Курица в ореховом соусе.", price: 670, image: "pasta_carbonara", category: "Горячее", restaurantBrand: .theGeorgia)
                ]
            }
        }
        
        // THE БЫК
        let bykRestaurants = [
            Restaurant(
                name: "THE БЫК на Тверской",
                description: "Премиальные стейки из мраморной говядины",
                address: "ул. Тверская, 15",
                city: "Москва",
                imageURL: "94033",
                rating: 4.8,
                cuisine: "Стейк-хаус",
                deliveryTime: 45,
                brand: .theByk,
                menu: [
                    Dish(
                        name: "Рибай стейк",
                        description: "Премиальный стейк из мраморной говядины",
                        price: 3200,
                        image: "ribai_steak",
                        category: "Стейки",
                        restaurantBrand: .theByk
                    ),
                    Dish(
                        name: "Стриплойн стейк",
                        description: "Стейк из поясничной части",
                        price: 2800,
                        image: "ribai_steak",
                        category: "Стейки",
                        restaurantBrand: .theByk
                    ),
                    Dish(
                        name: "Цезарь с курицей",
                        description: "Классический салат с куриным филе",
                        price: 750,
                        image: "caesar_salad",
                        category: "Салаты",
                        restaurantBrand: .theByk
                    )
                ],
                features: [.parking, .wifi, .reservation, .cardPayment, .liveMusic, .takeaway],
                workingHours: .default,
                location: Location(latitude: 55.7558, longitude: 37.6173),
                tables: Table.mockTables
            ),
            Restaurant(
                name: "THE БЫК на Арбате",
                description: "Уютный стейк-хаус в историческом центре",
                address: "ул. Арбат, 25",
                city: "Москва",
                imageURL: "94033",
                rating: 4.7,
                cuisine: "Стейк-хаус",
                deliveryTime: 50,
                brand: .theByk,
                menu: generateMenu(for: .theByk),
                features: [.parking, .wifi, .reservation, .cardPayment, .takeaway],
                workingHours: .default,
                location: Location(latitude: 55.7494, longitude: 37.5914),
                tables: Table.mockTables
            ),
            Restaurant(
                name: "THE БЫК в Калуге Центр",
                description: "Лучшие стейки в центре Калуги!",
                address: "ул. Кирова, 10",
                city: "Калуга",
                imageURL: "94033",
                rating: 4.6,
                cuisine: "Стейк-хаус",
                deliveryTime: 50,
                brand: .theByk,
                menu: generateMenu(for: .theByk),
                features: [.parking, .wifi, .reservation, .cardPayment, .takeaway],
                workingHours: .default,
                location: Location(latitude: 54.5293, longitude: 36.2754),
                tables: Table.mockTables
            ),
            Restaurant(
                name: "THE БЫК Калуга Парк",
                description: "Стейк-хаус в парковой зоне Калуги",
                address: "ул. Пушкина, 5",
                city: "Калуга",
                imageURL: "94033",
                rating: 4.5,
                cuisine: "Стейк-хаус",
                deliveryTime: 55,
                brand: .theByk,
                menu: generateMenu(for: .theByk),
                features: [.parking, .wifi, .reservation, .cardPayment, .takeaway],
                workingHours: .default,
                location: Location(latitude: 54.5312, longitude: 36.2734),
                tables: Table.mockTables
            ),
            Restaurant(
                name: "THE БЫК на Невском",
                description: "Премиальные стейки и уютная атмосфера в центре Питера.",
                address: "Невский проспект, 100",
                city: "Санкт-Петербург",
                imageURL: "94033",
                rating: 4.7,
                cuisine: "Стейк-хаус",
                deliveryTime: 55,
                brand: .theByk,
                menu: generateMenu(for: .theByk),
                features: [.parking, .wifi, .reservation, .cardPayment, .takeaway],
                workingHours: .default,
                location: Location(latitude: 59.9343, longitude: 30.3351),
                tables: Table.mockTables
            ),
            Restaurant(
                name: "THE БЫК Васильевский остров",
                description: "Стейк-хаус с видом на Неву",
                address: "наб. Макарова, 15",
                city: "Санкт-Петербург",
                imageURL: "94033",
                rating: 4.8,
                cuisine: "Стейк-хаус",
                deliveryTime: 60,
                brand: .theByk,
                menu: generateMenu(for: .theByk),
                features: [.parking, .wifi, .reservation, .cardPayment, .takeaway],
                workingHours: .default,
                location: Location(latitude: 59.9363, longitude: 30.3151),
                tables: Table.mockTables
            ),
            Restaurant(
                name: "THE БЫК Ереван Центр",
                description: "Настоящие стейки теперь и в Армении!",
                address: "проспект Маштоца, 20",
                city: "Ереван",
                imageURL: "94033",
                rating: 4.9,
                cuisine: "Стейк-хаус",
                deliveryTime: 60,
                brand: .theByk,
                menu: generateMenu(for: .theByk),
                features: [.parking, .wifi, .reservation, .cardPayment, .takeaway],
                workingHours: .default,
                location: Location(latitude: 40.1792, longitude: 44.4991),
                tables: Table.mockTables
            ),
            Restaurant(
                name: "THE БЫК Ереван Каскад",
                description: "Стейк-хаус у знаменитого каскада",
                address: "ул. Таманяна, 10",
                city: "Ереван",
                imageURL: "94033",
                rating: 4.7,
                cuisine: "Стейк-хаус",
                deliveryTime: 65,
                brand: .theByk,
                menu: generateMenu(for: .theByk),
                features: [.parking, .wifi, .reservation, .cardPayment, .takeaway],
                workingHours: .default,
                location: Location(latitude: 40.1912, longitude: 44.5151),
                tables: Table.mockTables
            )
        ]
        
        // THE ПИВО
        let pivoRestaurants = [
            Restaurant(
                name: "THE ПИВО на Маросейке",
                description: "Крафтовое пиво и закуски",
                address: "ул. Маросейка, 7",
                city: "Москва",
                imageURL: "94033",
                rating: 4.6,
                cuisine: "Пивной ресторан",
                deliveryTime: 40,
                brand: .thePivo,
                menu: generateMenu(for: .thePivo),
                features: [.wifi, .reservation, .cardPayment, .summerTerrace, .takeaway],
                workingHours: .default,
                location: Location(latitude: 55.7558, longitude: 37.6173),
                tables: Table.mockTables
            ),
            Restaurant(
                name: "THE ПИВО в Хамовниках",
                description: "Большой выбор крафтового пива",
                address: "ул. Льва Толстого, 18",
                city: "Москва",
                imageURL: "94033",
                rating: 4.5,
                cuisine: "Пивной ресторан",
                deliveryTime: 35,
                brand: .thePivo,
                menu: generateMenu(for: .thePivo),
                features: [.wifi, .reservation, .cardPayment, .summerTerrace, .takeaway],
                workingHours: .default,
                location: Location(latitude: 55.7558, longitude: 37.6173),
                tables: Table.mockTables
            )
        ]
        
        // MOSCA
        let moscaRestaurants = [
            Restaurant(
                name: "MOSCA на Пречистенке",
                description: "Аутентичная итальянская кухня",
                address: "ул. Пречистенка, 4",
                city: "Москва",
                imageURL: "94033",
                rating: 4.9,
                cuisine: "Итальянский ресторан",
                deliveryTime: 55,
                brand: .mosca,
                menu: generateMenu(for: .mosca),
                features: [.parking, .wifi, .reservation, .cardPayment, .businessLunch, .takeaway],
                workingHours: .default,
                location: Location(latitude: 55.7558, longitude: 37.6173),
                tables: Table.mockTables
            ),
            Restaurant(
                name: "MOSCA на Никольской",
                description: "Изысканная итальянская кухня",
                address: "ул. Никольская, 10",
                city: "Москва",
                imageURL: "94033",
                rating: 4.7,
                cuisine: "Итальянский ресторан",
                deliveryTime: 45,
                brand: .mosca,
                menu: generateMenu(for: .mosca),
                features: [.parking, .wifi, .reservation, .cardPayment, .businessLunch, .takeaway],
                workingHours: .default,
                location: Location(latitude: 55.7558, longitude: 37.6173),
                tables: Table.mockTables
            )
        ]
        
        let georgiaRestaurants = [
            Restaurant(
                name: "THE ГРУЗИЯ на Арбате",
                description: "Аутентичная грузинская кухня, уютная атмосфера и лучшие вина Грузии.",
                address: "ул. Арбат, 30",
                city: "Москва",
                imageURL: "georgia_main",
                rating: 4.9,
                cuisine: "Грузинская кухня",
                deliveryTime: 40,
                brand: .theGeorgia,
                menu: [
                    Dish(name: "Хинкали", description: "Классические грузинские хинкали с мясом.", price: 490, image: "khinkali", category: "Горячее", restaurantBrand: .theGeorgia),
                    Dish(name: "Хачапури по-аджарски", description: "Лодочка с сыром и яйцом.", price: 550, image: "khachapuri", category: "Выпечка", restaurantBrand: .theGeorgia),
                    Dish(name: "Лобио", description: "Фасоль с пряностями и зеленью.", price: 350, image: "lobio", category: "Закуски", restaurantBrand: .theGeorgia),
                    Dish(name: "Шашлык из баранины", description: "Сочный шашлык на углях.", price: 890, image: "shashlik", category: "Гриль", restaurantBrand: .theGeorgia),
                    Dish(name: "Сациви", description: "Курица в ореховом соусе.", price: 670, image: "satsivi", category: "Горячее", restaurantBrand: .theGeorgia)
                ],
                features: [.wifi, .reservation, .cardPayment, .takeaway],
                workingHours: .default,
                location: Location(latitude: 55.7522, longitude: 37.6056),
                tables: Table.mockTables,
                gallery: [],
                contacts: ContactInfo(
                    phone: "+7 (495) 555-55-55",
                    email: "info@thegeorgia.ru",
                    website: "www.thegeorgia.ru",
                    instagram: "@thegeorgia.msk"
                ),
                averageCheck: 1800,
                atmosphere: ["Уютная", "Семейная", "Аутентичная"]
            )
        ]
        
        restaurants = bykRestaurants + pivoRestaurants + moscaRestaurants + georgiaRestaurants
        loadingState = .loaded
    }
    
    func getRestaurantsByBrand(_ brand: Restaurant.Brand) -> [Restaurant] {
        return restaurants.filter { $0.brand == brand }
    }
    
    func refreshData() {
        loadMockData()
    }
} 