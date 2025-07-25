import SwiftUI
import CoreLocation

struct DishCard: View {
    let dish: Dish
    let onTap: () -> Void
    @EnvironmentObject var cartViewModel: CartViewModel
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    @State private var showAddAnimation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                // Основное изображение
                Image(dish.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width / 2 - 32, height: 160)
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
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Colors.brandColors(for: dish.restaurantBrand).accent.opacity(0.4),
                                        Colors.brandColors(for: dish.restaurantBrand).primary.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .frame(width: UIScreen.main.bounds.width / 2 - 32, height: 160)
                
                // Индикатор свайпа
                HStack {
                    Spacer()
                    VStack {
                        Image(systemName: "cart.badge.plus")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(
                                Circle()
                                    .fill(Color.green)
                                    .shadow(color: .black.opacity(0.3), radius: 4)
                            )
                            .opacity(dragOffset > 50 ? 1.0 : 0.0)
                            .scaleEffect(dragOffset > 50 ? 1.2 : 0.8)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: dragOffset)
                    }
                    .padding(.trailing, 20)
                }
                
                // Анимация добавления
                if showAddAnimation {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 60, height: 60)
                        .scaleEffect(showAddAnimation ? 2.0 : 0.1)
                        .opacity(showAddAnimation ? 0.0 : 0.8)
                        .animation(.easeOut(duration: 0.6), value: showAddAnimation)
                }
            }
            .offset(x: dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.width > 0 {
                            dragOffset = value.translation.width
                            isDragging = true
                            
                            // Haptic feedback при начале свайпа
                            if dragOffset > 10 && !isDragging {
                                HapticManager.shared.impact(.light)
                            }
                        }
                    }
                    .onEnded { value in
                        if dragOffset > 100 {
                            // Добавляем в корзину
                            addToCart()
                        }
                        
                        // Возвращаем карточку на место
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            dragOffset = 0
                            isDragging = false
                        }
                    }
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(dish.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Text(dish.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Text("\(dish.price, specifier: "%.0f") ₽")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Colors.brandColors(for: dish.restaurantBrand).accent)
                    
                    Spacer()
                    
                    // Кнопка добавления с haptic feedback
                    Button(action: {
                        HapticManager.shared.impact(.medium)
                        addToCart()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(Colors.brandColors(for: dish.restaurantBrand).accent)
                            .background(
                                Circle()
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.1), radius: 2)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .frame(height: 280) // Фиксированная высота для симметрии
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [
                            Colors.brandColors(for: dish.restaurantBrand).accent.opacity(0.3),
                            Colors.brandColors(for: dish.restaurantBrand).primary.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
        .scaleEffect(isDragging ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isDragging)
        .onTapGesture {
            // Открываем детальный экран блюда
            onTap()
        }
    }
    
    private func addToCart() {
        // Создаем временный ресторан для добавления в корзину
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
        
        let result = cartViewModel.addToCart(dish, from: tempRestaurant)
        
        switch result {
        case .success:
            // Показываем анимацию добавления только если блюдо действительно добавлено
            if cartViewModel.cartItems[dish.id] ?? 0 > 0 {
                showAddAnimation = true
                HapticManager.shared.notification(.success)
            } else {
                // Если блюдо не добавлено (показывается предупреждение), даем легкий фидбек
                HapticManager.shared.impact(.light)
            }
        case .failure(let error):
            // Haptic feedback для ошибки
            HapticManager.shared.notification(.error)
            print("Ошибка добавления в корзину: \(error.localizedDescription)")
        }
        
        // Скрываем анимацию
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            showAddAnimation = false
        }
    }
}

struct SimpleDishDetailView: View {
    let dish: Dish
    let brand: Restaurant.Brand
    let quantity: Int
    let onAdd: () -> Void
    let onRemove: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color) {
        Colors.brandColors(for: brand)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Изображение блюда - квадратное для симметрии
                    ZStack {
                        Image(dish.image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.width - 40)
                            .clipped()
                            .cornerRadius(16)
                    }
                            .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Название и цена
                        HStack {
                            Text(dish.name)
                                .font(.title2.weight(.bold))
                                        .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text(dish.price.formattedPrice)
                                .font(.title3.weight(.bold))
                                .foregroundColor(brandColors.accent)
                        }
                        
                        // Описание
                        Text(dish.description)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                        
                        // Категория
                        HStack {
                            Text("Категория:")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                            
                            Text(dish.category)
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(brandColors.accent)
                        }
                        
                            // Время приготовления
                        HStack {
                            Text("Время приготовления:")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                            
                            Text("\(dish.preparationTime) мин")
                                .font(.subheadline.weight(.medium))
                                        .foregroundColor(.white)
                        }
                        
                        // Кнопки управления количеством
                        HStack {
                            Text("Количество:")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                            
                            Spacer()
                            
                            HStack(spacing: 16) {
                                Button(action: onRemove) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(brandColors.accent)
                                }
                                
                                Text("\(quantity)")
                                    .font(.title3.weight(.medium))
                                    .frame(minWidth: 30)
                                    .foregroundColor(.white)
                                
                                Button(action: onAdd) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(brandColors.accent)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
                    .background(Color.black)
            .navigationTitle("Детали блюда")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                .foregroundColor(brandColors.accent)
                }
            }
        }
        .background(Color.black)
    }
}

#Preview {
    DishCard(
        dish: Dish(
            name: "Рибай стейк",
            description: "Премиальный стейк из мраморной говядины",
            price: 3200,
            image: "XXL_height",
            category: "Стейки",
            restaurantBrand: Restaurant.Brand.theByk
        ),
        onTap: {}
    )
    .environmentObject(CartViewModel(restaurantService: RestaurantService()))
    .padding()
    .background(Color.black)
} 