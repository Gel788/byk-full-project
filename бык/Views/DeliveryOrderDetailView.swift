import SwiftUI

struct DeliveryOrderDetailView: View {
    let order: DeliveryOrder
    @Environment(\.dismiss) private var dismiss
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color) {
        Colors.brandColors(for: order.restaurantBrand)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Заголовок заказа
                    OrderHeaderSection(order: order, brandColors: brandColors)
                    
                    // Статус заказа
                    OrderStatusSection(order: order, brandColors: brandColors)
                    
                    // Информация о доставке
                    DeliveryOrderInfoSection(order: order, brandColors: brandColors)
                    
                    // Блюда
                    DeliveryOrderItemsSection(order: order, brandColors: brandColors)
                    
                    // Информация о курьере
                    if let courierName = order.courierName {
                        CourierInfoSection(
                            courierName: courierName,
                            courierPhone: order.courierPhone,
                            brandColors: brandColors
                        )
                    }
                    
                    // Оплата
                    PaymentSection(order: order, brandColors: brandColors)
                    
                    // Специальные инструкции
                    if let instructions = order.specialInstructions {
                        SpecialInstructionsSection(
                            instructions: instructions,
                            brandColors: brandColors
                        )
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .background(Color.black)
            .navigationTitle("Заказ \(order.orderNumber)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
        .background(Color.black)
    }
}

// MARK: - Order Header Section
struct OrderHeaderSection: View {
    let order: DeliveryOrder
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(spacing: 16) {
            // Номер заказа и бренд
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(order.orderNumber)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(order.restaurantBrand.rawValue)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(brandColors.accent)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(Int(order.totalAmount)) ₽")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(order.orderDate, style: .date)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            // Время заказа
            HStack {
                Image(systemName: "clock")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                
                Text("Заказ размещен: \(order.orderDate, style: .time)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    brandColors.primary,
                    brandColors.primary.opacity(0.8)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }
}

// MARK: - Order Status Section
struct OrderStatusSection: View {
    let order: DeliveryOrder
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            DeliverySectionHeader(title: "Статус заказа", icon: "info.circle", color: brandColors.primary)
            
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(order.status.color).opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: order.status.icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(Color(order.status.color))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(order.status.rawValue)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(statusDescription)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.8))
                    .shadow(color: .white.opacity(0.05), radius: 3, x: 0, y: 1)
            )
        }
    }
    
    private var statusDescription: String {
        switch order.status {
        case .pending: return "Ожидаем подтверждения от ресторана"
        case .confirmed: return "Заказ подтвержден и принят в работу"
        case .preparing: return "Ваш заказ готовится на кухне"
        case .ready: return "Заказ готов и ожидает курьера"
        case .delivering: return "Курьер везет ваш заказ"
        case .delivered: return "Заказ успешно доставлен"
        case .cancelled: return "Заказ был отменен"
        }
    }
}

// MARK: - Delivery Info Section
struct DeliveryOrderInfoSection: View {
    let order: DeliveryOrder
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            DeliverySectionHeader(title: "Информация о доставке", icon: "location", color: brandColors.secondary)
            
            VStack(spacing: 12) {
                // Адрес доставки
                OrderDetailInfoRow(
                    icon: "location.fill",
                    title: "Адрес доставки",
                    value: order.deliveryAddress,
                    color: brandColors.secondary
                )
                
                // Время доставки
                OrderDetailInfoRow(
                    icon: "clock.fill",
                    title: "Время доставки",
                    value: order.deliveryTime, style: .shortened,
                    color: brandColors.accent
                )
                
                // Ожидаемое время доставки
                if order.status == .delivering || order.status == .preparing {
                    if let estimated = order.estimatedDeliveryTime {
                        OrderDetailInfoRow(
                            icon: "timer",
                            title: "Ожидаемое время",
                            value: estimated, style: .shortened,
                            color: brandColors.primary
                        )
                    } else {
                        OrderDetailInfoRow(
                            icon: "timer",
                            title: "Ожидаемое время",
                            value: "—",
                            color: brandColors.primary
                        )
                    }
                }
                
                // Фактическое время доставки
                if let actualTime = order.actualDeliveryTime {
                    OrderDetailInfoRow(
                        icon: "checkmark.circle.fill",
                        title: "Доставлен в",
                        value: actualTime, style: .shortened,
                        color: .green
                    )
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.8))
                    .shadow(color: .white.opacity(0.05), radius: 3, x: 0, y: 1)
            )
        }
    }
}

// MARK: - Order Items Section
struct DeliveryOrderItemsSection: View {
    let order: DeliveryOrder
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            DeliverySectionHeader(title: "Состав заказа", icon: "bag", color: brandColors.accent)
            
