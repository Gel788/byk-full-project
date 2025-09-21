import SwiftUI

struct EnhancedRestaurantSection: View {
    @Binding var selectedRestaurant: Restaurant?
    @Binding var showingRestaurantPicker: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Заголовок
            HStack {
                Text("Ресторан")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    showingRestaurantPicker = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            
            // Выбранный ресторан или плейсхолдер
            if let restaurant = selectedRestaurant {
                SelectedRestaurantView(
                    restaurant: restaurant,
                    onRemove: {
                        selectedRestaurant = nil
                    }
                )
            } else {
                RestaurantPlaceholderView {
                    showingRestaurantPicker = true
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

struct SelectedRestaurantView: View {
    let restaurant: Restaurant
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Изображение ресторана
            AsyncImage(url: URL(string: restaurant.imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Информация о ресторане
            VStack(alignment: .leading, spacing: 4) {
                Text(restaurant.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(restaurant.cuisine)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack {
                    ForEach(0..<Int(restaurant.rating), id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                    
                    Text("\(restaurant.rating, specifier: "%.1f")")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // Кнопка удаления
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.2))
        )
    }
}

struct RestaurantPlaceholderView: View {
    let onAdd: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "building.2")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text("Выберите ресторан")
                .font(.headline)
                .foregroundColor(.gray)
            
            Button("Выбрать ресторан", action: onAdd)
                .buttonStyle(.borderedProminent)
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [10]))
        )
    }
}
