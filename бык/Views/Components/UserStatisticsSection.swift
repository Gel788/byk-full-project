import SwiftUI

struct UserStatisticsSection: View {
    @EnvironmentObject var userDataService: UserDataService
    
    var body: some View {
        VStack(spacing: 16) {
            let orderStats = userDataService.getOrderStats()
            let reservationStats = userDataService.getReservationStats()
            let loyaltyProgress = userDataService.getLoyaltyProgress()
            
            // Заголовок секции
            HStack {
                Text("Ваша активность")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white,
                                Color.white.opacity(0.8)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Spacer()
                
                // Индикатор обновления
                HStack(spacing: 3) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 5, height: 5)
                    
                    Text("Live")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.green)
                }
            }
            .padding(.horizontal, 20)
            
            // Карточки статистики
            HStack(spacing: 10) {
                PremiumStatCard(
                    title: "Заказов",
                    value: "\(orderStats.total)",
                    subtitle: "всего",
                    icon: "bag.fill",
                    color: Color("BykAccent")
                )
                
                PremiumStatCard(
                    title: "Броней",
                    value: "\(reservationStats.active)",
                    subtitle: "активных",
                    icon: "calendar",
                    color: .blue
                )
                
                PremiumStatCard(
                    title: "Бонусов",
                    value: "\(loyaltyProgress.current)",
                    subtitle: "накоплено",
                    icon: "star.fill",
                    color: .yellow
                )
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, -5)
    }
}

struct PremiumStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            // Иконка с фоном
            ZStack {
                // Основной фон иконки
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                color.opacity(0.3),
                                color.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        color.opacity(0.5),
                                        color.opacity(0.2)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                
                // Иконка
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                color,
                                color.opacity(0.8)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            // Значение
            VStack(spacing: 3) {
                Text(value)
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white,
                                Color.white.opacity(0.9)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text(subtitle)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            // Заголовок
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.8),
                            Color.black.opacity(0.6),
                            Color.black.opacity(0.4)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    color.opacity(0.4),
                                    color.opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
        )
        .shadow(color: color.opacity(0.3), radius: 12, x: 0, y: 6)
    }
} 