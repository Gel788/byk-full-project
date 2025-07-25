import SwiftUI

struct PostsFiltersView: View {
    @Binding var selectedRestaurant: Restaurant?
    let onClose: () -> Void
    
    @StateObject private var restaurantService = RestaurantService()
    
    var body: some View {
        VStack(spacing: 16) {
            // Заголовок
            HStack {
                Text("Фильтры")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("Сбросить") {
                    selectedRestaurant = nil
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Colors.bykAccent)
            }
            
            // Фильтр по ресторанам
            VStack(alignment: .leading, spacing: 12) {
                Text("Ресторан")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        // Кнопка "Все"
                        Button(action: { selectedRestaurant = nil }) {
                            Text("Все")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(selectedRestaurant == nil ? .white : Colors.bykAccent)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(selectedRestaurant == nil ? Colors.bykAccent : Color.clear)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Colors.bykAccent, lineWidth: 1)
                                        )
                                )
                        }
                        
                        // Рестораны
                        ForEach(restaurantService.restaurants) { restaurant in
                            Button(action: { selectedRestaurant = restaurant }) {
                                HStack(spacing: 6) {
                                    Text("🐂")
                                        .font(.system(size: 12))
                                    
                                    Text(restaurant.name)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(selectedRestaurant?.id == restaurant.id ? .white : Colors.bykAccent)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(selectedRestaurant?.id == restaurant.id ? Colors.bykAccent : Color.clear)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Colors.bykAccent, lineWidth: 1)
                                        )
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
            
            // Кнопка закрытия
            Button(action: onClose) {
                Text("Применить")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Colors.bykAccent,
                                        Colors.bykPrimary
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.95),
                            Color.black.opacity(0.9)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Colors.bykAccent.opacity(0.5),
                                    Colors.bykPrimary.opacity(0.3)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: Color.black.opacity(0.5), radius: 20, x: 0, y: 10)
        .padding(.horizontal)
    }
}

#Preview {
    PostsFiltersView(
        selectedRestaurant: .constant(nil),
        onClose: {}
    )
    .background(Color.black)
} 