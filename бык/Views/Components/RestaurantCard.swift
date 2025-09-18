import SwiftUI

struct RestaurantCard: View {
    let restaurant: Restaurant
    let onTap: () -> Void
    let onFavoriteToggle: ((Restaurant) -> Void)?
    
    @State private var isPressed = false
    @State private var showGlow = false
    @State private var isFavorite = false
    @State private var showDeliveryBadge = false
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color) {
        Colors.brandColors(for: restaurant.brand)
    }
    
    init(restaurant: Restaurant, onTap: @escaping () -> Void, onFavoriteToggle: ((Restaurant) -> Void)? = nil) {
        self.restaurant = restaurant
        self.onTap = onTap
        self.onFavoriteToggle = onFavoriteToggle
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Изображение ресторана
            ZStack {
                Image(restaurant.imageURL)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 220)
                    .clipped()
                    .overlay(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.black.opacity(0.4)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(16, corners: [.topLeft, .topRight])
                
                // Верхний слой с бейджами
                VStack {
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
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    isFavorite.toggle()
                                }
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
                    
                    Spacer()
                    
                    // Нижний слой с информацией
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
            
            // Информация о ресторане
            VStack(alignment: .leading, spacing: 12) {
                // Название ресторана
                Text(restaurant.name)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                // Кухня с эмодзи
                HStack(spacing: 6) {
                    Text("🍽️")
                        .font(.caption)
                    
                    Text(restaurant.cuisine)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                // Описание
                Text(restaurant.description)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // Адрес с расстоянием
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
                
                // Особенности ресторана (первые 3)
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
                }
                
                // Средний чек
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
            .padding(16)
        }
        .background(
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
            
            // Анимация бейджа доставки
            if restaurant.features.contains(.delivery) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3)) {
                    showDeliveryBadge = true
                }
            }
            
            // Загружаем состояние избранного (в реальном приложении из UserDefaults)
            isFavorite = UserDefaults.standard.bool(forKey: "favorite_\(restaurant.id)")
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
