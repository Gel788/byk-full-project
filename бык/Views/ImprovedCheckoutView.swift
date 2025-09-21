import SwiftUI
import CoreLocation

// MARK: - Checkout Steps
enum CheckoutStep: Int, CaseIterable {
    case delivery = 0
    case address = 1
    case payment = 2
    case confirmation = 3
    
    var title: String {
        switch self {
        case .delivery: return "Способ получения"
        case .address: return "Адрес доставки"
        case .payment: return "Оплата"
        case .confirmation: return "Подтверждение"
        }
    }
    
    var icon: String {
        switch self {
        case .delivery: return "shippingbox"
        case .address: return "location"
        case .payment: return "creditcard"
        case .confirmation: return "checkmark.seal"
        }
    }
}

// MARK: - Order Data Model
class OrderData: ObservableObject {
    @Published var deliveryMethod: DeliveryMethod = .delivery
    @Published var address: String = ""
    @Published var coordinate: CLLocationCoordinate2D?
    @Published var name: String = ""
    @Published var phone: String = ""
    @Published var paymentMethod: PaymentMethod = .card
    @Published var tipAmount: Double = 0
    @Published var specialRequests: String = ""
    @Published var selectedTime: Date = Date().addingTimeInterval(3600)
    @Published var deliveryCalculation: DeliveryCalculation?
    
    var isDeliveryStepValid: Bool {
        true // Выбор способа доставки всегда валиден
    }
    
    var isAddressStepValid: Bool {
        if deliveryMethod == .delivery {
            return !address.isEmpty && !name.isEmpty && !phone.isEmpty
        } else {
            return !name.isEmpty && !phone.isEmpty
        }
    }
    
    var isPaymentStepValid: Bool {
        true // Выбор способа оплаты всегда валиден
    }
    
    func reset() {
        deliveryMethod = .delivery
        address = ""
        coordinate = nil
        name = ""
        phone = ""
        paymentMethod = .card
        tipAmount = 0
        specialRequests = ""
        selectedTime = Date().addingTimeInterval(3600)
        deliveryCalculation = nil
    }
}

