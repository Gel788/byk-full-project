import SwiftUI

struct PickupRestaurantSelectionView: View {
    @EnvironmentObject private var restaurantService: RestaurantService
    @EnvironmentObject private var cartViewModel: CartViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedBrand: Restaurant.Brand = .theByk
    @State private var animateCards = false
    @State private var searchText = ""
    @State private var selectedRestaurant: Restaurant?
    @State private var showingPickupView = false
    
    private var filteredRestaurants: [Restaurant] {
        let restaurants = restaurantService.restaurants.filter { restaurant in
            restaurant.brand == selectedBrand && restaurant.features.contains(.takeaway)
        }
        
        if searchText.isEmpty {
            return restaurants
        } else {
            return restaurants.filter { restaurant in
                restaurant.name.localizedCaseInsensitiveContains(searchText) ||
                restaurant.address.localizedCaseInsensitiveContains(searchText) ||
                restaurant.city.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Градиентный фон
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color.black.opacity(0.9)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Заголовок
                VStack(spacing: 12) {
                    Text("Выберите ресторан")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("для самовывоза")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.top, 20)
                .padding(.bottom, 24)
                
                // Поиск
                PickupSearchBar(text: $searchText, placeholder: "Поиск ресторана...")
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                
                // Фильтр по брендам
                BrandFilterView(selectedBrand: $selectedBrand)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                
                // Список ресторанов
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(Array(filteredRestaurants.enumerated()), id: \.element.id) { index, restaurant in
                            RestaurantSelectionCard(
                                restaurant: restaurant,
                                brandColors: Colors.brandColors(for: restaurant.brand)
                            ) {
                                print("Выбран ресторан: \(restaurant.name)")
                                selectedRestaurant = restaurant
                                showingPickupView = true
                            }
                            .offset(y: animateCards ? 0 : 50)
                            .opacity(animateCards ? 1 : 0)
                            .animation(.easeOut(duration: 0.6).delay(Double(index) * 0.1), value: animateCards)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
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
                .foregroundColor(.white)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animateCards = true
            }
        }
        .navigationDestination(isPresented: $showingPickupView) {
            if let restaurant = selectedRestaurant {
                PickupView(restaurant: restaurant)
                    .environmentObject(cartViewModel)
                    .environmentObject(restaurantService)
            }
        }
    }
}

// MARK: - Brand Filter View
struct BrandFilterView: View {
    @Binding var selectedBrand: Restaurant.Brand
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Restaurant.Brand.allCases, id: \.self) { brand in
                    PickupBrandFilterButton(
                        brand: brand,
                        isSelected: selectedBrand == brand
                    ) {
                        selectedBrand = brand
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Pickup Brand Filter Button
struct PickupBrandFilterButton: View {
    let brand: Restaurant.Brand
    let isSelected: Bool
    let action: () -> Void
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color) {
        Colors.brandColors(for: brand)
    }
    
    var body: some View {
        Button(action: action) {
            Text(brand.rawValue)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? brandColors.accent : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(isSelected ? brandColors.accent : Color.white.opacity(0.3), lineWidth: 1)
                        )
                )
        }
    }
}

// MARK: - Restaurant Selection Card
struct RestaurantSelectionCard: View {
    let restaurant: Restaurant
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 16) {
                // Заголовок и рейтинг
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(restaurant.name)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Text(restaurant.address)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    // Рейтинг
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(brandColors.accent)
                        
                        Text(String(format: "%.1f", restaurant.rating))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.black.opacity(0.6))
                    )
                }
                
                // Информация о ресторане
                HStack(spacing: 16) {
                    InfoItem(
                        icon: "clock",
                        text: "\(restaurant.deliveryTime) мин",
                        brandColors: brandColors
                    )
                    
                    InfoItem(
                        icon: "mappin.circle",
                        text: restaurant.city,
                        brandColors: brandColors
                    )
                    
                    InfoItem(
                        icon: "creditcard",
                        text: "\(restaurant.averageCheck)₽",
                        brandColors: brandColors
                    )
                }
                
                // Особенности
                if !restaurant.features.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(restaurant.features.prefix(3)), id: \.self) { feature in
                                Text(feature.rawValue)
                                    .font(.system(size: 12))
                                    .foregroundColor(brandColors.accent)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(brandColors.accent.opacity(0.1))
                                    )
                            }
                        }
                    }
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
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Info Item
struct InfoItem: View {
    let icon: String
    let text: String
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(brandColors.accent)
            
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

// MARK: - Pickup Search Bar
struct PickupSearchBar: View {
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.6))
            
            TextField(placeholder, text: $text)
                .foregroundColor(.white)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    PickupRestaurantSelectionView()
        .environmentObject(RestaurantService())
        .environmentObject(CartViewModel(restaurantService: RestaurantService()))
} 