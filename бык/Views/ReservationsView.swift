import SwiftUI

struct ReservationsView: View {
    @State private var activeReservations: [Reservation] = []
    @State private var pastReservations: [Reservation] = []
    @State private var selectedTab = 0
    @State private var showingNewReservation = false
    @State private var selectedReservation: Reservation?
    @State private var animateCards = false
    
    var body: some View {
        ZStack {
            // Градиентный фон
            let gradientColors = [
                Color.black,
                Color.purple.opacity(0.1),
                Color.black
            ]
            
            LinearGradient(
                gradient: Gradient(colors: gradientColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Премиальный заголовок
                PremiumHeaderSection()
                
                // Переключатель табов с анимацией
                PremiumTabSelector(selectedTab: $selectedTab)
                
                // Контент
                if selectedTab == 0 {
                    if activeReservations.isEmpty {
                        PremiumEmptyState(
                            icon: "calendar.badge.plus",
                            title: "Нет активных броней",
                            subtitle: "Создайте новое бронирование, чтобы начать",
                            actionTitle: "Забронировать стол",
                            action: { showingNewReservation = true }
                        )
                    } else {
                        PremiumReservationsList(
                            reservations: activeReservations,
                            isActive: true,
                            animateCards: animateCards,
                            onReservationTap: { reservation in
                                selectedReservation = reservation
                            }
                        )
                    }
                } else {
                    if pastReservations.isEmpty {
                        PremiumEmptyState(
                            icon: "clock.arrow.circlepath",
                            title: "История пуста",
                            subtitle: "Ваши завершенные бронирования появятся здесь",
                            actionTitle: "Забронировать стол",
                            action: { showingNewReservation = true }
                        )
                    } else {
                        PremiumReservationsList(
                            reservations: pastReservations,
                            isActive: false,
                            animateCards: animateCards,
                            onReservationTap: { reservation in
                                selectedReservation = reservation
                            }
                        )
                    }
                }
            }
        }
        .navigationTitle("Мои бронирования")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)

        .onAppear {
            loadReservations()
            withAnimation(.easeInOut(duration: 0.8)) {
                animateCards = true
            }
        }
        .sheet(isPresented: $showingNewReservation) {
            NavigationStack {
                VStack(spacing: 20) {
                    Text("Выберите ресторан для бронирования")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.top)
                    
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(Restaurant.mockRestaurants) { restaurant in
                                RestaurantCard(
                                    restaurant: restaurant,
                                    onTap: {
                                        showingNewReservation = false
                                        // Здесь можно открыть форму бронирования для выбранного ресторана
                                    }
                                )
                            }
                        }
                        .padding()
                    }
                }
                .background(Color.black)
                .navigationTitle("Новое бронирование")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Отмена") {
                            showingNewReservation = false
                        }
                        .foregroundColor(.white)
                    }
                }
            }
        }
        .sheet(item: $selectedReservation) { reservation in
            ReservationDetailView(reservation: reservation)
        }
    }
    
    private func loadReservations() {
        print("🔄 Загружаем бронирования...")
        
        // Временные данные для демонстрации
        activeReservations = [
            Reservation(
                id: UUID(),
                restaurant: Restaurant.mock,
                date: Date().addingTimeInterval(24 * 3600),
                guestCount: 4,
                status: .confirmed,
                tableNumber: 12
            ),
            Reservation(
                id: UUID(),
                restaurant: Restaurant.mock,
                date: Date().addingTimeInterval(3 * 24 * 3600),
                guestCount: 2,
                status: .pending,
                tableNumber: 8
            )
        ]
        
        pastReservations = [
            Reservation(
                id: UUID(),
                restaurant: Restaurant.mock,
                date: Date().addingTimeInterval(-2 * 24 * 3600),
                guestCount: 3,
                status: .completed,
                tableNumber: 15
            )
        ]
        
        print("✅ Активных бронирований: \(activeReservations.count)")
        print("✅ Прошлых бронирований: \(pastReservations.count)")
    }
}

// EmptyReservationsView удален - используется из ReservationsManagementView

struct ReservationsList: View {
    let reservations: [Reservation]
    let isActive: Bool
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(reservations) { reservation in
                    ReservationCardView(reservation: reservation)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .background(Color.black)
    }
}

struct ReservationCardView: View {
    let reservation: Reservation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Заголовок с названием ресторана
            HStack {
                Text(reservation.restaurant.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                StatusBadge(status: reservation.status)
            }
            
            // Детали бронирования
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.gray)
                    Text(reservation.formattedDate)
                        .foregroundColor(.white)
                }
                
                HStack {
                    Image(systemName: "person.2")
                        .foregroundColor(.gray)
                    Text("\(reservation.guestCount) гостей")
                        .foregroundColor(.white)
                }
                
                HStack {
                    Image(systemName: "tablecells")
                        .foregroundColor(.gray)
                    Text("Стол №\(reservation.tableNumber)")
                        .foregroundColor(.white)
                }
                
                if let specialRequests = reservation.specialRequests, !specialRequests.isEmpty {
                    HStack {
                        Image(systemName: "text.bubble")
                            .foregroundColor(.gray)
                        Text(specialRequests)
                            .foregroundColor(.white)
                            .lineLimit(2)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// ReservationCard удален - используется из ReservationsManagementView

struct StatusBadge: View {
    let status: Reservation.Status
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(status.color.opacity(0.1))
            .foregroundColor(status.color)
            .cornerRadius(8)
    }
}

// Удалено дублирующееся определение InfoRow - используется из CommonComponents.swift

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(color.opacity(0.1))
                .foregroundColor(color)
                .cornerRadius(8)
        }
    }
}

