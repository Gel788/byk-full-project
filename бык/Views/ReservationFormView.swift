import SwiftUI

struct ReservationFormView: View {
    let restaurant: Restaurant
    @StateObject private var reservationService = ReservationService()
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedDate = Date()
    @State private var selectedTime = Date()
    @State private var selectedGuests = 2
    @State private var selectedTable: Table?
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
    
    private var availableTables: [Table] {
        restaurant.tables.filter { table in
            table.isAvailable &&
            table.capacity >= selectedGuests &&
            reservationService.isTableAvailable(
                restaurant: restaurant,
                tableNumber: table.number,
                at: selectedDate
            )
        }
    }
    
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
                    VStack(spacing: 20) {
                        // Информация о ресторане
                        RestaurantInfoCard(restaurant: restaurant, brandColors: brandColors)
                        
                        // Дата и время
                        DateTimeSection(
                            selectedDate: $selectedDate,
                            selectedTime: $selectedTime,
                            dateRange: dateRange,
                            brandColors: brandColors,
                            workingHours: restaurant.workingHours
                        )
                        
                        // Количество гостей
                        GuestsSection(
                            selectedGuests: $selectedGuests,
                            guestRange: guestRange,
                            brandColors: brandColors
                        )
                        
                        // Выбор стола
                        TablesSection(
                            availableTables: availableTables,
                            selectedTable: $selectedTable,
                            brandColors: brandColors
                        )
                        
                        // Особые пожелания
                        SpecialRequestsSection(
                            specialRequests: $specialRequests,
                            brandColors: brandColors
                        )
                        
                        // Кнопка бронирования
                        ReservationButton(
                            isEnabled: isFormValid,
                            brandColors: brandColors,
                            action: createReservation
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Бронирование")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                    .foregroundColor(brandColors.accent)
                }
            }
            .sheet(isPresented: $showingError) {
                ReservationErrorAlertView(
                    errorMessage: errorMessage,
                    brandColors: brandColors,
                    onDismiss: { showingError = false }
                )
            }
            .fullScreenCover(isPresented: $showingSuccess) {
                ReservationSuccessView(
                    reservation: newReservation!,
                    brandColors: brandColors,
                    onClose: { dismiss() }
                )
            }
        }
        .background(Color.black)
    }
    
    private var isFormValid: Bool {
        selectedTable != nil
    }
    
    private func createReservation() {
        guard let table = selectedTable else { return }
        
        // Объединяем выбранные дату и время
        let calendar = Calendar.current
        let reservationDate = calendar.date(
            bySettingHour: calendar.component(.hour, from: selectedTime),
            minute: calendar.component(.minute, from: selectedTime),
            second: 0,
            of: selectedDate
        ) ?? selectedDate
        
        // Проверяем, что ресторан открыт в выбранное время
        guard restaurant.workingHours.isOpen(at: reservationDate) else {
            errorMessage = "Ресторан закрыт в выбранное время"
            showingError = true
            return
        }
        
        // Создаем бронирование
        let reservation = reservationService.createReservation(
            restaurant: restaurant,
            date: reservationDate,
            guestCount: selectedGuests,
            tableNumber: table.number,
            specialRequests: specialRequests.isEmpty ? nil : specialRequests
        )
        
        newReservation = reservation
        showingSuccess = true
    }
}

// MARK: - DateTime Section
struct DateTimeSection: View {
    @Binding var selectedDate: Date
    @Binding var selectedTime: Date
    let dateRange: ClosedRange<Date>
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let workingHours: WorkingHours
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .font(.title2)
                    .foregroundColor(brandColors.accent)
                
