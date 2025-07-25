import SwiftUI

// MARK: - Shared Components

struct RestaurantInfoCard: View {
    let restaurant: Restaurant
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Название
            Text(restaurant.name)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            // Адрес
            HStack(spacing: 8) {
                Image(systemName: "location.fill")
                    .foregroundColor(brandColors.accent)
                Text(restaurant.address)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            // Часы работы
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Image(systemName: "clock.fill")
                        .foregroundColor(brandColors.accent)
                    Text("Часы работы")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                HStack {
                    Text(formatWorkingDays())
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    Spacer()
                    Text("\(restaurant.workingHours.openTime) - \(restaurant.workingHours.closeTime)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(brandColors.accent.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private func formatWorkingDays() -> String {
        let weekdays = restaurant.workingHours.weekdays
        let allDays: Set<WorkingHours.Weekday> = Set(WorkingHours.Weekday.allCases)
        
        if weekdays == allDays {
            return "Ежедневно"
        } else if weekdays == Set([.monday, .tuesday, .wednesday, .thursday, .friday]) {
            return "Пн-Пт"
        } else if weekdays == Set([.saturday, .sunday]) {
            return "Сб-Вс"
        } else {
            let dayNames = weekdays.map { dayName($0) }.sorted()
            return dayNames.joined(separator: ", ")
        }
    }
    
    private func dayName(_ weekday: WorkingHours.Weekday) -> String {
        switch weekday {
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        case .sunday: return "Вс"
        }
    }
}

struct OrderItemsCard: View {
    let cartViewModel: CartViewModel
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ваш заказ")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            ForEach(cartViewModel.groupedCartItems()) { item in
                HStack {
                    Text(item.dish.name)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(item.quantity) × \(item.dish.price.formattedPrice)")
                        .font(.system(size: 14))
                        .foregroundColor(brandColors.accent)
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            HStack {
                Text("Итого")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(cartViewModel.totalAmount.formattedPrice)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(brandColors.accent)
            }
        }
        .padding(16)
        .background(Color.black.opacity(0.6))
        .cornerRadius(12)
    }
}

struct ContactInfoCard: View {
    @Binding var name: String
    @Binding var phone: String
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Контактная информация")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            TextField("Ваше имя", text: $name)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(12)
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
                .foregroundColor(.white)
            
            TextField("Номер телефона", text: $phone)
                .textFieldStyle(PlainTextFieldStyle())
                .keyboardType(.phonePad)
                .padding(12)
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
                .foregroundColor(.white)
        }
        .padding(16)
        .background(Color.black.opacity(0.6))
        .cornerRadius(12)
    }
}

struct PaymentMethodCard: View {
    @Binding var selectedMethod: PaymentMethod
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Способ оплаты")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            ForEach(PaymentMethod.allCases, id: \.self) { method in
                Button(action: {
                    selectedMethod = method
                }) {
                    HStack {
                        Image(systemName: method.icon)
                            .foregroundColor(selectedMethod == method ? brandColors.accent : .white.opacity(0.7))
                        
                        Text(method.rawValue)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        if selectedMethod == method {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(brandColors.accent)
                        }
                    }
                    .padding(12)
                    .background(selectedMethod == method ? brandColors.accent.opacity(0.2) : Color.clear)
                    .cornerRadius(8)
                }
            }
        }
        .padding(16)
        .background(Color.black.opacity(0.6))
        .cornerRadius(12)
    }
}

struct TipCard: View {
    @Binding var tipAmount: Double
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    private let tipOptions = [0.0, 100.0, 200.0, 300.0, 500.0]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Чаевые")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            HStack {
                ForEach(tipOptions, id: \.self) { tip in
                    Button(action: {
                        tipAmount = tip
                    }) {
                        Text(tip == 0 ? "Нет" : "\(Int(tip)) ₽")
                            .font(.system(size: 12))
                            .foregroundColor(tipAmount == tip ? .white : .white.opacity(0.7))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(tipAmount == tip ? brandColors.accent : Color.clear)
                            .cornerRadius(6)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.black.opacity(0.6))
        .cornerRadius(12)
    }
}



struct TotalCard: View {
    let subtotal: Double
    let deliveryFee: Double
    let tipAmount: Double
    let total: Double
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Итого")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            HStack {
                Text("Стоимость блюд")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Text(subtotal.formattedPrice)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
            }
            
            if deliveryFee > 0 {
                HStack {
                    Text("Доставка")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Text(deliveryFee.formattedPrice)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                }
            }
            
            if tipAmount > 0 {
                HStack {
                    Text("Чаевые")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Text(tipAmount.formattedPrice)
                        .font(.system(size: 14))
                        .foregroundColor(brandColors.accent)
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            HStack {
                Text("Итого к оплате")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(total.formattedPrice)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(brandColors.accent)
            }
        }
        .padding(16)
        .background(Color.black.opacity(0.6))
        .cornerRadius(12)
    }
}

struct CheckoutButton: View {
    let isProcessing: Bool
    let isEnabled: Bool
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isProcessing {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                }
                
                Text(isProcessing ? "Оформляем заказ..." : "Оформить заказ")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isEnabled ? brandColors.accent : Color.gray.opacity(0.3))
            )
        }
        .disabled(!isEnabled || isProcessing)
    }
}

struct DeliveryMethodCard: View {
    @Binding var selectedMethod: DeliveryMethod
    @Binding var address: String
    @Binding var selectedPickupTime: Date
    @Binding var selectedDeliveryTime: Date
    let restaurant: Restaurant
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Способ получения")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            ForEach(DeliveryMethod.allCases, id: \.self) { method in
                Button(action: {
                    selectedMethod = method
                }) {
                    HStack {
                        Image(systemName: method.icon)
                            .foregroundColor(selectedMethod == method ? brandColors.accent : .white.opacity(0.7))
                        
                        Text(method.rawValue)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        if selectedMethod == method {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(brandColors.accent)
                        }
                    }
                    .padding(12)
                    .background(selectedMethod == method ? brandColors.accent.opacity(0.2) : Color.clear)
                    .cornerRadius(8)
                }
            }
            
            if selectedMethod == .delivery {
                TextField("Адрес доставки", text: $address, axis: .vertical)
                    .textFieldStyle(PlainTextFieldStyle())
                    .lineLimit(2...4)
                    .padding(12)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(8)
                    .foregroundColor(.white)
                
                DatePicker(
                    "Время доставки",
                    selection: $selectedDeliveryTime,
                    in: Date().addingTimeInterval(3600)...Date().addingTimeInterval(86400),
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.compact)
                .tint(brandColors.accent)
            } else {
                DatePicker(
                    "Время самовывоза",
                    selection: $selectedPickupTime,
                    in: Date().addingTimeInterval(1800)...Date().addingTimeInterval(86400),
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.compact)
                .tint(brandColors.accent)
            }
        }
        .padding(16)
        .background(Color.black.opacity(0.6))
        .cornerRadius(12)
    }
} 