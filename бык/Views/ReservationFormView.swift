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
    @State private var showingActionSheet = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Динамический градиентный фон
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        brandColors.accent.opacity(0.1),
                        brandColors.primary.opacity(0.05),
                        Color.black
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                

                
                ScrollView {
                    VStack(spacing: 32) {
                        // Анимированная иконка успеха с пульсацией
                        ZStack {
                            // Внешние круги с пульсацией
                            ForEach(0..<3) { index in
                                Circle()
                                    .stroke(brandColors.accent.opacity(0.3), lineWidth: 2)
                                    .frame(width: 120 + CGFloat(index * 20), height: 120 + CGFloat(index * 20))
                                    .scaleEffect(showingAnimation ? 1.2 : 0.8)
                                    .opacity(showingAnimation ? 0.0 : 0.8)
                                    .animation(
                                        .easeInOut(duration: 2.0)
                                        .repeatForever(autoreverses: true)
                                        .delay(Double(index) * 0.2),
                                        value: showingAnimation
                                    )
                            }
                            
                            // Основной круг
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            brandColors.accent.opacity(0.3),
                                            brandColors.primary.opacity(0.2)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 140, height: 140)
                                .scaleEffect(showingAnimation ? 1 : 0)
                                .animation(.spring(response: 0.8, dampingFraction: 0.6), value: showingAnimation)
                            
                            // Галочка с вращением
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 60, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [brandColors.accent, brandColors.primary],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .scaleEffect(showingAnimation ? 1 : 0)
                                .rotationEffect(.degrees(showingAnimation ? 360 : 0))
                                .animation(
                                    .spring(response: 0.6, dampingFraction: 0.7).delay(0.3),
                                    value: showingAnimation
                                )
                        }
                        .padding(.top, 40)
                        
                        // Заголовок с эмодзи
                        VStack(spacing: 16) {
                            Text("🎉 Готово!")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(brandColors.accent)
                                .opacity(showingAnimation ? 1 : 0)
                                .scaleEffect(showingAnimation ? 1 : 0.5)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: showingAnimation)
                            
                            Text("Ваш стол успешно забронирован!")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .opacity(showingAnimation ? 1 : 0)
                                .animation(.easeInOut(duration: 0.5).delay(0.5), value: showingAnimation)
                            
                            Text("Ждем вас в указанное время ✨")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .opacity(showingAnimation ? 1 : 0)
                                .animation(.easeInOut(duration: 0.5).delay(0.6), value: showingAnimation)
                        }
                        
                        // Премиальная карточка с информацией о бронировании
                        VStack(spacing: 20) {
                            // Заголовок карточки
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                    .font(.system(size: 16))
                                
                                Text("Детали бронирования")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Text("№\(reservation.id.uuidString.prefix(6))")
                                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                                    .foregroundColor(brandColors.accent)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(brandColors.accent.opacity(0.2))
                                    )
                            }
                            
                            // Информация
                            VStack(spacing: 16) {
                                EnhancedInfoRow(
                                    icon: "building.2.fill", 
                                    title: "Ресторан", 
                                    value: reservation.restaurant.name,
                                    subtitle: reservation.restaurant.address,
                                    brandColors: brandColors
                                )
                                
                                EnhancedInfoRow(
                                    icon: "calendar.badge.clock", 
                                    title: "Дата и время", 
                                    value: formatDate(reservation.date),
                                    subtitle: getTimeUntilReservation(),
                                    brandColors: brandColors
                                )
                                
                                EnhancedInfoRow(
                                    icon: "person.2.fill", 
                                    title: "Количество гостей", 
                                    value: "\(reservation.guestCount) \(reservation.guestCount == 1 ? "гость" : "гостей")",
                                    subtitle: "Стол №\(reservation.tableNumber)",
                                    brandColors: brandColors
                                )
                                
                                if let specialRequests = reservation.specialRequests, !specialRequests.isEmpty {
                                    EnhancedInfoRow(
                                        icon: "text.bubble.fill", 
                                        title: "Особые пожелания", 
                                        value: specialRequests,
                                        subtitle: nil,
                                        brandColors: brandColors
                                    )
                                }
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    brandColors.accent.opacity(0.6),
                                                    brandColors.accent.opacity(0.2),
                                                    Color.clear
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 2
                                        )
                                )
                                .shadow(color: brandColors.accent.opacity(0.3), radius: 20, x: 0, y: 10)
                        )
                        .opacity(showingAnimation ? 1 : 0)
                        .scaleEffect(showingAnimation ? 1 : 0.9)
                        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.7), value: showingAnimation)
                        
                        // Полезные быстрые действия
                        VStack(spacing: 16) {
                            Text("Что дальше?")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .opacity(showingAnimation ? 1 : 0)
                                .animation(.easeInOut(duration: 0.5).delay(0.9), value: showingAnimation)
                            
                            HStack(spacing: 12) {
                                // Добавить в календарь
                                QuickActionButton(
                                    icon: "calendar.badge.plus",
                                    title: "В календарь",
                                    subtitle: "Добавить событие",
                                    brandColors: brandColors,
                                    isPrimary: true
                                ) {
                                    addToCalendar()
                                }
                                
                                // Маршрут
                                QuickActionButton(
                                    icon: "location.fill",
                                    title: "Маршрут",
                                    subtitle: "Как добраться",
                                    brandColors: brandColors,
                                    isPrimary: false
                                ) {
                                    openRoute()
                                }
                            }
                            
                            HStack(spacing: 12) {
                                // Позвонить в ресторан
                                QuickActionButton(
                                    icon: "phone.fill",
                                    title: "Позвонить",
                                    subtitle: "Связаться",
                                    brandColors: brandColors,
                                    isPrimary: false
                                ) {
                                    callRestaurant()
                                }
                                
                                // Поделиться
                                QuickActionButton(
                                    icon: "square.and.arrow.up.fill",
                                    title: "Поделиться",
                                    subtitle: "Рассказать друзьям",
                                    brandColors: brandColors,
                                    isPrimary: false
                                ) {
                                    shareReservation()
                                }
                            }
                        }
                        .opacity(showingAnimation ? 1 : 0)
                        .animation(.easeInOut(duration: 0.5).delay(1.0), value: showingAnimation)
                        
                        // Основные кнопки
                        VStack(spacing: 12) {
                            Button(action: {
                                // TODO: Открыть список бронирований
                            }) {
                                HStack {
                                    Image(systemName: "list.bullet.rectangle")
                                        .font(.system(size: 18, weight: .semibold))
                                    Text("Мои бронирования")
                                        .font(.system(size: 18, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(
                                    LinearGradient(
                                        colors: [brandColors.accent, brandColors.primary],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: brandColors.accent.opacity(0.4), radius: 12, x: 0, y: 6)
                            }
                            
                            Button(action: onClose) {
                                Text("Вернуться к ресторанам")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .padding(.top, 8)
                        }
                        .opacity(showingAnimation ? 1 : 0)
                        .animation(.easeInOut(duration: 0.5).delay(1.1), value: showingAnimation)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                withAnimation {
                    showingAnimation = true
                }
                // Добавляем haptic feedback
                HapticManager.shared.successPattern()
            }
        }
    }
    
    // MARK: - Helper Methods
    private func addToCalendar() {
        HapticManager.shared.buttonPress()
        // TODO: Реализовать добавление в календарь
    }
    
    private func openRoute() {
        HapticManager.shared.buttonPress()
        
        // Используем Яндекс Карты как основной сервис
        if let url = YandexMapsConfig.routeURL(
            to: (reservation.restaurant.location.latitude, reservation.restaurant.location.longitude), 
            name: reservation.restaurant.name
        ) {
            if YandexMapsConfig.isYandexMapsInstalled {
                UIApplication.shared.open(url)
            } else {
                // Fallback на веб-версию Яндекс Карт
                if let webUrl = YandexMapsConfig.webURL(
                    for: (reservation.restaurant.location.latitude, reservation.restaurant.location.longitude), 
                    name: reservation.restaurant.name
                ) {
                    UIApplication.shared.open(webUrl)
                }
            }
        }
    }
    
    private func callRestaurant() {
        HapticManager.shared.buttonPress()
        if let phoneURL = URL(string: "tel://\(reservation.restaurant.contacts.phone)") {
            UIApplication.shared.open(phoneURL)
        }
    }
    
    private func shareReservation() {
        HapticManager.shared.buttonPress()
        let shareText = "Забронировал стол в \(reservation.restaurant.name) на \(formatDate(reservation.date))!"
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
    
    private func getTimeUntilReservation() -> String {
        let now = Date()
        let timeInterval = reservation.date.timeIntervalSince(now)
        
        if timeInterval <= 0 {
            return "Время прошло"
        }
        
        let days = Int(timeInterval) / (24 * 3600)
        let hours = Int(timeInterval) % (24 * 3600) / 3600
        let minutes = Int(timeInterval) % 3600 / 60
        
        if days > 0 {
            return "через \(days) \(days == 1 ? "день" : "дней")"
        } else if hours > 0 {
            return "через \(hours) \(hours == 1 ? "час" : "часов")"
        } else {
            return "через \(minutes) минут"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}

// MARK: - Enhanced Info Row
struct EnhancedInfoRow: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String?
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        HStack(spacing: 16) {
            // Иконка в кружке
            ZStack {
                Circle()
                    .fill(brandColors.accent.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(brandColors.accent)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                
                Text(value)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(brandColors.accent.opacity(0.8))
                }
            }
            
            Spacer()
        }
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let isPrimary: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
                action()
            }
        }) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            isPrimary 
                            ? LinearGradient(colors: [brandColors.accent, brandColors.primary], startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .stroke(
                                    isPrimary ? Color.clear : brandColors.accent.opacity(0.3),
                                    lineWidth: 1.5
                                )
                        )
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(isPrimary ? .white : brandColors.accent)
                }
                
                VStack(spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
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