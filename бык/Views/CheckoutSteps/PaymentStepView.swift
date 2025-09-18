import SwiftUI

struct PaymentStepView: View {
    @ObservedObject var orderData: OrderData
    let totalAmount: Double
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    private let tipOptions: [Double] = [0, 50, 100, 150, 200]
    
    var body: some View {
        VStack(spacing: 24) {
            // Способы оплаты
            paymentMethodSection
            
            // Чаевые
            tipSection
            
            // Особые пожелания
            specialRequestsSection
        }
    }
    
    // MARK: - Payment Method Section
    
    private var paymentMethodSection: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "creditcard.fill")
                    .foregroundColor(brandColors.accent)
                
                Text("Способ оплаты")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                ForEach(PaymentMethod.allCases, id: \.self) { method in
                    CheckoutPaymentMethodCard(
                        method: method,
                        isSelected: orderData.paymentMethod == method,
                        brandColors: brandColors
                    ) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            orderData.paymentMethod = method
                        }
                        HapticManager.shared.impact(.light)
                    }
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
    
    // MARK: - Tip Section
    
    private var tipSection: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(brandColors.accent)
                
                Text("Чаевые")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("Спасибо персоналу ❤️")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            // Быстрые варианты чаевых
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(tipOptions, id: \.self) { tipAmount in
                    TipOptionButton(
                        amount: tipAmount,
                        isSelected: orderData.tipAmount == tipAmount,
                        brandColors: brandColors
                    ) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            orderData.tipAmount = tipAmount
                        }
                        HapticManager.shared.impact(.light)
                    }
                }
                
                // Кнопка "Другая сумма"
                CustomTipButton(
                    currentAmount: orderData.tipAmount,
                    brandColors: brandColors
                ) { customAmount in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        orderData.tipAmount = customAmount
                    }
                }
            }
            
            // Итоговая сумма с чаевыми
            if orderData.tipAmount > 0 {
                TotalWithTipView(
                    subtotal: totalAmount - orderData.tipAmount,
                    tipAmount: orderData.tipAmount,
                    total: totalAmount,
                    brandColors: brandColors
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
    
    // MARK: - Special Requests Section
    
    private var specialRequestsSection: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "text.bubble.fill")
                    .foregroundColor(brandColors.accent)
                
                Text("Особые пожелания")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Комментарий к заказу (необязательно)")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    orderData.specialRequests.isEmpty ? Color.gray.opacity(0.3) : brandColors.accent,
                                    lineWidth: 1
                                )
                        )
                        .frame(height: 100)
                    
                    TextEditor(text: $orderData.specialRequests)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                    
                    if orderData.specialRequests.isEmpty {
                        Text("Например: стейк средней прожарки, без лука в салате...")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.4))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .allowsHitTesting(false)
                    }
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
}

// MARK: - Checkout Payment Method Card

struct CheckoutPaymentMethodCard: View {
    let method: PaymentMethod
    let isSelected: Bool
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Иконка
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? brandColors.accent : Color.gray.opacity(0.3))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: method.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .gray)
                }
                
                // Название и описание
                VStack(alignment: .leading, spacing: 4) {
                    Text(method.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(paymentDescription)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                // Индикатор выбора
                ZStack {
                    Circle()
                        .stroke(isSelected ? brandColors.accent : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 20, height: 20)
                    
                    if isSelected {
                        Circle()
                            .fill(brandColors.accent)
                            .frame(width: 10, height: 10)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? brandColors.accent.opacity(0.1) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? brandColors.accent : Color.gray.opacity(0.2),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var paymentDescription: String {
        switch method {
        case .card:
            return "Безопасная оплата картой"
        case .cash:
            return "Оплата наличными курьеру"
        case .online:
            return "Онлайн оплата через банк"
        }
    }
}

// MARK: - Tip Option Button

struct TipOptionButton: View {
    let amount: Double
    let isSelected: Bool
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(amount == 0 ? "Без чаевых" : "\(Int(amount)) ₽")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.8))
                
                if amount > 0 {
                    Text("~\(Int(amount/10))%")
                        .font(.system(size: 10))
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .white.opacity(0.5))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? brandColors.accent : Color.gray.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? brandColors.accent : Color.gray.opacity(0.3),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Custom Tip Button

struct CustomTipButton: View {
    let currentAmount: Double
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let onAmountSelected: (Double) -> Void
    
    @State private var showingCustomTipSheet = false
    @State private var customTipText = ""
    
    private var isCustomAmount: Bool {
        let standardAmounts: [Double] = [0, 50, 100, 150, 200]
        return !standardAmounts.contains(currentAmount)
    }
    
    var body: some View {
        Button(action: {
            showingCustomTipSheet = true
        }) {
            VStack(spacing: 4) {
                if isCustomAmount && currentAmount > 0 {
                    Text("\(Int(currentAmount)) ₽")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("Своя сумма")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.8))
                } else {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("Своя сумма")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isCustomAmount ? brandColors.accent : Color.gray.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isCustomAmount ? brandColors.accent : Color.gray.opacity(0.3),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingCustomTipSheet) {
            CustomTipSheet(
                currentAmount: currentAmount,
                brandColors: brandColors,
                onAmountSelected: onAmountSelected
            )
        }
    }
}

// MARK: - Custom Tip Sheet

struct CustomTipSheet: View {
    let currentAmount: Double
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let onAmountSelected: (Double) -> Void
    
    @State private var tipText = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Введите сумму чаевых")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                VStack(spacing: 8) {
                    TextField("0", text: $tipText)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.1))
                        )
                    
                    Text("₽")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Button(action: {
                    if let amount = Double(tipText) {
                        onAmountSelected(amount)
                        dismiss()
                    }
                }) {
                    Text("Применить")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(brandColors.accent)
                        )
                }
                .disabled(tipText.isEmpty)
                
                Spacer()
            }
            .padding(20)
            .background(Color.black)
            .navigationTitle("Чаевые")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Отмена") {
                        dismiss()
                    }
                    .foregroundColor(brandColors.accent)
                }
            }
        }
        .onAppear {
            if currentAmount > 0 {
                tipText = String(Int(currentAmount))
            }
        }
    }
}

// MARK: - Total with Tip View

struct TotalWithTipView: View {
    let subtotal: Double
    let tipAmount: Double
    let total: Double
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Сумма заказа")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
                Text("\(Int(subtotal)) ₽")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
            }
            
            HStack {
                Text("Чаевые")
                    .font(.system(size: 14))
                    .foregroundColor(brandColors.accent)
                Spacer()
                Text("+\(Int(tipAmount)) ₽")
                    .font(.system(size: 14))
                    .foregroundColor(brandColors.accent)
            }
            
            Divider()
                .background(Color.white.opacity(0.3))
            
            HStack {
                Text("Итого")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Text("\(Int(total)) ₽")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(brandColors.accent)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(brandColors.accent.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(brandColors.accent.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    PaymentStepView(
        orderData: OrderData(),
        totalAmount: 2500,
        brandColors: Colors.brandColors(for: .theByk)
    )
    .background(Color.black)
}