import SwiftUI

struct CartView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var cartViewModel: CartViewModel
    @EnvironmentObject private var restaurantService: RestaurantService
    @State private var showingCheckout = false
    @State private var animateItems = false
    @State private var selectedTab = 0
    
    // Определяем ресторан из корзины
    private var restaurantFromCart: Restaurant? {
        guard let firstItem = cartViewModel.groupedCartItems().first else { return nil }
        return restaurantService.restaurants.first { $0.menu.contains(where: { $0.id == firstItem.dish.id }) }
    }
    
    // Минимальная сумма для бесплатной доставки
    private let freeDeliveryThreshold: Double = 1500
    private var progressToFreeDelivery: Double {
        min(cartViewModel.totalAmount / freeDeliveryThreshold, 1.0)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Фон
                CartBackgroundView()
                
                if cartViewModel.hasItems {
                    CartFilledView(
                        cartViewModel: cartViewModel,
                        restaurantFromCart: restaurantFromCart,
                        progressToFreeDelivery: progressToFreeDelivery,
                        freeDeliveryThreshold: freeDeliveryThreshold,
                        showingCheckout: $showingCheckout,
                        animateItems: $animateItems
                    )
                } else {
                    CartEmptyView()
                }
            }
            .navigationTitle("Корзина")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5)) {
                    animateItems = true
                }
            }
        }
    }
}

struct CartBackgroundView: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.black,
                Color.black.opacity(0.95),
                Color.black
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct CartFilledView: View {
    @ObservedObject var cartViewModel: CartViewModel
    let restaurantFromCart: Restaurant?
    let progressToFreeDelivery: Double
    let freeDeliveryThreshold: Double
    @Binding var showingCheckout: Bool
    @Binding var animateItems: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Список товаров
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(cartViewModel.groupedCartItems(), id: \.dish.id) { item in
                        CartItemRow(
                            item: CartItem(
                                dish: item.dish,
                                quantity: item.quantity
                            ),
                            cartViewModel: cartViewModel
                        )
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .trailing)),
                                removal: .opacity.combined(with: .move(edge: .leading))
                            ))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
            }
            
            // Прогресс до бесплатной доставки
            FreeDeliveryProgressView(
                progress: progressToFreeDelivery,
                threshold: freeDeliveryThreshold,
                currentAmount: cartViewModel.totalAmount
            )
            
            // Итоговая панель
            CartBottomPanel(
                totalAmount: cartViewModel.totalAmount,
                restaurant: restaurantFromCart,
                showingCheckout: $showingCheckout
            )
        }
    }
}

struct CartEmptyView: View {
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "cart")
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("Корзина пуста")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("Добавьте блюда из меню ресторана")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CartItemRow: View {
    let item: CartItem
    @ObservedObject var cartViewModel: CartViewModel
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Изображение блюда
            AsyncImage(url: URL(string: item.dish.image)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 8) {
                // Название блюда
                Text(item.dish.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                // Цена за единицу
                Text("\(Int(item.dish.price)) ₽")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                // Общая цена
                Text("\(Int(item.totalPrice)) ₽")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Счетчик количества
            QuantityControl(
                quantity: item.quantity,
                onIncrement: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        _ = cartViewModel.updateQuantity(for: item.dish.id, increment: true)
                    }
                },
                onDecrement: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        _ = cartViewModel.updateQuantity(for: item.dish.id, increment: false)
                    }
                },
                onRemove: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        cartViewModel.removeFromCart(dishId: item.dish.id)
                    }
                }
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
        )
        .scaleEffect(isAnimating ? 1.0 : 0.95)
        .opacity(isAnimating ? 1.0 : 0.0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                isAnimating = true
            }
        }
    }
}

struct QuantityControl: View {
    let quantity: Int
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Кнопка уменьшения
            Button(action: quantity > 1 ? onDecrement : onRemove) {
                Image(systemName: quantity > 1 ? "minus" : "trash")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(Color.red.opacity(0.8))
                    )
            }
            
            // Количество
            Text("\(quantity)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(minWidth: 30)
            
            // Кнопка увеличения
            Button(action: onIncrement) {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(Color.green.opacity(0.8))
                    )
            }
        }
    }
}

struct FreeDeliveryProgressView: View {
    let progress: Double
    let threshold: Double
    let currentAmount: Double
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("До бесплатной доставки")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text("\(Int(threshold - currentAmount)) ₽")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Прогресс-бар
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.green)
                        .frame(width: geometry.size.width * progress, height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding(.horizontal)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
        )
        .padding(.horizontal)
    }
}

struct CartBottomPanel: View {
    let totalAmount: Double
    let restaurant: Restaurant?
    @Binding var showingCheckout: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            // Итого
            HStack {
                Text("Итого:")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(Int(totalAmount)) ₽")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            
            // Кнопка оформления заказа
            Button(action: {
                showingCheckout = true
            }) {
                Text("Оформить заказ")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue)
                    )
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.1))
                .ignoresSafeArea(edges: .bottom)
        )
        .sheet(isPresented: $showingCheckout) {
            if let restaurant = restaurant {
                CheckoutView(restaurant: restaurant)
            }
        }
    }
}

#Preview {
    CartView()
        .environmentObject(CartViewModel(restaurantService: RestaurantService(), menuService: MenuService()))
        .environmentObject(RestaurantService())
}
