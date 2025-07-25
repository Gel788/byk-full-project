import Foundation
import SwiftUI
import CoreLocation

// Модель сети ресторанов
struct RestaurantNetwork: Identifiable {
    let id = UUID()
    let brand: RestaurantBrand
    let name: String
    let description: String
    let foundedYear: Int
    let restaurants: [Restaurant]
    let news: [NewsItem]
    let specialOffers: [SpecialOffer]
}

// Модель ресторана
struct Restaurant: Identifiable, Hashable, Codable {
    let id: UUID
    let name: String
    let description: String
    let address: String
    let city: String
    let imageURL: String
    let rating: Double
    let cuisine: String
    let deliveryTime: Int
    let brand: Brand
    let menu: [Dish]
    let features: Set<Feature>
    let workingHours: WorkingHours
    let location: Location
    let tables: [Table]
    let gallery: [GalleryImage]
    let contacts: ContactInfo
    let averageCheck: Int
    let atmosphere: [String]
    
    // MARK: - Hashable Implementation
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // MARK: - Equatable Implementation
    static func == (lhs: Restaurant, rhs: Restaurant) -> Bool {
        lhs.id == rhs.id
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        address: String,
        city: String,
        imageURL: String,
        rating: Double,
        cuisine: String,
        deliveryTime: Int,
        brand: Brand,
        menu: [Dish],
        features: Set<Feature>,
        workingHours: WorkingHours,
        location: Location,
        tables: [Table],
        gallery: [GalleryImage] = [],
        contacts: ContactInfo = ContactInfo(),
        averageCheck: Int = 2000,
        atmosphere: [String] = []
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.address = address
        self.city = city
        self.imageURL = imageURL
        self.rating = rating
        self.cuisine = cuisine
        self.deliveryTime = deliveryTime
        self.brand = brand
        self.menu = menu
        self.features = features
        self.workingHours = workingHours
        self.location = location
        self.tables = tables
        self.gallery = gallery
        self.contacts = contacts
        self.averageCheck = averageCheck
        self.atmosphere = atmosphere
    }
    
    enum Brand: String, CaseIterable, Codable {
        case theByk = "THE БЫК"
        case thePivo = "THE ПИВО"
        case mosca = "MOSCA"
        case theGeorgia = "THE ГРУЗИЯ"
        
        var displayName: String {
            switch self {
            case .theByk: return "БЫК"
            case .thePivo: return "ПИВО"
            case .mosca: return "MOSCA"
            case .theGeorgia: return "ГРУЗИЯ"
            }
        }
        
        var emoji: String {
            switch self {
            case .theByk: return "🐂"
            case .thePivo: return "🍺"
            case .mosca: return "🍷"
            case .theGeorgia: return "🍇"
            }
        }
    }
    
    enum Feature: String, Codable {
        case parking = "Парковка"
        case wifi = "Wi-Fi"
        case reservation = "Бронирование"
        case cardPayment = "Оплата картой"
        case delivery = "Доставка"
        case takeaway = "Навынос"
        case liveMusic = "Живая музыка"
        case summerTerrace = "Летняя терраса"
        case businessLunch = "Бизнес-ланч"
        case hookah = "Кальян"
        case playground = "Детская площадка"
        case privateRoom = "VIP-комната"
        
        var icon: String {
            switch self {
            case .parking: return "car"
            case .wifi: return "wifi"
            case .reservation: return "calendar"
            case .cardPayment: return "creditcard"
            case .delivery: return "bicycle"
            case .takeaway: return "bag"
            case .liveMusic: return "music.note"
            case .summerTerrace: return "sun.max"
            case .businessLunch: return "briefcase"
            case .hookah: return "smoke"
            case .playground: return "figure.and.child.holdinghands"
            case .privateRoom: return "lock"
            }
        }
    }
}

struct GalleryImage: Identifiable, Hashable, Codable {
    let id: UUID = UUID()
    let imageURL: String
    let description: String
}

