import SwiftUI

struct MenuView: View {
    let restaurant: Restaurant
    @EnvironmentObject private var cartViewModel: CartViewModel
    @State private var selectedCategory: String?
    @State private var searchText = ""
    @State private var showSearchBar = false
    @State private var searchBarOffset: CGFloat = -100
    @State private var categoryOffset: CGFloat = 100
    @State private var dishesOffset: CGFloat = 200
    @State private var showPulse = false
    @State private var showShimmer = false
    @State private var showDatingMode = false // Новое состояние для Dating режима
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color) {
        let colors = Colors.brandColors(for: restaurant.brand)
        // Fallback на дефолтные цвета если что-то не работает
        return (
            primary: colors.primary,
            secondary: colors.secondary,
            accent: colors.accent
        )
    }
    
    private var filteredDishes: [Dish] {
        var dishes = restaurant.menu
        
        if let category = selectedCategory {
            dishes = dishes.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            dishes = dishes.filter { dish in
                dish.name.localizedCaseInsensitiveContains(searchText) ||
                dish.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return dishes
    }
    
    private var categories: [String] {
        let categorySet = Set(restaurant.menu.map { $0.category })
        return Array(categorySet).sorted()
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Грандиозный фон
                GrandMenuBackgroundView(brandColors: brandColors, showPulse: showPulse)
                
                VStack(spacing: 0) {
                    // Грандиозная поисковая панель
                    GrandMenuSearchBarView(
                        searchText: $searchText,
                        showSearchBar: $showSearchBar,
                        offset: searchBarOffset,
                        brandColors: brandColors
                    )
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Большая кнопка Dating Mode
                    VStack(spacing: 8) {
                        Button(action: {
                            showDatingMode = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("Бык Dating")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("🐂")
                                    .font(.system(size: 16))
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
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
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color.white.opacity(0.3),
                                                        Color.clear
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1
                                            )
                                    )
                            )
                            .shadow(color: brandColors.accent.opacity(0.5), radius: 10, x: 0, y: 5)
                        }
                        .scaleEffect(showPulse ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: showPulse)
                        .shadow(color: brandColors.accent.opacity(showPulse ? 0.8 : 0.5), radius: showPulse ? 15 : 10, x: 0, y: showPulse ? 8 : 5)
                        
                        Text("Свайпай блюда как в Tinder!")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    
                    // Грандиозные категории
                    if !categories.isEmpty {
                        GrandCategoriesView(
                            categories: categories,
                            selectedCategory: $selectedCategory,
                            offset: categoryOffset,
                            brandColors: brandColors
                        )
                        .padding(.horizontal)
                        .padding(.top, 16)
                    }
                    
                    // Грандиозный список блюд
                    if filteredDishes.isEmpty {
                        GrandEmptyMenuView(searchText: searchText, brandColors: brandColors)
                    } else {
                        GrandDishesListView(
                            dishes: filteredDishes,
                            brandColors: brandColors,
                            cartItems: cartViewModel.cartItems,
                            offset: dishesOffset,
                            showShimmer: showShimmer,
                            onAddToCart: { dish in
                                let result = cartViewModel.addToCart(dish, from: restaurant)
                                if case .failure(let error) = result {
                                    print("Ошибка добавления в корзину: \(error.localizedDescription)")
                                }
                            },
                            onRemoveFromCart: { dish in
                                _ = cartViewModel.updateQuantity(for: dish.id, increment: false)
                            },
                            restaurantBrand: restaurant.brand
                        )
                    }
                }
            }
            .navigationTitle(restaurant.name)
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.black)
        }
        .background(Color.black)
        .onAppear {
            startGrandAnimations()
        }
        .sheet(isPresented: $showDatingMode) {
            DatingModeView(
                dishes: filteredDishes,
                restaurant: restaurant,
                brandColors: brandColors,
                onAddToCart: { dish in
                    _ = cartViewModel.addToCart(dish, from: restaurant)
                }
            )
        }
    }
    
    private func startGrandAnimations() {
        // Анимация поисковой панели
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1)) {
            searchBarOffset = 0
        }
        
        // Анимация категорий
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.3)) {
            categoryOffset = 0
        }
        
        // Анимация блюд
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.5)) {
            dishesOffset = 0
        }
        
        // Пульсация
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(1.0)) {
            showPulse = true
        }
        
        // Блеск
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(1.5)) {
            showShimmer = true
        }
    }
}

