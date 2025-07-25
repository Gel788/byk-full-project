import SwiftUI

struct PremiumProfileSection<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let content: Content
    @State private var isPressed = false
    
    init(title: String, icon: String, color: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Заголовок секции
            HStack(spacing: 12) {
                ZStack {
                    // Фон иконки
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
                        .frame(width: 40, height: 40)
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
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
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
                
                Text(title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white,
                                Color.white.opacity(0.9)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Spacer()
                
                // Индикатор
                Circle()
                    .fill(color.opacity(0.3))
                    .frame(width: 6, height: 6)
            }
            
            // Содержимое секции
            content
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
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
                    RoundedRectangle(cornerRadius: 20)
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
        .shadow(color: color.opacity(0.3), radius: 15, x: 0, y: 8)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
        }
    }
}

struct PremiumPersonalDataSection: View {
    let user: User?
    
    var body: some View {
        VStack(spacing: 16) {
            PremiumDataRow(
                icon: "person.fill",
                title: "Имя",
                value: user?.fullName ?? "Не указано",
                color: Color("BykAccent")
            )
            
            PremiumDataRow(
                icon: "at",
                title: "Username",
                value: user?.username ?? "Не указано",
                color: .blue
            )
            
            if let email = user?.email {
                PremiumDataRow(
                    icon: "envelope.fill",
                    title: "Email",
                    value: email,
                    color: .green
                )
            }
            
            PremiumDataRow(
                icon: "calendar.fill",
                title: "Дата регистрации",
                value: user?.createdAt.formatted(date: .abbreviated, time: .omitted) ?? "Не указано",
                color: .orange
            )
        }
    }
}

struct PremiumDataRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
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
                    .frame(width: 36, height: 36)
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
                    .scaleEffect(isHovered ? 1.1 : 1.0)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
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
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                
                Text(value)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white,
                                Color.white.opacity(0.9)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            
            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.2))
                .opacity(isHovered ? 1.0 : 0.0)
        )
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered.toggle()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHovered = false
                }
            }
        }
    }
}

struct PremiumOrderHistorySection: View {
    @EnvironmentObject var userDataService: UserDataService
    let onViewOrderHistory: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            let recentOrders = userDataService.getRecentOrders(limit: 3)
            let orderStats = userDataService.getOrderStats()
            
            // Статистика
            HStack(spacing: 12) {
                PremiumMiniStat(
                    title: "Всего",
                    value: "\(orderStats.total)",
                    color: Color("BykAccent")
                )
                
                PremiumMiniStat(
                    title: "Ожидают",
                    value: "\(orderStats.pending)",
                    color: .orange
                )
                
                PremiumMiniStat(
                    title: "Завершённых",
                    value: "\(orderStats.delivered)",
                    color: .blue
                )
            }
            
            // Последние заказы
            if !recentOrders.isEmpty {
                VStack(spacing: 12) {
                    ForEach(recentOrders.prefix(2)) { order in
                        PremiumOrderRow(order: order)
                    }
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "bag")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.4))
                    
                    Text("Заказов пока нет")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.vertical, 16)
            }
            
            // Кнопка "Посмотреть все"
            Button(action: onViewOrderHistory) {
                HStack(spacing: 8) {
                    Text("Посмотреть все заказы")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color("BykAccent").opacity(0.8),
                                    Color("BykAccent").opacity(0.6)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color("BykAccent").opacity(0.5), lineWidth: 1)
                        )
                )
                .shadow(color: Color("BykAccent").opacity(0.3), radius: 8, x: 0, y: 4)
            }
        }
    }
}

struct PremiumMiniStat: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
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
            
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct PremiumOrderRow: View {
    let order: UserOrder
    
    var body: some View {
        HStack(spacing: 12) {
            // Иконка статуса
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Image(systemName: statusIcon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(statusColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Заказ #\(order.id)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(order.orderDate.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                
                Text("\(order.items.count) позиций • \(order.totalAmount, specifier: "%.0f") ₽")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            // Статус
            Text(statusText)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(statusColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(statusColor.opacity(0.15))
                        .overlay(
                            Capsule()
                                .stroke(statusColor.opacity(0.3), lineWidth: 1)
                        )
                )
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.2))
        )
    }
    
    private var statusColor: Color {
        switch order.status {
        case .pending: return .orange
        case .confirmed: return .blue
        case .preparing: return .yellow
        case .ready: return .green
        case .delivering: return .purple
        case .delivered: return .green
        case .cancelled: return .red
        }
    }
    
    private var statusIcon: String {
        switch order.status {
        case .pending: return "clock"
        case .confirmed: return "checkmark.circle"
        case .preparing: return "wrench.and.screwdriver"
        case .ready: return "checkmark.seal"
        case .delivering: return "bicycle"
        case .delivered: return "bag"
        case .cancelled: return "xmark.circle"
        }
    }
    
    private var statusText: String {
        switch order.status {
        case .pending: return "Ожидает"
        case .confirmed: return "Подтверждён"
        case .preparing: return "Готовится"
        case .ready: return "Готов"
        case .delivering: return "Доставляется"
        case .delivered: return "Доставлен"
        case .cancelled: return "Отменён"
        }
    }
}

