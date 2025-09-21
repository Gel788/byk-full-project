import SwiftUI

struct ReservationFormView: View {
    let restaurant: Restaurant
    @StateObject private var reservationService = ReservationService()
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedDate = Date()
    @State private var selectedTime = Date()
    @State private var selectedGuests = 2
    // Убрали selectedTable - больше не выбираем стол
    @State private var specialRequests = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingSuccess = false
    @State private var newReservation: Reservation?
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color) {
        Colors.brandColors(for: restaurant.brand)
    }
    
    private let guestRange = 1...12
    private let dateRange: ClosedRange<Date> = {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let end = calendar.date(byAdding: .day, value: 30, to: start)!
        return start...end
    }()
    
    // Убрали availableTables - больше не выбираем стол
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Градиентный фон
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        brandColors.primary.opacity(0.1),
                        Color.black
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Информация о ресторане (компактная)
                        CompactRestaurantInfo(restaurant: restaurant, brandColors: brandColors)
                        
                        // Основная форма в одной карточке
                        VStack(spacing: 20) {
                            // Заголовок
                            Text("Бронирование стола")
                    .font(.title2)
                                .fontWeight(.bold)
                    .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
            
                            // Дата и время в одной строке
                            HStack(spacing: 12) {
                                // Дата
                VStack(alignment: .leading, spacing: 8) {
                                    Label("Дата", systemImage: "calendar")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                    
                    DatePicker("", selection: $selectedDate, in: dateRange, displayedComponents: .date)
                                        .datePickerStyle(.compact)
                                        .labelsHidden()
                                        .colorScheme(.dark)
                                }
                                .frame(maxWidth: .infinity)
                
                // Время
                VStack(alignment: .leading, spacing: 8) {
                                    Label("Время", systemImage: "clock")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                    
                                    DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                                        .datePickerStyle(.compact)
                                        .labelsHidden()
                                        .colorScheme(.dark)
                }
                .frame(maxWidth: .infinity)
                            }
                            
                            // Гости и стол в одной строке
                            HStack(spacing: 12) {
                                // Количество гостей
                                VStack(alignment: .leading, spacing: 8) {
                                    Label("Гости", systemImage: "person.2")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                    
                                    Picker("Гости", selection: $selectedGuests) {
                                        ForEach(guestRange, id: \.self) { count in
                                            Text("\(count)").tag(count)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(8)
                                }
                                .frame(maxWidth: .infinity)
                                
                                // Убрали выбор стола - автоматическое назначение
                            }
                            
                            // Особые пожелания
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Особые пожелания", systemImage: "note.text")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                                
                                TextField("Например: стол у окна", text: $specialRequests)
                                    .textFieldStyle(PlainTextFieldStyle())
                                .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            
                            // Кнопка бронирования
                            Button(action: createReservation) {
                                HStack {
                                    if reservationService.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "calendar.badge.plus")
                                    }
                                    
                                    Text("Забронировать стол")
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [brandColors.accent, brandColors.primary],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                                .shadow(color: brandColors.accent.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .disabled(reservationService.isLoading)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(brandColors.accent.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Бронирование")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .alert("Ошибка", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showingSuccess) {
            if let reservation = newReservation {
                ReservationSuccessView(reservation: reservation, restaurant: restaurant)
            }
        }
    }
    
    // MARK: - Actions
    private func createReservation() {
        // Убрали проверку выбора стола
        
        let calendar = Calendar.current
        let combinedDateTime = calendar.date(
            bySettingHour: calendar.component(.hour, from: selectedTime),
            minute: calendar.component(.minute, from: selectedTime),
            second: 0,
            of: selectedDate
        ) ?? selectedDate
        
        Task {
            do {
                // Создаем резервацию через API с автоматическим назначением стола
                let randomTableNumber = Int.random(in: 1...20)
                let reservation = try await reservationService.createReservation(
                    restaurant: restaurant,
                    date: combinedDateTime,
                    guestCount: selectedGuests,
                    tableNumber: randomTableNumber,
                    specialRequests: specialRequests.isEmpty ? nil : specialRequests,
                    contactName: "Пользователь", // TODO: Получать из профиля
                    contactPhone: "+7 (999) 123-45-67" // TODO: Получать из профиля
                )
                
                newReservation = reservation
                print("ReservationFormView: Резервация создана через API успешно")
                print("ReservationFormView: newReservation = \(reservation)")
                showingSuccess = true
                print("ReservationFormView: showingSuccess = true")
            } catch {
                print("ReservationFormView: Ошибка создания резервации - \(error)")
                errorMessage = error.localizedDescription
                showingError = true
            }
        }
    }
}

// MARK: - Compact Restaurant Info
struct CompactRestaurantInfo: View {
    let restaurant: Restaurant
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        HStack(spacing: 12) {
            // Эмодзи бренда
            Text(restaurant.brand.emoji)
                .font(.system(size: 32))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(restaurant.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(restaurant.address)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Рейтинг
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundColor(.yellow)
                
                Text(String(format: "%.1f", restaurant.rating))
                    .font(.caption)
                    .fontWeight(.semibold)
                        .foregroundColor(.white)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(brandColors.accent.opacity(0.2))
            )
        }
        .padding(16)
                .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                        .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(brandColors.accent.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

#Preview {
        ReservationFormView(restaurant: Restaurant.mock)
} 