// MARK: - Grand Background View
struct GrandMenuBackgroundView: View {
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let showPulse: Bool
    
    var body: some View {
        ZStack {
            // Основной градиентный фон
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    brandColors.primary.opacity(0.1),
                    brandColors.secondary.opacity(0.05),
                    Color.black
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Плавающие элементы
            ForEach(0..<8, id: \.self) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                brandColors.accent.opacity(0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 50
                        )
                    )
                    .frame(width: CGFloat.random(in: 20...60))
                    .offset(
                        x: CGFloat.random(in: -200...200),
                        y: CGFloat.random(in: -400...400)
                    )
                    .scaleEffect(showPulse ? 1.2 : 1.0)
                    .animation(
                        .easeInOut(duration: Double.random(in: 2...4))
                        .repeatForever(autoreverses: true)
                        .delay(Double.random(in: 0...2)),
                        value: showPulse
                    )
            }
        }
    }
}

// MARK: - Grand Menu Search Bar View
struct GrandMenuSearchBarView: View {
    @Binding var searchText: String
    @Binding var showSearchBar: Bool
    let offset: CGFloat
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(brandColors.accent)
                
                TextField("Поиск блюд...", text: $searchText)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(brandColors.accent)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
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
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        brandColors.accent.opacity(0.5),
                                        brandColors.primary.opacity(0.3)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
        }
        .offset(y: offset)
    }
}

// MARK: - Grand Categories View
struct GrandCategoriesView: View {
    let categories: [String]
    @Binding var selectedCategory: String?
    let offset: CGFloat
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                GrandCategoryButton(
                    title: "Все",
                    isSelected: selectedCategory == nil,
                    brandColors: brandColors
                ) {
                    selectedCategory = nil
                }
                
                ForEach(categories, id: \.self) { category in
                    GrandCategoryButton(
                        title: category,
                        isSelected: selectedCategory == category,
                        brandColors: brandColors
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .offset(y: offset)
    }
}

// MARK: - Grand Category Button
struct GrandCategoryButton: View {
    let title: String
    let isSelected: Bool
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
                action()
            }
        }) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(isSelected ? .white : brandColors.accent)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            isSelected ?
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    brandColors.accent,
                                    brandColors.primary
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    brandColors.primary.opacity(0.1),
                                    brandColors.secondary.opacity(0.05)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    isSelected ?
                                    brandColors.accent.opacity(0.8) :
                                    brandColors.accent.opacity(0.3),
                                    lineWidth: isSelected ? 2 : 1
                                )
                        )
                )
                .shadow(
                    color: isSelected ? brandColors.accent.opacity(0.5) : Color.clear,
                    radius: isSelected ? 8 : 0,
                    x: 0,
                    y: 4
                )
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
    }
}

// MARK: - Grand Empty Menu View
struct GrandEmptyMenuView: View {
    let searchText: String
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(spacing: 24) {
            // Анимированная иконка
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                brandColors.accent.opacity(0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: searchText.isEmpty ? "fork.knife" : "magnifyingglass")
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(brandColors.accent)
            }
            
