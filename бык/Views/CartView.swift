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
                // Градиентный фон
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
                
                if cartViewModel.hasItems {
                    ImprovedCartFilledView(
                        groupedItems: cartViewModel.groupedCartItems(),
                        totalAmount: cartViewModel.totalAmount,
                        progressToFreeDelivery: progressToFreeDelivery,
                        freeDeliveryThreshold: freeDeliveryThreshold,
                        onUpdateQuantity: { dishId, increment in
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                _ = cartViewModel.updateQuantity(for: dishId, increment: increment)
                            }
                        },
                        onRemoveItem: { dishId in
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                cartViewModel.removeFromCart(dishId: dishId)
                            }
                        },
                        onCheckout: {
                            showingCheckout = true
                        }
                    )
                } else {
                    ImprovedEmptyCartView()
                }
            }
            .navigationTitle("Корзина")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(.black), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationBarItems(trailing: 
                cartViewModel.hasItems ? 
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        cartViewModel.clearCart()
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "trash")
                            .font(.system(size: 14, weight: .medium))
                        Text("Очистить")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(.red)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.red.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
                            )
                    )
                } : nil
            )
        }
        .sheet(isPresented: $showingCheckout) {
            if let restaurant = restaurantFromCart {
                ImprovedCheckoutView(restaurant: restaurant)
                    .environmentObject(cartViewModel)
            }
        }
    }
}

// MARK: - Улучшенная корзина с товарами
struct ImprovedCartFilledView: View {
    let groupedItems: [CartGroupedItem]
    let totalAmount: Double
    let progressToFreeDelivery: Double
    let freeDeliveryThreshold: Double
    let onUpdateQuantity: (UUID, Bool) -> Void
    let onRemoveItem: (UUID) -> Void
    let onCheckout: () -> Void
    
    @EnvironmentObject private var restaurantService: RestaurantService
    @State private var animateItems = false
    @State private var showingItemDetail: CartGroupedItem?
    
    private var restaurant: Restaurant? {
        guard let firstItem = groupedItems.first else { return nil }
        return firstItem.restaurant
    }
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color)? {
        guard let restaurant = restaurant else { return nil }
        return Colors.brandColors(for: restaurant.brand)
    }
    
    private var hasMultipleRestaurants: Bool {
        let restaurantIds = Set(groupedItems.compactMap { $0.restaurant?.id })
        return restaurantIds.count > 1
    }
    
    private var totalCalories: Int {
        groupedItems.reduce(0) { $0 + ($1.dish.calories * $1.quantity) }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Заголовок с информацией о ресторане
                if hasMultipleRestaurants {
                    ImprovedMultipleRestaurantsHeaderView(groupedItems: groupedItems)
                        .transition(.move(edge: .top).combined(with: .opacity))
                } else if let restaurant = restaurant, let brandColors = brandColors {
                    ImprovedCartRestaurantHeaderView(restaurant: restaurant, brandColors: brandColors)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // Прогресс-бар бесплатной доставки
                if totalAmount < freeDeliveryThreshold {
                    FreeDeliveryProgressView(
                        currentAmount: totalAmount,
                        threshold: freeDeliveryThreshold,
                        progress: progressToFreeDelivery
                    )
                    .transition(.scale.combined(with: .opacity))
                }
                
                // Статистика заказа
                OrderStatsView(
                    itemCount: groupedItems.count,
                    totalCalories: totalCalories,
                    totalAmount: totalAmount
                )
                .transition(.scale.combined(with: .opacity))
                
                // Предупреждение о множественных ресторанах
                if hasMultipleRestaurants {
                    ImprovedMultipleRestaurantsWarningView()
                        .transition(.scale.combined(with: .opacity))
                }
                
                // Список товаров
                ImprovedCartItemsList(
                    groupedItems: groupedItems,
                    onUpdateQuantity: onUpdateQuantity,
                    onRemoveItem: onRemoveItem,
                    onItemTap: { item in
                        showingItemDetail = item
                    }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                
                // Итоговая секция
                ImprovedCartTotalSection(
                    totalAmount: totalAmount,
                    onCheckout: onCheckout
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 100)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).delay(0.2)) {
                animateItems = true
            }
        }
        .sheet(item: $showingItemDetail) { item in
            DishDetailSheet(dish: item.dish, restaurant: item.restaurant)
        }
    }
}