struct PremiumReservationsSection: View {
    @EnvironmentObject var userDataService: UserDataService
    let onViewReservations: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            let activeReservations = userDataService.getActiveReservations()
            let reservationStats = userDataService.getReservationStats()
            
            // Статистика
            HStack(spacing: 16) {
                PremiumMiniStat(
                    title: "Всего",
                    value: "\(reservationStats.active + reservationStats.completed + reservationStats.cancelled)",
                    color: .green
                )
                
                PremiumMiniStat(
                    title: "Активных",
                    value: "\(reservationStats.active)",
                    color: .blue
                )
                
                PremiumMiniStat(
                    title: "Завершённых",
                    value: "\(reservationStats.completed)",
                    color: .orange
                )
            }
            
            // Последние бронирования
            if !activeReservations.isEmpty {
                VStack(spacing: 16) {
                    ForEach(activeReservations.prefix(2)) { reservation in
                        PremiumReservationRow(reservation: reservation)
                    }
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "calendar")
                        .font(.system(size: 32))
                        .foregroundColor(.white.opacity(0.4))
                    
                    Text("Бронирований пока нет")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.vertical, 24)
            }
            
            // Кнопка "Управление бронированиями"
            Button(action: onViewReservations) {
                HStack(spacing: 12) {
                    Text("Управление бронированиями")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    .green.opacity(0.8),
                                    .green.opacity(0.6)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.green.opacity(0.5), lineWidth: 1)
                        )
                )
                .shadow(color: .green.opacity(0.3), radius: 10, x: 0, y: 5)
            }
        }
    }
}

struct PremiumReservationRow: View {
    let reservation: UserReservation
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Иконка статуса
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                statusColor.opacity(0.3),
                                statusColor.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        statusColor.opacity(0.5),
                                        statusColor.opacity(0.2)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .scaleEffect(isHovered ? 1.1 : 1.0)
                
                Image(systemName: statusIcon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                statusColor,
                                statusColor.opacity(0.8)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(reservation.restaurantName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(reservation.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                
                Text("\(reservation.guests) гостей")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            // Статус
            Text(statusText)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(statusColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(statusColor.opacity(0.15))
                        .overlay(
                            Capsule()
                                .stroke(statusColor.opacity(0.3), lineWidth: 1)
                        )
                )
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.2))
                .opacity(isHovered ? 1.0 : 0.0)
        )
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered.toggle()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHovered = false
                }
            }
        }
    }
    
    private var statusColor: Color {
        switch reservation.status {
        case .pending: return .orange
        case .confirmed: return .green
        case .cancelled: return .red
        case .completed: return .blue
        }
    }
    
    private var statusIcon: String {
        switch reservation.status {
        case .pending: return "clock"
        case .confirmed: return "checkmark.circle"
        case .cancelled: return "xmark.circle"
        case .completed: return "checkmark.shield"
        }
    }
    
    private var statusText: String {
        switch reservation.status {
        case .pending: return "Ожидает"
        case .confirmed: return "Подтверждено"
        case .cancelled: return "Отменено"
        case .completed: return "Завершено"
        }
    }
}

struct PremiumLoyaltySection: View {
    @EnvironmentObject var userDataService: UserDataService
    @State private var animateProgress = false
    
    var body: some View {
        VStack(spacing: 20) {
            let loyaltyProgress = userDataService.getLoyaltyProgress()
            
            // Прогресс уровня
            VStack(spacing: 16) {
                HStack {
                    Text("Уровень лояльности")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white,
                                    Color.white.opacity(0.9)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Spacer()
                    
                    Text("Бронза")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    .yellow,
                                    .orange
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                // Прогресс-бар
                VStack(spacing: 8) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.2),
                                            Color.white.opacity(0.1)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(height: 12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                            
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            .yellow,
                                            .orange,
                                            .red
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * (animateProgress ? loyaltyProgress.progress : 0), height: 12)
                                .animation(.easeOut(duration: 1.5).delay(0.5), value: animateProgress)
                        }
                    }
                    .frame(height: 12)
                    
                    HStack {
                        Text("\(loyaltyProgress.current) / \(loyaltyProgress.next)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Spacer()
                        
                        Text("\(Int(loyaltyProgress.progress * 100))%")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        .yellow,
                                        .orange
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
            }
            
            // Бонусы
            HStack(spacing: 16) {
                PremiumMiniStat(
                    title: "Бонусов",
                    value: "\(loyaltyProgress.current)",
                    color: .yellow
                )
                
                PremiumMiniStat(
                    title: "Скидка",
                    value: "10%",
                    color: .green
                )
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                animateProgress = true
            }
        }
    }
}