            VStack(spacing: 12) {
                Text(searchText.isEmpty ? "Меню пусто" : "Ничего не найдено")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text(searchText.isEmpty ? "В этом ресторане пока нет блюд" : "Попробуйте изменить поисковый запрос")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

// MARK: - Grand Dishes List View
struct GrandDishesListView: View {
    let dishes: [Dish]
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let cartItems: [UUID: Int]
    let offset: CGFloat
    let showShimmer: Bool
    let onAddToCart: (Dish) -> Void
    let onRemoveFromCart: (Dish) -> Void
    let restaurantBrand: Restaurant.Brand
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(Array(dishes.enumerated()), id: \.element.id) { index, dish in
                    GrandDishCard(
                        dish: dish,
                        quantity: cartItems[dish.id] ?? 0,
                        brandColors: brandColors,
                        restaurantBrand: restaurantBrand,
                        showShimmer: showShimmer,
                        onAdd: { onAddToCart(dish) },
                        onRemove: { onRemoveFromCart(dish) }
                    )
                    .offset(y: offset)
                    .animation(
                        .spring(response: 0.8, dampingFraction: 0.7)
                        .delay(Double(index) * 0.1),
                        value: offset
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .background(Color.black)
    }
}

// MARK: - Grand Dish Card
struct GrandDishCard: View {
    let dish: Dish
    let quantity: Int
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let restaurantBrand: Restaurant.Brand
    let showShimmer: Bool
    let onAdd: () -> Void
    let onRemove: () -> Void
    @State private var showDetail = false
    @State private var isPressed = false
    @State private var animateToCart = false
    @Namespace private var animation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Картинка блюда
            ZStack(alignment: .topTrailing) {
                Image(dish.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 140)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .cornerRadius(12, corners: [.topLeft, .topRight])
                    .opacity(animateToCart ? 0 : 1)
                
                // Индикатор количества
                if quantity > 0 {
                    Text("\(max(0, quantity))")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .frame(minWidth: 20, minHeight: 20)
                        .background(
                            Circle()
                                .fill(brandColors.accent)
                        )
                        .padding(8)
                }
            }
            
            // Информационная секция
            VStack(alignment: .leading, spacing: 8) {
                // Название блюда
                Text(dish.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack(alignment: .center) {
                    // Цена
                    Text(dish.price.formattedPrice)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(brandColors.accent)
                    
                    Spacer()
                    
                    // Кнопки управления
                    HStack(spacing: 6) {
                        if quantity > 0 {
                            Button(action: onRemove) {
                                Image(systemName: "minus")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(width: 24, height: 24)
                                    .background(
                                        Circle()
                                            .fill(brandColors.accent.opacity(0.8))
                                    )
                            }
                        }
                        
                        Button(action: onAdd) {
                            Image(systemName: "plus")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 24, height: 24)
                                .background(
                                    Circle()
                                        .fill(brandColors.accent)
                                )
                        }
                    }
                }
            }
            .padding(12)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.black.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isPressed)
        .onTapGesture {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isPressed = true
                showDetail = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isPressed = false
            }
        }
        .sheet(isPresented: $showDetail) {
            SimpleDishDetailView(dish: dish, brand: restaurantBrand, quantity: quantity, onAdd: onAdd, onRemove: onRemove)
        }
    }
}

// Кастомный модификатор для анимации "падения" в корзину
struct FlyToCartAnimation: ViewModifier {
    @State private var fly = false
    func body(content: Content) -> some View {
        content
            .offset(x: fly ? 120 : 0, y: fly ? -220 : 0)
            .scaleEffect(fly ? 0.1 : 1.0)
            .opacity(fly ? 0 : 1)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.7)) {
                    fly = true
                }
            }
    }
}

// MARK: - Grand Action Button
struct GrandActionButton: View {
    let icon: String
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
                action()
            }
        }) {
            Image(systemName: "\(icon).circle.fill")
                .font(.system(size: 28))
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            brandColors.accent,
                            brandColors.primary
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: brandColors.accent.opacity(0.5), radius: 4, x: 0, y: 2)
        }
        .scaleEffect(isPressed ? 0.9 : 1.0)
    }
}

// MARK: - Grand Add Button
struct GrandAddButton: View {
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
                action()
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .bold))
                Text("Добавить")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
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
            )
            .shadow(color: brandColors.accent.opacity(0.5), radius: 8, x: 0, y: 4)
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
    }
}

// MARK: - Grand Cart Button
struct GrandCartButton: View {
    let cartViewModel: CartViewModel
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    @State private var isPressed = false
    