struct ContactInfo: Hashable, Codable {
    var phone: String = "+7 (999) 123-45-67"
    var email: String = "info@restaurant.com"
    var website: String = "www.restaurant.com"
    var instagram: String = "@restaurant"
    var facebook: String = "restaurant"
}

struct Location: Hashable, Codable {
    let latitude: Double
    let longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    // MARK: - Hashable Implementation
    func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
    
    static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

struct WorkingHours: Hashable, Codable {
    let openTime: String
    let closeTime: String
    let weekdays: Set<Weekday>
    
    static let `default` = WorkingHours(
        openTime: "10:00",
        closeTime: "23:00",
        weekdays: Set(Weekday.allCases)
    )
    
    func isOpen(at date: Date = Date()) -> Bool {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let currentWeekday = Weekday(rawValue: weekday)!
        
        guard weekdays.contains(currentWeekday) else { return false }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let currentTimeString = formatter.string(from: date)
        
        return currentTimeString >= openTime && currentTimeString <= closeTime
    }
    
    enum Weekday: Int, CaseIterable, Codable {
        case sunday = 1
        case monday = 2
        case tuesday = 3
        case wednesday = 4
        case thursday = 5
        case friday = 6
        case saturday = 7
    }
}

struct Table: Identifiable, Hashable, Codable {
    let id: UUID = UUID()
    let number: Int
    let capacity: Int
    let isAvailable: Bool
    let location: TableLocation
    
    enum TableLocation: String, Hashable, Codable {
        case main = "Основной зал"
        case terrace = "Терраса"
        case vip = "VIP-зона"
        case bar = "У бара"
        case window = "У окна"
    }
    
    // MARK: - Hashable Implementation
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Table, rhs: Table) -> Bool {
        lhs.id == rhs.id
    }
    
    static var mockTables: [Table] {
        [
            Table(number: 1, capacity: 2, isAvailable: true, location: .window),
            Table(number: 2, capacity: 4, isAvailable: true, location: .main),
            Table(number: 3, capacity: 6, isAvailable: true, location: .terrace),
            Table(number: 4, capacity: 2, isAvailable: true, location: .bar),
            Table(number: 5, capacity: 8, isAvailable: true, location: .vip)
        ]
    }
}

// Модель специального предложения
struct SpecialOffer: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let description: String
    let imageURL: String
    let validUntil: Date
    let discount: Int
    let conditions: String
    
    static func == (lhs: SpecialOffer, rhs: SpecialOffer) -> Bool {
        lhs.id == rhs.id
    }
}

// Перечисление дней недели
enum Weekday: Int, CaseIterable {
    case monday = 1, tuesday, wednesday, thursday, friday, saturday, sunday
    
    var name: String {
        switch self {
        case .monday: return "Понедельник"
        case .tuesday: return "Вторник"
        case .wednesday: return "Среда"
        case .thursday: return "Четверг"
        case .friday: return "Пятница"
        case .saturday: return "Суббота"
        case .sunday: return "Воскресенье"
        }
    }
}

// Перечисление особенностей ресторана
enum RestaurantFeature: String {
    case parking = "Парковка"
    case wifi = "Wi-Fi"
    case delivery = "Доставка"
    case takeaway = "Самовывоз"
    case reservation = "Бронирование"
    case cardPayment = "Оплата картой"
    case liveMusic = "Живая музыка"
    case summerTerrace = "Летняя терраса"
    case businessLunch = "Бизнес-ланч"
    case childRoom = "Детская комната"
    
    var icon: String {
        switch self {
        case .parking: return "car"
        case .wifi: return "wifi"
        case .delivery: return "bicycle"
        case .takeaway: return "bag"
        case .reservation: return "calendar"
        case .cardPayment: return "creditcard"
        case .liveMusic: return "music.note"
        case .summerTerrace: return "sun.max"
        case .businessLunch: return "briefcase"
        case .childRoom: return "figure.2.and.child.holdinghands"
        }
    }
}

// Перечисление бренда ресторана
enum RestaurantBrand {
    case theByk
    case thePivo
    case mosca
    case theGeorgia
    
