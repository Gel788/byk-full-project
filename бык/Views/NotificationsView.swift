import SwiftUI

struct NotificationsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var notifications: [NotificationItem] = []
    @State private var selectedFilter: NotificationFilter = .all
    @State private var showingClearAlert = false
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color) {
        (Color("BykPrimary"), Color("BykSecondary"), Color("BykAccent"))
    }
    
    private var filteredNotifications: [NotificationItem] {
        switch selectedFilter {
        case .all:
            return notifications
        case .unread:
            return notifications.filter { !$0.isRead }
        case .orders:
            return notifications.filter { $0.type == .order }
        case .promotions:
            return notifications.filter { $0.type == .promotion }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Фон
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        brandColors.accent.opacity(0.1),
                        Color.black.opacity(0.95)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Заголовок
                    headerSection
                    
                    // Фильтры
                    filterSection
                    
                    // Список уведомлений
                    if filteredNotifications.isEmpty {
                        emptyStateView
                    } else {
                        notificationsList
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                loadNotifications()
            }
            .alert("Очистить уведомления", isPresented: $showingClearAlert) {
                Button("Отмена", role: .cancel) { }
                Button("Очистить", role: .destructive) {
                    clearAllNotifications()
                }
            } message: {
                Text("Вы уверены, что хотите удалить все уведомления?")
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            Button(action: { dismiss() }) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Text("Уведомления")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.white, Color.white.opacity(0.9)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                if !notifications.filter({ !$0.isRead }).isEmpty {
                    Text("\(notifications.filter({ !$0.isRead }).count) непрочитанных")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(brandColors.accent)
                }
            }
            
            Spacer()
            
            Button(action: {
                showingClearAlert = true
            }) {
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "trash")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 16)
    }
    
    // MARK: - Filter Section
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(NotificationFilter.allCases, id: \.self) { filter in
                    NotificationFilterChip(
                        title: filter.title,
                        isSelected: selectedFilter == filter,
                        count: getCountForFilter(filter)
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedFilter = filter
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 16)
    }
    
    // MARK: - Notifications List
    private var notificationsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredNotifications) { notification in
                    NotificationCard(notification: notification) {
                        markAsRead(notification)
                    } onDelete: {
                        deleteNotification(notification)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                brandColors.accent.opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "bell.slash.fill")
                    .font(.system(size: 48, weight: .light))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            VStack(spacing: 8) {
                Text("Нет уведомлений")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Здесь будут отображаться уведомления\nо заказах, акциях и новостях")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Methods
    private func loadNotifications() {
        // Загрузка тестовых уведомлений
        notifications = [
            NotificationItem(
                id: "1",
                title: "Заказ готов!",
                message: "Ваш заказ BY-2024-001 готов к получению в ресторане The Бык",
                type: .order,
                timestamp: Date().addingTimeInterval(-300), // 5 минут назад
                isRead: false
            ),
            NotificationItem(
                id: "2",
                title: "Новая акция!",
                message: "Скидка 20% на все стейки до конца недели. Не упустите возможность!",
                type: .promotion,
                timestamp: Date().addingTimeInterval(-3600), // 1 час назад
                isRead: false
            ),
            NotificationItem(
                id: "3",
                title: "Заказ подтвержден",
                message: "Ваш заказ BY-2024-002 принят в работу. Время доставки: 35-45 мин",
                type: .order,
                timestamp: Date().addingTimeInterval(-7200), // 2 часа назад
                isRead: true
            ),
            NotificationItem(
                id: "4",
                title: "Бронирование подтверждено",
                message: "Столик на 4 персоны забронирован на сегодня в 19:00",
                type: .reservation,
                timestamp: Date().addingTimeInterval(-10800), // 3 часа назад
                isRead: true
            ),
            NotificationItem(
                id: "5",
                title: "Добро пожаловать!",
                message: "Спасибо за регистрацию в БЫК! Получите скидку 15% на первый заказ",
                type: .promotion,
                timestamp: Date().addingTimeInterval(-86400), // 1 день назад
                isRead: true
            )
        ]
    }
    
    private func getCountForFilter(_ filter: NotificationFilter) -> Int {
        switch filter {
        case .all:
            return notifications.count
        case .unread:
            return notifications.filter { !$0.isRead }.count
        case .orders:
            return notifications.filter { $0.type == .order }.count
        case .promotions:
            return notifications.filter { $0.type == .promotion }.count
        }
    }
    
    private func markAsRead(_ notification: NotificationItem) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].isRead = true
        }
    }
    
    private func deleteNotification(_ notification: NotificationItem) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            notifications.removeAll { $0.id == notification.id }
        }
    }
    
    private func clearAllNotifications() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            notifications.removeAll()
        }
    }
}

// MARK: - Models
struct NotificationItem: Identifiable {
    let id: String
    let title: String
    let message: String
    let type: NotificationType
    let timestamp: Date
    var isRead: Bool
}

enum NotificationType {
    case order
    case promotion
    case reservation
    case system
    
    var icon: String {
        switch self {
        case .order: return "bag.fill"
        case .promotion: return "percent"
        case .reservation: return "calendar"
        case .system: return "gear"
        }
    }
    
    var color: Color {
        switch self {
        case .order: return .green
        case .promotion: return .orange
        case .reservation: return .blue
        case .system: return .gray
        }
    }
}

enum NotificationFilter: CaseIterable {
    case all
    case unread
    case orders
    case promotions
    
    var title: String {
        switch self {
        case .all: return "Все"
        case .unread: return "Непрочитанные"
        case .orders: return "Заказы"
        case .promotions: return "Акции"
        }
    }
}

// MARK: - Notification Filter Chip
struct NotificationFilterChip: View {
    let title: String
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color) {
        (Color("BykPrimary"), Color("BykSecondary"), Color("BykAccent"))
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                
                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(isSelected ? .white : brandColors.accent)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(isSelected ? Color.white.opacity(0.2) : brandColors.accent.opacity(0.2))
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? brandColors.accent : Color.white.opacity(0.1))
                    .overlay(
                        Capsule()
                            .stroke(
                                isSelected ? brandColors.accent : Color.white.opacity(0.2),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Notification Card
struct NotificationCard: View {
    let notification: NotificationItem
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Иконка типа уведомления
                ZStack {
                    Circle()
                        .fill(notification.type.color.opacity(0.2))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: notification.type.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(notification.type.color)
                }
                
                // Содержимое уведомления
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(notification.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        if !notification.isRead {
                            Circle()
                                .fill(Color("BykAccent"))
                                .frame(width: 8, height: 8)
                        }
                    }
                    
                    Text(notification.message)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(2)
                    
                    Text(timeAgoString(from: notification.timestamp))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                }
                
                // Кнопка удаления
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white.opacity(0.4))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        notification.isRead ?
                        Color.white.opacity(0.05) :
                        Color.white.opacity(0.08)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                notification.isRead ?
                                Color.white.opacity(0.1) :
                                Color("BykAccent").opacity(0.3),
                                lineWidth: notification.isRead ? 1 : 1.5
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func timeAgoString(from date: Date) -> String {
        let now = Date()
        let difference = now.timeIntervalSince(date)
        
        if difference < 60 {
            return "Только что"
        } else if difference < 3600 {
            let minutes = Int(difference / 60)
            return "\(minutes) мин назад"
        } else if difference < 86400 {
            let hours = Int(difference / 3600)
            return "\(hours) ч назад"
        } else {
            let days = Int(difference / 86400)
            return "\(days) дн назад"
        }
    }
}