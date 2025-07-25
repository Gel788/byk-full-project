import SwiftUI

struct CheckoutView: View {
    let restaurant: Restaurant
    @EnvironmentObject private var cartViewModel: CartViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var phone = ""
    @State private var address = ""
    @State private var selectedPaymentMethod: PaymentMethod = .card
    @State private var tipAmount: Double = 0
    @State private var specialRequests = ""
    @State private var selectedDeliveryTime = Date().addingTimeInterval(3600)
    @State private var isProcessing = false
    @State private var showingSuccess = false
    @State private var animateCards = false
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color) {
        Colors.brandColors(for: restaurant.brand)
    }
    
    private var totalAmount: Double {
        cartViewModel.totalAmount + 200 + tipAmount
    }
    
    private var isFormValid: Bool {
        !name.isEmpty && !phone.isEmpty && !address.isEmpty
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
                VStack(spacing: 20) {
                    // Заголовок
                    VStack(spacing: 8) {
                        Text("Оформление доставки")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Доставка из \(restaurant.name)")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.top, 20)
                    
                    // Информация о ресторане
                    RestaurantInfoCard(
                        restaurant: restaurant,
                        brandColors: brandColors
                    )
                    .offset(y: animateCards ? 0 : 50)
                    .opacity(animateCards ? 1 : 0)
                    
                    // Время доставки
                    DeliveryTimeSection(
                        selectedTime: $selectedDeliveryTime,
                        brandColors: brandColors,
                        restaurant: restaurant
                    )
                    .offset(y: animateCards ? 0 : 50)
                    .opacity(animateCards ? 1 : 0)
                    
                    // Контактная информация
                    ContactInfoSection(
                        name: $name,
                        phone: $phone,
                        address: $address,
                        brandColors: brandColors
                    )
                    .offset(y: animateCards ? 0 : 50)
                    .opacity(animateCards ? 1 : 0)
                    
                    // Способ оплаты
                    PaymentMethodSection(
                        selectedMethod: $selectedPaymentMethod,
                        brandColors: brandColors
                    )
                    .offset(y: animateCards ? 0 : 50)
                    .opacity(animateCards ? 1 : 0)
                    
                    // Чаевые
                    TipSection(
                        tipAmount: $tipAmount,
                        brandColors: brandColors
                    )
                    .offset(y: animateCards ? 0 : 50)
                    .opacity(animateCards ? 1 : 0)
                    
                    // Особые пожелания
                    SpecialRequestsSection(
                        specialRequests: $specialRequests,
                        brandColors: brandColors
                    )
                    .offset(y: animateCards ? 0 : 50)
                    .opacity(animateCards ? 1 : 0)
                    
                    // Итого
                    TotalSection(
                        subtotal: cartViewModel.totalAmount,
                        deliveryFee: 200,
                        tipAmount: tipAmount,
                        total: totalAmount,
                        brandColors: brandColors
                    )
                    .offset(y: animateCards ? 0 : 50)
                    .opacity(animateCards ? 1 : 0)
                    
                    // Кнопка оформления
                    CheckoutButtonSection(
                        isProcessing: isProcessing,
                        isEnabled: isFormValid,
                        brandColors: brandColors
                    ) {
                        processOrder()
                    }
                    .offset(y: animateCards ? 0 : 50)
                    .opacity(animateCards ? 1 : 0)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Доставка")
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
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animateCards = true
            }
        }
        .sheet(isPresented: $showingSuccess) {
            DeliverySuccessView(order: createOrder(), restaurant: restaurant)
        }
    }
    
    private func createOrder() -> DeliveryOrder {
        DeliveryOrder(
            orderNumber: "DLV-\(Int.random(in: 1000...9999))",
            items: cartViewModel.groupedCartItems().map { item in
                DeliveryOrderItem(
                    dish: item.dish,
                    quantity: item.quantity,
                    price: item.dish.price
                )
            },
            totalAmount: totalAmount,
            deliveryAddress: address,
            deliveryTime: selectedDeliveryTime,
            orderDate: Date(),
            status: .preparing,
            restaurantBrand: restaurant.brand,
            deliveryFee: 200,
            tip: tipAmount > 0 ? tipAmount : nil,
            estimatedDeliveryTime: selectedDeliveryTime,
            paymentMethod: DeliveryPaymentMethod(rawValue: selectedPaymentMethod.rawValue) ?? .card,
            specialInstructions: specialRequests.isEmpty ? nil : specialRequests
        )
    }
    
    private func processOrder() {
        isProcessing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isProcessing = false
            showingSuccess = true
        }
    }
}

// MARK: - Delivery Time Section
struct DeliveryTimeSection: View {
    @Binding var selectedTime: Date
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let restaurant: Restaurant
    
    private var timeSlots: [Date] {
        let calendar = Calendar.current
        let now = Date()
        let startTime = calendar.date(byAdding: .hour, value: 1, to: now) ?? now
        let endTime = calendar.date(byAdding: .hour, value: 4, to: now) ?? now
        
        var slots: [Date] = []
        var currentTime = startTime
        
        while currentTime <= endTime {
            slots.append(currentTime)
            currentTime = calendar.date(byAdding: .minute, value: 30, to: currentTime) ?? currentTime
        }
        
        return slots
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "clock.fill")
                    .font(.title2)
                    .foregroundColor(brandColors.accent)
                