                Text("Дата и время")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 16) {
                // Календарь
                VStack(alignment: .leading, spacing: 8) {
                    Text("Выберите дату")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    DatePicker("", selection: $selectedDate, in: dateRange, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .environment(\.locale, Locale(identifier: "ru_RU"))
                        .tint(brandColors.accent)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(12)
                }
                
                // Время
                VStack(alignment: .leading, spacing: 8) {
                    Text("Выберите время")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    TimePickerView(
                        selectedTime: $selectedTime,
                        brandColors: brandColors,
                        workingHours: workingHours
                    )
                }
                
                // Часы работы
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(brandColors.accent)
                    Text("Часы работы: \(workingHours.openTime)-\(workingHours.closeTime)")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                if !workingHours.isOpen(at: selectedDate) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("Ресторан закрыт в выбранное время")
                            .font(.system(size: 14))
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(brandColors.accent.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Guests Section
struct GuestsSection: View {
    @Binding var selectedGuests: Int
    let guestRange: ClosedRange<Int>
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "person.3.fill")
                    .font(.title2)
                    .foregroundColor(brandColors.accent)
                
                Text("Количество гостей")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Picker("Выберите количество гостей", selection: $selectedGuests) {
                ForEach(guestRange, id: \.self) { number in
                    Text("\(number) \(number == 1 ? "гость" : "гостей")")
                        .tag(number)
                        .foregroundColor(.white)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 120)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(brandColors.accent.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Tables Section
struct TablesSection: View {
    let availableTables: [Table]
    @Binding var selectedTable: Table?
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "tablecells.fill")
                    .font(.title2)
                    .foregroundColor(brandColors.accent)
                
                Text("Доступные столы")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            
            if availableTables.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tablecells.badge.xmark")
                        .font(.title)
                        .foregroundColor(.gray)
                    
                    Text("Нет доступных столов")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text("Попробуйте выбрать другое время или количество гостей")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(availableTables) { table in
                        TableCard(
                            table: table,
                            isSelected: selectedTable?.id == table.id,
                            brandColors: brandColors,
                            action: { selectedTable = table }
                        )
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(brandColors.accent.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Table Card
struct TableCard: View {
    let table: Table
    let isSelected: Bool
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: "tablecells")
                    .font(.title2)
                    .foregroundColor(isSelected ? brandColors.accent : .white.opacity(0.7))
                
                Text("Стол №\(String(table.number))")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isSelected ? brandColors.accent : .white)
                
                Text("\(table.capacity) мест")
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? brandColors.accent : .white.opacity(0.6))
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(brandColors.accent)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? brandColors.accent.opacity(0.2) : Color.black.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? brandColors.accent : Color.white.opacity(0.2), lineWidth: 2)
                    )
            )
        }
    }
}



// MARK: - Reservation Button
struct ReservationButton: View {
    let isEnabled: Bool
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                
                Text("Забронировать стол")
                    .font(.system(size: 18, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isEnabled ? brandColors.accent : Color.gray.opacity(0.3))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isEnabled ? brandColors.accent : Color.clear, lineWidth: 2)
            )
        }
        .disabled(!isEnabled)
    }
}

// MARK: - Reservation Success View
struct ReservationSuccessView: View {
    let reservation: Reservation
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let onClose: () -> Void
    
    @State private var showingAnimation = false
    
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
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Элегантная иконка успеха
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        brandColors.accent.opacity(0.2),
                                        brandColors.primary.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .scaleEffect(showingAnimation ? 1 : 0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showingAnimation)
                        
