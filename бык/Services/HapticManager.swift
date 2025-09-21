import UIKit

// MARK: - Haptic Manager
class HapticManager {
    static let shared = HapticManager()
    private init() {}
    
    // Основные методы
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    // Дополнительные методы для совместимости
    func buttonPress() {
        impact(.light)
    }
    
    func navigationTransition() {
        impact(.light)
    }
    
    func successPattern() {
        notification(.success)
    }
    
    func warningPattern() {
        notification(.warning)
    }
    
    func errorPattern() {
        notification(.error)
    }
    
    func restaurantSelect() {
        impact(.medium)
    }
    
    func selection() {
        impact(.light)
    }
}
