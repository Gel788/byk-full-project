import SwiftUI

struct ConfirmationStepView: View {
    @ObservedObject var orderData: OrderData
    let restaurant: Restaurant
    let cartItems: [CartGroupedItem]
    let totalAmount: Double
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Информация о заказе
            orderSummarySection
            
            // Детали доставки/самовывоза
            deliveryDetailsSection
            
            // Состав заказа
            orderItemsSection
            
            // Итоговая стоимость
            totalSection
            
            // Условия и соглашения
            termsSection
        }
    }
    
    // MARK: - Order Summary Section
    
    private var orderSummarySection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .foregroundColor(brandColors.accent)
                
                Text("Детали заказа")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                OrderDetailRow(
                    icon: "building.2.fill",
                    title: "Ресторан",
                    value: restaurant.name,
                    color: brandColors.accent
                )
                
                OrderDetailRow(
                    icon: orderData.deliveryMethod.icon,
                    title: "Способ получения",
                    value: orderData.deliveryMethod.rawValue,
                    color: brandColors.accent
                )
                
                if orderData.deliveryMethod == .delivery {
                    OrderDetailRow(
                        icon: "location.fill",
                        title: "Адрес доставки",
                        value: orderData.address,
                        color: brandColors.accent
                    )
                } else {
                    OrderDetailRow(
                        icon: "location.fill",
                        title: "Адрес ресторана",
                        value: restaurant.address,
                        color: brandColors.accent
                    )
                }
                
                OrderDetailRow(
                    icon: "person.fill",
                    title: "Получатель",
                    value: orderData.name,
                    color: brandColors.accent
                )
                
                OrderDetailRow(
                    icon: "phone.fill",
                    title: "Телефон",
                    value: orderData.phone,
                    color: brandColors.accent
                )
                
                OrderDetailRow(
                    icon: orderData.paymentMethod.icon,
                    title: "Способ оплаты",
                    value: orderData.paymentMethod.rawValue,
                    color: brandColors.accent
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(brandColors.accent.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Delivery Details Section
    
    private var deliveryDetailsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(brandColors.accent)
                
                Text(orderData.deliveryMethod == .delivery ? "Детали доставки" : "Детали самовывоза")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                OrderDetailRow(
                    icon: "calendar",
                    title: "Дата и время",
                    value: formatDateTime(orderData.selectedTime),
                    color: brandColors.accent
                )
                
                if orderData.deliveryMethod == .delivery {
                    if let calculation = orderData.deliveryCalculation {
                        OrderDetailRow(
                            icon: "timer",
                            title: "Время доставки",
                            value: "~\(calculation.estimatedTime) минут",
                            color: brandColors.accent
                        )
                        
                        OrderDetailRow(
                            icon: "car.fill",
                            title: "Стоимость доставки",
                            value: calculation.isFreeDelivery ? "Бесплатно" : "\(Int(calculation.deliveryFee)) ₽",
                            color: calculation.isFreeDelivery ? .green : brandColors.accent
                        )
                        
                        if let zone = calculation.zone {
                            OrderDetailRow(
                                icon: "map.fill",
                                title: "Зона доставки",
                                value: zone.name,
                                color: brandColors.accent
                            )
                        }
                    }
                } else {
                    OrderDetailRow(
                        icon: "bag.fill",
                        title: "Самовывоз",
                        value: "Бесплатно",
                        color: .green
                    )
                }
                
                if !orderData.specialRequests.isEmpty {
                    OrderDetailRow(
                        icon: "text.bubble.fill",
                        title: "Комментарий",
                        value: orderData.specialRequests,
                        color: brandColors.accent
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(brandColors.accent.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Order Items Section
    
    private var orderItemsSection: some View {
        VStack(spacing: 16) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "list.bullet")
                        .foregroundColor(brandColors.accent)
                    
                    Text("Состав заказа")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("(\(cartItems.count) \(itemsCountText))")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(brandColors.accent)
                        .font(.system(size: 12, weight: .medium))
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                VStack(spacing: 8) {
                    ForEach(cartItems, id: \.id) { item in
                        CheckoutOrderItemRow(
                            item: item,
                            brandColors: brandColors
                        )
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(brandColors.accent.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Total Section
    
    private var totalSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "calculator.fill")
                    .foregroundColor(brandColors.accent)
                
                Text("Итого к оплате")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            VStack(spacing: 8) {
                let subtotal = cartItems.reduce(0) { $0 + $1.totalPrice }
                let deliveryFee = orderData.deliveryCalculation?.deliveryFee ?? 0
                let tipAmount = orderData.tipAmount
                
                TotalRow(
                    title: "Сумма заказа",
                    value: subtotal,
                    isSubtotal: true
                )
                
                if orderData.deliveryMethod == .delivery {
                    TotalRow(
                        title: "Доставка",
                        value: deliveryFee,
                        isSubtotal: true,
                        isFree: deliveryFee == 0
                    )
                }
                
                if tipAmount > 0 {
                    TotalRow(
                        title: "Чаевые",
                        value: tipAmount,
                        isSubtotal: true,
                        color: brandColors.accent
                    )
                }
                
                Divider()
                    .background(Color.white.opacity(0.3))
                
                TotalRow(
                    title: "Итого",
                    value: totalAmount,
                    isSubtotal: false,
                    color: brandColors.accent
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(brandColors.accent.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(brandColors.accent.opacity(0.5), lineWidth: 2)
                )
        )
    }
    
    // MARK: - Terms Section
    
    private var termsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                
                Text("Важная информация")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                TermsRow(
                    icon: "checkmark.circle",
                    text: "Нажимая \"Оформить заказ\", вы соглашаетесь с условиями обслуживания"
                )
                
                TermsRow(
                    icon: "clock",
                    text: "Время доставки может увеличиться в часы пик"
                )
                
                if orderData.paymentMethod == .cash {
                    TermsRow(
                        icon: "banknote",
                        text: "При оплате наличными просьба подготовить точную сумму"
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.blue.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Helper Properties
    
    private var itemsCountText: String {
        let count = cartItems.count
        if count == 1 {
            return "позиция"
        } else if count >= 2 && count <= 4 {
            return "позиции"
        } else {
            return "позиций"
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM в HH:mm"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Views

struct OrderDetailRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.trailing)
        }
    }
}

struct CheckoutOrderItemRow: View {
    let item: CartGroupedItem
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        HStack(spacing: 12) {
            // Количество
            Text("\(item.quantity)×")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(brandColors.accent)
                .frame(width: 30, alignment: .leading)
            
            // Название блюда
            Text(item.dish.name)
                .font(.system(size: 14))
                .foregroundColor(.white)
            
            Spacer()
            
            // Стоимость
            Text("\(Int(item.totalPrice)) ₽")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
        }
        .padding(.vertical, 4)
    }
}

struct TotalRow: View {
    let title: String
    let value: Double
    let isSubtotal: Bool
    let isFree: Bool
    let color: Color?
    
    init(title: String, value: Double, isSubtotal: Bool, isFree: Bool = false, color: Color? = nil) {
        self.title = title
        self.value = value
        self.isSubtotal = isSubtotal
        self.isFree = isFree
        self.color = color
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: isSubtotal ? 14 : 16, weight: isSubtotal ? .medium : .bold))
                .foregroundColor(isSubtotal ? .white.opacity(0.8) : .white)
            
            Spacer()
            
            if isFree {
                Text("Бесплатно")
                    .font(.system(size: isSubtotal ? 14 : 16, weight: isSubtotal ? .medium : .bold))
                    .foregroundColor(.green)
            } else {
                Text("\(Int(value)) ₽")
                    .font(.system(size: isSubtotal ? 14 : 16, weight: isSubtotal ? .medium : .bold))
                    .foregroundColor(color ?? (isSubtotal ? .white : .white))
            }
        }
    }
}

struct TermsRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.system(size: 12))
                .frame(width: 16, height: 16)
            
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.leading)
        }
    }
}

#Preview {
    ConfirmationStepView(
        orderData: OrderData(),
        restaurant: Restaurant.mock,
        cartItems: [
            CartGroupedItem(dish: Dish(name: "Тест", description: "", price: 500, image: "", category: "", restaurantBrand: .theByk), quantity: 2, restaurant: nil)
        ],
        totalAmount: 1200,
        brandColors: Colors.brandColors(for: .theByk)
    )
    .background(Color.black)
}