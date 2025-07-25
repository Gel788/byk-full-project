import SwiftUI

struct ReservationsManagementView: View {
    @EnvironmentObject var userDataService: UserDataService
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFilter: ReservationStatus? = nil
    @State private var showingCancelAlert = false
    @State private var reservationToCancel: UserReservation? = nil
    
    private var filteredReservations: [UserReservation] {
        var reservations = userDataService.userReservations
        
        if let filter = selectedFilter {
            reservations = reservations.filter { $0.status == filter }
        }
        
        return reservations.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Анимированный градиентный фон
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        Color("BykAccent").opacity(0.1),
                        Color.black
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Заголовок
                    ReservationsHeader(reservationCount: filteredReservations.count)
                    
                    // Фильтры
                    ReservationFilterSection(selectedFilter: $selectedFilter)
                    
                    // Список бронирований
                    if filteredReservations.isEmpty {
                        EmptyReservationsView()
                    } else {
                        ReservationListSection(
                            reservations: filteredReservations,
                            onCancelReservation: { reservation in
                                reservationToCancel = reservation
                                showingCancelAlert = true
                            }
                        )
                    }
                }
            }
            .navigationTitle("Управление бронями")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                    .foregroundColor(Color("BykAccent"))
                }
            }
        }
        .alert("Отменить бронирование?", isPresented: $showingCancelAlert) {
            Button("Отмена", role: .cancel) { }
            Button("Отменить", role: .destructive) {
                if let reservation = reservationToCancel {
                    userDataService.cancelReservation(reservation)
                }
            }
        } message: {
            if let reservation = reservationToCancel {
                Text("Вы уверены, что хотите отменить бронирование в \(reservation.restaurantName) на \(reservation.date.formatted(date: .abbreviated, time: .omitted))?")
            }
        }
    }
}

struct ReservationsHeader: View {
    let reservationCount: Int
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Управление бронями")
                        .font(.custom("Helvetica Neue", size: 28, relativeTo: .largeTitle))
                        .fontWeight(.light)
                        .foregroundColor(.white)
                    
                    Text("\(reservationCount) бронирований")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Иконка календаря
                ZStack {
                    Circle()
                        .fill(Color("BykAccent").opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 20))
                        .foregroundColor(Color("BykAccent"))
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
}

struct ReservationFilterSection: View {
    @Binding var selectedFilter: ReservationStatus?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // Кнопка "Все"
                ReservationFilterChip(
                    title: "Все",
                    isSelected: selectedFilter == nil,
                    color: Color("BykAccent")
                ) {
                    selectedFilter = nil
                }
                
                // Фильтры по статусам
                ForEach(ReservationStatus.allCases, id: \.self) { status in
                    ReservationFilterChip(
                        title: status.rawValue,
                        isSelected: selectedFilter == status,
                        color: Color(status.color)
                    ) {
                        selectedFilter = status
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 20)
    }
}

struct ReservationFilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            isSelected ?
                            LinearGradient(
                                gradient: Gradient(colors: [color, color.opacity(0.7)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ) :
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0.05)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    isSelected ? color.opacity(0.5) : Color.white.opacity(0.2),
                                    lineWidth: 1
                                )
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ReservationListSection: View {
    let reservations: [UserReservation]
    let onCancelReservation: (UserReservation) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(reservations) { reservation in
                    ReservationCard(
                        reservation: reservation,
                        onCancel: {
                            onCancelReservation(reservation)
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
    }
}

struct ReservationCard: View {
    let reservation: UserReservation
    let onCancel: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Заголовок бронирования
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Бронирование #\(reservation.reservationNumber)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(reservation.restaurantName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color("BykAccent"))
                }
                
                Spacer()
                
                // Статус бронирования
                ReservationStatusBadge(status: reservation.status)
            }
            
            // Детали бронирования
            VStack(spacing: 12) {
                ReservationDetailRow(
                    icon: "calendar",
                    title: "Дата",
                    value: reservation.date.formatted(date: .abbreviated, time: .omitted),
                    color: .blue
                )
                
                ReservationDetailRow(
                    icon: "clock",
                    title: "Время",
                    value: reservation.time,
                    color: .green
                )
                
                ReservationDetailRow(
                    icon: "person.2",
                    title: "Гостей",
                    value: "\(reservation.guests) чел.",
                    color: .orange
                )
                
                if let specialRequests = reservation.specialRequests {
                    ReservationDetailRow(
                        icon: "note.text",
                        title: "Особые пожелания",
                        value: specialRequests,
                        color: .purple
                    )
                }
            }
            
            // Кнопки действий
            if reservation.status == .confirmed || reservation.status == .pending {
                HStack(spacing: 12) {
                    Button(action: {
                        // Изменить бронирование
                    }) {
                        HStack {
                            Image(systemName: "pencil")
                                .font(.system(size: 14, weight: .medium))
                            Text("Изменить")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(Color("BykAccent"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color("BykAccent").opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color("BykAccent").opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    
                    Spacer()
                    
                    Button(action: onCancel) {
                        HStack {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .medium))
                            Text("Отменить")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(.red)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.red.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
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
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color("BykAccent").opacity(0.3),
                                    Color("BykAccent").opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: Color("BykAccent").opacity(0.2), radius: 10, x: 0, y: 5)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

struct ReservationStatusBadge: View {
    let status: ReservationStatus
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: status.icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(statusColor)
            
            Text(status.rawValue)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(statusColor)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(statusColor.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(statusColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var statusColor: Color {
        switch status {
        case .confirmed: return .green
        case .pending: return .orange
        case .cancelled: return .red
        case .completed: return .blue
        }
    }
}

struct ReservationDetailRow: View {
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
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                
                Text(value)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
    }
}

struct EmptyReservationsView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Иконка
            ZStack {
                Circle()
                    .fill(Color("BykAccent").opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 60))
                    .foregroundColor(Color("BykAccent"))
            }
            
            VStack(spacing: 8) {
                Text("Бронирования не найдены")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Здесь будут отображаться все ваши бронирования")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            
            // Кнопка создания бронирования
            Button(action: {
                // Переход к созданию бронирования
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text("Создать бронирование")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color("BykAccent"),
                                    Color("BykAccent").opacity(0.8)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
                .shadow(color: Color("BykAccent").opacity(0.3), radius: 8, x: 0, y: 4)
            }
            
            Spacer()
        }
        .padding(40)
    }
}

#Preview {
    ReservationsManagementView()
        .environmentObject(UserDataService())
} 