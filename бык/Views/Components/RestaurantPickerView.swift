import SwiftUI

struct RestaurantPickerView: View {
    @Binding var selectedRestaurant: Restaurant?
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var restaurantService = RestaurantService()
    @State private var selectedBrand: Restaurant.Brand = .theByk
    
    private var filteredRestaurants: [Restaurant] {
        restaurantService.restaurants.filter { $0.brand == selectedBrand }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Заголовок
                    Text("Выберите ресторан")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top)
                    
                    // Фильтр по брендам
                    RestaurantBrandFilterView(selectedBrand: $selectedBrand)
                    
                    // Список ресторанов
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredRestaurants) { restaurant in
                                RestaurantPickerCardView(
                                    restaurant: restaurant,
                                    isSelected: selectedRestaurant?.id == restaurant.id,
                                    onSelect: {
                                        selectedRestaurant = restaurant
                                        dismiss()
                                    }
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Рестораны")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Отмена") {
                        dismiss()
                    }
                    .foregroundColor(Colors.bykAccent)
                }
            }
        }
    }
}

// MARK: - Restaurant Brand Filter View
struct RestaurantBrandFilterView: View {
    @Binding var selectedBrand: Restaurant.Brand
    
    private var filteredRestaurants: [Restaurant] {
        RestaurantService().restaurants.filter { $0.brand == selectedBrand }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Сегментированный контроль
            HStack(spacing: 0) {
                ForEach(Restaurant.Brand.allCases, id: \.self) { brand in
                    RestaurantBrandButtonView(
                        brand: brand,
                        isSelected: selectedBrand == brand,
                        action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedBrand = brand
                            }
                        }
                    )
                }
            }
            .padding(.horizontal)
            
            // Информация о бренде
            HStack(spacing: 12) {
                Text(selectedBrand.emoji)
                    .font(.system(size: 24))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(selectedBrand.displayName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("\(filteredRestaurants.count) ресторан\(filteredRestaurants.count == 1 ? "" : "а")")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
            }
            .padding(.horizontal)
        }
        .padding(.bottom)
    }
}

// MARK: - Restaurant Brand Button View
struct RestaurantBrandButtonView: View {
    let brand: Restaurant.Brand
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(brand.displayName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                
                Text(brand.emoji)
                    .font(.system(size: 16))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(backgroundGradient)
            .overlay(overlayStroke)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var backgroundGradient: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                isSelected ? 
                    AnyShapeStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Colors.brandColors(for: brand).accent,
                                Colors.brandColors(for: brand).primary
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    ) : 
                    AnyShapeStyle(Color.white.opacity(0.05))
            )
    }
    
    private var overlayStroke: some View {
        RoundedRectangle(cornerRadius: 12)
            .stroke(
                isSelected ? 
                    Colors.brandColors(for: brand).accent.opacity(0.3) : 
                    Color.white.opacity(0.1),
                lineWidth: 1
            )
    }
}

// MARK: - Restaurant Picker Card View
struct RestaurantPickerCardView: View {
    let restaurant: Restaurant
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Логотип бренда
                RestaurantBrandLogoView(brand: restaurant.brand)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(restaurant.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(restaurant.address)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                    
                    RestaurantPickerStatsView(restaurant: restaurant)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Colors.brandColors(for: restaurant.brand).accent)
                }
            }
            .padding(16)
            .background(cardBackground)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.white.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? 
                            Colors.brandColors(for: restaurant.brand).accent.opacity(0.3) : 
                            Color.white.opacity(0.1),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
    }
}

// MARK: - Restaurant Brand Logo View
struct RestaurantBrandLogoView: View {
    let brand: Restaurant.Brand
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Colors.brandColors(for: brand).accent,
                            Colors.brandColors(for: brand).primary
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 40, height: 40)
            
            Text(brand.emoji)
                .font(.system(size: 20))
        }
    }
}

// MARK: - Restaurant Picker Stats View
struct RestaurantPickerStatsView: View {
    let restaurant: Restaurant
    
    var body: some View {
        HStack(spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.yellow)
                
                Text(String(format: "%.1f", restaurant.rating))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
                
                Text("\(restaurant.deliveryTime) мин")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }
}



#Preview {
    RestaurantPickerView(selectedRestaurant: .constant(nil))
} 