    var body: some View {
        NavigationLink(destination: CartView()) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                brandColors.accent.opacity(0.2),
                                brandColors.primary.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        brandColors.accent.opacity(0.8),
                                        brandColors.primary.opacity(0.6)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                
                Image(systemName: "cart")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(brandColors.accent)
                
                if cartViewModel.totalItems > 0 {
                    Text("\(cartViewModel.totalItems)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 20, height: 20)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.red,
                                    Color.orange
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(Circle())
                        .offset(x: 15, y: -15)
                        .shadow(color: Color.red.opacity(0.5), radius: 4, x: 0, y: 2)
                }
            }
        }
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }
    }
}

// MARK: - Dating Mode Button
struct DatingModeButton: View {
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let action: () -> Void
    @State private var isPressed = false
    @State private var showPulse = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
                action()
            }
        }) {
            ZStack {
                // Пульсирующий фон
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                brandColors.accent.opacity(showPulse ? 0.4 : 0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 30
                        )
                    )
                    .frame(width: 44, height: 44)
                
                // Основная кнопка
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
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.3),
                                        Color.clear
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                
                // Иконка сердца
                Image(systemName: "heart.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
            }
        }
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .shadow(color: brandColors.accent.opacity(0.5), radius: 8, x: 0, y: 4)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                showPulse = true
            }
        }
    }
}

// MARK: - Dating Mode View
struct DatingModeView: View {
    let dishes: [Dish]
    let restaurant: Restaurant
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let onAddToCart: (Dish) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var currentIndex = 0
    @State private var offset: CGSize = .zero
    @State private var showFilters = false
    @State private var selectedCategories: Set<String> = []
    @State private var maxPrice: Double = 1000
    @State private var showSuccess = false
    @State private var likedDishes: [Dish] = []
    
    private var filteredDishes: [Dish] {
        var filtered = dishes
        
        if !selectedCategories.isEmpty {
            filtered = filtered.filter { selectedCategories.contains($0.category) }
        }
        
        filtered = filtered.filter { $0.price <= maxPrice }
        
        return filtered
    }
    
    var body: some View {
        ZStack {
            // Фон с анимированными элементами
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        brandColors.primary.opacity(0.1),
                        Color.black
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Плавающие сердца
                ForEach(0..<6, id: \.self) { index in
                    Text("🐂")
                        .font(.system(size: CGFloat.random(in: 20...40)))
                        .opacity(0.3)
                        .offset(
                            x: CGFloat.random(in: -150...150),
                            y: CGFloat.random(in: -300...300)
                        )
                        .animation(
                            .easeInOut(duration: Double.random(in: 3...6))
                            .repeatForever(autoreverses: true)
                            .delay(Double.random(in: 0...2)),
                            value: UUID()
                        )
                }
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Заголовок
                DatingHeaderView(
                    brandColors: brandColors,
                    onClose: { dismiss() },
                    onFilters: { showFilters = true }
                )
                
                if filteredDishes.isEmpty {
                    // Пустое состояние
                    DatingEmptyView(brandColors: brandColors)
                } else if currentIndex >= filteredDishes.count {
                    // Все блюда просмотрены
                    DatingCompleteView(
                        likedDishes: likedDishes,
                        brandColors: brandColors,
                        onClose: { dismiss() }
                    )
                } else {
                    // Карточка блюда
                    DatingDishCard(
                        dish: filteredDishes[currentIndex],
                        offset: $offset,
                        brandColors: brandColors,
                        onSwipe: { direction in
                            handleSwipe(direction: direction)
                        }
                    )
                }
                
                // Кнопки действий
                if !filteredDishes.isEmpty && currentIndex < filteredDishes.count {
                    DatingActionButtons(
                        brandColors: brandColors,
                        onDislike: { handleSwipe(direction: .left) },
                        onLike: { handleSwipe(direction: .right) }
                    )
                    .padding(.bottom, 40)
                }
            }
        }
        .sheet(isPresented: $showFilters) {
            DatingFiltersView(
                categories: Set(dishes.map { $0.category }),
                selectedCategories: $selectedCategories,
                maxPrice: $maxPrice,
                brandColors: brandColors
            )
        }
        .overlay(
            // Уведомление о добавлении в корзину
            Group {
                if showSuccess {
                    DatingSuccessNotification(brandColors: brandColors)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        )
    }
    
    private func handleSwipe(direction: SwipeDirection) {
        let dish = filteredDishes[currentIndex]
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            offset = direction == .right ? CGSize(width: 500, height: 0) : CGSize(width: -500, height: 0)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if direction == .right {
                // Добавляем в корзину
                onAddToCart(dish)
                likedDishes.append(dish)
                
                // Показываем уведомление
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    showSuccess = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        showSuccess = false
                    }
                }
            }
            
