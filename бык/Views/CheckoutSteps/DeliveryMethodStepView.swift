import SwiftUI

struct DeliveryMethodStepView: View {
    @ObservedObject var orderData: OrderData
    let restaurant: Restaurant
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(spacing: 20) {
            // Информация о ресторане
            RestaurantInfoCard(
                restaurant: restaurant,
                brandColors: brandColors
            )
            
            // Варианты доставки
            VStack(spacing: 16) {
                ForEach(DeliveryMethod.allCases, id: \.self) { method in
                    CheckoutDeliveryMethodCard(
                        method: method,
                        restaurant: restaurant,
                        isSelected: orderData.deliveryMethod == method,
                        brandColors: brandColors
                    ) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            orderData.deliveryMethod = method
                        }
                        HapticManager.shared.impact(.light)
                    }
                }
            }
            
            // Дополнительная информация
            DeliveryInfoCard(
                selectedMethod: orderData.deliveryMethod,
                restaurant: restaurant,
                brandColors: brandColors
            )
        }
    }
}

struct CheckoutDeliveryMethodCard: View {
    let method: DeliveryMethod
    let restaurant: Restaurant
    let isSelected: Bool
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Иконка
                ZStack {
                    Circle()
                        .fill(isSelected ? brandColors.accent : Color.gray.opacity(0.3))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: method.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .gray)
                }
                
                // Информация
                VStack(alignment: .leading, spacing: 6) {
                    Text(method.rawValue)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(methodDescription)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                    
                    // Дополнительные детали
                    HStack(spacing: 16) {
                        if method == .delivery {
                            Label("\(restaurant.deliveryTime) мин", systemImage: "clock.fill")
                                .font(.system(size: 12))
                                .foregroundColor(brandColors.accent)
                            
                            Label("от 200 ₽", systemImage: "car.fill")
                                .font(.system(size: 12))
                                .foregroundColor(brandColors.accent)
                        } else {
                            Label("15-30 мин", systemImage: "timer")
                                .font(.system(size: 12))
                                .foregroundColor(brandColors.accent)
                            
                            Label("Бесплатно", systemImage: "checkmark.circle")
                                .font(.system(size: 12))
                                .foregroundColor(.green)
                        }
                    }
                }
                
                Spacer()
                
                // Индикатор выбора
                ZStack {
                    Circle()
                        .stroke(isSelected ? brandColors.accent : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(brandColors.accent)
                            .frame(width: 12, height: 12)
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? brandColors.accent : Color.gray.opacity(0.2),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    
    private var methodDescription: String {
        switch method {
        case .delivery:
            return "Курьер доставит заказ по указанному адресу"
        case .pickup:
            return "Заберите готовый заказ в ресторане"
        }
    }
}

struct DeliveryInfoCard: View {
    let selectedMethod: DeliveryMethod
    let restaurant: Restaurant
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(brandColors.accent)
                
                Text("Полезная информация")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 12) {
                if selectedMethod == .delivery {
                    DeliveryInfoRow(
                        icon: "car.fill",
                        title: "Зона доставки",
                        value: "В радиусе 15 км от ресторана",
                        color: brandColors.accent
                    )
                    
                    DeliveryInfoRow(
                        icon: "gift.fill",
                        title: "Бесплатная доставка",
                        value: "При заказе от 1500 ₽",
                        color: .green
                    )
                    
                    DeliveryInfoRow(
                        icon: "clock.fill",
                        title: "Время доставки",
                        value: "30-60 минут",
                        color: brandColors.accent
                    )
                } else {
                    DeliveryInfoRow(
                        icon: "location.fill",
                        title: "Адрес ресторана",
                        value: restaurant.address,
                        color: brandColors.accent
                    )
                    
                    DeliveryInfoRow(
                        icon: "phone.fill",
                        title: "Телефон",
                        value: restaurant.contacts.phone,
                        color: brandColors.accent
                    )
                    
                    DeliveryInfoRow(
                        icon: "clock.fill",
                        title: "Время работы",
                        value: "\(restaurant.workingHours.openTime) - \(restaurant.workingHours.closeTime)",
                        color: brandColors.accent
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(brandColors.accent.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct DeliveryInfoRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                Text(value)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
    }
}

#Preview {
    DeliveryMethodStepView(
        orderData: OrderData(),
        restaurant: Restaurant.mock,
        brandColors: Colors.brandColors(for: .theByk)
    )
    .background(Color.black)
}