                Text("Время доставки")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(timeSlots, id: \.self) { time in
                        let isSelected = Calendar.current.isDate(selectedTime, equalTo: time, toGranularity: .minute)
                        Button(action: {
                            selectedTime = time
                        }) {
                            Text(formatTime(time))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(isSelected ? brandColors.accent : Color.clear)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(isSelected ? brandColors.accent : brandColors.accent.opacity(0.3), lineWidth: 1)
                                        )
                                )
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(brandColors.secondary.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(brandColors.accent.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Contact Info Section
struct ContactInfoSection: View {
    @Binding var name: String
    @Binding var phone: String
    @Binding var address: String
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "person.fill")
                    .font(.title2)
                    .foregroundColor(brandColors.accent)
                Text("Контактная информация")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            VStack(spacing: 12) {
                CustomTextField(text: $name, icon: "person", placeholder: "Ваше имя")
                CustomTextField(text: $phone, icon: "phone", placeholder: "Номер телефона")
                CustomTextField(text: $address, icon: "location", placeholder: "Адрес доставки")
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(brandColors.secondary.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(brandColors.accent.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Payment Method Section
struct PaymentMethodSection: View {
    @Binding var selectedMethod: PaymentMethod
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "creditcard.fill")
                    .font(.title2)
                    .foregroundColor(brandColors.accent)
                Text("Способ оплаты")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            VStack(spacing: 8) {
                ForEach(PaymentMethod.allCases, id: \.self) { method in
                    PaymentMethodButton(
                        method: method,
                        isSelected: selectedMethod == method,
                        brandColors: brandColors
                    ) {
                        selectedMethod = method
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(brandColors.secondary.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(brandColors.accent.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Payment Method Button
struct PaymentMethodButton: View {
    let method: PaymentMethod
    let isSelected: Bool
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: method.icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? .white : brandColors.accent)
                
                Text(method.rawValue)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.8))
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? brandColors.accent : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? brandColors.accent : brandColors.accent.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - Tip Section
struct TipSection: View {
    @Binding var tipAmount: Double
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    private let tipOptions: [Double] = [0, 50, 100, 200, 500]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "heart.fill")
                    .font(.title2)
                    .foregroundColor(brandColors.accent)
                
                Text("Чаевые")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            
            HStack(spacing: 8) {
                ForEach(tipOptions, id: \.self) { tip in
                    TipButton(
                        amount: tip,
                        isSelected: tipAmount == tip,
                        brandColors: brandColors
                    ) {
                        tipAmount = tip
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(brandColors.secondary.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(brandColors.accent.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Tip Button
struct TipButton: View {
    let amount: Double
    let isSelected: Bool
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(amount == 0 ? "Нет" : "\(Int(amount))₽")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? brandColors.accent : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isSelected ? brandColors.accent : brandColors.accent.opacity(0.3), lineWidth: 1)
                        )
                )
        }
    }
}

// MARK: - Special Requests Section
struct SpecialRequestsSection: View {
    @Binding var specialRequests: String
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "text.bubble.fill")
                    .font(.title2)
                    .foregroundColor(brandColors.accent)
                
                Text("Особые пожелания")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            
            TextEditor(text: $specialRequests)
                .frame(minHeight: 100)
                .padding(12)
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .foregroundColor(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(brandColors.accent.opacity(0.3), lineWidth: 1)
                )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(brandColors.secondary.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(brandColors.accent.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Total Section
struct TotalSection: View {
    let subtotal: Double
    let deliveryFee: Double
    let tipAmount: Double
    let total: Double
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "creditcard.fill")
                    .font(.title2)
                    .foregroundColor(brandColors.accent)
                
                Text("Итого")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 8) {
                DetailRow(title: "Сумма заказа", value: "\(Int(subtotal))₽")
                DetailRow(title: "Доставка", value: "\(Int(deliveryFee))₽")
                if tipAmount > 0 {
                    DetailRow(title: "Чаевые", value: "\(Int(tipAmount))₽")
                }
                Divider()
                    .background(Color.white.opacity(0.3))
                DetailRow(title: "К оплате", value: "\(Int(total))₽")
                    .font(.system(size: 18, weight: .bold))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(brandColors.secondary.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(brandColors.accent.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Checkout Button Section
struct CheckoutButtonSection: View {
    let isProcessing: Bool
    let isEnabled: Bool
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "bag.fill")
                        .font(.title3)
                }
                
                Text(isProcessing ? "Оформляем заказ..." : "Оформить заказ")
                    .font(.system(size: 18, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isEnabled ? brandColors.accent : Color.gray.opacity(0.5))
            )
        }
        .disabled(!isEnabled || isProcessing)
    }
}

#Preview {
    CheckoutView(restaurant: Restaurant.mock)
        .environmentObject(CartViewModel(restaurantService: RestaurantService()))
} 