            // Переходим к следующему блюду
            currentIndex += 1
            offset = .zero
        }
    }
}

// MARK: - Swipe Direction
enum SwipeDirection {
    case left, right
}

// MARK: - Dating Header View
struct DatingHeaderView: View {
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let onClose: () -> Void
    let onFilters: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(brandColors.accent)
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                HStack(spacing: 8) {
                    Text("🐂")
                        .font(.system(size: 20))
                    
                    Text("Бык Dating")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text("Свайпай блюда как в Tinder!")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Button(action: onFilters) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 20))
                    .foregroundColor(brandColors.accent)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 30)
    }
}

// MARK: - Dating Dish Card
struct DatingDishCard: View {
    let dish: Dish
    @Binding var offset: CGSize
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let onSwipe: (SwipeDirection) -> Void
    
    @State private var showLike = false
    @State private var showDislike = false
    
    var body: some View {
        ZStack {
            // Карточка блюда
            VStack(spacing: 0) {
                // Изображение с градиентным оверлеем
                ZStack(alignment: .bottomLeading) {
                    Image(dish.image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 240)
                        .frame(maxWidth: .infinity)
                        .clipped()
                    
                    // Градиентный оверлей
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color.black.opacity(0.3),
                            Color.black.opacity(0.7)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 240)
                    
                    // Информация поверх изображения
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(dish.name)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: Color.black.opacity(0.8), radius: 4, x: 0, y: 2)
                            
                            Spacer()
                            
                            Text(dish.price.formattedPrice)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(brandColors.accent)
                                .shadow(color: Color.black.opacity(0.8), radius: 4, x: 0, y: 2)
                        }
                        
                        Text(dish.description)
                            .font(.system(size: 15))
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(2)
                            .shadow(color: Color.black.opacity(0.8), radius: 4, x: 0, y: 2)
                    }
                    .padding(20)
                }
                
                // Дополнительная информация
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(dish.category)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(brandColors.accent)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(brandColors.accent.opacity(0.15))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(brandColors.accent.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        
                        Spacer()
                        
                        // Иконка быка
                        Text("🐂")
                            .font(.system(size: 16))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .frame(maxWidth: .infinity, maxHeight: 320)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.black.opacity(0.9),
                                Color.black.opacity(0.7)
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
                                        brandColors.accent.opacity(0.6),
                                        brandColors.primary.opacity(0.4),
                                        brandColors.accent.opacity(0.3)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
            )
            .shadow(color: Color.black.opacity(0.5), radius: 20, x: 0, y: 10)
            .offset(offset)
            .rotationEffect(.degrees(Double(offset.width / 20)))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        offset = value.translation
                        
                        // Показываем индикаторы
                        if offset.width > 50 {
                            showLike = true
                            showDislike = false
                        } else if offset.width < -50 {
                            showDislike = true
                            showLike = false
                        } else {
                            showLike = false
                            showDislike = false
                        }
                    }
                    .onEnded { value in
                        let threshold: CGFloat = 100
                        
                        if value.translation.width > threshold {
                            onSwipe(.right)
                        } else if value.translation.width < -threshold {
                            onSwipe(.left)
                        } else {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                offset = .zero
                                showLike = false
                                showDislike = false
                            }
                        }
                    }
            )
            
            // Индикаторы свайпа
            if showLike {
                VStack(spacing: 8) {
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
                            .frame(width: 60, height: 60)
                            .shadow(color: brandColors.accent.opacity(0.6), radius: 15, x: 0, y: 8)
                        
                        Text("🐂")
                            .font(.system(size: 24))
                    }
                    
                    Text("В корзину!")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.8), radius: 4, x: 0, y: 2)
                }
                .offset(x: 70, y: -80)
                .transition(.scale.combined(with: .opacity))
            }
            
            if showDislike {
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.9))
                            .frame(width: 60, height: 60)
                            .shadow(color: Color.red.opacity(0.6), radius: 15, x: 0, y: 8)
                        
                        Image(systemName: "xmark")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Text("Пропустить")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.8), radius: 4, x: 0, y: 2)
                }
                .offset(x: -70, y: -80)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 20)
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: showLike)
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: showDislike)
    }
}

