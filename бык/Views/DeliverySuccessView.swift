import SwiftUI

struct DeliverySuccessView: View {
    let order: DeliveryOrder
    let restaurant: Restaurant
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var cartViewModel: CartViewModel
    @State private var showingAnimation = false
    @State private var showingDetails = false
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color) {
        Colors.brandColors(for: order.restaurantBrand)
    }
    
    var body: some View {
        ZStack {
            // Градиентный фон
            LinearGradient(
                gradient: Gradient(colors: [
                    brandColors.primary.opacity(0.1),
                    brandColors.secondary.opacity(0.05),
                    Color.black
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Анимированная иконка успеха
                    DeliverySuccessIconView(brandColors: brandColors, showingAnimation: $showingAnimation)
                    
                    // Заголовок
                    VStack(spacing: 12) {
                        Text("Заказ оформлен!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(brandColors.primary)
                            .opacity(showingAnimation ? 1 : 0)
                            .scaleEffect(showingAnimation ? 1 : 0.8)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: showingAnimation)
                        
                        Text("Ваш заказ успешно принят и готовится")
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .opacity(showingAnimation ? 1 : 0)
                            .animation(.easeInOut(duration: 0.5).delay(0.5), value: showingAnimation)
                    }
                    
                    // Информация о заказе
                    OrderInfoCard(order: order, restaurant: restaurant, brandColors: brandColors, showingAnimation: showingAnimation)
                    
                    // Время доставки
                    DeliveryTimeCard(order: order, brandColors: brandColors, showingAnimation: showingAnimation)
                    
                    // Кнопки действий
                    DeliveryActionButtonsView(
                        brandColors: brandColors,
                        showingAnimation: showingAnimation,
                        onTrackOrder: {
                            // TODO: Открыть отслеживание заказа
                        },
                        onViewHistory: {
                            // TODO: Открыть историю заказов
                        },
                        onClose: {
                            // Очищаем корзину и закрываем все модальные окна
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                cartViewModel.clearCart()
                            }
                            dismiss()
                        }
                    )
                }
                .padding()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation {
                showingAnimation = true
            }
        }
    }
    
    // Функция форматирования времени доставки теперь вне body
    private func formatDeliveryTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Delivery Success Icon View
private struct DeliverySuccessIconView: View {
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    @Binding var showingAnimation: Bool
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        ZStack {
            // Внешний круг с градиентом
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            brandColors.primary,
                            brandColors.secondary
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 120, height: 120)
                .scaleEffect(showingAnimation ? 1 : 0)
                .rotationEffect(.degrees(rotationAngle))
                .animation(.spring(response: 0.8, dampingFraction: 0.6), value: showingAnimation)
                .onAppear {
                    withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                        rotationAngle = 360
                    }
                }
            
            // Внутренний круг
            Circle()
                .fill(Color.black)
                .frame(width: 100, height: 100)
                .scaleEffect(showingAnimation ? 1 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: showingAnimation)
            
            // Иконка галочки
            Image(systemName: "checkmark")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(brandColors.primary)
                .scaleEffect(showingAnimation ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.4), value: showingAnimation)
        }
    }
}

// MARK: - Order Info Card
private struct OrderInfoCard: View {
    let order: DeliveryOrder
    let restaurant: Restaurant
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let showingAnimation: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "doc.text")
                    .font(.title2)
                    .foregroundColor(brandColors.primary)
                
                Text("Информация о заказе")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                DeliverySuccessInfoRow(
                    icon: "number",
                    title: "Номер заказа",
                    value: order.orderNumber,
                    brandColors: brandColors
                )
                
                DeliverySuccessInfoRow(
                    icon: "building.2",
                    title: "Ресторан",
                    value: "THE \(order.restaurantBrand.rawValue)",
                    brandColors: brandColors
                )
                
                DeliverySuccessInfoRow(
                    icon: "mappin.and.ellipse",
                    title: "Адрес доставки",
                    value: order.deliveryAddress,
                    brandColors: brandColors
                )
                
                DeliverySuccessInfoRow(
                    icon: "creditcard",
                    title: "Сумма заказа",
                    value: "\(Int(order.totalAmount)) ₽",
                    brandColors: brandColors
                )
                
                DeliverySuccessInfoRow(
                    icon: "clock",
                    title: "Время доставки",
                    value: order.estimatedDeliveryTime != nil ? formatDeliveryTime(order.estimatedDeliveryTime!) : "—",
                    brandColors: brandColors
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.8))
                .shadow(color: brandColors.primary.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .opacity(showingAnimation ? 1 : 0)
        .offset(y: showingAnimation ? 0 : 50)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.6), value: showingAnimation)
    }
}

