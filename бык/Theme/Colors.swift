import SwiftUI

enum Colors {
    // Основные цвета приложения
    static let appPrimary = Color("AppPrimary")
    static let appSecondary = Color("AppSecondary")
    static let appAccent = Color("BykAccent")
    static let appBackground = Color("AppBackground")
    static let appSurface = Color("AppSurface")
    static let appError = Color("AppError")
    
    // Цвета для THE БЫК
    static let bykPrimary = Color("BykPrimary")
    static let bykSecondary = Color("BykSecondary")
    static let bykAccent = Color("BykAccent")
    
    // Цвета для THE ПИВО
    static let pivoPrimary = Color("PivoPrimary")
    static let pivoSecondary = Color("PivoSecondary")
    static let pivoAccent = Color("PivoAccent")
    
    // Цвета для MOSCA
    static let moscaPrimary = Color("MoscaPrimary")
    static let moscaSecondary = Color("MoscaSecondary")
    static let moscaAccent = Color("MoscaAccent")
    
    // Цвета для THE ГРУЗИЯ
    static let georgiaPrimary = Color("GeorgiaPrimary")
    static let georgiaSecondary = Color("GeorgiaSecondary")
    static let georgiaAccent = Color("GeorgiaAccent")
    
    // Вспомогательные функции
    static func brandColors(for brand: Restaurant.Brand) -> (primary: Color, secondary: Color, accent: Color) {
        switch brand {
        case .theByk:
            return (bykPrimary, bykSecondary, bykAccent)
        case .thePivo:
            return (pivoPrimary, pivoSecondary, pivoAccent)
        case .mosca:
            return (moscaPrimary, moscaSecondary, moscaAccent)
        case .theGeorgia:
            return (georgiaPrimary, georgiaSecondary, georgiaAccent)
        }
    }
}

extension Double {
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = " "
        return (formatter.string(from: NSNumber(value: self)) ?? "") + " ₽"
    }
} 