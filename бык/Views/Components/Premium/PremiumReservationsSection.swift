import SwiftUI

struct PremiumReservationsSection: View {
    @State private var reservations: [ReservationHistoryItem] = [
        ReservationHistoryItem(id: UUID(), restaurantName: "Бык", date: Date(), guests: 4, status: "Подтверждено"),
        ReservationHistoryItem(id: UUID(), restaurantName: "Грузия", date: Date().addingTimeInterval(-86400), guests: 2, status: "Завершено"),
        ReservationHistoryItem(id: UUID(), restaurantName: "Моска", date: Date().addingTimeInterval(-172800), guests: 6, status: "Отменено")
    ]
    
    var body: some View {
        PremiumProfileSection(
            title: "Бронирования",
            icon: "calendar",
            color: .orange
        ) {
            PremiumReservationsContent(reservations: reservations)
        }
    }
}

struct PremiumReservationsContent: View {
    let reservations: [ReservationHistoryItem]
    
    var body: some View {
        VStack(spacing: 12) {
            // Статистика
            HStack(spacing: 16) {
                PremiumMiniStat(
                    title: "Всего бронирований",
                    value: "\(reservations.count)",
                    icon: "calendar.circle.fill",
                    color: .orange
                )
                
                PremiumMiniStat(
                    title: "Активных",
                    value: "\(reservations.filter { $0.status == "Подтверждено" }.count)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
            }
            
            // Список бронирований
            VStack(spacing: 8) {
                ForEach(reservations.prefix(3)) { reservation in
                    PremiumReservationRow(reservation: reservation)
                }
                
                if reservations.count > 3 {
                    Button("Показать все бронирования") {
                        // Навигация к полной истории
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.blue)
                }
            }
        }
    }
}

struct PremiumReservationRow: View {
    let reservation: ReservationHistoryItem
    
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
                Text(reservation.restaurantName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                HStack {
                    Text(reservation.date, style: .date)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    Text("•")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    Text("\(reservation.guests) гостей")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Text(reservation.status)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(statusColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(statusColor.opacity(0.2))
                )
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.1))
        )
    }
    
    private var statusColor: Color {
        switch reservation.status {
        case "Подтверждено": return .green
        case "Отменено": return .red
        case "Завершено": return .blue
        default: return .gray
        }
    }
    
    private var statusIcon: String {
        switch reservation.status {
        case "Подтверждено": return "checkmark.circle"
        case "Отменено": return "xmark.circle"
        case "Завершено": return "checkmark.circle.fill"
        default: return "clock"
        }
    }
}

// Временная модель для демонстрации
struct ReservationHistoryItem: Identifiable {
    let id: UUID
    let restaurantName: String
    let date: Date
    let guests: Int
    let status: String
}