// MARK: - Прогресс-бар бесплатной доставки
struct FreeDeliveryProgressView: View {
    let currentAmount: Double
    let threshold: Double
    let progress: Double
    
    @State private var animateProgress = false
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Бесплатная доставка")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Добавьте еще на \(threshold - currentAmount, specifier: "%.0f")₽")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Image(systemName: "truck.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.green)
            }
            
            // Прогресс-бар
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 8)
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [.green, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: UIScreen.main.bounds.width * 0.8 * progress, height: 8)
                    .scaleEffect(x: animateProgress ? 1.0 : 0.0, anchor: .leading)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color.green.opacity(0.1), Color.blue.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                )
        )
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animateProgress = true
            }
        }
    }
}

// MARK: - Статистика заказа
struct OrderStatsView: View {
    let itemCount: Int
    let totalCalories: Int
    let totalAmount: Double
    
    var body: some View {
        HStack(spacing: 16) {
            StatCard(
                icon: "bag.fill",
                title: "Товары",
                value: "\(itemCount)",
                color: .blue
            )
            
            StatCard(
                icon: "flame.fill",
                title: "Калории",
                value: "\(totalCalories)",
                color: .orange
            )
            
            StatCard(
                icon: "creditcard.fill",
                title: "Сумма",
                value: totalAmount.formattedPrice,
                color: .green
            )
        }
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Улучшенный список товаров
struct ImprovedCartItemsList: View {
    let groupedItems: [CartGroupedItem]
    let onUpdateQuantity: (UUID, Bool) -> Void
    let onRemoveItem: (UUID) -> Void
    let onItemTap: (CartGroupedItem) -> Void
    
    @EnvironmentObject private var restaurantService: RestaurantService
    
    private var groupedByRestaurant: [Restaurant: [CartGroupedItem]] {
        Dictionary(grouping: groupedItems) { item in
            item.restaurant ?? restaurantService.restaurants.first { $0.menu.contains(where: { $0.id == item.dish.id }) } ?? Restaurant.mock
        }
    }
    
    var body: some View {
        LazyVStack(spacing: 16) {
            if groupedByRestaurant.count > 1 {
                ForEach(Array(groupedByRestaurant.keys.sorted(by: { $0.name < $1.name })), id: \.id) { restaurant in
                    if let items = groupedByRestaurant[restaurant] {
                        ImprovedRestaurantItemsGroup(
                            restaurant: restaurant,
                            items: items,
                            onUpdateQuantity: onUpdateQuantity,
                            onRemoveItem: onRemoveItem,
                            onItemTap: onItemTap
                        )
                    }
                }
            } else {
                ForEach(groupedItems) { item in
                    ImprovedCartItemRowView(
                        item: item,
                        onUpdateQuantity: onUpdateQuantity,
                        onRemoveItem: onRemoveItem,
                        onItemTap: onItemTap
                    )
                }
            }
        }
    }
}

// MARK: - Улучшенная карточка товара
struct ImprovedCartItemRowView: View {
    let item: CartGroupedItem
    let onUpdateQuantity: (UUID, Bool) -> Void
    let onRemoveItem: (UUID) -> Void
    let onItemTap: (CartGroupedItem) -> Void
    
    @State private var isPressed = false
    
    private var restaurant: Restaurant? {
        item.restaurant
    }
    
    private var brand: Restaurant.Brand? {
        restaurant?.brand
    }
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color)? {
        guard let brand = brand else { return nil }
        return Colors.brandColors(for: brand)
    }
    
    var body: some View {
        // Основная карточка
        HStack(spacing: 0) {
            // Левая часть с изображением
            Button(action: {
                onItemTap(item)
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    brandColors?.accent.opacity(0.2) ?? Color.gray.opacity(0.2),
                                    brandColors?.primary.opacity(0.1) ?? Color.gray.opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Image(item.dish.image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 70, height: 70)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            brandColors?.accent.opacity(0.6) ?? Color.white.opacity(0.3),
                                            brandColors?.primary.opacity(0.4) ?? Color.white.opacity(0.2)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                }
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.leading, 16)
            
            // Центральная часть с информацией
            VStack(alignment: .leading, spacing: 6) {
                // Название блюда
                Text(item.dish.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // Ресторан и калории
                HStack(spacing: 12) {
                    if let restaurant = restaurant {
                        HStack(spacing: 4) {
                            Image(systemName: "building.2.fill")
                                .font(.system(size: 10))
                                .foregroundColor(brandColors?.accent ?? .white.opacity(0.7))
                            
                            Text(restaurant.name)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                                .lineLimit(1)
                        }
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.orange)
                        
                        Text("\(item.dish.calories) ккал")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                
                // Цена за единицу
                Text("\(item.dish.price.formattedPrice) за шт.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(brandColors?.accent ?? .white.opacity(0.8))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            
            // Правая часть с управлением
            VStack(spacing: 8) {
                // Счетчик количества
                CompactQuantityCounter(
                    quantity: item.quantity,
                    onIncrement: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            onUpdateQuantity(item.dish.id, true)
                        }
                    },
                    onDecrement: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            onUpdateQuantity(item.dish.id, false)
                        }
                    }
                )
                
                // Общая стоимость
                VStack(spacing: 2) {
                    Text("Итого:")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text((item.dish.price * Double(item.quantity)).formattedPrice)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(brandColors?.accent ?? .white)
                }
            }
            .padding(.trailing, 16)
        }
        .frame(height: 100)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.7),
                            Color.black.opacity(0.5)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    brandColors?.accent.opacity(0.4) ?? Color.white.opacity(0.15),
                                    brandColors?.primary.opacity(0.3) ?? Color.white.opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Компактный счетчик количества
struct CompactQuantityCounter: View {
    let quantity: Int
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    
    @State private var animateIncrement = false
    @State private var animateDecrement = false
    
    var body: some View {
        HStack(spacing: 0) {
            // Кнопка уменьшения
            Button(action: {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                    animateDecrement = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    animateDecrement = false
                    onDecrement()
                }
            }) {
                Image(systemName: "minus")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.red, Color.red.opacity(0.8)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .scaleEffect(animateDecrement ? 0.8 : 1.0)
            }
            
            // Количество
            Text("\(quantity)")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 28)
                .padding(.horizontal, 2)
            
            // Кнопка увеличения
            Button(action: {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                    animateIncrement = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    animateIncrement = false
                    onIncrement()
                }
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .scaleEffect(animateIncrement ? 0.8 : 1.0)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.black.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Улучшенная итоговая секция
struct ImprovedCartTotalSection: View {
    let totalAmount: Double
    let onCheckout: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Детализация с улучшенным дизайном
            VStack(spacing: 16) {
                HStack {
                    Text("Стоимость блюд")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    Spacer()
                    Text(totalAmount.formattedPrice)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
                
                HStack {
                    Text("Доставка")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.green)
                        Text("Бесплатно")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.green)
                    }
                }
                
                Divider()
                    .background(Color.white.opacity(0.2))
                
                HStack {
                    Text("Итого")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Text(totalAmount.formattedPrice)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
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
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.1),
                                        Color.white.opacity(0.05)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
            
            // Слайдер-кнопка оформления заказа в стиле iPhone
            SlideToCheckoutButton(onCheckout: onCheckout)
        }
    }
}

// MARK: - Улучшенная пустая корзина
struct ImprovedEmptyCartView: View {
    @State private var animateIcon = false
    @State private var animateText = false
    @State private var animateButton = false
    @State private var isButtonPressed = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Анимированная иконка корзины
            ZStack {
                // Фоновый круг с градиентом
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.2),
                                Color.purple.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(animateIcon ? 1.1 : 1.0)
                
