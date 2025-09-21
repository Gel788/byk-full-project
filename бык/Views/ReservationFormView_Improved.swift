import SwiftUI

struct ReservationFormView_Improved: View {
    let restaurant: Restaurant
    @StateObject private var reservationService = ReservationService()
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authService: AuthService
    
    @State private var selectedDate = Date()
    @State private var selectedTime = Date()
    @State private var selectedGuests = 2
    // Убрали selectedTable - больше не выбираем стол
    @State private var specialRequests = ""
    @State private var contactName = ""
    @State private var contactPhone = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingSuccess = false
    @State private var newReservation: Reservation?
    @State private var isLoading = false
    // Убрали availableTables - больше не загружаем столы
    @State private var isAnimating = false
    
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
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Красивый градиентный фон
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        brandColors.primary.opacity(0.2),
                        Color.black
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Заголовок с анимацией
                        ReservationHeaderView(restaurant: restaurant, brandColors: brandColors)
                            .scaleEffect(isAnimating ? 1.0 : 0.9)
                            .opacity(isAnimating ? 1.0 : 0.0)
                            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.1), value: isAnimating)
                        
                        // Основная форма
                        VStack(spacing: 20) {
                            // Дата и время
                            ReservationDateTimeSection(
                                selectedDate: $selectedDate,
                                selectedTime: $selectedTime,
                                dateRange: dateRange,
                                brandColors: brandColors
                            )
                            .scaleEffect(isAnimating ? 1.0 : 0.9)
                            .opacity(isAnimating ? 1.0 : 0.0)
                            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2), value: isAnimating)
                            
                            // Количество гостей
                            ReservationGuestsSection(
                                selectedGuests: $selectedGuests,
                                guestRange: guestRange,
                                brandColors: brandColors
                            )
                            .scaleEffect(isAnimating ? 1.0 : 0.9)
                            .opacity(isAnimating ? 1.0 : 0.0)
                            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.3), value: isAnimating)
                            
                            // Контактная информация
                            ReservationContactSection(
                                contactName: $contactName,
                                contactPhone: $contactPhone,
                                brandColors: brandColors
                            )
                            .scaleEffect(isAnimating ? 1.0 : 0.9)
                            .opacity(isAnimating ? 1.0 : 0.0)
                            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.4), value: isAnimating)
                            
                            // Убрали выбор стола - теперь бронирование без выбора стола
                            
                            // Специальные пожелания
                            ReservationFormSpecialRequestsSection(
                                specialRequests: $specialRequests,
                                brandColors: brandColors
                            )
                            .scaleEffect(isAnimating ? 1.0 : 0.9)
                            .opacity(isAnimating ? 1.0 : 0.0)
                            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.6), value: isAnimating)
                            
                            // Кнопка бронирования
                            ReservationSubmitButton(
                                isLoading: isLoading,
                                isEnabled: !contactName.isEmpty && !contactPhone.isEmpty,
                                brandColors: brandColors,
                                action: createReservation
                            )
                            .scaleEffect(isAnimating ? 1.0 : 0.9)
                            .opacity(isAnimating ? 1.0 : 0.0)
                            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.7), value: isAnimating)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
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
            .onAppear {
                // Убрали загрузку столов - больше не нужна
            }
        }
        .alert("Ошибка", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .fullScreenCover(isPresented: $showingSuccess) {
            if let reservation = newReservation {
                ReservationSuccessView(reservation: reservation, restaurant: restaurant)
            }
        }
        .onAppear {
            loadUserData()
            withAnimation {
                isAnimating = true
            }
        }
        // Убрали onChange для загрузки столов
    }
    
    // MARK: - Actions
    private func loadUserData() {
        if let user = authService.currentUser {
            contactName = user.fullName
            contactPhone = user.phoneNumber
        }
    }
    
    private func loadAvailableTables() {
        // Убрали загрузку столов - больше не нужна
        print("ReservationFormView: Загрузка столов отключена")
        
    }
    
    
    private func createReservation() {
        // Убрали проверку выбора стола
        
        guard !contactName.isEmpty else {
            errorMessage = "Пожалуйста, укажите ваше имя"
            showingError = true
            return
        }
        
        guard !contactPhone.isEmpty else {
            errorMessage = "Пожалуйста, укажите номер телефона"
            showingError = true
            return
        }
        
        isLoading = true
        
        let calendar = Calendar.current
        let combinedDateTime = calendar.date(
            bySettingHour: calendar.component(.hour, from: selectedTime),
            minute: calendar.component(.minute, from: selectedTime),
            second: 0,
            of: selectedDate
        ) ?? selectedDate
        
        Task {
            do {
                // Создаем локальную резервацию с автоматическим назначением стола
                let randomTableNumber = Int.random(in: 1...20) // Случайный стол от 1 до 20
                let reservation = Reservation(
                    restaurant: restaurant,
                    date: combinedDateTime,
                    guestCount: selectedGuests,
                    status: .pending,
                    tableNumber: randomTableNumber,
                    specialRequests: specialRequests.isEmpty ? nil : specialRequests
                )
                
                await MainActor.run {
                    newReservation = reservation
                    showingSuccess = true
                    isLoading = false
                }
                
                // В будущем можно будет включить API:
                /*
                newReservation = try await reservationService.createReservation(
                    restaurant: restaurant,
                    date: combinedDateTime,
                    guestCount: selectedGuests,
                    tableNumber: table.tableNumber,
                    specialRequests: specialRequests.isEmpty ? nil : specialRequests,
                    contactName: contactName,
                    contactPhone: contactPhone
                )
                */
            } catch {
                print("ReservationFormView: Ошибка создания резервации - \(error)")
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showingError = true
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Reservation Header View
struct ReservationHeaderView: View {
    let restaurant: Restaurant
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(spacing: 16) {
            // Изображение ресторана
            AsyncImage(url: URL(string: restaurant.imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: brandColors.accent))
                    )
            }
            .frame(height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            VStack(spacing: 8) {
                Text(restaurant.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(restaurant.address)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack(spacing: 16) {
                    Label("\(restaurant.rating, specifier: "%.1f")", systemImage: "star.fill")
                        .foregroundColor(brandColors.accent)
                    
                    Label("\(restaurant.deliveryTime) мин", systemImage: "clock")
                        .foregroundColor(.gray)
                }
                .font(.caption)
            }
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
}

// MARK: - Date Time Section
struct ReservationDateTimeSection: View {
    @Binding var selectedDate: Date
    @Binding var selectedTime: Date
    let dateRange: ClosedRange<Date>
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Дата и время")
                .font(.headline)
                .foregroundColor(.white)
            
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
        }
    }
}

// MARK: - Guests Section
struct ReservationGuestsSection: View {
    @Binding var selectedGuests: Int
    let guestRange: ClosedRange<Int>
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Количество гостей")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack {
                Button(action: {
                    if selectedGuests > guestRange.lowerBound {
                        selectedGuests -= 1
                        HapticManager.shared.buttonPress()
                    }
                }) {
                    Image(systemName: "minus")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(brandColors.accent.opacity(0.2))
                        .clipShape(Circle())
                }
                .disabled(selectedGuests <= guestRange.lowerBound)
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text("\(selectedGuests)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(selectedGuests == 1 ? "гость" : "гостей")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: {
                    if selectedGuests < guestRange.upperBound {
                        selectedGuests += 1
                        HapticManager.shared.buttonPress()
                    }
                }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(brandColors.accent.opacity(0.2))
                        .clipShape(Circle())
                }
                .disabled(selectedGuests >= guestRange.upperBound)
            }
        }
    }
}