            VStack(spacing: 12) {
                ForEach(order.items) { item in
                    DeliveryOrderItemRow(item: item, brandColors: brandColors)
                    
                    if item.id != order.items.last?.id {
                        Divider()
                            .background(Color.black.opacity(0.6))
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.8))
                    .shadow(color: .white.opacity(0.05), radius: 3, x: 0, y: 1)
            )
        }
    }
}

struct DeliveryOrderItemRow: View {
    let item: DeliveryOrderItem
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        HStack(spacing: 12) {
            // Иконка блюда
            ZStack {
                Circle()
                    .fill(brandColors.primary.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "fork.knife")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(brandColors.primary)
            }
            
            // Информация о блюде
            VStack(alignment: .leading, spacing: 4) {
                Text(item.dish.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                if let instructions = item.specialInstructions {
                    Text(instructions)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
            
            Spacer()
            
            // Количество и цена
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(item.quantity)x")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text("\(Int(item.price)) ₽")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
            }
        }
    }
}

// MARK: - Courier Info Section
struct CourierInfoSection: View {
    let courierName: String
    let courierPhone: String?
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            DeliverySectionHeader(title: "Курьер", icon: "person.circle", color: brandColors.primary)
            
            VStack(spacing: 12) {
                OrderDetailInfoRow(
                    icon: "person.fill",
                    title: "Имя курьера",
                    value: courierName,
                    color: brandColors.primary
                )
                
                if let phone = courierPhone {
                    Button(action: {
                        if let url = URL(string: "tel:\(phone.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: ""))") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        OrderDetailInfoRow(
                            icon: "phone.fill",
                            title: "Телефон курьера",
                            value: phone,
                            color: brandColors.accent
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.8))
                    .shadow(color: .white.opacity(0.05), radius: 3, x: 0, y: 1)
            )
        }
    }
}

// MARK: - Payment Section
struct PaymentSection: View {
    let order: DeliveryOrder
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            DeliverySectionHeader(title: "Оплата", icon: "creditcard", color: brandColors.secondary)
            
            VStack(spacing: 12) {
                // Способ оплаты
                OrderDetailInfoRow(
                    icon: order.paymentMethod.icon,
                    title: "Способ оплаты",
                    value: order.paymentMethod.rawValue,
                    color: brandColors.secondary
                )
                
                // Стоимость блюд
                DeliveryPaymentRow(
                    title: "Стоимость блюд",
                    value: order.items.reduce(0) { $0 + $1.price }
                )
                
                // Стоимость доставки
                DeliveryPaymentRow(
                    title: "Доставка",
                    value: order.deliveryFee
                )
                
                // Чаевые
                if let tip = order.tip {
                    DeliveryPaymentRow(
                        title: "Чаевые",
                        value: tip
                    )
                }
                
                Divider()
                    .background(Color.black.opacity(0.6))
                
                // Итого
                HStack {
                    Text("Итого")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(Int(order.totalAmount)) ₽")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(brandColors.primary)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.8))
                    .shadow(color: .white.opacity(0.05), radius: 3, x: 0, y: 1)
            )
        }
    }
}

struct DeliveryPaymentRow: View {
    let title: String
    let value: Double
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
            
            Text("\(Int(value)) ₽")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Special Instructions Section
struct SpecialInstructionsSection: View {
    let instructions: String
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            DeliverySectionHeader(title: "Особые пожелания", icon: "note.text", color: brandColors.accent)
            
            HStack(spacing: 12) {
                Image(systemName: "note.text")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(brandColors.accent)
                
                Text(instructions)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .italic()
                
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.8))
                    .shadow(color: .white.opacity(0.05), radius: 3, x: 0, y: 1)
            )
        }
    }
}

// MARK: - Helper Components
struct DeliverySectionHeader: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

struct OrderDetailInfoRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    init(icon: String, title: String, value: String, color: Color) {
        self.icon = icon
        self.title = title
        self.value = value
        self.color = color
    }
    
    init(icon: String, title: String, value: Date, style: Date.FormatStyle.TimeStyle, color: Color) {
        self.icon = icon
        self.title = title
        self.value = value.formatted(date: .omitted, time: style)
        self.color = color
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(color)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    let mockOrder = DeliveryOrder(
        orderNumber: "BY-2024-001",
        items: [
            DeliveryOrderItem(
                dish: Dish(name: "Рибай стейк", description: "Премиальный стейк", price: 3200, image: "ribai_steak", category: "Стейки", restaurantBrand: .theByk),
                quantity: 1,
                price: 3200
            )
        ],
        totalAmount: 3400,
        deliveryAddress: "ул. Тверская, 15, кв. 45",
        deliveryTime: Date(),
        orderDate: Date(),
        status: .delivering,
        restaurantBrand: .theByk,
        deliveryFee: 200,
        estimatedDeliveryTime: Date().addingTimeInterval(1800),
        courierName: "Иван Петров",
        courierPhone: "+7 (999) 123-45-67",
        paymentMethod: .card
    )
    
    DeliveryOrderDetailView(order: mockOrder)
} 