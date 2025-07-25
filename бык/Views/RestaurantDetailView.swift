import SwiftUI

struct RestaurantDetailView: View {
    let restaurant: Restaurant
    @Environment(\.dismiss) private var dismiss
    @State private var showingReservation = false
    @State private var showingMenu = false
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color) {
        Colors.brandColors(for: restaurant.brand)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Заголовок ресторана и инфо
                    RestaurantInfoSection(
                        restaurant: restaurant,
                        brandColors: brandColors
                    )
                    .padding(.vertical, 20)
                    
                    // Кнопки действий
                    ActionButtonsSection(
                        restaurant: restaurant,
                        brandColors: brandColors,
                        onReservation: { showingReservation = true }
                    )
                    .padding(.vertical, 20)
                    
                    // Карта
                    RestaurantMapView(restaurant: restaurant)
                        .padding(.bottom, 20)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.black)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .sheet(isPresented: $showingReservation) {
                ReservationFormView(restaurant: restaurant)
            }
            .sheet(isPresented: $showingMenu) {
                MenuView(restaurant: restaurant)
            }
        }
        .background(Color.black)
    }
}

private struct RestaurantInfoSection: View {
    let restaurant: Restaurant
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Фото ресторана
            if !restaurant.imageURL.isEmpty {
                Image(restaurant.imageURL)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 220)
                    .clipped()
                    .cornerRadius(16)
            }
            // Название и рейтинг
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(restaurant.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(brandColors.primary)
                    
                    Text(restaurant.cuisine)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", restaurant.rating))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.8))
                .cornerRadius(8)
            }
            
            // Описание
            Text(restaurant.description)
                .font(.body)
                .foregroundColor(.white)
                .lineLimit(nil)
            
            // Особенности
            if !restaurant.features.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Особенности")
                        .font(.headline)
                        .foregroundColor(brandColors.primary)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        ForEach(Array(restaurant.features), id: \.self) { feature in
                            HStack(spacing: 8) {
                                Image(systemName: feature.icon)
                                    .foregroundColor(brandColors.accent)
                                Text(feature.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.black.opacity(0.8))
                            .cornerRadius(8)
                        }
                    }
                }
            }
            
            // Часы работы
            VStack(alignment: .leading, spacing: 8) {
                Text("Часы работы")
                    .font(.headline)
                    .foregroundColor(brandColors.primary)
                
                ForEach(Weekday.allCases, id: \.self) { weekday in
                    HStack {
                        Text(weekday.name)
                            .font(.subheadline)
                            .foregroundColor(.white)
                        Spacer()
                        Text("\(restaurant.workingHours.openTime) - \(restaurant.workingHours.closeTime)")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            .padding()
            .background(Color.black.opacity(0.8))
            .cornerRadius(12)
        }
    }
}

private struct ActionButtonsSection: View {
    let restaurant: Restaurant
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let onReservation: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Button(action: onReservation) {
                HStack {
                    Image(systemName: "calendar")
                    Text("Забронировать столик")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(brandColors.accent)
                .cornerRadius(12)
            }
            
            NavigationLink(destination: MenuView(restaurant: restaurant)) {
                HStack {
                    Image(systemName: "fork.knife")
                    Text("Посмотреть меню")
                }
                .font(.headline)
                .foregroundColor(brandColors.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(brandColors.secondary.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
}

#Preview {
    RestaurantDetailView(restaurant: Restaurant.mock)
} 