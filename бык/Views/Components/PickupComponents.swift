import SwiftUI

// MARK: - Pickup Contact Info Section
struct PickupContactInfoSection: View {
    @Binding var name: String
    @Binding var phone: String
    @Binding var address: String
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Контактная информация")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                CustomTextField(
                    title: "Имя",
                    text: $name,
                    placeholder: "Ваше имя",
                    icon: "person.fill",
                    brandColors: brandColors
                )
                
                CustomTextField(
                    title: "Телефон",
                    text: $phone,
                    placeholder: "Номер телефона",
                    icon: "phone.fill",
                    brandColors: brandColors
                )
                
                CustomTextField(
                    title: "Адрес",
                    text: $address,
                    placeholder: "Адрес (опционально)",
                    icon: "location.fill",
                    brandColors: brandColors
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(brandColors.accent.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Time Slot Button
struct TimeSlotButton: View {
    let time: Date
    let isSelected: Bool
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(time, style: .time)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : .white)
                
                Text("Доступно")
                    .font(.system(size: 10))
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .gray)
            }
            .frame(width: 80, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? brandColors.accent : Color.gray.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? brandColors.accent : Color.gray.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Pickup Restaurant Info Card
struct PickupRestaurantInfoCard: View {
    let restaurant: Restaurant
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(restaurant.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(restaurant.address)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("⭐ \(restaurant.rating, specifier: "%.1f")")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(brandColors.accent)
                    )
            }
            
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(brandColors.accent)
                Text("Время работы: \(restaurant.workingHours.openTime) - \(restaurant.workingHours.closeTime)")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Image(systemName: "phone")
                    .foregroundColor(brandColors.accent)
                Text(restaurant.contacts.phone)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(brandColors.accent.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Pickup Time Section
struct PickupTimeSection: View {
    @Binding var selectedTime: Date
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let restaurant: Restaurant
    
    private var timeSlots: [Date] {
        let calendar = Calendar.current
        let now = Date()
        let openTime = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: now) ?? now
        let closeTime = calendar.date(bySettingHour: 22, minute: 0, second: 0, of: now) ?? now
        
        var slots: [Date] = []
        var currentTime = max(now.addingTimeInterval(1800), openTime) // Минимум 30 минут
        
        while currentTime <= closeTime {
            slots.append(currentTime)
            currentTime = calendar.date(byAdding: .hour, value: 1, to: currentTime) ?? currentTime
        }
        
        return slots
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Время самовывоза")
                .font(.headline)
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<timeSlots.count, id: \.self) { index in
                        let time = timeSlots[index]
                        let isSelected = Calendar.current.isDate(selectedTime, equalTo: time, toGranularity: .minute)
                        TimeSlotButton(
                            time: time,
                            isSelected: isSelected,
                            brandColors: brandColors
                        ) {
                            selectedTime = time
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(brandColors.accent.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Pickup Payment Method Section
struct PickupPaymentMethodSection: View {
    @Binding var selectedMethod: PickupPaymentMethod
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Способ оплаты")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 8) {
                ForEach(PickupPaymentMethod.allCases, id: \.self) { method in
                    Button(action: {
                        selectedMethod = method
                    }) {
                        HStack {
                            Image(systemName: method.icon)
                                .foregroundColor(brandColors.accent)
                                .frame(width: 20)
                            
                            Text(method.rawValue)
                                .font(.body)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            if selectedMethod == method {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(brandColors.accent)
                            }
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedMethod == method ? brandColors.accent.opacity(0.1) : Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(selectedMethod == method ? brandColors.accent : Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(brandColors.accent.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Pickup Tip Section
struct PickupTipSection: View {
    @Binding var tipAmount: Double
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    private let tipOptions = [0.0, 50.0, 100.0, 200.0]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Чаевые")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    ForEach(tipOptions, id: \.self) { amount in
                        Button(action: {
                            tipAmount = amount
                        }) {
                            Text(amount == 0 ? "Нет" : "\(Int(amount)) ₽")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(tipAmount == amount ? .white : .white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(tipAmount == amount ? brandColors.accent : Color.gray.opacity(0.2))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(tipAmount == amount ? brandColors.accent : Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                // Кастомная сумма
                HStack {
                    Text("Другая сумма:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    TextField("₽", value: $tipAmount, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 80)
                        .keyboardType(.numberPad)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(brandColors.accent.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Pickup Payment Method Enum
enum PickupPaymentMethod: String, CaseIterable {
    case card = "Банковская карта"
    case cash = "Наличными при получении"
    case online = "Онлайн оплата"
    
    var icon: String {
        switch self {
        case .card: return "creditcard.fill"
        case .cash: return "banknote.fill"
        case .online: return "globe"
        }
    }
}
