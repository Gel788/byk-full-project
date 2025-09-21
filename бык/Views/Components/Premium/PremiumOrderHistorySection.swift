import SwiftUI

struct PremiumOrderHistorySection: View {
    @State private var orders: [OrderHistoryItem] = [
        OrderHistoryItem(id: UUID(), restaurantName: "Бык", date: Date(), amount: 2500, status: "Доставлен"),
        OrderHistoryItem(id: UUID(), restaurantName: "Грузия", date: Date().addingTimeInterval(-86400), amount: 1800, status: "Доставлен"),
        OrderHistoryItem(id: UUID(), restaurantName: "Моска", date: Date().addingTimeInterval(-172800), amount: 3200, status: "Отменен")
    ]
    
    var body: some View {
        PremiumProfileSection(
            title: "История заказов",
            icon: "bag",
            color: .green
        ) {
            PremiumOrderHistoryContent(orders: orders)
        }
    }
}

struct PremiumOrderHistoryContent: View {
    let orders: [OrderHistoryItem]
    
    var body: some View {
        VStack(spacing: 12) {
            // Статистика
            HStack(spacing: 16) {
                PremiumMiniStat(
                    title: "Всего заказов",
                    value: "\(orders.count)",
                    icon: "bag.fill",
                    color: .blue
                )
                
                PremiumMiniStat(
                    title: "Потрачено",
                    value: "\(orders.reduce(0) { $0 + $1.amount }) ₽",
                    icon: "rublesign.circle.fill",
                    color: .green
                )
            }
            
            // Список заказов
            VStack(spacing: 8) {
                ForEach(orders.prefix(3)) { order in
                    PremiumOrderRow(order: order)
                }
                
                if orders.count > 3 {
                    Button("Показать все заказы") {
                        // Навигация к полной истории
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.blue)
                }
            }
        }
    }
}

struct PremiumMiniStat: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 24, height: 24)
                
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

struct PremiumOrderRow: View {
    let order: OrderHistoryItem
    
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
                Text(order.restaurantName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(order.date, style: .date)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(order.amount) ₽")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                
                Text(order.status)
                    .font(.system(size: 12))
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
        switch order.status {
        case "Доставлен": return .green
        case "Отменен": return .red
        case "В пути": return .orange
        default: return .gray
        }
    }
    
    private var statusIcon: String {
        switch order.status {
        case "Доставлен": return "checkmark.circle"
        case "Отменен": return "xmark.circle"
        case "В пути": return "truck"
        default: return "clock"
        }
    }
}

// Временная модель для демонстрации
struct OrderHistoryItem: Identifiable {
    let id: UUID
    let restaurantName: String
    let date: Date
    let amount: Int
    let status: String
}