// MARK: - Improved Checkout View
struct ImprovedCheckoutView: View {
    let restaurant: Restaurant
    @EnvironmentObject private var cartViewModel: CartViewModel
    @StateObject private var orderData = OrderData()
    @StateObject private var deliveryService = SmartDeliveryService()
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentStep: CheckoutStep = .delivery
    @State private var isProcessing = false
    @State private var showingSuccess = false
    @State private var animateSteps = false
    @State private var showingLocationPicker = false
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color) {
        Colors.brandColors(for: restaurant.brand)
    }
    
    private var canProceedToNextStep: Bool {
        switch currentStep {
        case .delivery:
            return orderData.isDeliveryStepValid
        case .address:
            return orderData.isAddressStepValid
        case .payment:
            return orderData.isPaymentStepValid
        case .confirmation:
            return true
        }
    }
    
    private var totalAmount: Double {
        let subtotal = cartViewModel.totalAmount
        let deliveryFee = orderData.deliveryCalculation?.deliveryFee ?? 0
        let tip = orderData.tipAmount
        return subtotal + deliveryFee + tip
    }
    
    var body: some View {
        NavigationStack {
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
                
                VStack(spacing: 0) {
                    // Прогресс-бар
                    CheckoutProgressBar(
                        currentStep: currentStep,
                        brandColors: brandColors
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Контент шага
                    ScrollView {
                        VStack(spacing: 24) {
                            // Заголовок шага
                            StepHeaderView(
                                step: currentStep,
                                brandColors: brandColors
                            )
                            .opacity(animateSteps ? 1 : 0)
                            .offset(y: animateSteps ? 0 : 30)
                            
                            // Контент в зависимости от шага
                            Group {
                                switch currentStep {
                                case .delivery:
                                    DeliveryMethodStepView(
                                        orderData: orderData,
                                        restaurant: restaurant,
                                        brandColors: brandColors
                                    )
                                    
                                case .address:
                                    AddressStepView(
                                        orderData: orderData,
                                        restaurant: restaurant,
                                        deliveryService: deliveryService,
                                        brandColors: brandColors
                                    ) {
                                        showingLocationPicker = true
                                    }
                                    
                                case .payment:
                                    PaymentStepView(
                                        orderData: orderData,
                                        totalAmount: totalAmount,
                                        brandColors: brandColors
                                    )
                                    
                                case .confirmation:
                                    ConfirmationStepView(
                                        orderData: orderData,
                                        restaurant: restaurant,
                                        cartItems: cartViewModel.groupedCartItems(),
                                        totalAmount: totalAmount,
                                        brandColors: brandColors
                                    )
                                }
                            }
                            .opacity(animateSteps ? 1 : 0)
                            .offset(y: animateSteps ? 0 : 50)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 120) // Space for bottom buttons
                    }
                    
                    Spacer()
                }
                
                // Нижние кнопки
                VStack {
                    Spacer()
                    CheckoutBottomButtons(
                        currentStep: currentStep,
                        canProceed: canProceedToNextStep,
                        isProcessing: isProcessing,
                        brandColors: brandColors,
                        onBack: previousStep,
                        onNext: nextStep,
                        onComplete: processOrder
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.clear,
                                Color.black.opacity(0.8),
                                Color.black
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 100)
                    )
                }
            }
            .navigationTitle("Оформление заказа")
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
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animateSteps = true
            }
            deliveryService.requestLocationPermission()
        }
        .sheet(isPresented: $showingLocationPicker) {
            LocationPickerView(
                selectedAddress: $orderData.address,
                selectedCoordinate: $orderData.coordinate,
                deliveryService: deliveryService
            )
        }
        .sheet(isPresented: $showingSuccess) {
            OrderSuccessView(
                order: createOrder(),
                restaurant: restaurant
            )
            .environmentObject(cartViewModel)
        }
        .environmentObject(orderData)
    }
    
    // MARK: - Navigation Methods
    
    private func nextStep() {
        guard canProceedToNextStep else { return }
        
        let nextStepValue = currentStep.rawValue + 1
        if let nextStep = CheckoutStep(rawValue: nextStepValue) {
            withAnimation(.easeInOut(duration: 0.3)) {
                animateSteps = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                currentStep = nextStep
                withAnimation(.easeInOut(duration: 0.3)) {
                    animateSteps = true
                }
            }
            
            // Автоматический расчет доставки при переходе на шаг адреса
            if nextStep == .payment && orderData.deliveryMethod == .delivery {
                Task {
                    await calculateDelivery()
                }
            }
        }
    }
    
    private func previousStep() {
        let previousStepValue = currentStep.rawValue - 1
        if let previousStep = CheckoutStep(rawValue: previousStepValue) {
            withAnimation(.easeInOut(duration: 0.3)) {
                animateSteps = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                currentStep = previousStep
                withAnimation(.easeInOut(duration: 0.3)) {
                    animateSteps = true
                }
            }
        }
    }
    
    private func calculateDelivery() async {
        guard orderData.deliveryMethod == .delivery,
              !orderData.address.isEmpty else { return }
        
        let calculation = await deliveryService.calculateDelivery(
            to: orderData.address,
            coordinate: orderData.coordinate,
            restaurant: restaurant,
            orderAmount: cartViewModel.totalAmount
        )
        
        await MainActor.run {
            orderData.deliveryCalculation = calculation
        }
    }
    
    private func processOrder() {
        isProcessing = true
        
        // Имитация обработки заказа
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isProcessing = false
            showingSuccess = true
        }
    }
    
    private func createOrder() -> DeliveryOrder {
        let orderNumber = "\(restaurant.brand.rawValue.prefix(3))-\(Int.random(in: 1000...9999))"
        
        return DeliveryOrder(
            orderNumber: orderNumber,
            items: cartViewModel.groupedCartItems().map { item in
                DeliveryOrderItem(
                    dish: item.dish,
                    quantity: item.quantity,
                    price: item.dish.price
                )
            },
            totalAmount: totalAmount,
            deliveryAddress: orderData.deliveryMethod == .delivery ? orderData.address : restaurant.address,
            deliveryTime: orderData.selectedTime,
            orderDate: Date(),
            status: .preparing,
            restaurantBrand: restaurant.brand,
            deliveryFee: orderData.deliveryCalculation?.deliveryFee ?? 0,
            tip: orderData.tipAmount > 0 ? orderData.tipAmount : nil,
            estimatedDeliveryTime: orderData.selectedTime,
            paymentMethod: convertPaymentMethod(orderData.paymentMethod),
            specialInstructions: orderData.specialRequests.isEmpty ? nil : orderData.specialRequests
        )
    }
    
    private func convertPaymentMethod(_ method: PaymentMethod) -> DeliveryPaymentMethod {
        switch method {
        case .card: return .card
        case .cash: return .cash
        case .online: return .online
        }
    }
}

