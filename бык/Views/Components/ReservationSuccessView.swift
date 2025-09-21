import SwiftUI

struct ReservationSuccessView: View {
    let reservation: Reservation
    let restaurant: Restaurant
    @Environment(\.dismiss) private var dismiss
    @State private var showingAnimation = false
    @State private var showingDetails = false
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color) {
        Colors.brandColors(for: restaurant.brand)
    }
    
    var body: some View {
        ZStack {
            // Простой фон для тестирования
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Простая анимация успеха
                ZStack {
                    // Основной круг
                    Circle()
                        .fill(Color.green)
                        .frame(width: 120, height: 120)
                    
                    // Иконка галочки
                    Image(systemName: "checkmark")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Заголовок
                VStack(spacing: 12) {
                    Text("🎉 Бронирование подтверждено!")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Ваш стол забронирован успешно")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                
                // Детали бронирования
                if showingDetails {
                    VStack(spacing: 16) {
                        ReservationDetailCard(
                            title: "Ресторан",
                            value: restaurant.name,
                            icon: "building.2.fill",
                            brandColors: brandColors
                        )
                        
                        ReservationDetailCard(
                            title: "Дата и время",
                            value: formatDateTime(reservation.date),
                            icon: "calendar.badge.clock",
                            brandColors: brandColors
                        )
                        
                        ReservationDetailCard(
                            title: "Количество гостей",
                            value: "\(reservation.guestCount) чел.",
                            icon: "person.2.fill",
                            brandColors: brandColors
                        )
                        
                        ReservationDetailCard(
                            title: "Стол",
                            value: "№\(reservation.tableNumber)",
                            icon: "table.furniture.fill",
                            brandColors: brandColors
                        )
                        
                        if let requests = reservation.specialRequests, !requests.isEmpty {
                            ReservationDetailCard(
                                title: "Особые пожелания",
                                value: requests,
                                icon: "note.text",
                                brandColors: brandColors
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
                }
                
                Spacer()
                
                // Кнопки действий
                VStack(spacing: 12) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Отлично!")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 40)
        }
        .onAppear {
            print("ReservationSuccessView: onAppear вызван")
            print("ReservationSuccessView: reservation = \(reservation)")
            print("ReservationSuccessView: restaurant = \(restaurant)")
            
            // Автоматически показать детали через 1 секунду
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showingDetails = true
            }
        }
    }
    
    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy в HH:mm"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}

// MARK: - Reservation Detail Card
struct ReservationDetailCard: View {
    let title: String
    let value: String
    let icon: String
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        HStack(spacing: 16) {
            // Иконка
            ZStack {
                Circle()
                    .fill(brandColors.accent.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(brandColors.accent)
            }
            
            // Контент
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

#Preview {
    ReservationSuccessView(
        reservation: Reservation.mockActiveReservations.first!,
        restaurant: Restaurant.mock
    )
}