// MARK: - Premium Components

struct PremiumHeaderSection: View {
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Мои бронирования")
                        .font(.custom("Helvetica Neue", size: 28, relativeTo: .largeTitle))
                        .fontWeight(.light)
                        .foregroundColor(.white)
                    
                    Text("Управляйте своими столиками")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }
}

struct PremiumTabSelector: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<2) { index in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = index
                    }
                }) {
                    VStack(spacing: 8) {
                        Text(index == 0 ? "Активные" : "История")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(selectedTab == index ? .white : .white.opacity(0.6))
                        
                        // Индикатор
                        Rectangle()
                            .fill(
                                selectedTab == index ?
                                LinearGradient(
                                    gradient: Gradient(colors: [.purple, .blue]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ) : LinearGradient(
                                    gradient: Gradient(colors: [Color.clear, Color.clear]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(height: 3)
                            .cornerRadius(1.5)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
}

struct PremiumEmptyState: View {
    let icon: String
    let title: String
    let subtitle: String
    let actionTitle: String
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Иконка
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.purple.opacity(0.2), .blue.opacity(0.2)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Image(systemName: icon)
                    .font(.system(size: 40, weight: .light))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            
            // Кнопка действия
            Button(action: action) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text(actionTitle)
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.purple, .blue]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
                .shadow(color: .purple.opacity(0.3), radius: 10, x: 0, y: 5)
                .scaleEffect(isPressed ? 0.95 : 1.0)
            }
            .buttonStyle(PlainButtonStyle())
            .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = pressing
                }
            }, perform: {})
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
}

struct PremiumReservationsList: View {
    let reservations: [Reservation]
    let isActive: Bool
    let animateCards: Bool
    let onReservationTap: (Reservation) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(Array(reservations.enumerated()), id: \.element.id) { index, reservation in
                    PremiumReservationCard(
                        reservation: reservation,
                        isActive: isActive,
                        onTap: {
                            onReservationTap(reservation)
                        }
                    )
                    .offset(y: animateCards ? 0 : 50)
                    .opacity(animateCards ? 1 : 0)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .delay(Double(index) * 0.1),
                        value: animateCards
                    )
                    .padding(.horizontal, 20)
                }
            }
            .padding(.vertical, 20)
        }
    }
}

struct PremiumReservationCard: View {
    let reservation: Reservation
    let isActive: Bool
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 16) {
                // Заголовок с рестораном и статусом
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(reservation.restaurant.name)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(reservation.restaurant.address)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    PremiumStatusBadge(status: reservation.status)
                }
                
                // Детали бронирования
                VStack(spacing: 12) {
                    PremiumInfoRow(
                        icon: "calendar",
                        title: "Дата и время",
                        value: reservation.formattedDate,
                        color: .blue
                    )
                    
                    PremiumInfoRow(
                        icon: "person.2.fill",
                        title: "Гости",
                        value: "\(reservation.guestCount) человек",
                        color: .green
                    )
                    
                    PremiumInfoRow(
                        icon: "tablecells.fill",
                        title: "Стол",
                        value: "№\(reservation.tableNumber)",
                        color: .orange
                    )
                    
                    if let specialRequests = reservation.specialRequests, !specialRequests.isEmpty {
                        PremiumInfoRow(
                            icon: "text.bubble.fill",
                            title: "Особые пожелания",
                            value: specialRequests,
                            color: .purple
                        )
                    }
                }
                
                // Кнопки действий (только для активных бронирований)
                if isActive {
                    HStack(spacing: 12) {
                        PremiumActionButton(
                            title: "Изменить",
                            icon: "pencil",
                            color: .blue
                        ) {
                            // Действие изменения
                        }
                        
                        PremiumActionButton(
                            title: "Отменить",
                            icon: "xmark.circle",
                            color: .red
                        ) {
                            // Действие отмены
                        }
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.black.opacity(0.8),
                                Color.black.opacity(0.6)
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
                                        .purple.opacity(0.3),
                                        .blue.opacity(0.3)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: .purple.opacity(0.2), radius: 10, x: 0, y: 5)
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

struct PremiumStatusBadge: View {
    let status: Reservation.Status
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(status.color)
                .frame(width: 8, height: 8)
            
            Text(status.rawValue)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(status.color)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(status.color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(status.color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct PremiumInfoRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                
                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
    }
}

struct PremiumActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

#Preview {
    ReservationsView()
} 