// MARK: - Progress Bar
struct CheckoutProgressBar: View {
    let currentStep: CheckoutStep
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(CheckoutStep.allCases, id: \.self) { step in
                let isCompleted = step.rawValue < currentStep.rawValue
                let isCurrent = step == currentStep
                
                HStack(spacing: 0) {
                    // Индикатор шага
                    ZStack {
                        Circle()
                            .fill(isCompleted || isCurrent ? brandColors.accent : Color.gray.opacity(0.3))
                            .frame(width: 24, height: 24)
                        
                        if isCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        } else {
                            Text("\(step.rawValue + 1)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(isCurrent ? .white : .gray)
                        }
                    }
                    
                    // Линия соединения
                    if step != CheckoutStep.allCases.last {
                        Rectangle()
                            .fill(isCompleted ? brandColors.accent : Color.gray.opacity(0.3))
                            .frame(height: 2)
                            .animation(.easeInOut(duration: 0.3), value: currentStep)
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentStep)
    }
}

// MARK: - Step Header
struct StepHeaderView: View {
    let step: CheckoutStep
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: step.icon)
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(brandColors.accent)
            
            Text(step.title)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text(stepDescription)
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 20)
    }
    
    private var stepDescription: String {
        switch step {
        case .delivery:
            return "Выберите способ получения заказа"
        case .address:
            return "Укажите адрес доставки и контактные данные"
        case .payment:
            return "Выберите способ оплаты и добавьте чаевые"
        case .confirmation:
            return "Проверьте детали заказа перед подтверждением"
        }
    }
}

// MARK: - Bottom Buttons
struct CheckoutBottomButtons: View {
    let currentStep: CheckoutStep
    let canProceed: Bool
    let isProcessing: Bool
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let onBack: () -> Void
    let onNext: () -> Void
    let onComplete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Кнопка "Назад"
            if currentStep != .delivery {
                Button(action: onBack) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                        Text("Назад")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(brandColors.accent)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(brandColors.accent, lineWidth: 1)
                    )
                }
                .disabled(isProcessing)
            }
            
            // Кнопка "Далее" / "Оформить"
            Button(action: currentStep == .confirmation ? onComplete : onNext) {
                HStack {
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Text(currentStep == .confirmation ? "Оформить заказ" : "Далее")
                            .font(.system(size: 16, weight: .bold))
                        
                        if currentStep != .confirmation {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .medium))
                        }
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            canProceed && !isProcessing ?
                            brandColors.accent :
                            Color.gray.opacity(0.3)
                        )
                )
            }
            .disabled(!canProceed || isProcessing)
        }
    }
}

#Preview {
    ImprovedCheckoutView(restaurant: Restaurant.mock)
        .environmentObject(CartViewModel(restaurantService: RestaurantService(), menuService: MenuService()))
}