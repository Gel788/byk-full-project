import SwiftUI

struct MenuListView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    @StateObject private var menuService = MenuService()
    @State private var selectedBrand: Restaurant.Brand? = nil
    @State private var selectedCategories: Set<String> = []
    @State private var searchText = ""
    @State private var selectedDish: Dish?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Красивый темный фон
                LinearGradient(
                    colors: [Color.black, Color.gray.opacity(0.1)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Поиск
                    MenuSearchSection(searchText: $searchText)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    
                    // Фильтры брендов
                    MenuBrandFilterSection(selectedBrand: $selectedBrand)
                        .padding(.vertical, 12)
                    
                    // Фильтры категорий
                    if !availableCategories.isEmpty {
                        MenuCategoryFilterSection(
                            availableCategories: availableCategories,
                            selectedCategories: $selectedCategories
                        )
                        .padding(.bottom, 12)
                    }
                    
                    // Сетка блюд с квадратными карточками
                    if filteredDishes.isEmpty {
                        MenuEmptyState()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 16) {
                                ForEach(filteredDishes) { dish in
                                    DishCard(dish: dish) {
                                        selectedDish = dish
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 100)
                        }
                    }
                }
            }
            .navigationTitle("Меню")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: Binding<Bool>(
                get: { selectedDish != nil },
                set: { if !$0 { selectedDish = nil } }
            )) {
                if let dish = selectedDish {
                    DishDetailView(dish: dish)
                }
            }
            .refreshable {
                await menuService.loadMenuFromAPI()
            }
            .onAppear {
                print("🛒 MenuListView: onAppear вызван")
                print("🛒 MenuListView: CartViewModel доступен = \(cartViewModel != nil)")
                print("🛒 MenuListView: Текущее количество в корзине = \(cartViewModel.totalItems)")
                
                if menuService.dishes.isEmpty {
                    Task {
                        await menuService.loadMenuFromAPI()
                    }
                }
            }
        }
    }
    
    private var filteredDishes: [Dish] {
        var dishes = menuService.dishes
        
        // Фильтр по бренду
        if let brand = selectedBrand {
            dishes = dishes.filter { $0.restaurantBrand == brand }
        }
        
        // Фильтр по категориям
        if !selectedCategories.isEmpty {
            dishes = dishes.filter { selectedCategories.contains($0.category) }
        }
        
        // Фильтр по поиску
        if !searchText.isEmpty {
            dishes = dishes.filter { dish in
                dish.name.localizedCaseInsensitiveContains(searchText) ||
                dish.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return dishes
    }
    
    private var availableCategories: [String] {
        let categorySet = Set(menuService.dishes.map { $0.category })
        return Array(categorySet).sorted()
    }
}

// MARK: - Красивый DishDetailView
struct DishDetailView: View {
    let dish: Dish
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var cartViewModel: CartViewModel
    @State private var showPulse = false
    @State private var isAnimating = false
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color) {
        let colors = Colors.brandColors(for: dish.restaurantBrand)
        return (
            primary: colors.primary,
            secondary: colors.secondary,
            accent: colors.accent
        )
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Красивый градиентный фон
                LinearGradient(
                    colors: [Color.black, brandColors.primary.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Большое изображение блюда
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 300)
                            
                            AsyncImage(url: URL(string: dish.image)) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxHeight: 300)
                                case .failure(_):
                                    Image(systemName: "photo")
                                        .font(.system(size: 60))
                                        .foregroundColor(.gray)
                                case .empty:
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: brandColors.accent))
                                        .scaleEffect(1.5)
                                @unknown default:
                                    Image(systemName: "photo")
                                        .font(.system(size: 60))
                                        .foregroundColor(.gray)
                                }
                            }
                            .frame(height: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            
                            // Градиентный оверлей для красоты
                            LinearGradient(
                                colors: [Color.clear, Color.black.opacity(0.3)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                        .padding(.horizontal, 20)
                        .scaleEffect(isAnimating ? 1.0 : 0.9)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .animation(.spring(response: 0.8, dampingFraction: 0.8), value: isAnimating)
                        
                        VStack(alignment: .leading, spacing: 20) {
                            // Название и цена
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(dish.name)
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    Text(dish.restaurantBrand.displayName)
                                        .font(.subheadline)
                                        .foregroundColor(brandColors.accent)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("\(Int(dish.price)) ₽")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    Text("за порцию")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            // Описание
                            Text(dish.description)
                                .font(.body)
                                .foregroundColor(.gray)
                                .lineLimit(nil)
                            
                            // Кнопка добавления в корзину
                            Button(action: {
                                let tempRestaurant = Restaurant(
                                    name: dish.restaurantBrand.rawValue,
                                    description: "Temporary restaurant for cart",
                                    address: "Temp Address",
                                    city: "Moscow",
                                    imageURL: "94033",
                                    rating: 4.5,
                                    cuisine: "Mixed",
                                    deliveryTime: 30,
                                    brand: dish.restaurantBrand,
                                    menu: [],
                                    features: [],
                                    workingHours: WorkingHours(openTime: "10:00", closeTime: "22:00", weekdays: Set(WorkingHours.Weekday.allCases)),
                                    location: Location(latitude: 55.7558, longitude: 37.6176),
                                    tables: [],
                                    gallery: [],
                                    contacts: ContactInfo(),
                                    averageCheck: 1500,
                                    atmosphere: ["Casual"]
                                )
                                
                                _ = cartViewModel.addToCart(dish, from: tempRestaurant)
                                HapticManager.shared.successPattern()
                                
                                // Анимация пульса
                                withAnimation(.easeInOut(duration: 0.6)) {
                                    showPulse = true
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                    withAnimation(.easeInOut(duration: 0.6)) {
                                        showPulse = false
                                    }
                                }
                                
                                // Закрываем через секунду
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                    dismiss()
                                }
                            }) {
                                HStack {
                                    Image(systemName: "cart.fill")
                                        .font(.title2)
                                    Text("Добавить в корзину за \(Int(dish.price)) ₽")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(
                                            LinearGradient(
                                                colors: [brandColors.accent, brandColors.primary],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                )
                                .scaleEffect(showPulse ? 1.05 : 1.0)
                                .animation(.easeInOut(duration: 0.6), value: showPulse)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2)) {
                    isAnimating = true
                }
            }
        }
    }
}

#Preview {
    MenuListView()
        .environmentObject(CartViewModel(restaurantService: RestaurantService(), menuService: MenuService()))
}