                Image(systemName: "cart.badge.plus")
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(.blue)
                    .scaleEffect(animateIcon ? 1.2 : 1.0)
                    .rotationEffect(.degrees(animateIcon ? 5 : 0))
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    animateIcon = true
                }
            }
            
            VStack(spacing: 16) {
                Text("Корзина пуста")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .opacity(animateText ? 1.0 : 0.0)
                    .offset(y: animateText ? 0 : 20)
                
                Text("Добавьте блюда из меню ресторанов\nи мы доставим их к вам")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .opacity(animateText ? 1.0 : 0.0)
                    .offset(y: animateText ? 0 : 20)
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                    animateText = true
                }
            }
            
            // Улучшенная кнопка "Перейти к меню"
            Button(action: {
                // Здесь можно добавить навигацию к меню
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "fork.knife")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text("Перейти к меню")
                        .font(.system(size: 18, weight: .bold))
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.blue,
                                    Color.purple
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
                        .scaleEffect(isButtonPressed ? 0.95 : 1.0)
                )
            }
            .buttonStyle(PlainButtonStyle())
            .opacity(animateButton ? 1.0 : 0.0)
            .offset(y: animateButton ? 0 : 20)
            .onAppear {
                withAnimation(.easeOut(duration: 0.8).delay(0.6)) {
                    animateButton = true
                }
            }
            .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                withAnimation(.easeInOut(duration: 0.1)) {
                    isButtonPressed = pressing
                }
            }, perform: {})
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
}

