import SwiftUI

struct OrderSuccessView: View {
    let order: DeliveryOrder
    let restaurant: Restaurant
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var cartViewModel: CartViewModel
    
    @State private var showingAnimation = false
    @State private var showingConfetti = false
    @State private var currentStep = 0
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color) {
        Colors.brandColors(for: order.restaurantBrand)
    }
    
    private var estimatedDeliveryTime: String {
        guard let estimatedTime = order.estimatedDeliveryTime else {
            return "Уточняется"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: estimatedTime)
    }
    
    private var orderStatusSteps: [OrderStatusStep] {
        let isDelivery = order.deliveryAddress != restaurant.address
        
        if isDelivery {
            return [
                OrderStatusStep(
                    title: "Заказ принят",
                    description: "Ресторан получил ваш заказ",
                    icon: "checkmark.circle.fill",
                    isCompleted: true,
                    estimatedTime: "Сейчас"
                ),
                OrderStatusStep(
                    title: "Готовим",
                    description: "Повара готовят ваш заказ",
                    icon: "flame.fill",
                    isCompleted: false,
                    estimatedTime: "+15 мин"
                ),
                OrderStatusStep(
                    title: "В пути",
                    description: "Курьер везет заказ",
                    icon: "car.fill",
                    isCompleted: false,
                    estimatedTime: "+30 мин"
                ),
                OrderStatusStep(
                    title: "Доставлен",
                    description: "Заказ у вас!",
                    icon: "house.fill",
                    isCompleted: false,
                    estimatedTime: estimatedDeliveryTime
                )
            ]
        } else {
            return [
                OrderStatusStep(
                    title: "Заказ принят",
                    description: "Ресторан получил ваш заказ",
                    icon: "checkmark.circle.fill",
                    isCompleted: true,
                    estimatedTime: "Сейчас"
                ),
                OrderStatusStep(
                    title: "Готовим",
                    description: "Повара готовят ваш заказ",
                    icon: "flame.fill",
                    isCompleted: false,
                    estimatedTime: "+15 мин"
                ),
                OrderStatusStep(
                    title: "Готов к выдаче",
                    description: "Заказ готов, можете забирать",
                    icon: "bag.fill",
                    isCompleted: false,
                    estimatedTime: estimatedDeliveryTime
                )
            ]
        }
    }
    
    var body: some View {
        ZStack {
            // Градиентный фон
            LinearGradient(
                gradient: Gradient(colors: [
                    brandColors.primary.opacity(0.1),
                    brandColors.secondary.opacity(0.05),
                    Color.black
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Успешная анимация
                    successAnimationSection
                    
                    // Информация о заказе
                    orderInfoSection
                    
                    // Статус заказа
                    orderStatusSection
                    
                    // Контактная информация
                    contactInfoSection
                    
                    // Кнопки действий
                    actionButtonsSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 40)
            }
            
            // Конфетти
            if showingConfetti {
                ConfettiView()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            startSuccessAnimation()
        }
    }
    
    // MARK: - Success Animation Section
    
    private var successAnimationSection: some View {
        VStack(spacing: 24) {
            ZStack {
                // Фоновые круги
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .stroke(
                            brandColors.accent.opacity(0.2 - Double(index) * 0.05),
                            lineWidth: 2
                        )
                        .frame(width: 120 + CGFloat(index * 40), height: 120 + CGFloat(index * 40))
                        .scaleEffect(showingAnimation ? 1 : 0)
                        .animation(
                            .easeOut(duration: 0.8)
                            .delay(Double(index) * 0.2),
                            value: showingAnimation
                        )
                }
                
                // Центральная иконка
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    brandColors.accent,
                                    brandColors.primary
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(showingAnimation ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: showingAnimation)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(showingAnimation ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.5), value: showingAnimation)
                }
            }
            
            VStack(spacing: 16) {
                Text("Заказ оформлен!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .opacity(showingAnimation ? 1 : 0)
                    .animation(.easeOut(duration: 0.8).delay(0.6), value: showingAnimation)
                
                Text("Спасибо за заказ! Мы уже начали его готовить")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .opacity(showingAnimation ? 1 : 0)
                    .animation(.easeOut(duration: 0.8).delay(0.7), value: showingAnimation)
            }
        }
    }
    
    // MARK: - Order Info Section
    
    private var orderInfoSection: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .foregroundColor(brandColors.accent)
                
                Text("Детали заказа")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                SuccessOrderInfoRow(
                    icon: "number",
                    title: "Номер заказа",
                    value: order.orderNumber,
                    color: brandColors.accent
                )
                
                SuccessOrderInfoRow(
                    icon: "building.2.fill",
                    title: "Ресторан",
                    value: restaurant.name,
                    color: brandColors.accent
                )
                
                SuccessOrderInfoRow(
                    icon: "clock.fill",
                    title: "Время заказа",
                    value: formatTime(order.orderDate),
                    color: brandColors.accent
                )
                
                SuccessOrderInfoRow(
                    icon: "creditcard.fill",
                    title: "Способ оплаты",
                    value: order.paymentMethod.rawValue,
                    color: brandColors.accent
                )
                
                SuccessOrderInfoRow(
                    icon: "banknote.fill",
                    title: "Сумма заказа",
                    value: "\(Int(order.totalAmount)) ₽",
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
        .opacity(showingAnimation ? 1 : 0)
        .offset(y: showingAnimation ? 0 : 30)
        .animation(.easeOut(duration: 0.8).delay(0.8), value: showingAnimation)
    }
    
    // MARK: - Order Status Section
    
    private var orderStatusSection: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "list.bullet.clipboard.fill")
                    .foregroundColor(brandColors.accent)
                
                Text("Статус заказа")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            VStack(spacing: 16) {
                ForEach(Array(orderStatusSteps.enumerated()), id: \.offset) { index, step in
                    OrderStatusStepView(
                        step: step,
                        isLast: index == orderStatusSteps.count - 1,
                        brandColors: brandColors
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
        .opacity(showingAnimation ? 1 : 0)
        .offset(y: showingAnimation ? 0 : 30)
        .animation(.easeOut(duration: 0.8).delay(0.9), value: showingAnimation)
    }
    
    // MARK: - Contact Info Section
    
    private var contactInfoSection: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "phone.fill")
                    .foregroundColor(brandColors.accent)
                
                Text("Контакты")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                SuccessOrderInfoRow(
                    icon: "building.2",
                    title: "Ресторан",
                    value: restaurant.contacts.phone,
                    color: brandColors.accent
                )
                
                if let courierPhone = order.courierPhone {
                    SuccessOrderInfoRow(
                        icon: "car.fill",
                        title: "Курьер",
                        value: courierPhone,
                        color: brandColors.accent
                    )
                }
                
                SuccessOrderInfoRow(
                    icon: "questionmark.circle",
                    title: "Поддержка",
                    value: "+7 (800) 555-35-35",
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
        .opacity(showingAnimation ? 1 : 0)
        .offset(y: showingAnimation ? 0 : 30)
        .animation(.easeOut(duration: 0.8).delay(1.0), value: showingAnimation)
    }
    
    // MARK: - Action Buttons Section
    
    private var actionButtonsSection: some View {
        VStack(spacing: 16) {
            Button(action: {
                // Отслеживание заказа
            }) {
                HStack {
                    Image(systemName: "location.fill")
                        .font(.system(size: 16, weight: .medium))
                    
                    Text("Отследить заказ")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(brandColors.accent)
                )
            }
            
            Button(action: {
                cartViewModel.clearCart()
                dismiss()
            }) {
                Text("Вернуться к покупкам")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(brandColors.accent)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(brandColors.accent, lineWidth: 1)
                    )
            }
        }
        .opacity(showingAnimation ? 1 : 0)
        .offset(y: showingAnimation ? 0 : 30)
        .animation(.easeOut(duration: 0.8).delay(1.1), value: showingAnimation)
    }
    
    // MARK: - Private Methods
    
    private func startSuccessAnimation() {
        withAnimation {
            showingAnimation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                showingConfetti = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                showingConfetti = false
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Models and Views

struct OrderStatusStep {
    let title: String
    let description: String
    let icon: String
    let isCompleted: Bool
    let estimatedTime: String
}

struct SuccessOrderInfoRow: View {
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
        }
    }
}

