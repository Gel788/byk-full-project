import Foundation

struct PostTemplate: Identifiable, Codable {
    let id: UUID
    let name: String
    let content: String
    let hashtags: [String]
    let category: String
    
    init(id: UUID = UUID(), name: String, content: String, hashtags: [String], category: String) {
        self.id = id
        self.name = name
        self.content = content
        self.hashtags = hashtags
        self.category = category
    }
    
    // Предустановленные шаблоны
    static let templates = [
        PostTemplate(
            name: "Вкусный ужин",
            content: "Отличный ужин в ресторане! Блюда были невероятно вкусными, атмосфера уютная, а сервис на высоте. Рекомендую всем!",
            hashtags: ["вкусно", "ужин", "ресторан", "рекомендую"],
            category: "Ресторан"
        ),
        PostTemplate(
            name: "Быстрая доставка",
            content: "Заказал доставку, привезли очень быстро! Еда горячая и вкусная. Спасибо за отличный сервис!",
            hashtags: ["доставка", "быстро", "вкусно", "сервис"],
            category: "Доставка"
        ),
        PostTemplate(
            name: "Романтический вечер",
            content: "Прекрасный романтический вечер в уютном ресторане. Идеальная атмосфера для свидания!",
            hashtags: ["романтика", "свидание", "атмосфера", "вечер"],
            category: "Романтика"
        ),
        PostTemplate(
            name: "Семейный обед",
            content: "Отличное место для семейного обеда! Детям понравилось, взрослым тоже. Уютная атмосфера и вкусная еда.",
            hashtags: ["семья", "дети", "обед", "уютно"],
            category: "Семья"
        )
    ]
}
