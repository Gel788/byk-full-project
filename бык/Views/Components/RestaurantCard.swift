import SwiftUI

struct RestaurantCard: View {
    let restaurant: Restaurant
    let onTap: () -> Void
    let onFavoriteToggle: ((Restaurant) -> Void)?
    let isFavorite: Bool
    
    @State private var isPressed = false
    @State private var showGlow = false
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color) {
        Colors.brandColors(for: restaurant.brand)
    }
    
    init(restaurant: Restaurant, onTap: @escaping () -> Void, onFavoriteToggle: ((Restaurant) -> Void)? = nil, isFavorite: Bool = false) {
        self.restaurant = restaurant
        self.onTap = onTap
        self.onFavoriteToggle = onFavoriteToggle
        self.isFavorite = isFavorite
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            RestaurantImageSection(
                restaurant: restaurant,
                brandColors: brandColors,
                onFavoriteToggle: onFavoriteToggle,
                isFavorite: isFavorite
            )
                    .frame(height: 220)
            
            RestaurantInfoSection(
                restaurant: restaurant,
                brandColors: brandColors
            )
        }
        .clipped()
        .background(
            RestaurantCardBackground(
                brandColors: brandColors,
                showGlow: showGlow
                )
        )
        .shadow(
            color: showGlow ? brandColors.accent.opacity(0.4) : Color.black.opacity(0.3),
            radius: showGlow ? 20 : 10,
            x: 0,
            y: showGlow ? 10 : 5
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .onTapGesture {
            // Haptic feedback при нажатии
            HapticManager.shared.restaurantSelect()
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isPressed = false
                }
                // Открываем детальный экран
                onTap()
            }
        }
        .onAppear {
            // Анимация появления с задержкой
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true).delay(Double.random(in: 0.5...2.0))) {
                showGlow = true
            }
        }
    }
}

// MARK: - Restaurant Card Preview
#Preview {
    RestaurantCard(
        restaurant: Restaurant(
            name: "THE БЫК на Тверской",
            description: "Премиальные стейки из мраморной говядины",
            address: "ул. Тверская, 15",
            city: "Москва",
            imageURL: "94033",
            rating: 4.8,
            cuisine: "Стейк-хаус",
            deliveryTime: 45,
            brand: .theByk,
            menu: [],
            features: [],
            workingHours: .default,
            location: Location(latitude: 55.7558, longitude: 37.6173),
            tables: []
        ),
        onTap: {}
    )
    .padding()
    .background(Color.black)
}

#Preview {
    RestaurantCard(
        restaurant: Restaurant(
            name: "THE БЫК на Тверской",
            description: "Премиальные стейки из мраморной говядины",
            address: "ул. Тверская, 15",
            city: "Москва",
            imageURL: "94033",
            rating: 4.8,
            cuisine: "Стейк-хаус",
            deliveryTime: 45,
            brand: .theByk,
            menu: [],
            features: [],
            workingHours: .default,
            location: Location(latitude: 55.7558, longitude: 37.6173),
            tables: []
        ),
        onTap: {}
    )
    .padding()
    .background(Color.black)
} 

// MARK: - Restaurant Image Card
struct RestaurantImageCard: View {
    let imageURL: String
    @State private var imageLoadError = false
    
    var body: some View {
        HStack {
            Spacer()
            AsyncImage(url: URL(string: imageURL)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 220)
                        .background(Color.black.opacity(0.1))
                        .cornerRadius(16, corners: [.topLeft, .topRight])
                        .onAppear {
                            imageLoadError = false
                        }
                case .failure(_):
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 300, height: 220)
                        .overlay(
                            VStack(spacing: 8) {
                                Image(systemName: "photo")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white.opacity(0.6))
                                Text("Фото недоступно")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        )
                        .cornerRadius(16, corners: [.topLeft, .topRight])
                        .onAppear {
                            imageLoadError = true
                        }
                case .empty:
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 300, height: 220)
                        .overlay(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        )
                        .cornerRadius(16, corners: [.topLeft, .topRight])
                @unknown default:
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 300, height: 220)
                        .overlay(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        )
                        .cornerRadius(16, corners: [.topLeft, .topRight])
                }
            }
            Spacer()
        }
        .frame(height: 220)
    }
}