// MARK: - Вспомогательные компоненты
struct ImprovedCartRestaurantHeaderView: View {
    let restaurant: Restaurant
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        HStack(spacing: 16) {
            Image(restaurant.imageURL)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(restaurant.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Text(restaurant.cuisine)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(brandColors.accent)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            brandColors.primary.opacity(0.2),
                            brandColors.secondary.opacity(0.1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(brandColors.accent.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct ImprovedMultipleRestaurantsHeaderView: View {
    let groupedItems: [CartGroupedItem]
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "building.2.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.orange)
                
                Text("Заказ из нескольких ресторанов")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            Text("\(groupedItems.count) товаров из \(Set(groupedItems.compactMap { $0.restaurant?.name }).count) ресторанов")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.orange.opacity(0.2),
                            Color.red.opacity(0.1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct ImprovedMultipleRestaurantsWarningView: View {
    @State private var animateWarning = false
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.orange.opacity(0.2),
                                Color.red.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                    .scaleEffect(animateWarning ? 1.1 : 1.0)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.orange)
                    .rotationEffect(.degrees(animateWarning ? 5 : 0))
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    animateWarning = true
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Блюда из разных ресторанов")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Заказ будет разделен на несколько доставок")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .lineSpacing(2)
            }
            
            Spacer()
            
            Image(systemName: "info.circle.fill")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.orange.opacity(0.1),
                            Color.red.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.orange.opacity(0.3),
                                    Color.red.opacity(0.2)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: Color.orange.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

struct ImprovedRestaurantItemsGroup: View {
    let restaurant: Restaurant
    let items: [CartGroupedItem]
    let onUpdateQuantity: (UUID, Bool) -> Void
    let onRemoveItem: (UUID) -> Void
    let onItemTap: (CartGroupedItem) -> Void
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color) {
        Colors.brandColors(for: restaurant.brand)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Заголовок группы ресторана
            HStack {
                Image(restaurant.imageURL)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 32, height: 32)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Text(restaurant.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(items.count) товаров")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(brandColors.primary.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(brandColors.accent.opacity(0.3), lineWidth: 1)
                    )
            )
            
            // Товары ресторана
            VStack(spacing: 8) {
                ForEach(items) { item in
                    ImprovedCartItemRowView(
                        item: item,
                        onUpdateQuantity: onUpdateQuantity,
                        onRemoveItem: onRemoveItem,
                        onItemTap: onItemTap
                    )
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(brandColors.primary.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Детальный просмотр блюда
struct DishDetailSheet: View {
    let dish: Dish
    let restaurant: Restaurant?
    @Environment(\.dismiss) private var dismiss
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color)? {
        guard let restaurant = restaurant else { return nil }
        return Colors.brandColors(for: restaurant.brand)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Изображение блюда
                    Image(dish.image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 250)
                        .clipped()
                        .cornerRadius(16)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Название и цена
                        HStack {
                            Text(dish.name)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text(dish.price.formattedPrice)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(brandColors?.accent ?? .white)
                        }
                        
                        // Описание
                        Text(dish.description)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .lineSpacing(4)
                        
                        // Характеристики
                        HStack(spacing: 24) {
                            CharacteristicView(
                                icon: "flame.fill",
                                title: "Калории",
                                value: "\(dish.calories) ккал",
                                color: .orange
                            )
                            
                            CharacteristicView(
                                icon: "clock.fill",
                                title: "Время",
                                value: "\(dish.preparationTime) мин",
                                color: .blue
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .background(Color.black)
            .navigationTitle("Детали блюда")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

struct CharacteristicView: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Слайдер-кнопка в стиле iPhone
struct SlideToCheckoutButton: View {
    let onCheckout: () -> Void
    
    @State private var dragOffset: CGFloat = 0
    @State private var isCompleted = false
    @State private var showSuccess = false
    
    private let buttonHeight: CGFloat = 60
    
    var body: some View {
        GeometryReader { geometry in
            let maxDragDistance = geometry.size.width - buttonHeight + 8
            
            ZStack {
                // Фон слайдера с нашими цветами
                RoundedRectangle(cornerRadius: buttonHeight / 2)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Colors.appPrimary.opacity(0.2),
                                Colors.appSecondary.opacity(0.1)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: buttonHeight)
                    .overlay(
                        HStack {
                            Spacer()
                            Text("Оформить заказ")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white.opacity(0.8))
                            Spacer()
                        }
                    )
                
                // Прогресс-бар заполнения
                HStack {
                    RoundedRectangle(cornerRadius: buttonHeight / 2)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Colors.appPrimary,
                                    Colors.appAccent
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, dragOffset + buttonHeight - 8), height: buttonHeight - 8)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: dragOffset)
                    
                    Spacer()
                }
                .padding(.horizontal, 4)
                
                // Слайдер-кнопка
                HStack {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Colors.appPrimary,
                                        Colors.appAccent
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: buttonHeight - 8, height: buttonHeight - 8)
                            .shadow(color: Colors.appPrimary.opacity(0.4), radius: 8, x: 0, y: 4)
                        
                        if isCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .scaleEffect(showSuccess ? 1.2 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showSuccess)
                        } else {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .rotationEffect(.degrees((dragOffset / maxDragDistance) * 90.0))
                        }
                    }
                    .offset(x: dragOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if !isCompleted {
                                    let newOffset = min(max(0, value.translation.width), maxDragDistance)
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        dragOffset = newOffset
                                    }
                                }
                            }
                            .onEnded { value in
                                if !isCompleted {
                                    if dragOffset >= maxDragDistance * 0.8 {
                                        // Завершаем слайдер
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                            dragOffset = maxDragDistance
                                            isCompleted = true
                                        }
                                        
                                        // Показываем анимацию успеха
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                                showSuccess = true
                                            }
                                            
                                            // Вызываем действие
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                onCheckout()
                                            }
                                        }
                                    } else {
                                        // Возвращаем в исходное положение
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            dragOffset = 0
                                        }
                                    }
                                }
                            }
                    )
                    
                    Spacer()
                }
                .padding(.horizontal, 4)
            }
        }
        .frame(height: buttonHeight)
        .onAppear {
            // Сброс состояния при появлении
            isCompleted = false
            showSuccess = false
            dragOffset = 0
        }
    }
}

#Preview {
    NavigationView {
        let restaurantService = RestaurantService()
        let cartViewModel = CartViewModel(restaurantService: restaurantService)
        
        return CartView()
            .environmentObject(cartViewModel)
            .environmentObject(restaurantService)
    }
} 