import SwiftUI

struct DeliveryCartView: View {
    let restaurant: Restaurant
    let cartItems: [UUID: Int]
    let onUpdateQuantity: (UUID, Bool) -> Void
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var cartViewModel: CartViewModel
    @State private var deliveryAddress = ""
    @State private var deliveryTime = Date()
    @State private var comment = ""
    @State private var showingOrderConfirmation = false
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color) {
        Colors.brandColors(for: restaurant.brand)
    }
    
    private var cartDishes: [(dish: Dish, quantity: Int)] {
        restaurant.menu
            .filter { cartItems[$0.id] ?? 0 > 0 }
            .map { ($0, cartItems[$0.id] ?? 0) }
    }
    
    private var subtotal: Double {
        cartDishes.reduce(0) { $0 + $1.dish.price * Double($1.quantity) }
    }
    
    private var deliveryFee: Double {
        subtotal >= 2000 ? 0 : 300 // Бесплатная доставка от 2000₽
    }
    
    private var total: Double {
        subtotal + deliveryFee
    }
    
    private var orderItems: [DeliveryOrderItem] {
        cartDishes.map { item in
            DeliveryOrderItem(
                dish: item.dish,
                quantity: item.quantity,
                price: item.dish.price
            )
        }
    }
    
    private func makeDeliveryOrder() -> DeliveryOrder {
        DeliveryOrder(
            orderNumber: "\(restaurant.brand.rawValue.prefix(3))-\(Int.random(in: 1000...9999))",
            items: orderItems,
            totalAmount: total,
            deliveryAddress: deliveryAddress,
            deliveryTime: deliveryTime,
            orderDate: Date(),
            status: .preparing,
            restaurantBrand: restaurant.brand,
            deliveryFee: deliveryFee,
            estimatedDeliveryTime: deliveryTime,
            paymentMethod: .card,
            specialInstructions: comment.isEmpty ? nil : comment
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Список блюд
                ForEach(cartDishes, id: \.dish.id) { item in
                    let groupedItem = CartGroupedItem(dish: item.dish, quantity: item.quantity)
                    CartItemRow(
                        item: CartItem(
                            dish: item.dish,
                            quantity: item.quantity
                        ),
                        cartViewModel: cartViewModel
                    )
                }
                
                // Адрес доставки
                VStack(alignment: .leading, spacing: 8) {
                    Text("Адрес доставки")
                        .font(.headline)
                    
                    TextField("Введите адрес", text: $deliveryAddress)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                // Время доставки
                VStack(alignment: .leading, spacing: 8) {
                    Text("Время доставки")
                        .font(.headline)
                    
                    DatePicker(
                        "Выберите время",
                        selection: $deliveryTime,
                        in: Date()...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.compact)
                }
                .padding(.horizontal)
                
                // Комментарий к заказу
                VStack(alignment: .leading, spacing: 8) {
                    Text("Комментарий к заказу")
                        .font(.headline)
                    
                    TextEditor(text: $comment)
                        .frame(height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                }
                .padding(.horizontal)
                
                // Итоговая сумма
                VStack(spacing: 8) {
                    HStack {
                        Text("Сумма заказа")
                        Spacer()
                        Text("\(Int(subtotal)) ₽")
                    }
                    
                    HStack {
                        Text("Доставка")
                        Spacer()
                        Text(deliveryFee == 0 ? "Бесплатно" : "\(Int(deliveryFee)) ₽")
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Итого")
                            .font(.headline)
                        Spacer()
                        Text("\(Int(total)) ₽")
                            .font(.headline)
                    }
                }
                .padding()
                .background(Color.black.opacity(0.8))
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
        .navigationTitle("Корзина")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Закрыть") {
                    dismiss()
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if !cartDishes.isEmpty {
                Button {
                    showingOrderConfirmation = true
                } label: {
                    Text("Оформить заказ")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            deliveryAddress.isEmpty
                            ? Color.gray
                            : brandColors.primary
                        )
                        .cornerRadius(16)
                }
                .disabled(deliveryAddress.isEmpty)
                .padding()
            }
        }
        .sheet(isPresented: $showingOrderConfirmation) {
            DeliverySuccessView(order: makeDeliveryOrder(), restaurant: restaurant)
                .environmentObject(cartViewModel)
                .onDisappear {
                    // Очищаем корзину после закрытия экрана успеха
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        cartViewModel.clearCart()
                    }
                    dismiss()
                }
        }
    }
} 