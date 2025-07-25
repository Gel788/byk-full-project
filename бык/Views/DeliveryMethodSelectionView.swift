import SwiftUI

struct DeliveryMethodSelectionView: View {
    let restaurant: Restaurant
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var cartViewModel: CartViewModel
    @State private var selectedMethod: DeliveryMethod = .delivery
    @State private var showingCheckout = false
    @State private var showingPickup = false
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color) {
        Colors.brandColors(for: restaurant.brand)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Фон
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Информация о ресторане
                        RestaurantInfoCard(restaurant: restaurant, brandColors: brandColors)
                        
                        // Выбор способа доставки
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Выберите способ получения")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            
                            VStack(spacing: 12) {
                                ForEach(DeliveryMethod.allCases, id: \.self) { method in
                                    DeliveryMethodSelectionCard(
                                        method: method,
                                        restaurant: restaurant,
                                        isSelected: selectedMethod == method,
                                        brandColors: brandColors
                                    ) {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            selectedMethod = method
                                        }
                                    }
                                }
                            }
                        }
                        .padding(16)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(12)
                        
                        // Кнопка продолжения
                        ContinueButton(
                            selectedMethod: selectedMethod,
                            brandColors: brandColors
                        ) {
                            if selectedMethod == .delivery {
                                showingCheckout = true
                            } else {
                                showingPickup = true
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Способ получения")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                    .foregroundColor(brandColors.accent)
                }
            }
            .sheet(isPresented: $showingCheckout) {
                CheckoutView(restaurant: restaurant)
                    .environmentObject(cartViewModel)
            }
            .navigationDestination(isPresented: $showingPickup) {
                PickupRestaurantSelectionView()
                    .environmentObject(cartViewModel)
                    .environmentObject(RestaurantService())
            }
        }
        .background(Color.black)
    }
}

// MARK: - Delivery Method Selection Specific Components

struct DeliveryMethodSelectionCard: View {
    let method: DeliveryMethod
    let restaurant: Restaurant
    let isSelected: Bool
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Иконка
                ZStack {
                    Circle()
                        .fill(isSelected ? brandColors.accent : Color.black.opacity(0.6))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: method.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(isSelected ? .white : brandColors.primary)
                }
                
                // Информация
                VStack(alignment: .leading, spacing: 4) {
                    Text(method.rawValue)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(methodDescription)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    if method == .delivery {
                        HStack(spacing: 12) {
                            Label("\(restaurant.deliveryTime) мин", systemImage: "clock.fill")
                                .font(.system(size: 12))
                                .foregroundColor(brandColors.accent)
                            
                            Label("200 ₽", systemImage: "car.fill")
                                .font(.system(size: 12))
                                .foregroundColor(brandColors.accent)
                        }
                    } else {
                        Label(restaurant.address, systemImage: "location.fill")
                            .font(.system(size: 12))
                            .foregroundColor(brandColors.accent)
                    }
                }
                
                Spacer()
                
                // Индикатор выбора
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(brandColors.accent)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? brandColors.accent.opacity(0.2) : Color.black.opacity(0.4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? brandColors.accent.opacity(0.5) : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var methodDescription: String {
        switch method {
        case .delivery:
            return "Доставка курьером"
        case .pickup:
            return "Забрать в ресторане"
        }
    }
}

struct ContinueButton: View {
    let selectedMethod: DeliveryMethod
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "arrow.right")
                    .font(.system(size: 16))
                
                Text("Продолжить")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(brandColors.accent)
            )
        }
    }
}

#Preview {
    DeliveryMethodSelectionView(restaurant: Restaurant.mock)
        .environmentObject(CartViewModel(restaurantService: RestaurantService()))
} 