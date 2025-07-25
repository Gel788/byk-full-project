import Foundation
import UIKit

struct YandexMapsConfig {
    // Замените на ваш API ключ от Яндекс Карт
    static let apiKey = "YOUR_YANDEX_MAPS_API_KEY"
    
    // URL схемы для открытия Яндекс Карт
    static let yandexMapsURLScheme = "yandexmaps://"
    static let yandexMapsWebURL = "https://maps.yandex.ru/"
    
    // Проверяем, установлено ли приложение Яндекс Карт
    static var isYandexMapsInstalled: Bool {
        guard let url = URL(string: yandexMapsURLScheme) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
    
    // Создаем URL для открытия маршрута в Яндекс Картах
    static func routeURL(to coordinate: (latitude: Double, longitude: Double), name: String) -> URL? {
        let urlString = "\(yandexMapsURLScheme)maps.yandex.ru/?pt=\(coordinate.longitude),\(coordinate.latitude),pm2rdm&z=16&l=map&text=\(name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        return URL(string: urlString)
    }
    
    // Создаем URL для веб-версии Яндекс Карт
    static func webURL(for coordinate: (latitude: Double, longitude: Double), name: String) -> URL? {
        let urlString = "\(yandexMapsWebURL)?pt=\(coordinate.longitude),\(coordinate.latitude),pm2rdm&z=16&l=map&text=\(name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        return URL(string: urlString)
    }
    
    // Создаем строку для шаринга локации
    static func shareString(for coordinate: (latitude: Double, longitude: Double), name: String, address: String) -> String {
        let webURL = webURL(for: coordinate, name: name)?.absoluteString ?? ""
        return "\(name)\n\(address)\n\(webURL)"
    }
} 