    var colors: (primary: Color, secondary: Color, accent: Color) {
        switch self {
        case .theByk:
            return (Colors.bykPrimary, Colors.bykSecondary, Colors.bykAccent)
        case .thePivo:
            return (Colors.pivoPrimary, Colors.pivoSecondary, Colors.pivoAccent)
        case .mosca:
            return (Colors.moscaPrimary, Colors.moscaSecondary, Colors.moscaAccent)
        case .theGeorgia:
            return (Colors.georgiaPrimary, Colors.georgiaSecondary, Colors.georgiaAccent)
        }
    }
    
    var font: Font {
        switch self {
        case .theByk:
            return .custom("PlayfairDisplay-Bold", size: 24)
        case .thePivo:
            return .custom("Roboto-Bold", size: 24)
        case .mosca:
            return .custom("Montserrat-Bold", size: 24)
        case .theGeorgia:
            return .custom("PlayfairDisplay-Bold", size: 24)
        }
    }
    
    var networkName: String {
        switch self {
        case .theByk:
            return "THE БЫК"
        case .thePivo:
            return "THE ПИВО"
        case .mosca:
            return "MOSCA"
        case .theGeorgia:
            return "THE ГРУЗИЯ"
        }
    }
    
    var description: String {
        switch self {
        case .theByk:
            return "Премиальный стейк-хаус в самом сердце Москвы. Мы специализируемся на приготовлении высококачественных стейков из отборной мраморной говядины. Уютная атмосфера, профессиональное обслуживание и богатая винная карта сделают ваш вечер незабываемым."
        case .thePivo:
            return "Крафтовый пивной ресторан с богатым выбором пива и закусок"
        case .mosca:
            return "Аутентичный итальянский ресторан с традиционными рецептами"
        case .theGeorgia:
            return "Премиальный стейк-хаус в самом сердце Москвы. Мы специализируемся на приготовлении высококачественных стейков из отборной мраморной говядины. Уютная атмосфера, профессиональное обслуживание и богатая винная карта сделают ваш вечер незабываемым."
        }
    }
}

enum CuisineType: String {
    case steakhouse = "Стейк-хаус"
    case european = "Европейская"
    case italian = "Итальянская"
    case craft = "Крафтовая"
    case local = "Локальная"
} 

