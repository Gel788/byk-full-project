import SwiftUI

struct PickupView: View {
    let restaurant: Restaurant
    @EnvironmentObject private var cartViewModel: CartViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var phone = ""
    @State private var address = ""
    @State private var selectedPaymentMethod: PaymentMethod = .card
    @State private var tipAmount: Double = 0
    @State private var specialRequests = ""
    @State private var selectedPickupTime = Date().addingTimeInterval(1800)
    @State private var isProcessing = false
    @State private var showingSuccess = false
    @State private var animateCards = false
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color) {
        Colors.brandColors(for: restaurant.brand)
    }
    
    private var totalAmount: Double {
        cartViewModel.totalAmount + tipAmount
    }
    
    private var isFormValid: Bool {
        !name.isEmpty && !phone.isEmpty
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
                        Text("Оформление самовывоза")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Заберите заказ в \(restaurant.name)")
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
                    
                    // Время самовывоза
                    PickupTimeSection(
                        selectedTime: $selectedPickupTime,
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
                        deliveryFee: 0,
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
                        brandColors: brandColors,
                        action: processOrder
                    )
                    .offset(y: animateCards ? 0 : 50)
                    .opacity(animateCards ? 1 : 0)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Самовывоз")
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
            let order = DeliveryOrder(
                orderNumber: "\(restaurant.brand.rawValue.prefix(3))-\(Int.random(in: 1000...9999))",
                items: cartViewModel.groupedCartItems().map { item in
                    DeliveryOrderItem(
                        dish: item.dish,
                        quantity: item.quantity,
                        price: item.dish.price
                    )
                },
                totalAmount: totalAmount,
                deliveryAddress: restaurant.address,
                deliveryTime: selectedPickupTime,
                orderDate: Date(),
                status: .preparing,
                restaurantBrand: restaurant.brand,
                deliveryFee: 0,
                tip: tipAmount > 0 ? tipAmount : nil,
                estimatedDeliveryTime: selectedPickupTime,
                paymentMethod: convertPaymentMethod(selectedPaymentMethod),
                specialInstructions: specialRequests.isEmpty ? nil : specialRequests
            )
            
            PickupSuccessView(order: order, restaurant: restaurant)
                .environmentObject(cartViewModel)
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
    
    private func convertPaymentMethod(_ method: PaymentMethod) -> DeliveryPaymentMethod {
        switch method {
        case .card:
            return .card
        case .cash:
            return .cash
        case .online:
            return .online
        }
    }
}

// MARK: - Pickup Time Section
struct PickupTimeSection: View {
    @Binding var selectedTime: Date
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let restaurant: Restaurant
    
    private var dateRange: ClosedRange<Date> {
        let now = Date()
        let minTime = now.addingTimeInterval(1800) // 30 минут от сейчас
        let maxTime = now.addingTimeInterval(86400) // 24 часа от сейчас
        return minTime...maxTime
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "clock.fill")
                    .font(.title2)
                    .foregroundColor(brandColors.accent)
                
                Text("Время самовывоза")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Календарь
            VStack(alignment: .leading, spacing: 8) {
                Text("Выберите дату")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                DatePicker("", selection: $selectedTime, in: dateRange, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .environment(\.locale, Locale(identifier: "ru_RU"))
                    .tint(brandColors.accent)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(12)
            }
            
            // Время
            VStack(alignment: .leading, spacing: 8) {
                Text("Выберите время")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                PickupTimePickerView(
                    selectedTime: $selectedTime,
                    brandColors: brandColors
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(brandColors.accent.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Pickup Time Picker View
struct PickupTimePickerView: View {
    @Binding var selectedTime: Date
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    private var timeSlots: [Date] {
        let calendar = Calendar.current
        let now = Date()
        let minTime = now.addingTimeInterval(1800)
        let maxTime = now.addingTimeInterval(86400)
        
        var slots: [Date] = []
        var currentTime = minTime
        
        while currentTime <= maxTime {
            slots.append(currentTime)
            currentTime = calendar.date(byAdding: .minute, value: 30, to: currentTime) ?? currentTime
        }
        
        return slots
    }
    
    var body: some View {
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
            .padding(.horizontal, 16)
        }
        .frame(height: 60)
        .background(Color.black.opacity(0.6))
        .cornerRadius(12)
    }
}





// MARK: - Pickup Success View
struct PickupSuccessView: View {
    let order: DeliveryOrder
    let restaurant: Restaurant
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var cartViewModel: CartViewModel
    @State private var showingAnimation = false
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color) {
        Colors.brandColors(for: order.restaurantBrand)
    }
    
    var body: some View {
        ZStack {
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
            VStack(spacing: 32) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    brandColors.primary,
                                    brandColors.secondary
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(showingAnimation ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showingAnimation)
                    Image(systemName: "checkmark")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(showingAnimation ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: showingAnimation)
                }
                .padding(.top, 60)
                VStack(spacing: 16) {
                    Text("Заказ на самовывоз оформлен!")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    Text("Ваш заказ успешно принят и готовится")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                VStack(spacing: 12) {
                    DetailRow(title: "Номер заказа", value: order.orderNumber)
                    DetailRow(title: "Ресторан", value: restaurant.name)
                    DetailRow(title: "Время самовывоза", value: formatTime(order.estimatedDeliveryTime ?? Date()))
                    DetailRow(title: "Сумма", value: "\(Int(order.totalAmount))₽")
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
                .padding(.horizontal, 20)
                Spacer()
                Button(action: {
                    cartViewModel.clearCart()
                    dismiss()
                }) {
                    Text("Готово")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [brandColors.accent, brandColors.accent.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation {
                showingAnimation = true
            }
        }
    }
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy в HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    PickupView(restaurant: Restaurant.mock)
        .environmentObject(CartViewModel(restaurantService: RestaurantService()))
} 