struct PremiumSettingsSection: View {
    var body: some View {
        VStack(spacing: 16) {
            PremiumSettingsRow(
                icon: "bell.fill",
                title: "Уведомления",
                subtitle: "Настройки push-уведомлений",
                color: .blue
            )
            
            PremiumSettingsRow(
                icon: "lock.fill",
                title: "Безопасность",
                subtitle: "Пароль и двухфакторная аутентификация",
                color: .green
            )
            
            PremiumSettingsRow(
                icon: "creditcard.fill",
                title: "Способы оплаты",
                subtitle: "Управление картами и кошельками",
                color: .purple
            )
            
            PremiumSettingsRow(
                icon: "questionmark.circle.fill",
                title: "Помощь",
                subtitle: "FAQ и поддержка",
                color: .orange
            )
        }
    }
}

struct PremiumSettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
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
                    .frame(width: 44, height: 44)
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
                    .scaleEffect(isPressed ? 0.95 : 1.0)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
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
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.2))
                .opacity(isPressed ? 1.0 : 0.0)
        )
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
        }
    }
} 

struct PremiumDeliveryHistorySection: View {
    @EnvironmentObject var userDataService: UserDataService
    let onViewDeliveryHistory: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            let deliveryOrders = userDataService.getRecentOrders(limit: 3)
            
            // Статистика доставки
            HStack(spacing: 12) {
                PremiumMiniStat(
                    title: "Всего",
                    value: "\(deliveryOrders.count)",
                    color: .purple
                )
                
                PremiumMiniStat(
                    title: "Доставлено",
                    value: "\(deliveryOrders.filter { $0.status == .delivered }.count)",
                    color: .green
                )
                
                PremiumMiniStat(
                    title: "В пути",
                    value: "\(deliveryOrders.filter { $0.status == .delivering }.count)",
                    color: .orange
                )
            }
            
            // Последние доставки
            if !deliveryOrders.isEmpty {
                VStack(spacing: 12) {
                    ForEach(deliveryOrders.prefix(2)) { order in
                        PremiumDeliveryRow(order: order)
                    }
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "bicycle")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.4))
                    
                    Text("Доставок пока нет")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.vertical, 16)
            }
            
            // Кнопка "Посмотреть все"
            Button(action: onViewDeliveryHistory) {
                HStack(spacing: 8) {
                    Text("Посмотреть все доставки")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.purple.opacity(0.8),
                                    Color.purple.opacity(0.6)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.purple.opacity(0.5), lineWidth: 1)
                        )
                )
                .shadow(color: Color.purple.opacity(0.3), radius: 8, x: 0, y: 4)
            }
        }
    }
}



struct PremiumDeliveryRow: View {
    let order: UserOrder
    
    var body: some View {
        HStack(spacing: 12) {
            // Иконка статуса доставки
            ZStack {
                Circle()
                    .fill(deliveryStatusColor.opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Image(systemName: deliveryStatusIcon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(deliveryStatusColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Доставка #\(order.orderNumber)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(order.deliveryAddress ?? "Адрес не указан")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(1)
                
                Text("\(order.items.count) позиций • \(order.totalAmount, specifier: "%.0f") ₽")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            // Статус доставки
            Text(deliveryStatusText)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(deliveryStatusColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(deliveryStatusColor.opacity(0.15))
                        .overlay(
                            Capsule()
                                .stroke(deliveryStatusColor.opacity(0.3), lineWidth: 1)
                        )
                )
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.2))
        )
    }
    
    private var deliveryStatusColor: Color {
        switch order.status {
        case .pending: return .orange
        case .confirmed: return .blue
        case .preparing: return .yellow
        case .ready: return .green
        case .delivering: return .purple
        case .delivered: return .green
        case .cancelled: return .red
        }
    }
    
    private var deliveryStatusIcon: String {
        switch order.status {
        case .pending: return "clock"
        case .confirmed: return "checkmark.circle"
        case .preparing: return "wrench.and.screwdriver"
        case .ready: return "checkmark.seal"
        case .delivering: return "bicycle"
        case .delivered: return "bag"
        case .cancelled: return "xmark.circle"
        }
    }
    
    private var deliveryStatusText: String {
        switch order.status {
        case .pending: return "Ожидает"
        case .confirmed: return "Подтверждён"
        case .preparing: return "Готовится"
        case .ready: return "Готов"
        case .delivering: return "В пути"
        case .delivered: return "Доставлен"
        case .cancelled: return "Отменён"
        }
    }
} 