// MARK: - Mock Data
extension Restaurant {
    static var mock: Restaurant {
        Restaurant(
            name: "THE БЫК на Тверской",
            description: "Премиальный стейк-хаус в самом сердце Москвы. Мы специализируемся на приготовлении высококачественных стейков из отборной мраморной говядины. Уютная атмосфера, профессиональное обслуживание и богатая винная карта сделают ваш вечер незабываемым.",
            address: "ул. Тверская, 15",
            city: "Москва",
            imageURL: "thebyk_main",
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
                    name: "Цезарь салат",
                    description: "Классический салат с куриным филе и соусом Цезарь",
                    price: 450,
                    image: "caesar_salad",
                    category: "Салаты",
                    restaurantBrand: .theByk
                ),
                Dish(
                    name: "Карбонара",
                    description: "Паста с беконом, яйцом и пармезаном",
                    price: 650,
                    image: "pasta_carbonara",
                    category: "Паста",
                    restaurantBrand: .theByk
                ),
                Dish(
                    name: "Креветки гриль",
                    description: "Королевские креветки на гриле с лимоном",
                    price: 890,
                    image: "ribai_steak",
                    category: "Морепродукты",
                    restaurantBrand: .theByk
                )
            ],
            features: [.parking, .wifi, .reservation, .cardPayment, .liveMusic],
            workingHours: WorkingHours(
                openTime: "10:00",
                closeTime: "23:00",
                weekdays: Set(WorkingHours.Weekday.allCases)
            ),
            location: Location(latitude: 55.7558, longitude: 37.6173),
            tables: Table.mockTables,
            gallery: [
                GalleryImage(imageURL: "thebyk_interior1", description: "Основной зал"),
                GalleryImage(imageURL: "thebyk_interior2", description: "Барная стойка"),
                GalleryImage(imageURL: "thebyk_interior3", description: "VIP-зал"),
                GalleryImage(imageURL: "thebyk_interior4", description: "Летняя терраса")
            ],
            contacts: ContactInfo(
                phone: "+7 (495) 123-45-67",
                email: "info@thebyk.ru",
                website: "www.thebyk.ru",
                instagram: "@thebyk.msk",
                facebook: "thebyk.moscow"
            ),
            averageCheck: 3500,
            atmosphere: ["Уютная", "Деловая", "Романтическая", "Премиальная"]
        )
    }
    
    static var mockRestaurants: [Restaurant] {
        [
            mock,
            Restaurant(
                name: "THE ПИВО на Арбате",
                description: "Крафтовое пиво и авторские закуски в атмосферном баре в самом сердце старой Москвы. Более 30 сортов разливного пива, уникальные коллаборации с локальными пивоварнями и авторское меню от шеф-повара.",
                address: "ул. Арбат, 25",
                city: "Москва",
                imageURL: "thepivo_main",
                rating: 4.6,
                cuisine: "Пивной ресторан",
                deliveryTime: 40,
                brand: .thePivo,
                menu: [
                    Dish(
                        name: "Фирменные колбаски",
                        description: "Ассорти из трех видов колбасок с гарнирами",
                        price: 890,
                        image: "sausages",
                        category: "Закуски",
                        restaurantBrand: .thePivo
                    ),
                    Dish(
                        name: "Крафтовое пиво",
                        description: "Свежее крафтовое пиво собственного производства",
                        price: 350,
                        image: "sausages",
                        category: "Напитки",
                        restaurantBrand: .thePivo
                    ),
                    Dish(
                        name: "Брецель",
                        description: "Немецкий крендель с солью и горчицей",
                        price: 250,
                        image: "pretzel",
                        category: "Закуски",
                        restaurantBrand: .thePivo
                    ),
                    Dish(
                        name: "Сырная тарелка",
                        description: "Ассорти из европейских сыров с орехами",
                        price: 650,
                        image: "sausages",
                        category: "Закуски",
                        restaurantBrand: .thePivo
                    )
                ],
                features: [.wifi, .delivery, .cardPayment, .summerTerrace],
                workingHours: WorkingHours(
                    openTime: "12:00",
                    closeTime: "00:00",
                    weekdays: Set(WorkingHours.Weekday.allCases)
                ),
                location: Location(latitude: 55.7494, longitude: 37.5995),
                tables: Table.mockTables,
                gallery: [],
                contacts: ContactInfo(
                    phone: "+7 (495) 234-56-78",
                    email: "info@thepivo.ru",
                    website: "www.thepivo.ru",
                    instagram: "@thepivo.msk"
                ),
                averageCheck: 2000,
                atmosphere: ["Неформальная", "Дружеская", "Шумная"]
            ),
            Restaurant(
                name: "MOSCA в Сити",
                description: "Современная итальянская кухня с потрясающим видом на Москва-Сити. Аутентичные рецепты в современной интерпретации, собственная винотека и регулярные гастрономические события.",
                address: "Пресненская наб., 8с1",
                city: "Москва",
                imageURL: "mosca_main",
                rating: 4.7,
                cuisine: "Итальянская",
                deliveryTime: 50,
                brand: .mosca,
                menu: [
                    Dish(
                        name: "Пицца Маргарита",
                        description: "Классическая итальянская пицца с томатами и моцареллой",
                        price: 650,
                        image: "pizza_margherita",
                        category: "Пицца",
                        restaurantBrand: .mosca
                    ),
                    Dish(
                        name: "Паста Карбонара",
                        description: "Спагетти с беконом, яйцом и пармезаном",
                        price: 750,
                        image: "pasta_carbonara",
                        category: "Паста",
                        restaurantBrand: .mosca
                    ),
                    Dish(
                        name: "Брускетта",
                        description: "Тосты с томатами, базиликом и моцареллой",
                        price: 350,
                        image: "caesar_salad",
                        category: "Закуски",
                        restaurantBrand: .mosca
                    ),
                    Dish(
                        name: "Тирамису",
                        description: "Классический итальянский десерт",
                        price: 450,
                        image: "pizza_margherita",
                        category: "Десерты",
                        restaurantBrand: .mosca
                    )
                ],
                features: [.parking, .wifi, .reservation, .cardPayment, .businessLunch],
                workingHours: WorkingHours(
                    openTime: "11:00",
                    closeTime: "23:00",
                    weekdays: Set(WorkingHours.Weekday.allCases)
                ),
                location: Location(latitude: 55.7470, longitude: 37.5392),
                tables: Table.mockTables,
                gallery: [],
                contacts: ContactInfo(
                    phone: "+7 (495) 345-67-89",
                    email: "info@mosca.ru",
                    website: "www.mosca.ru",
                    instagram: "@mosca.msk"
                ),
                averageCheck: 2500,
                atmosphere: ["Современная", "Элегантная", "Панорамная"]
            ),
            Restaurant(
                name: "THE ГРУЗИЯ на Тверской",
                description: "Премиальный стейк-хаус в самом сердце Москвы. Мы специализируемся на приготовлении высококачественных стейков из отборной мраморной говядины. Уютная атмосфера, профессиональное обслуживание и богатая винная карта сделают ваш вечер незабываемым.",
                address: "ул. Тверская, 15",
                city: "Москва",
                imageURL: "thegeorgia_main",
                rating: 4.8,
                cuisine: "Стейк-хаус",
                deliveryTime: 45,
                brand: .theGeorgia,
                menu: [
                    Dish(
                        name: "Рибай стейк",
                        description: "Премиальный стейк из мраморной говядины",
                        price: 3200,
                        image: "ribai_steak",
                        category: "Стейки",
                        restaurantBrand: .theGeorgia
                    ),
                    Dish(
                        name: "Цезарь салат",
                        description: "Классический салат с куриным филе и соусом Цезарь",
                        price: 450,
                        image: "caesar_salad",
                        category: "Салаты",
                        restaurantBrand: .theGeorgia
                    ),
                    Dish(
                        name: "Карбонара",
                        description: "Паста с беконом, яйцом и пармезаном",
                        price: 650,
                        image: "pasta_carbonara",
                        category: "Паста",
                        restaurantBrand: .theGeorgia
                    ),
                    Dish(
                        name: "Креветки гриль",
                        description: "Королевские креветки на гриле с лимоном",
                        price: 890,
                        image: "ribai_steak",
                        category: "Морепродукты",
                        restaurantBrand: .theGeorgia
                    )
                ],
                features: [.parking, .wifi, .reservation, .cardPayment, .liveMusic],
                workingHours: WorkingHours(
                    openTime: "10:00",
                    closeTime: "23:00",
                    weekdays: Set(WorkingHours.Weekday.allCases)
                ),
                location: Location(latitude: 55.7558, longitude: 37.6173),
                tables: Table.mockTables,
                gallery: [
                    GalleryImage(imageURL: "thegeorgia_interior1", description: "Основной зал"),
                    GalleryImage(imageURL: "thegeorgia_interior2", description: "Барная стойка"),
                    GalleryImage(imageURL: "thegeorgia_interior3", description: "VIP-зал"),
                    GalleryImage(imageURL: "thegeorgia_interior4", description: "Летняя терраса")
                ],
                contacts: ContactInfo(
                    phone: "+7 (495) 123-45-67",
                    email: "info@thegeorgia.ru",
                    website: "www.thegeorgia.ru",
                    instagram: "@thegeorgia.msk",
                    facebook: "thegeorgia.moscow"
                ),
                averageCheck: 3500,
                atmosphere: ["Уютная", "Деловая", "Романтическая", "Премиальная"]
            )
        ]
    }
} 