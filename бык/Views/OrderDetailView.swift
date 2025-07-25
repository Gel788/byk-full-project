import SwiftUI

struct OrderDetailView: View {
    let order: UserOrder
    @Environment(\.dismiss) private var dismiss
    @State private var showingRepeatOrder = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Анимированный градиентный фон
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        Color("BykAccent").opacity(0.1),
                        Color.black
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Заголовок заказа
                        OrderDetailHeader(order: order)
                        
                        // Статус заказа
                        OrderStatusTimeline(order: order)
                        
                        // Блюда
                        OrderItemsSection(order: order)
                        
                        // Информация о доставке
                        if order.deliveryAddress != nil {
                            DeliveryInfoSection(order: order)
                        }
                        
                        // Оплата
                        PaymentInfoSection(order: order)
                        
                        // Кнопки действий
                        OrderActionButtons(
                            order: order,
                            onRepeatOrder: {
                                showingRepeatOrder = true
                            }
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Заказ #\(order.orderNumber)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                    .foregroundColor(Color("BykAccent"))
                }
            }
        }
        .alert("Повторить заказ?", isPresented: $showingRepeatOrder) {
            Button("Отмена", role: .cancel) { }
            Button("Повторить") {
                // Логика повтора заказа
                dismiss()
            }
        } message: {
            Text("Добавить все блюда из этого заказа в корзину?")
        }
    }
}

struct OrderDetailHeader: View {
    let order: UserOrder
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Заказ #\(order.orderNumber)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(order.restaurantName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color("BykAccent"))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(String(format: "%.0f", order.totalAmount)) ₽")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(order.orderDate, style: .date)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            // Статус заказа
            HStack(spacing: 8) {
                Image(systemName: order.status.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(statusColor)
                
                Text(order.status.rawValue)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(statusColor)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(statusColor.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(statusColor.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.8),
                            Color.black.opacity(0.6)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color("BykAccent").opacity(0.3),
                                    Color("BykAccent").opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: Color("BykAccent").opacity(0.2), radius: 10, x: 0, y: 5)
    }
    
    private var statusColor: Color {
        switch order.status {
        case .pending: return .orange
        case .confirmed: return .blue
        case .preparing: return .purple
        case .ready: return .yellow
        case .delivering: return .green
        case .delivered: return .green
        case .cancelled: return .red
        }
    }
}

struct OrderStatusTimeline: View {
    let order: UserOrder
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Статус заказа")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                StatusTimelineItem(
                    title: "Заказ оформлен",
                    subtitle: order.orderDate.formatted(date: .abbreviated, time: .shortened),
                    icon: "bag.fill",
                    color: .green,
                    isCompleted: true
                )
                
                if order.status != .pending && order.status != .cancelled {
                    StatusTimelineItem(
                        title: "Заказ подтвержден",
                        subtitle: order.orderDate.formatted(date: .abbreviated, time: .shortened),
                        icon: "checkmark.circle.fill",
                        color: .blue,
                        isCompleted: true
                    )
                }
                
                if order.status == .delivered || order.status == .delivering {
                    StatusTimelineItem(
                        title: "Заказ доставлен",
                        subtitle: order.estimatedDeliveryTime?.formatted(date: .abbreviated, time: .shortened) ?? "В пути",
                        icon: "bicycle",
                        color: .green,
                        isCompleted: order.status == .delivered
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.8),
                            Color.black.opacity(0.6)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color("BykAccent").opacity(0.3),
                                    Color("BykAccent").opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: Color("BykAccent").opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

struct StatusTimelineItem: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let isCompleted: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(isCompleted ? color : Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isCompleted ? .white : .gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isCompleted ? .white : .white.opacity(0.7))
                
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(isCompleted ? .white.opacity(0.7) : .gray)
            }
            
            Spacer()
        }
    }
}

struct OrderItemsSection: View {
    let order: UserOrder
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Блюда")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                ForEach(order.items) { item in
                    OrderItemRow(item: item)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black.opacity(0.4))
                        )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.8),
                            Color.black.opacity(0.6)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color("BykAccent").opacity(0.3),
                                    Color("BykAccent").opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: Color("BykAccent").opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

struct OrderItemRow: View {
    let item: OrderItem
    
    var body: some View {
        HStack(spacing: 12) {
            // Изображение блюда
            Image(item.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
            
            // Информация о блюде
            VStack(alignment: .leading, spacing: 4) {
                Text(item.dishName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Text("Количество: \(item.quantity)")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            // Цена
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(String(format: "%.0f", item.price)) ₽")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                Text("×\(item.quantity)")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }
}

struct DeliveryInfoSection: View {
    let order: UserOrder
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Информация о доставке")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                if let address = order.deliveryAddress {
                    OrderInfoRow(
                        icon: "location.fill",
                        title: "Адрес доставки",
                        value: address,
                        color: Color("BykAccent")
                    )
                }
                
                if let estimatedTime = order.estimatedDeliveryTime {
                    OrderInfoRow(
                        icon: "clock.fill",
                        title: "Время доставки",
                        value: estimatedTime.formatted(date: .abbreviated, time: .shortened),
                        color: .blue
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.8),
                            Color.black.opacity(0.6)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color("BykAccent").opacity(0.3),
                                    Color("BykAccent").opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: Color("BykAccent").opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

struct OrderInfoRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                
                Text(value)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
    }
}

struct PaymentInfoSection: View {
    let order: UserOrder
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Оплата")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                PaymentRow(
                    title: "Стоимость блюд",
                    value: order.items.reduce(0) { $0 + $1.price }
                )
                
                PaymentRow(
                    title: "Доставка",
                    value: 200
                )
                
                Divider()
                    .background(Color.white.opacity(0.2))
                
                PaymentRow(
                    title: "Итого",
                    value: order.totalAmount,
                    isTotal: true
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.8),
                            Color.black.opacity(0.6)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color("BykAccent").opacity(0.3),
                                    Color("BykAccent").opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: Color("BykAccent").opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

struct PaymentRow: View {
    let title: String
    let value: Double
    var isTotal: Bool = false
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: isTotal ? 18 : 16, weight: isTotal ? .bold : .medium))
                .foregroundColor(.white)
            
            Spacer()
            
            Text("\(String(format: "%.0f", value)) ₽")
                .font(.system(size: isTotal ? 18 : 16, weight: isTotal ? .bold : .medium))
                .foregroundColor(isTotal ? .white : .white.opacity(0.8))
        }
    }
}

struct OrderActionButtons: View {
    let order: UserOrder
    let onRepeatOrder: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Button(action: onRepeatOrder) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Повторить заказ")
                        .font(.system(size: 18, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color("BykAccent"), Color("BykAccent").opacity(0.8)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(16)
                .shadow(color: Color("BykAccent").opacity(0.3), radius: 10, x: 0, y: 5)
            }
            
            Button(action: {
                // Поделиться заказом
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Поделиться")
                        .font(.system(size: 18, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.1),
                            Color.white.opacity(0.05)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
            }
        }
    }
}

#Preview {
    OrderDetailView(
        order: UserOrder(
            orderNumber: "BY-2024-001",
            restaurantName: "The Бык",
            items: [
                OrderItem(dishName: "Стейк Рибай", quantity: 1, price: 2500, image: "ribai_steak"),
                OrderItem(dishName: "Цезарь салат", quantity: 2, price: 450, image: "caesar_salad")
            ],
            totalAmount: 3400,
            orderDate: Date(),
            status: .delivered,
            deliveryAddress: "ул. Тверская, 15, кв. 42",
            estimatedDeliveryTime: Date()
        )
    )
} 