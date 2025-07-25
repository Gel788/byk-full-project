import SwiftUI

struct MixedRestaurantAlertView: View {
    let pendingDish: (dish: Dish, restaurant: Restaurant, quantity: Int)?
    let currentBrand: Restaurant.Brand?
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var showAnimation = false
    
    private var currentBrandColors: (primary: Color, secondary: Color, accent: Color) {
        if let brand = currentBrand {
            return Colors.brandColors(for: brand)
        }
        return Colors.brandColors(for: .theByk)
    }
    
    private var pendingBrandColors: (primary: Color, secondary: Color, accent: Color) {
        if let pending = pendingDish {
            return Colors.brandColors(for: pending.restaurant.brand)
        }
        return Colors.brandColors(for: .theByk)
    }
    
    var body: some View {
        ZStack {
            // Элегантный затемненный фон
            Color.black.opacity(showAnimation ? 0.5 : 0.0)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.3), value: showAnimation)
                .onTapGesture {
                    onCancel()
                }
            
            // Основное окно
            VStack(spacing: 0) {
                // Заголовок
                VStack(spacing: 20) {
                    // Элегантная иконка
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color("BykAccent").opacity(0.1),
                                        Color("BykPrimary").opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 70, height: 70)
                        
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(Color("BykAccent"))
                    }
                    .scaleEffect(showAnimation ? 1.0 : 0.5)
                    .opacity(showAnimation ? 1.0 : 0.0)
                    
                    // Заголовок
                    Text("Добавить из другого ресторана?")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .opacity(showAnimation ? 1.0 : 0.0)
                        .offset(y: showAnimation ? 0 : 20)
                }
                .padding(.top, 32)
                .padding(.horizontal, 24)
                
                // Информация о ресторанах
                if let pending = pendingDish, let currentBrand = currentBrand {
                    VStack(spacing: 24) {
                        // Текущий ресторан
                        HStack(spacing: 16) {
                            // Иконка текущего ресторана
                            ZStack {
                                Circle()
                                    .fill(currentBrandColors.accent.opacity(0.1))
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: "cart.fill")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(currentBrandColors.accent)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Текущая корзина")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text(currentBrand.displayName)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .opacity(showAnimation ? 1.0 : 0.0)
                        .offset(x: showAnimation ? 0 : -30)
                        
                        // Стрелка
                        Image(systemName: "arrow.down")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .opacity(showAnimation ? 1.0 : 0.0)
                            .scaleEffect(showAnimation ? 1.0 : 0.5)
                        
                        // Новый ресторан
                        HStack(spacing: 16) {
                            // Иконка нового ресторана
                            ZStack {
                                Circle()
                                    .fill(pendingBrandColors.accent.opacity(0.1))
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(pendingBrandColors.accent)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Новое блюдо")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text(pending.restaurant.brand.displayName)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Text(pending.dish.name)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .opacity(showAnimation ? 1.0 : 0.0)
                        .offset(x: showAnimation ? 0 : 30)
                    }
                    .padding(.vertical, 20)
                }
                
                // Сообщение
                VStack(spacing: 16) {
                    Text("Чтобы добавить блюдо из другого ресторана, нужно очистить текущую корзину.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    
                    Text("Все блюда из текущей корзины будут удалены.")
                        .font(.subheadline)
                        .foregroundColor(Color("BykAccent"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .opacity(showAnimation ? 1.0 : 0.0)
                .offset(y: showAnimation ? 0 : 20)
                
                Spacer()
                
                // Кнопки
                VStack(spacing: 12) {
                    // Кнопка подтверждения
                    Button(action: {
                        HapticManager.shared.impact(.medium)
                        onConfirm()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "trash.fill")
                                .font(.system(size: 16, weight: .medium))
                            
                            Text("Очистить корзину и добавить")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        colors: [Color("BykAccent"), Color("BykPrimary")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                    }
                    .scaleEffect(showAnimation ? 1.0 : 0.9)
                    
                    // Кнопка отмены
                    Button(action: {
                        HapticManager.shared.impact(.light)
                        onCancel()
                    }) {
                        Text("Отмена")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemGray6))
                            )
                    }
                    .scaleEffect(showAnimation ? 1.0 : 0.9)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                .opacity(showAnimation ? 1.0 : 0.0)
                .offset(y: showAnimation ? 0 : 30)
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 24)
            .scaleEffect(showAnimation ? 1.0 : 0.8)
            .opacity(showAnimation ? 1.0 : 0.0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showAnimation = true
            }
        }
    }
}

#Preview {
    MixedRestaurantAlertView(
        pendingDish: (
            dish: Dish(
                name: "Пицца Маргарита",
                description: "Классическая итальянская пицца",
                price: 650,
                image: "pizza_margherita",
                category: "Пицца",
                restaurantBrand: .mosca
            ),
            restaurant: Restaurant(
                name: "Mosca",
                description: "Итальянская кухня",
                address: "ул. Тверская, 1",
                city: "Москва",
                imageURL: "mosca_main",
                rating: 4.8,
                cuisine: "Итальянская",
                deliveryTime: 25,
                brand: .mosca,
                menu: [],
                features: [],
                workingHours: WorkingHours(openTime: "10:00", closeTime: "22:00", weekdays: Set(WorkingHours.Weekday.allCases)),
                location: Location(latitude: 55.7558, longitude: 37.6176),
                tables: [],
                gallery: [],
                contacts: ContactInfo(),
                averageCheck: 1200,
                atmosphere: ["Уютно"]
            ),
            quantity: 1
        ),
        currentBrand: .theByk,
        onConfirm: {},
        onCancel: {}
    )
} 