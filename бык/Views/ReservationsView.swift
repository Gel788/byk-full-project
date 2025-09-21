import SwiftUI

struct ReservationsView: View {
    @StateObject private var viewModel = ReservationsViewModel()
    @EnvironmentObject private var reservationService: ReservationService
    
    var body: some View {
        NavigationView {
        ZStack {
                // Фон
                LinearGradient(
                    gradient: Gradient(colors: [
                Color.black,
                Color.purple.opacity(0.1),
                Color.black
                    ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                    // Заголовок
                    ReservationsHeaderView()
                
                    // Переключатель табов
                    ReservationsTabSelector(selectedTab: $viewModel.selectedTab)
                
                // Контент
                    ReservationsContentView(
                        selectedTab: viewModel.selectedTab,
                        activeReservations: reservationService.reservations.filter { $0.status != .completed && $0.status != .cancelled },
                        pastReservations: reservationService.reservations.filter { $0.status == .completed || $0.status == .cancelled },
                        onNewReservation: { viewModel.showingNewReservation = true },
                        onReservationTap: { viewModel.selectedReservation = $0 }
                    )
            }
        }
        .navigationTitle("Мои бронирования")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .sheet(isPresented: $viewModel.showingNewReservation) {
            ReservationsRestaurantPicker()
        }
        .sheet(item: $viewModel.selectedReservation) { reservation in
            ReservationDetailView(reservation: reservation)
        }
        .onAppear {
            // Данные уже загружаются автоматически в ReservationService
        }
    }
}

// MARK: - View Model
class ReservationsViewModel: ObservableObject {
    @Published var selectedTab = 0
    @Published var showingNewReservation = false
    @Published var selectedReservation: Reservation?
}

// MARK: - Header View
struct ReservationsHeaderView: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Мои бронирования")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Управляйте своими столиками")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "calendar.badge.plus")
                    .font(.title2)
                    .foregroundColor(Color("BykAccent"))
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }
}

// MARK: - Tab Selector
struct ReservationsTabSelector: View {
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
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(selectedTab == index ? .white : .gray)
                        
                        Rectangle()
                            .fill(Color("BykAccent"))
                            .frame(height: 2)
                            .opacity(selectedTab == index ? 1 : 0)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
}

// MARK: - Content View
struct ReservationsContentView: View {
    let selectedTab: Int
    let activeReservations: [Reservation]
    let pastReservations: [Reservation]
    let onNewReservation: () -> Void
    let onReservationTap: (Reservation) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if selectedTab == 0 {
                    if activeReservations.isEmpty {
                        ReservationsEmptyState(
                            icon: "calendar.badge.plus",
                            title: "Нет активных броней",
                            subtitle: "Создайте новое бронирование",
                            actionTitle: "Забронировать стол",
                            action: onNewReservation
                        )
                    } else {
                        ForEach(activeReservations) { reservation in
                            ReservationCardView(reservation: reservation) {
                                onReservationTap(reservation)
                            }
                        }
                    }
                } else {
                    if pastReservations.isEmpty {
                        ReservationsEmptyState(
                            icon: "clock.arrow.circlepath",
                            title: "История пуста",
                            subtitle: "Ваши завершенные бронирования появятся здесь",
                            actionTitle: "Забронировать стол",
                            action: onNewReservation
                        )
                    } else {
                        ForEach(pastReservations) { reservation in
                            ReservationCardView(reservation: reservation) {
                                onReservationTap(reservation)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }
}

// MARK: - Empty State
struct ReservationsEmptyState: View {
    let icon: String
    let title: String
    let subtitle: String
    let actionTitle: String
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
                Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(Color("BykAccent"))
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: action) {
                    Text(actionTitle)
                    .font(.headline)
                .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color("BykAccent"))
                    )
            }
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 60)
    }
}

// MARK: - Restaurant Picker
struct ReservationsRestaurantPicker: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Выберите ресторан")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top)
                    
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(Restaurant.mockRestaurants) { restaurant in
                                RestaurantCard(restaurant: restaurant) {
                                    // Переходим к форме бронирования
                                    dismiss()
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Отмена") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

#Preview {
    ReservationsView()
} 
