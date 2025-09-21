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
    @State private var showDatingMode = false
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color) {
        let colors = Colors.brandColors(for: restaurant.brand)
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
                // Фон
                MenuBackgroundView(
                    restaurant: restaurant,
                    showShimmer: $showShimmer
                )
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Поиск
                        MenuSearchBarView(
                            searchText: $searchText,
                            showSearchBar: $showSearchBar,
                            searchBarOffset: $searchBarOffset,
                            brandColors: brandColors
                        )
                        .padding(.top, 20)
                        
                        // Категории
                        MenuCategoriesView(
                            categories: categories,
                            selectedCategory: $selectedCategory,
                            categoryOffset: $categoryOffset,
                            brandColors: brandColors
                        )
                        .padding(.top, 20)
                        
                        // Список блюд
                        if filteredDishes.isEmpty {
                            MenuEmptyView(brandColors: brandColors)
                                .frame(height: 300)
                        } else {
                            MenuDishesListView(
                                filteredDishes: filteredDishes,
                                restaurant: restaurant,
                                brandColors: brandColors,
                                dishesOffset: $dishesOffset
                            )
                            .padding(.top, 20)
                        }
                        
                        // Отступ снизу
                        Color.clear.frame(height: 100)
                    }
                }
                
                // Кнопка Dating режима (если нужно)
                if showDatingMode {
                    DatingModeButton()
                        .padding(.bottom, 100)
                }
            }
            .navigationTitle(restaurant.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showDatingMode.toggle()
                    }) {
                        Image(systemName: showDatingMode ? "heart.fill" : "heart")
                            .foregroundColor(brandColors.accent)
                    }
                }
            }
            .onAppear {
                startAnimations()
            }
        }
    }
    
    private func startAnimations() {
        // Анимация появления элементов
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                searchBarOffset = 0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                categoryOffset = 0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
                dishesOffset = 0
            }
        }
        
        // Shimmer эффект
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 0.5)) {
                showShimmer = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showShimmer = false
                }
            }
        }
    }
}

struct DatingModeButton: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack {
            Spacer()
            
            Button(action: {
                // Логика Dating режима
            }) {
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.white)
                    Text("Dating Mode")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.pink)
                )
            }
            .scaleEffect(isAnimating ? 1.1 : 1.0)
            .animation(
                Animation.easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
        }
    }
}

#Preview {
    MenuView(restaurant: Restaurant(
        id: UUID(),
        name: "Тестовый ресторан",
        description: "Описание",
        address: "Адрес",
        city: "Город",
        imageURL: "",
        rating: 4.5,
        cuisine: "Кухня",
        deliveryTime: 45,
        brand: .theByk,
        menu: [],
        features: [],
        workingHours: WorkingHours.default,
        location: Location(latitude: 0, longitude: 0),
        tables: [],
        gallery: []
    ))
    .environmentObject(CartViewModel(restaurantService: RestaurantService(), menuService: MenuService()))
}
