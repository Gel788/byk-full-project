import SwiftUI

struct MenuDishesListView: View {
    let filteredDishes: [Dish]
    let restaurant: Restaurant
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    @Binding var dishesOffset: CGFloat
    
    var body: some View {
        LazyVStack(spacing: 16) {
            ForEach(filteredDishes.indices, id: \.self) { index in
                MenuDishCard(
                    dish: filteredDishes[index],
                    restaurant: restaurant,
                    brandColors: brandColors
                )
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .trailing)),
                    removal: .opacity.combined(with: .move(edge: .leading))
                ))
                .animation(
                    .spring(response: 0.6, dampingFraction: 0.8)
                    .delay(Double(index) * 0.1),
                    value: filteredDishes
                )
            }
        }
        .padding(.horizontal)
        .offset(y: dishesOffset)
        .animation(.spring(response: 1.0, dampingFraction: 0.8), value: dishesOffset)
    }
}

struct MenuEmptyView: View {
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "fork.knife")
                .font(.system(size: 60))
                .foregroundColor(brandColors.accent.opacity(0.5))
            
            Text("Блюда не найдены")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            
            Text("Попробуйте изменить поисковый запрос или выберите другую категорию")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
    }
}
