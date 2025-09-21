import SwiftUI

struct RestaurantDetailView: View {
    let restaurant: Restaurant
    @Environment(\.dismiss) private var dismiss
    @StateObject private var restaurantReservationService = ReservationService()
    @State private var showingReservation = false
    @State private var showingMenu = false
    @State private var showingPhotoGallery = false
    @State private var showingReviews = false
    @State private var isFavorite = false
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color) {
        Colors.brandColors(for: restaurant.brand)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Фото ресторана
                    if !restaurant.imageURL.isEmpty {
                        Button(action: { showingPhotoGallery = true }) {
                            ZStack {
                                AsyncImage(url: URL(string: restaurant.imageURL)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxHeight: 250)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.black.opacity(0.1))
                                        .cornerRadius(16)
                                } placeholder: {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 250)
                                        .overlay(
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        )
                                }
                                
                                // Индикатор галереи
                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        
                                        HStack(spacing: 6) {
                                            Image(systemName: "photo.stack")
                                                .font(.caption)
                                                .foregroundColor(.white)
                                            
                                            Text("5 фото")
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .foregroundColor(.white)
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(
                                            Capsule()
                                                .fill(Color.black.opacity(0.6))
                                        )
                                        .padding(.trailing, 12)
                                        .padding(.bottom, 12)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Информация о ресторане
                    VStack(alignment: .leading, spacing: 16) {
                        // Название и рейтинг
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(restaurant.name)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
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
                        
                        // Отзывы
                        Button(action: { showingReviews = true }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Отзывы")
                                        .font(.headline)
                                        .foregroundColor(brandColors.primary)
                                    
                                    HStack(spacing: 4) {
                                        ForEach(0..<5) { index in
                                            Image(systemName: "star.fill")
                                                .font(.caption)
                                                .foregroundColor(index < Int(restaurant.rating) ? .yellow : .gray)
                                        }
                                        
                                        Text("\(String(format: "%.1f", restaurant.rating)) • 124 отзыва")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .padding()
                            .background(Color.black.opacity(0.8))
                            .cornerRadius(12)
                        }
                        
                        // Кнопки действий - ГЛАВНЫЕ И ВИДНЫЕ!
                        VStack(spacing: 12) {
                            // Бронирование - БОЛЬШАЯ КНОПКА
                            Button(action: { 
                                HapticManager.shared.buttonPress()
                                showingReservation = true 
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "calendar.badge.plus")
                                        .font(.system(size: 18, weight: .bold))
                                    Text("Забронировать столик")
                                        .font(.system(size: 18, weight: .bold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        colors: [brandColors.accent, brandColors.primary],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: brandColors.accent.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            
                            // Меню - ВТОРАЯ ВАЖНАЯ КНОПКА
                            Button(action: { 
                                HapticManager.shared.buttonPress()
                                showingMenu = true 
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "fork.knife")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Посмотреть меню")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(brandColors.primary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(brandColors.primary, lineWidth: 2)
                                        .background(Color.black.opacity(0.1))
                                )
                                .cornerRadius(14)
                            }
                            
                            // Дополнительные кнопки
                            HStack(spacing: 12) {
                                // Позвонить
                                Button(action: {
                                    HapticManager.shared.buttonPress()
                                    if let phoneURL = URL(string: "tel:\(restaurant.contacts.phone.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "-", with: ""))") {
                                        UIApplication.shared.open(phoneURL)
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "phone.fill")
                                        Text("Позвонить")
                                    }
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.green.opacity(0.8))
                                    .cornerRadius(10)
                                }
                                
                                // Маршрут
                                Button(action: {
                                    HapticManager.shared.buttonPress()
                                    
                                    // Используем Яндекс Карты
                                    if let url = YandexMapsConfig.routeURL(
                                        to: (restaurant.location.latitude, restaurant.location.longitude), 
                                        name: restaurant.name
                                    ) {
                                        if YandexMapsConfig.isYandexMapsInstalled {
                                            UIApplication.shared.open(url)
                                        } else {
                                            // Fallback на веб-версию
                                            if let webUrl = YandexMapsConfig.webURL(
                                                for: (restaurant.location.latitude, restaurant.location.longitude), 
                                                name: restaurant.name
                                            ) {
                                                UIApplication.shared.open(webUrl)
                                            }
                                        }
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "location.fill")
                                        Text("Маршрут")
                                    }
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.blue.opacity(0.8))
                                    .cornerRadius(10)
                                }
                            }
                        }
                        .padding(.vertical, 10)
                        
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
                                    ForEach(Array(restaurant.features.prefix(6)), id: \.self) { feature in
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
                        
                        // Карта
                        RestaurantMapView(restaurant: restaurant)
                            .frame(height: 200)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    
                    // Секция с резервациями для этого ресторана
                    if !restaurantReservationService.reservations.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Мои резервации")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Text("\(restaurantReservationService.reservations.count)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                            }
                            
                            ForEach(restaurantReservationService.reservations) { reservation in
                                RestaurantReservationCard(reservation: reservation)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.black)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        // Кнопка избранного
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                isFavorite.toggle()
                            }
                            UserDefaults.standard.set(isFavorite, forKey: "favorite_\(restaurant.id)")
                            if isFavorite {
                                HapticManager.shared.successPattern()
                            } else {
                                HapticManager.shared.warningPattern()
                            }
                        }) {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(isFavorite ? .red : .white)
                                .scaleEffect(isFavorite ? 1.2 : 1.0)
                        }
                        
                        // Кнопка поделиться
                        Button(action: shareRestaurant) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
            }
            .sheet(isPresented: $showingReservation) {
                ReservationFormView(restaurant: restaurant)
            }
            .sheet(isPresented: $showingMenu) {
                MenuView(restaurant: restaurant)
            }
            .sheet(isPresented: $showingPhotoGallery) {
                RestaurantPhotoGalleryView(restaurant: restaurant)
            }
            .sheet(isPresented: $showingReviews) {
                RestaurantReviewsView(restaurant: restaurant)
            }
            .onAppear {
                isFavorite = UserDefaults.standard.bool(forKey: "favorite_\(restaurant.id)")
                
                // Загружаем резервации для конкретного ресторана
                Task {
                    await restaurantReservationService.fetchReservationsForRestaurant(restaurant)
                }
            }
        }
    }
    
    private func shareRestaurant() {
        let shareText = "Проверь этот ресторан: \(restaurant.name) - \(restaurant.description)"
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
}

// MARK: - Restaurant Reservation Card
struct RestaurantReservationCard: View {
    let reservation: Reservation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(reservation.formattedDate)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Стол №\(reservation.tableNumber) • \(reservation.guestCount) чел.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                StatusBadge(status: reservation.status)
            }
            
            if let specialRequests = reservation.specialRequests, !specialRequests.isEmpty {
                Text(specialRequests)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 4)
            }
        }
        .padding(16)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}


struct RestaurantDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantDetailView(restaurant: Restaurant.mock)
    }
}