// MARK: - Delivery Time Card
private struct DeliveryTimeCard: View {
    let order: DeliveryOrder
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let showingAnimation: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "clock")
                    .font(.title2)
                    .foregroundColor(brandColors.primary)
                
                Text("Время доставки")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            HStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("Ожидаемое время")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(order.estimatedDeliveryTime != nil ? formatDeliveryTime(order.estimatedDeliveryTime!) : "—")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(brandColors.primary)
                }
                
                Divider()
                    .frame(height: 40)
                
                VStack(spacing: 8) {
                    Text("Статус")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(order.status.rawValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(order.status.color))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color(order.status.color).opacity(0.1))
                        .clipShape(Capsule())
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.8))
                .shadow(color: brandColors.primary.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .opacity(showingAnimation ? 1 : 0)
        .offset(y: showingAnimation ? 0 : 50)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.8), value: showingAnimation)
    }
    
    private func formatDeliveryTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Delivery Action Buttons View
private struct DeliveryActionButtonsView: View {
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let showingAnimation: Bool
    let onTrackOrder: () -> Void
    let onViewHistory: () -> Void
    let onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Кнопка отслеживания заказа
            Button(action: onTrackOrder) {
                HStack {
                    Image(systemName: "location")
                        .font(.title3)
                    Text("Отследить заказ")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [brandColors.primary, brandColors.secondary]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: brandColors.primary.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            
            // Кнопка истории заказов
            Button(action: onViewHistory) {
                HStack {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.title3)
                    Text("История заказов")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(brandColors.primary)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(brandColors.primary, lineWidth: 2)
                        .background(Color.black.opacity(0.8))
                )
            }
            
            // Кнопка закрытия
            Button(action: onClose) {
                Text("Вернуться к меню")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
            }
        }
        .opacity(showingAnimation ? 1 : 0)
        .offset(y: showingAnimation ? 0 : 50)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(1.0), value: showingAnimation)
    }
}

// MARK: - Delivery Success Info Row
private struct DeliverySuccessInfoRow: View {
    let icon: String
    let title: String
    let value: String
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(brandColors.primary)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
    }
}

// Глобальная функция форматирования времени для всех View этого файла
fileprivate func formatDeliveryTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter.string(from: date)
}

#Preview {
    let sampleOrder = DeliveryOrder(
        orderNumber: "BYK-2024-001",
        items: [],
        totalAmount: 2500,
        deliveryAddress: "ул. Доставки, 456",
        deliveryTime: Date().addingTimeInterval(3600),
        orderDate: Date(),
        status: .preparing,
        restaurantBrand: .theByk,
        deliveryFee: 300,
        estimatedDeliveryTime: Date().addingTimeInterval(3600),
        paymentMethod: .card
    )
    
    let sampleRestaurant = Restaurant(
        name: "THE БЫК",
        description: "Стейк-хаус",
        address: "ул. Примерная, 123",
        city: "Москва",
        imageURL: "thebyk_main",
        rating: 4.8,
        cuisine: "Стейки",
        deliveryTime: 45,
        brand: .theByk,
        menu: [],
        features: [],
        workingHours: .default,
        location: Location(latitude: 55.7558, longitude: 37.6176),
        tables: []
    )
    
    DeliverySuccessView(order: sampleOrder, restaurant: sampleRestaurant)
} 