import SwiftUI

// MARK: - Restaurant Image Section
struct RestaurantImageSection: View {
    let restaurant: Restaurant
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let onFavoriteToggle: ((Restaurant) -> Void)?
    let isFavorite: Bool
    
    var body: some View {
        ZStack {
            RestaurantImageCard(imageURL: restaurant.imageURL)
                .overlay(
                    LinearGradient(
                        colors: [Color.clear, Color.black.opacity(0.4)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            RestaurantOverlayContent(
                restaurant: restaurant,
                brandColors: brandColors,
                onFavoriteToggle: onFavoriteToggle,
                isFavorite: isFavorite
            )
        }
        .clipped()
    }
}

// MARK: - Restaurant Overlay Content
struct RestaurantOverlayContent: View {
    let restaurant: Restaurant
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let onFavoriteToggle: ((Restaurant) -> Void)?
    let isFavorite: Bool
    @State private var showDeliveryBadge = false
    
    var body: some View {
        VStack {
            RestaurantTopBar(
                restaurant: restaurant,
                brandColors: brandColors,
                onFavoriteToggle: onFavoriteToggle,
                isFavorite: isFavorite
            )
            
            Spacer()
            
            RestaurantBottomBar(
                restaurant: restaurant,
                brandColors: brandColors,
                showDeliveryBadge: showDeliveryBadge
            )
        }
        .onAppear {
            if restaurant.features.contains(.delivery) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3)) {
                    showDeliveryBadge = true
                }
            }
        }
    }
}

// MARK: - Restaurant Top Bar
struct RestaurantTopBar: View {
    let restaurant: Restaurant
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let onFavoriteToggle: ((Restaurant) -> Void)?
    let isFavorite: Bool
    
    var body: some View {
        HStack {
            // Бейдж бренда
            Text(restaurant.brand.emoji + " " + restaurant.brand.displayName)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(brandColors.accent.opacity(0.9))
                        .shadow(color: brandColors.accent.opacity(0.3), radius: 4, x: 0, y: 2)
                )
            
            Spacer()
            
            // Кнопка избранного
            if let onFavoriteToggle = onFavoriteToggle {
                Button(action: {
                    HapticManager.shared.buttonPress()
                    onFavoriteToggle(restaurant)
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.6))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(isFavorite ? .red : .white)
                            .scaleEffect(isFavorite ? 1.2 : 1.0)
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 12)
    }
}

// MARK: - Restaurant Bottom Bar
struct RestaurantBottomBar: View {
    let restaurant: Restaurant
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let showDeliveryBadge: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                // Статус работы
                HStack(spacing: 4) {
                    Circle()
                        .fill(restaurant.workingHours.isOpen() ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    
                    Text(restaurant.workingHours.isOpen() ? "Открыто" : "Закрыто")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.black.opacity(0.7))
                )
                
                // Время доставки (если есть доставка)
                if restaurant.features.contains(.delivery) {
                    HStack(spacing: 4) {
                        Image(systemName: "bicycle")
                            .font(.caption2)
                            .foregroundColor(brandColors.accent)
                        
                        Text("\(restaurant.deliveryTime) мин")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(brandColors.accent.opacity(0.8))
                    )
                    .scaleEffect(showDeliveryBadge ? 1.0 : 0.8)
                    .opacity(showDeliveryBadge ? 1.0 : 0.0)
                }
            }
            
            Spacer()
            
            // Рейтинг с улучшенным дизайном
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundColor(.yellow)
                
                Text(String(format: "%.1f", restaurant.rating))
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.7))
            )
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
    }
}

// MARK: - Restaurant Info Section
struct RestaurantInfoSection: View {
    let restaurant: Restaurant
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            RestaurantTitleSection(restaurant: restaurant)
            RestaurantCuisineSection(restaurant: restaurant)
            RestaurantDescriptionSection(restaurant: restaurant)
            RestaurantAddressSection(restaurant: restaurant, brandColors: brandColors)
            RestaurantFeaturesSection(restaurant: restaurant, brandColors: brandColors)
            RestaurantBottomInfoSection(restaurant: restaurant, brandColors: brandColors)
        }
        .padding(16)
    }
}

// MARK: - Restaurant Title Section
struct RestaurantTitleSection: View {
    let restaurant: Restaurant
    
    var body: some View {
        Text(restaurant.name)
            .font(.system(size: 18, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .lineLimit(1)
    }
}

// MARK: - Restaurant Cuisine Section
struct RestaurantCuisineSection: View {
    let restaurant: Restaurant
    
    var body: some View {
        HStack(spacing: 6) {
            Text("🍽️")
                .font(.caption)
            
            Text(restaurant.cuisine)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

// MARK: - Restaurant Description Section
struct RestaurantDescriptionSection: View {
    let restaurant: Restaurant
    
    var body: some View {
        Text(restaurant.description)
            .font(.system(size: 13, weight: .regular))
            .foregroundColor(.white.opacity(0.7))
            .lineLimit(2)
            .multilineTextAlignment(.leading)
    }
}

// MARK: - Restaurant Address Section
struct RestaurantAddressSection: View {
    let restaurant: Restaurant
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        HStack(spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: "location.fill")
                    .font(.caption2)
                    .foregroundColor(brandColors.accent)
                
                Text(restaurant.address)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Примерное расстояние (mock)
            Text("1.2 км")
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(brandColors.accent)
        }
    }
}

// MARK: - Restaurant Features Section
struct RestaurantFeaturesSection: View {
    let restaurant: Restaurant
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        if !restaurant.features.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(restaurant.features.prefix(3)), id: \.self) { feature in
                        HStack(spacing: 4) {
                            Image(systemName: feature.icon)
                                .font(.caption2)
                                .foregroundColor(brandColors.accent)
                            
                            Text(feature.rawValue)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(brandColors.accent.opacity(0.2))
                                .overlay(
                                    Capsule()
                                        .stroke(brandColors.accent.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                }
                .padding(.horizontal, 1)
            }
            .frame(height: 32)
        }
    }
}

// MARK: - Restaurant Bottom Info Section
struct RestaurantBottomInfoSection: View {
    let restaurant: Restaurant
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        HStack {
            Text("Средний чек:")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.6))
            
            Text("~\(restaurant.averageCheck)₽")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(brandColors.accent)
            
            Spacer()
            
            // Телефон
            Button(action: {
                if let phoneURL = URL(string: "tel:\(restaurant.contacts.phone.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "-", with: ""))") {
                    UIApplication.shared.open(phoneURL)
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "phone.fill")
                        .font(.caption2)
                    Text("Позвонить")
                        .font(.caption2)
                        .fontWeight(.medium)
                }
                .foregroundColor(brandColors.accent)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .stroke(brandColors.accent.opacity(0.5), lineWidth: 1)
                )
            }
        }
    }
}

// MARK: - Restaurant Card Background
struct RestaurantCardBackground: View {
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let showGlow: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.8),
                        Color.black.opacity(0.9)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [
                                brandColors.accent.opacity(showGlow ? 0.6 : 0.2),
                                brandColors.accent.opacity(showGlow ? 0.3 : 0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: showGlow ? 2 : 1
                    )
            )
    }
}
