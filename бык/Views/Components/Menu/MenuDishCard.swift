import SwiftUI

struct MenuDishCard: View {
    let dish: Dish
    let restaurant: Restaurant
    @EnvironmentObject private var cartViewModel: CartViewModel
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Изображение блюда
            AsyncImage(url: URL(string: dish.image)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: brandColors.accent))
                    )
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 8) {
                // Название блюда
                Text(dish.name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                // Описание
                Text(dish.description)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(2)
                
                // Цена
                HStack {
                    Text("\(Int(dish.price)) ₽")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(brandColors.accent)
                    
                    Spacer()
                    
                    // Кнопка добавления в корзину
                    AddToCartButton(
                        dish: dish,
                        restaurant: restaurant,
                        cartViewModel: cartViewModel,
                        brandColors: brandColors
                    )
                }
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(brandColors.accent.opacity(0.3), lineWidth: 1)
                )
        )
        .scaleEffect(isAnimating ? 1.02 : 1.0)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.3).delay(0.1)) {
                isAnimating = true
            }
        }
    }
}

struct AddToCartButton: View {
    let dish: Dish
    let restaurant: Restaurant
    @ObservedObject var cartViewModel: CartViewModel
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            _ = cartViewModel.addToCart(dish, from: restaurant)
            
            // Анимация нажатия
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
        }) {
            Image(systemName: "plus")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(brandColors.accent)
                )
        }
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
    }
}