                        Circle()
                            .stroke(brandColors.accent.opacity(0.3), lineWidth: 2)
                            .frame(width: 120, height: 120)
                            .scaleEffect(showingAnimation ? 1 : 0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: showingAnimation)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 50, weight: .bold))
                            .foregroundColor(brandColors.accent)
                            .scaleEffect(showingAnimation ? 1 : 0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.2), value: showingAnimation)
                    }
                    
                    // Заголовок
                    VStack(spacing: 12) {
                        Text("Бронирование подтверждено!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(brandColors.accent)
                            .opacity(showingAnimation ? 1 : 0)
                            .animation(.easeInOut(duration: 0.5).delay(0.3), value: showingAnimation)
                        
                        Text("Ваш стол забронирован на указанное время")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .opacity(showingAnimation ? 1 : 0)
                            .animation(.easeInOut(duration: 0.5).delay(0.4), value: showingAnimation)
                    }
                    
                    // Информация о бронировании
                    VStack(spacing: 16) {
                        InfoRow(icon: "building.2", title: "Ресторан", value: reservation.restaurant.name, brandColors: brandColors)
                        InfoRow(icon: "calendar", title: "Дата и время", value: formatDate(reservation.date), brandColors: brandColors)
                        InfoRow(icon: "person.2", title: "Гости", value: "\(reservation.guestCount) \(reservation.guestCount == 1 ? "гость" : "гостей")", brandColors: brandColors)
                        InfoRow(icon: "tablecells", title: "Стол", value: "№\(reservation.tableNumber)", brandColors: brandColors)
                        
                        if let specialRequests = reservation.specialRequests, !specialRequests.isEmpty {
                            InfoRow(icon: "text.bubble", title: "Пожелания", value: specialRequests, brandColors: brandColors)
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.black.opacity(0.9),
                                        Color.black.opacity(0.7)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                brandColors.accent.opacity(0.4),
                                                brandColors.accent.opacity(0.2)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                            .shadow(color: brandColors.accent.opacity(0.2), radius: 10, x: 0, y: 5)
                    )
                    .opacity(showingAnimation ? 1 : 0)
                    .animation(.easeInOut(duration: 0.5).delay(0.5), value: showingAnimation)
                    
                    Spacer()
                    
                    // Кнопки действий
                    VStack(spacing: 16) {
                        Button(action: {
                            // TODO: Открыть список бронирований
                        }) {
                            HStack {
                                Image(systemName: "calendar")
                                    .font(.title3)
                                Text("Мои бронирования")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [brandColors.accent, brandColors.primary],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: brandColors.accent.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        
                        Button(action: onClose) {
                            Text("Вернуться к ресторанам")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .opacity(showingAnimation ? 1 : 0)
                    .animation(.easeInOut(duration: 0.5).delay(0.6), value: showingAnimation)
                }
                .padding()
            }
            .navigationBarHidden(true)
            .onAppear {
                withAnimation {
                    showingAnimation = true
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(brandColors.accent)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .multilineTextAlignment(.trailing)
        }
    }
}

// MARK: - Time Picker View
struct TimePickerView: View {
    @Binding var selectedTime: Date
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let workingHours: WorkingHours
    
    private var timeSlots: [Date] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        guard let openTime = formatter.date(from: workingHours.openTime),
              let closeTime = formatter.date(from: workingHours.closeTime) else {
            return []
        }
        
        var slots: [Date] = []
        var currentTime = openTime
        
        while currentTime <= closeTime {
            slots.append(currentTime)
            currentTime = calendar.date(byAdding: .minute, value: 30, to: currentTime) ?? currentTime
        }
        
        return slots
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(timeSlots, id: \.self) { time in
                    TimeSlotButton(
                        time: time,
                        isSelected: Calendar.current.isDate(selectedTime, equalTo: time, toGranularity: .minute),
                        brandColors: brandColors
                    ) {
                        selectedTime = time
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 60)
        .background(Color.black.opacity(0.6))
        .cornerRadius(12)
    }
}

// MARK: - Time Slot Button
struct TimeSlotButton: View {
    let time: Date
    let isSelected: Bool
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let action: () -> Void
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: time)
    }
    
    var body: some View {
        Button(action: action) {
            Text(timeString)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? brandColors.accent : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isSelected ? brandColors.accent : Color.white.opacity(0.3), lineWidth: 1)
                        )
                )
        }
    }
}

#Preview {
    NavigationView {
        ReservationFormView(restaurant: Restaurant.mock)
    }
} 