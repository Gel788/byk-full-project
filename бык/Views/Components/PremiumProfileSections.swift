import SwiftUI

struct PremiumProfileSections: View {
    var body: some View {
        VStack(spacing: 20) {
            // Личные данные
            PremiumPersonalDataSection()
            
            // История заказов
            PremiumOrderHistorySection()
            
            // Бронирования
            PremiumReservationsSection()
            
            // Программа лояльности
            PremiumLoyaltySection()
            
            // Настройки
            PremiumSettingsSection()
            
            // История доставки
            PremiumDeliveryHistorySection()
        }
        .padding(.horizontal)
    }
}

struct PremiumLoyaltySection: View {
    @State private var loyaltyPoints = 1250
    @State private var nextLevelPoints = 2000
    @State private var currentLevel = "Серебряный"
    
    var body: some View {
        PremiumProfileSection(
            title: "Программа лояльности",
            icon: "star.circle",
            color: .yellow
        ) {
            PremiumLoyaltyContent(
                loyaltyPoints: loyaltyPoints,
                nextLevelPoints: nextLevelPoints,
                currentLevel: currentLevel
            )
        }
    }
}

struct PremiumLoyaltyContent: View {
    let loyaltyPoints: Int
    let nextLevelPoints: Int
    let currentLevel: String
    
    private var progress: Double {
        Double(loyaltyPoints) / Double(nextLevelPoints)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Текущий уровень
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Текущий уровень")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Text(currentLevel)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.yellow)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Баллы")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Text("\(loyaltyPoints)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            // Прогресс-бар
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("До следующего уровня")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text("\(nextLevelPoints - loyaltyPoints) баллов")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.yellow)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.yellow, .orange]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * progress, height: 8)
                    }
                }
                .frame(height: 8)
            }
            
            // Преимущества уровня
            VStack(alignment: .leading, spacing: 8) {
                Text("Преимущества уровня")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                
                ForEach(levelBenefits, id: \.self) { benefit in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.green)
                        
                        Text(benefit)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
    
    private var levelBenefits: [String] {
        switch currentLevel {
        case "Серебряный":
            return ["Скидка 5% на все заказы", "Приоритетная доставка", "Эксклюзивные предложения"]
        case "Золотой":
            return ["Скидка 10% на все заказы", "Бесплатная доставка", "Персональный менеджер"]
        default:
            return ["Скидка 15% на все заказы", "VIP-сервис", "Эксклюзивные мероприятия"]
        }
    }
}

struct PremiumSettingsSection: View {
    var body: some View {
        PremiumProfileSection(
            title: "Настройки",
            icon: "gearshape",
            color: .gray
        ) {
            PremiumSettingsContent()
        }
    }
}

struct PremiumSettingsContent: View {
    var body: some View {
        VStack(spacing: 12) {
            PremiumSettingsRow(
                icon: "bell",
                title: "Уведомления",
                subtitle: "Push и email уведомления",
                color: .blue
            ) {
                // Настройки уведомлений
            }
            
            PremiumSettingsRow(
                icon: "lock",
                title: "Безопасность",
                subtitle: "Пароль и двухфакторная аутентификация",
                color: .red
            ) {
                // Настройки безопасности
            }
            
            PremiumSettingsRow(
                icon: "globe",
                title: "Язык",
                subtitle: "Русский",
                color: .green
            ) {
                // Выбор языка
            }
            
            PremiumSettingsRow(
                icon: "questionmark.circle",
                title: "Поддержка",
                subtitle: "Помощь и обратная связь",
                color: .orange
            ) {
                // Поддержка
            }
        }
    }
}

struct PremiumSettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PremiumDeliveryHistorySection: View {
    @State private var deliveries: [DeliveryHistoryItem] = [
        DeliveryHistoryItem(id: UUID(), restaurantName: "Бык", date: Date(), address: "ул. Тверская, 1", status: "Доставлен"),
        DeliveryHistoryItem(id: UUID(), restaurantName: "Грузия", date: Date().addingTimeInterval(-86400), address: "пр. Мира, 10", status: "Доставлен"),
        DeliveryHistoryItem(id: UUID(), restaurantName: "Моска", date: Date().addingTimeInterval(-172800), address: "ул. Арбат, 5", status: "Отменен")
    ]
    
    var body: some View {
        PremiumProfileSection(
            title: "История доставки",
            icon: "truck",
            color: .purple
        ) {
            PremiumDeliveryHistoryContent(deliveries: deliveries)
        }
    }
}

struct PremiumDeliveryHistoryContent: View {
    let deliveries: [DeliveryHistoryItem]
    
    var body: some View {
        VStack(spacing: 12) {
            // Статистика
            HStack(spacing: 16) {
                PremiumMiniStat(
                    title: "Всего доставок",
                    value: "\(deliveries.count)",
                    icon: "truck.fill",
                    color: .purple
                )
                
                PremiumMiniStat(
                    title: "Успешных",
                    value: "\(deliveries.filter { $0.status == "Доставлен" }.count)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
            }
            
            // Список доставок
            VStack(spacing: 8) {
                ForEach(deliveries.prefix(3)) { delivery in
                    PremiumDeliveryRow(delivery: delivery)
                }
                
                if deliveries.count > 3 {
                    Button("Показать все доставки") {
                        // Навигация к полной истории
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.blue)
                }
            }
        }
    }
}

struct PremiumDeliveryRow: View {
    let delivery: DeliveryHistoryItem
    
    var body: some View {
        HStack(spacing: 12) {
            // Иконка статуса
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Image(systemName: statusIcon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(statusColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(delivery.restaurantName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(delivery.address)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(delivery.date, style: .date)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                
                Text(delivery.status)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(statusColor)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.1))
        )
    }
    
    private var statusColor: Color {
        switch delivery.status {
        case "Доставлен": return .green
        case "Отменен": return .red
        case "В пути": return .orange
        default: return .gray
        }
    }
    
    private var statusIcon: String {
        switch delivery.status {
        case "Доставлен": return "checkmark.circle"
        case "Отменен": return "xmark.circle"
        case "В пути": return "truck"
        default: return "clock"
        }
    }
}

// Временная модель для демонстрации
struct DeliveryHistoryItem: Identifiable {
    let id: UUID
    let restaurantName: String
    let date: Date
    let address: String
    let status: String
}

#Preview {
    ScrollView {
        PremiumProfileSections()
    }
    .background(Color.black)
}