// MARK: - Contact Section
struct ReservationContactSection: View {
    @Binding var contactName: String
    @Binding var contactPhone: String
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Контактная информация")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                // Имя
                VStack(alignment: .leading, spacing: 8) {
                    Label("Ваше имя", systemImage: "person")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    TextField("Введите ваше имя", text: $contactName)
                        .textFieldStyle(ReservationTextFieldStyle(brandColors: brandColors))
                }
                
                // Телефон
                VStack(alignment: .leading, spacing: 8) {
                    Label("Номер телефона", systemImage: "phone")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    TextField("+7 (999) 123-45-67", text: $contactPhone)
                        .textFieldStyle(ReservationTextFieldStyle(brandColors: brandColors))
                        .keyboardType(.phonePad)
                }
            }
        }
    }
}

// MARK: - Table Section
struct ReservationTableSection: View {
    let availableTables: [AvailableTableResponse]
    @Binding var selectedTable: AvailableTableResponse?
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Выбор стола")
                .font(.headline)
                .foregroundColor(.white)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(availableTables, id: \.tableNumber) { table in
                    TableCard(
                        table: table,
                        isSelected: selectedTable?.tableNumber == table.tableNumber,
                        brandColors: brandColors
                    ) {
                        selectedTable = table
                        HapticManager.shared.selection()
                    }
                }
            }
        }
    }
}

// MARK: - Table Card
struct TableCard: View {
    let table: AvailableTableResponse
    let isSelected: Bool
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Text("Стол №\(table.tableNumber)")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("До \(table.capacity) гостей")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(table.location)
                    .font(.caption2)
                    .foregroundColor(brandColors.accent)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? brandColors.accent.opacity(0.2) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? brandColors.accent : Color.clear, lineWidth: 2)
                    )
            )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Special Requests Section
struct ReservationFormSpecialRequestsSection: View {
    @Binding var specialRequests: String
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Специальные пожелания")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 8) {
                Label("Дополнительная информация", systemImage: "note.text")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                TextField("Например: столик у окна, день рождения...", text: $specialRequests, axis: .vertical)
                    .textFieldStyle(ReservationTextFieldStyle(brandColors: brandColors))
                    .lineLimit(3...6)
            }
        }
    }
}

// MARK: - Submit Button
struct ReservationSubmitButton: View {
    let isLoading: Bool
    let isEnabled: Bool
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                }
                
                Text(isLoading ? "Создание резервации..." : "Забронировать стол")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: isEnabled ? [brandColors.accent, brandColors.primary] : [Color.gray.opacity(0.3)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
        }
        .disabled(!isEnabled || isLoading)
        .opacity(isEnabled ? 1.0 : 0.6)
    }
}

// MARK: - Text Field Style
struct ReservationTextFieldStyle: TextFieldStyle {
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(brandColors.accent.opacity(0.3), lineWidth: 1)
                    )
            )
            .foregroundColor(.white)
    }
}

#Preview {
    ReservationFormView_Improved(restaurant: Restaurant.mock)
        .environmentObject(AuthService.shared)
}