struct OrderStatusStepView: View {
    let step: OrderStatusStep
    let isLast: Bool
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        HStack(spacing: 16) {
            // Иконка статуса
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(step.isCompleted ? brandColors.accent : Color.gray.opacity(0.3))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: step.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(step.isCompleted ? .white : .gray)
                }
                
                if !isLast {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 2, height: 30)
                }
            }
            
            // Информация о статусе
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(step.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text(step.estimatedTime)
                        .font(.system(size: 12))
                        .foregroundColor(brandColors.accent)
                }
                
                Text(step.description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
}

// MARK: - Confetti View

struct ConfettiView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ForEach(0..<50, id: \.self) { index in
                ConfettiPiece()
                    .offset(
                        x: CGFloat.random(in: -200...200),
                        y: animate ? 800 : -100
                    )
                    .animation(
                        .linear(duration: Double.random(in: 2...4))
                        .repeatForever(autoreverses: false)
                        .delay(Double.random(in: 0...2)),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

struct ConfettiPiece: View {
    let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .purple, .pink]
    
    var body: some View {
        Rectangle()
            .fill(colors.randomElement() ?? .blue)
            .frame(width: 8, height: 8)
            .rotationEffect(.degrees(Double.random(in: 0...360)))
    }
}

#Preview {
    OrderSuccessView(
        order: DeliveryOrder.mockOrder,
        restaurant: Restaurant.mock
    )
    .environmentObject(CartViewModel(restaurantService: RestaurantService(), menuService: MenuService()))
}

// MARK: - Mock Data Extension

extension DeliveryOrder {
    static var mockOrder: DeliveryOrder {
        DeliveryOrder(
            orderNumber: "BYK-1234",
            items: [],
            totalAmount: 2500,
            deliveryAddress: "ул. Тверская, 15",
            deliveryTime: Date().addingTimeInterval(3600),
            orderDate: Date(),
            status: .preparing,
            restaurantBrand: .theByk,
            deliveryFee: 200,
            estimatedDeliveryTime: Date().addingTimeInterval(3600),
            paymentMethod: .card
        )
    }
}