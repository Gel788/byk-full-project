import SwiftUI

struct RestaurantCard: View {
    let restaurant: Restaurant
    let onTap: () -> Void
    @State private var isPressed = false
    @State private var showGlow = false
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color) {
        Colors.brandColors(for: restaurant.brand)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Изображение ресторана
            ZStack(alignment: .topTrailing) {
                Image(restaurant.imageURL)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
                    .overlay(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.black.opacity(0.3)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                .cornerRadius(16, corners: [.topLeft, .topRight])
                
                // Статус открытия
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
                        .fill(Color.black.opacity(0.6))
                        .blur(radius: 0.5)
                )
                .padding(12)
            }
            
            // Информация о ресторане
            VStack(alignment: .leading, spacing: 8) {
                // Название и рейтинг
                HStack {
                    Text(restaurant.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                        
                        Text(String(format: "%.1f", restaurant.rating))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Описание
                Text(restaurant.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // Адрес и телефон
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "location.fill")
                            .font(.caption)
                            .foregroundColor(brandColors.accent)
                        
                        Text(restaurant.address)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: "phone.fill")
                            .font(.caption)
                            .foregroundColor(brandColors.accent)
                        
                        Text(restaurant.contacts.phone)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(16)
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(
            color: showGlow ? brandColors.accent.opacity(0.3) : .black.opacity(0.1),
            radius: showGlow ? 15 : 8,
            x: 0,
            y: showGlow ? 8 : 4
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
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(1.0)) {
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