// MARK: - Dating Action Buttons
struct DatingActionButtons: View {
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let onDislike: () -> Void
    let onLike: () -> Void
    
    @State private var likePressed = false
    @State private var dislikePressed = false
    
    var body: some View {
        HStack(spacing: 40) {
            // Кнопка "Не нравится"
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    dislikePressed = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    dislikePressed = false
                    onDislike()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.red.opacity(0.3),
                                    Color.red.opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.red,
                                            Color.red.opacity(0.7)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 3
                                )
                        )
                        .shadow(color: Color.red.opacity(0.4), radius: 10, x: 0, y: 5)
                    
                    Image(systemName: "xmark")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.red)
                }
            }
            .scaleEffect(dislikePressed ? 0.9 : 1.0)
            
            // Кнопка "Нравится"
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    likePressed = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    likePressed = false
                    onLike()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    brandColors.accent,
                                    brandColors.primary,
                                    brandColors.accent.opacity(0.8)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)
                        .shadow(color: brandColors.accent.opacity(0.6), radius: 15, x: 0, y: 8)
                    
                    Text("🐂")
                        .font(.system(size: 28))
                }
            }
            .scaleEffect(likePressed ? 0.9 : 1.0)
        }
    }
}

// MARK: - Dating Filters View
struct DatingFiltersView: View {
    let categories: Set<String>
    @Binding var selectedCategories: Set<String>
    @Binding var maxPrice: Double
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Заголовок
                    Text("Фильтры Бык Dating")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    ScrollView {
                        VStack(spacing: 32) {
                            // Категории
                            DatingCategorySection(
                                categories: Array(categories),
                                selectedCategories: $selectedCategories,
                                brandColors: brandColors
                            )
                            
                            // Максимальная цена
                            DatingPriceSection(
                                maxPrice: $maxPrice,
                                brandColors: brandColors
                            )
                            
                            // Кнопки действий
                            DatingFilterActions(
                                brandColors: brandColors,
                                onReset: {
                                    selectedCategories.removeAll()
                                    maxPrice = 1000
                                },
                                onApply: {
                                    dismiss()
                                }
                            )
                        }
                        .padding(24)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Dating Category Section
struct DatingCategorySection: View {
    let categories: [String]
    @Binding var selectedCategories: Set<String>
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Заголовок секции
            HStack {
                Image(systemName: "tag.fill")
                    .font(.system(size: 20))
                    .foregroundColor(brandColors.accent)
                
                Text("Категории блюд")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(selectedCategories.count)/\(categories.count)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            // Сетка категорий
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(categories, id: \.self) { category in
                    DatingCategoryCard(
                        category: category,
                        isSelected: selectedCategories.contains(category),
                        brandColors: brandColors
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if selectedCategories.contains(category) {
                                selectedCategories.remove(category)
                            } else {
                                selectedCategories.insert(category)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Dating Category Card
struct DatingCategoryCard: View {
    let category: String
    let isSelected: Bool
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let action: () -> Void
    
    private var categoryIcon: String {
        switch category.lowercased() {
        case let c where c.contains("стейк"): return "flame.fill"
        case let c where c.contains("салат"): return "leaf.fill"
        case let c where c.contains("суп"): return "cup.and.saucer.fill"
        case let c where c.contains("десерт"): return "birthday.cake.fill"
        case let c where c.contains("напиток"): return "wineglass.fill"
        case let c where c.contains("пицца"): return "circle.fill"
        case let c where c.contains("паста"): return "fork.knife"
        case let c where c.contains("закуск"): return "tray.fill"
        default: return "fork.knife"
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Иконка
                ZStack {
                    Circle()
                        .fill(
                            isSelected ?
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    brandColors.accent,
                                    brandColors.primary
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    brandColors.primary.opacity(0.2),
                                    brandColors.secondary.opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: categoryIcon)
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? .white : brandColors.accent)
                }
                
                // Название
                Text(category)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        isSelected ?
                        AnyShapeStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    brandColors.accent.opacity(0.2),
                                    brandColors.primary.opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        ) :
                        AnyShapeStyle(Color.white.opacity(0.05))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ?
                                brandColors.accent.opacity(0.5) :
                                Color.white.opacity(0.1),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Dating Price Section
struct DatingPriceSection: View {
    @Binding var maxPrice: Double
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Заголовок секции
            HStack {
                Image(systemName: "rublesign.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(brandColors.accent)
                
                Text("Максимальная цена")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            VStack(spacing: 16) {
                // Слайдер
                VStack(spacing: 8) {
                    Slider(
                        value: $maxPrice,
                        in: 100...2000,
                        step: 50
                    ) {
                        Text("Цена")
                    } minimumValueLabel: {
                        Text("100₽")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    } maximumValueLabel: {
                        Text("2000₽")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .accentColor(brandColors.accent)
                    
                    // Текущая цена
                    Text("\(Int(maxPrice)) ₽")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(brandColors.accent)
                        .padding(.top, 8)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(brandColors.accent.opacity(0.3), lineWidth: 1)
                        )
                )
            }
        }
    }
}

// MARK: - Dating Filter Actions
struct DatingFilterActions: View {
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let onReset: () -> Void
    let onApply: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Кнопка сброса
            Button(action: onReset) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .medium))
                    
                    Text("Сбросить фильтры")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(brandColors.accent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(brandColors.accent, lineWidth: 2)
                )
            }
            
            // Кнопка применения
            Button(action: onApply) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                    
                    Text("Применить фильтры")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
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
                )
            }
        }
    }
}

// MARK: - Dating Empty View
struct DatingEmptyView: View {
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(spacing: 24) {
            Text("🐂❌")
                .font(.system(size: 80))
            
            Text("Нет блюд по фильтрам")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Text("Попробуйте изменить фильтры")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Dating Complete View
struct DatingCompleteView: View {
    let likedDishes: [Dish]
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Text("🐂")
                .font(.system(size: 80))
            
            VStack(spacing: 12) {
                Text("Отлично!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Вы выбрали \(likedDishes.count) блюд")
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            if !likedDishes.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Выбранные блюда:")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    ForEach(likedDishes.prefix(3), id: \.id) { dish in
                        HStack {
                            Text("• \(dish.name)")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.8))
                            
                            Spacer()
                            
                            Text(dish.price.formattedPrice)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(brandColors.accent)
                        }
                    }
                    
                    if likedDishes.count > 3 {
                        Text("...и еще \(likedDishes.count - 3) блюд")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.black.opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(brandColors.accent.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            
            Button("Перейти в корзину") {
                onClose()
            }
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
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
            )
            .shadow(color: brandColors.accent.opacity(0.5), radius: 10, x: 0, y: 5)
        }
        .padding(20)
    }
}

// MARK: - Dating Success Notification
struct DatingSuccessNotification: View {
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        HStack(spacing: 12) {
            Text("🐂")
                .font(.system(size: 20))
            
            Text("Добавлено в корзину!")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
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
        )
        .shadow(color: brandColors.accent.opacity(0.5), radius: 10, x: 0, y: 5)
        .padding(.top, 100)
    }
}



#Preview {
    MenuView(restaurant: Restaurant.mock)
        .environmentObject(CartViewModel(restaurantService: RestaurantService()))
} 