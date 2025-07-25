import SwiftUI
import CoreLocation

struct MenuListView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var restaurantService: RestaurantService
    @State private var selectedBrand: Restaurant.Brand? = nil
    @State private var selectedCategories: Set<String> = []
    @State private var searchText = ""
    @State private var selectedDish: Dish?
    @State private var showDatingMode = false
    @State private var showProfile = false
    
    private var filteredDishes: [Dish] {
        let allDishes = restaurantService.restaurants.flatMap { $0.menu }
        let brandFiltered = selectedBrand == nil ? allDishes : allDishes.filter { $0.restaurantBrand == selectedBrand }
        let categoryFiltered = selectedCategories.isEmpty ? brandFiltered : brandFiltered.filter { selectedCategories.contains($0.category) }
        let searchFiltered = searchText.isEmpty ? categoryFiltered : categoryFiltered.filter { 
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
        return searchFiltered
    }
    
    private var availableCategories: [String] {
        let allDishes = restaurantService.restaurants.flatMap { $0.menu }
        let brandFiltered = selectedBrand == nil ? allDishes : allDishes.filter { $0.restaurantBrand == selectedBrand }
        let categories = Set(brandFiltered.map { $0.category })
        return Array(categories).sorted()
    }
    
    private var groupedDishes: [Restaurant.Brand: [String: [Dish]]] {
        let dishesByBrand = Dictionary(grouping: filteredDishes) { $0.restaurantBrand }
        var result: [Restaurant.Brand: [String: [Dish]]] = [:]
        
        for (brand, dishes) in dishesByBrand {
            result[brand] = Dictionary(grouping: dishes) { $0.category }
        }
        
        return result
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Поиск и фильтры
                VStack(spacing: 16) {
                    // Поиск
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Поиск блюд...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Фильтры брендов
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            // Кнопка "Все"
                            Button(action: {
                                HapticManager.shared.buttonPress()
                                selectedBrand = nil
                            }) {
                                Text("Все")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(selectedBrand == nil ? 
                                                AnyShapeStyle(LinearGradient(
                                                    colors: [Color("BykAccent"), Color("BykPrimary")],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )) : 
                                                AnyShapeStyle(Color(.systemGray5))
                                            )
                                    )
                                    .foregroundColor(selectedBrand == nil ? .white : .primary)
                            }
                            
                            // Фильтры по брендам
                            ForEach(Restaurant.Brand.allCases, id: \.self) { brand in
                                let brandColors = Colors.brandColors(for: brand)
                                Button(action: {
                                    HapticManager.shared.buttonPress()
                                    selectedBrand = brand
                                }) {
                                    Text(brand.displayName)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(selectedBrand == brand ? 
                                                    AnyShapeStyle(LinearGradient(
                                                        colors: [brandColors.accent, brandColors.primary],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )) : 
                                                    AnyShapeStyle(Color(.systemGray5))
                                                )
                                        )
                                        .foregroundColor(selectedBrand == brand ? .white : .primary)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    // Фильтры категорий
                    if !availableCategories.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                // Кнопка "Все категории"
                                Button(action: {
                                    HapticManager.shared.buttonPress()
                                    selectedCategories.removeAll()
                                }) {
                                    Text("Все категории")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(selectedCategories.isEmpty ? 
                                                    AnyShapeStyle(LinearGradient(
                                                        colors: [Color("BykAccent"), Color("BykPrimary")],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )) : 
                                                    AnyShapeStyle(Color(.systemGray5))
                                                )
                                        )
                                        .foregroundColor(selectedCategories.isEmpty ? .white : .primary)
                                }
                                
                                // Фильтры по категориям
                                ForEach(availableCategories, id: \.self) { category in
                                    Button(action: {
                                        HapticManager.shared.buttonPress()
                                        if selectedCategories.contains(category) {
                                            selectedCategories.remove(category)
                                        } else {
                                            selectedCategories.insert(category)
                                        }
                                    }) {
                                        Text(category)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .fill(selectedCategories.contains(category) ? 
                                                        AnyShapeStyle(LinearGradient(
                                                            colors: [Color("BykAccent"), Color("BykPrimary")],
                                                            startPoint: .leading,
                                                            endPoint: .trailing
                                                        )) : 
                                                        AnyShapeStyle(Color(.systemGray5))
                                                    )
                                            )
                                            .foregroundColor(selectedCategories.contains(category) ? .white : .primary)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    
                    // Кнопка Бык Dating
                    VStack(spacing: 8) {
                        Button(action: {
                            HapticManager.shared.buttonPress()
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
                                                Color("BykAccent"),
                                                Color("BykPrimary")
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
                            .shadow(color: Color("BykAccent").opacity(0.5), radius: 10, x: 0, y: 5)
                        }
                        
                        Text("Свайпай блюда как в Tinder!")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                // Список блюд по разделам
                ScrollView {
                    LazyVStack(spacing: 24) {
                        ForEach(Array(groupedDishes.keys.sorted(by: { $0.displayName < $1.displayName })), id: \.self) { brand in
                            if let categories = groupedDishes[brand], !categories.isEmpty {
                                VStack(alignment: .leading, spacing: 20) {
                                    // Заголовок бренда
                                    HStack {
                                        let brandColors = Colors.brandColors(for: brand)
                                        Text(brand.displayName)
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: [brandColors.accent, brandColors.primary],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                        
                                        Spacer()
                                        
                                        let totalDishes = categories.values.flatMap { $0 }.count
                                        Text("\(totalDishes) блюд")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 8)
                                    
                                    // Категории внутри бренда
                                    ForEach(Array(categories.keys.sorted()), id: \.self) { category in
                                        if let dishes = categories[category], !dishes.isEmpty {
                                            VStack(alignment: .leading, spacing: 12) {
                                                // Заголовок категории
                                                HStack {
                                                    Text(category)
                                                        .font(.headline)
                                                        .fontWeight(.semibold)
                                                        .foregroundColor(.primary)
                                                    
                                                    Spacer()
                                                    
                                                    Text("\(dishes.count)")
                                                        .font(.subheadline)
                                                        .foregroundColor(.secondary)
                                                }
                                                .padding(.horizontal, 20)
                                                
                                                // Сетка блюд для этой категории
                                                LazyVGrid(columns: [
                                                    GridItem(.flexible(), spacing: 16),
                                                    GridItem(.flexible(), spacing: 16)
                                                ], spacing: 16) {
                                                    ForEach(dishes, id: \.id) { dish in
                                                        DishCard(
                                                            dish: dish,
                                                            onTap: {
                                                                selectedDish = dish
                                                            }
                                                        )
                                                    }
                                                }
                                                .padding(.horizontal, 20)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Меню")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        HapticManager.shared.buttonPress()
                        showProfile = true
                    }) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color("BykAccent"), Color("BykPrimary")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
            }
        }
        .sheet(item: $selectedDish) { dish in
            SimpleDishDetailView(
                dish: dish,
                brand: dish.restaurantBrand,
                quantity: cartViewModel.getQuantity(for: dish),
                onAdd: {
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
                        menu: [dish],
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
                },
                onRemove: {
                    cartViewModel.removeFromCart(dish)
                }
            )
        }
        .sheet(isPresented: $showDatingMode) {
            DatingModeView(
                dishes: filteredDishes,
                restaurant: Restaurant(
                    name: "Бык Dating",
                    description: "Dating режим для блюд",
                    address: "Dating Address",
                    city: "Moscow",
                    imageURL: "94033",
                    rating: 5.0,
                    cuisine: "Dating",
                    deliveryTime: 0,
                    brand: .theByk,
                    menu: filteredDishes,
                    features: [],
                    workingHours: WorkingHours(openTime: "00:00", closeTime: "23:59", weekdays: Set(WorkingHours.Weekday.allCases)),
                    location: Location(latitude: 55.7558, longitude: 37.6176),
                    tables: [],
                    gallery: [],
                    contacts: ContactInfo(),
                    averageCheck: 0,
                    atmosphere: ["Dating"]
                ),
                brandColors: Colors.brandColors(for: .theByk),
                onAddToCart: { dish in
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
                        menu: [dish],
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
                }
            )
        }
        .sheet(isPresented: $showProfile) {
            ProfileView()
        }
        .sheet(isPresented: $cartViewModel.showMixedRestaurantAlert) {
            MixedRestaurantAlertView(
                pendingDish: cartViewModel.pendingDish,
                currentBrand: cartViewModel.currentRestaurantBrand,
                onConfirm: {
                    cartViewModel.confirmAddFromDifferentRestaurant()
                },
                onCancel: {
                    cartViewModel.cancelAddFromDifferentRestaurant()
                }
            )
        }
        .onAppear {
            HapticManager.shared.navigationTransition()
        }
    }
} 