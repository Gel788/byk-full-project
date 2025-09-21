import SwiftUI
import Foundation

// MARK: - Map Filters Panel
struct MapFiltersPanel: View {
    @Binding var selectedCity: String?
    @Binding var selectedBrands: Set<Restaurant.Brand>
    let availableCities: [String]
    let availableBrands: [Restaurant.Brand]
    let restaurantsCount: Int
    @Binding var showingFilters: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            // Компактная панель фильтров
            HStack(spacing: 12) {
                // Фильтр по городу
                Menu {
                    Button("Все города") {
                        selectedCity = nil
                        HapticManager.shared.selection()
                    }
                    
                    ForEach(availableCities, id: \.self) { city in
                        Button(city) {
                            selectedCity = city
                            HapticManager.shared.selection()
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "location.circle.fill")
                            .font(.system(size: 14))
                        Text(selectedCity ?? "Город")
                            .font(.system(size: 14, weight: .medium))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                
                // Быстрые фильтры по брендам
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(availableBrands, id: \.self) { brand in
                            BrandFilterChip(
                                brand: brand,
                                isSelected: selectedBrands.contains(brand)
                            ) {
                                HapticManager.shared.selection()
                                if selectedBrands.contains(brand) {
                                    selectedBrands.remove(brand)
                                } else {
                                    selectedBrands.insert(brand)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                Spacer()
                
                // Счетчик ресторанов
                Text("\(restaurantsCount)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    )
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.8),
                    Color.black.opacity(0.4),
                    Color.clear
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

// MARK: - Brand Filter Chip
struct BrandFilterChip: View {
    let brand: Restaurant.Brand
    let isSelected: Bool
    let action: () -> Void
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color) {
        Colors.brandColors(for: brand)
    }
    
    private var brandName: String {
        switch brand {
        case .theByk: return "БЫК"
        case .thePivo: return "ПИВО"
        case .mosca: return "MOSCA"
        case .theGeorgia: return "ГРУЗИЯ"
        }
    }
    
    var body: some View {
        Button(action: action) {
            Text(brandName)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(isSelected ? .white : brandColors.accent)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? brandColors.accent : .clear)
                        .overlay(
                            Capsule()
                                .stroke(brandColors.accent, lineWidth: 1.5)
                        )
                )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Map Filters Sheet
struct MapFiltersSheet: View {
    @Binding var selectedCity: String?
    @Binding var selectedBrands: Set<Restaurant.Brand>
    let availableCities: [String]
    let availableBrands: [Restaurant.Brand]
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Фильтр по городам
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "location.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.blue)
                            Text("Города")
                                .font(.system(size: 18, weight: .bold))
                            Spacer()
                        }
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            MapCityFilterButton(
                                title: "Все города",
                                isSelected: selectedCity == nil
                            ) {
                                selectedCity = nil
                                HapticManager.shared.selection()
                            }
                            
                            ForEach(availableCities, id: \.self) { city in
                                MapCityFilterButton(
                                    title: city,
                                    isSelected: selectedCity == city
                                ) {
                                    selectedCity = city
                                    HapticManager.shared.selection()
                                }
                            }
                        }
                    }
                    
                    Divider()
                        .background(Color.white.opacity(0.2))
                    
                    // Фильтр по брендам
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "tag.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.orange)
                            Text("Бренды")
                                .font(.system(size: 18, weight: .bold))
                            Spacer()
                            
                            if !selectedBrands.isEmpty {
                                Button("Сбросить") {
                                    selectedBrands.removeAll()
                                    HapticManager.shared.selection()
                                }
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.blue)
                            }
                        }
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(availableBrands, id: \.self) { brand in
                                BrandFilterCard(
                                    brand: brand,
                                    isSelected: selectedBrands.contains(brand)
                                ) {
                                    HapticManager.shared.selection()
                                    if selectedBrands.contains(brand) {
                                        selectedBrands.remove(brand)
                                    } else {
                                        selectedBrands.insert(brand)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(Color.black)
            .navigationTitle("Фильтры")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold))
                }
            }
        }
    }
}

// MARK: - Map City Filter Button
struct MapCityFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.8))
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.2) : Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.blue : Color.white.opacity(0.3), lineWidth: 1.5)
                    )
            )
        }
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Brand Filter Card
struct BrandFilterCard: View {
    let brand: Restaurant.Brand
    let isSelected: Bool
    let action: () -> Void
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color) {
        Colors.brandColors(for: brand)
    }
    
    private var brandInfo: (name: String, description: String) {
        switch brand {
        case .theByk:
            return ("THE БЫК", "Мясная кухня")
        case .thePivo:
            return ("THE ПИВО", "Пивной ресторан")
        case .mosca:
            return ("MOSCA", "Европейская кухня")
        case .theGeorgia:
            return ("THE ГРУЗИЯ", "Грузинская кухня")
        }
    }
    
    private var selectedBackgroundGradient: LinearGradient {
        LinearGradient(
            colors: [brandColors.accent.opacity(0.3), brandColors.primary.opacity(0.2)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var unselectedBackgroundGradient: LinearGradient {
        LinearGradient(
            colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(brandInfo.name)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(brandColors.accent)
                    }
                }
                
                Text(brandInfo.description)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? selectedBackgroundGradient : unselectedBackgroundGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? brandColors.accent : Color.white.opacity(0.3), lineWidth: 1.5)
                    )
            )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Restaurant Map Card
struct RestaurantMapCard: View {
    let restaurant: Restaurant
    let onClose: () -> Void
    let onViewDetails: () -> Void
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color) {
        Colors.brandColors(for: restaurant.brand)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Заголовок карточки
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(restaurant.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(restaurant.address)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            // Информация о ресторане
            HStack(spacing: 16) {
                // Рейтинг
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 12))
                    Text("\(restaurant.rating, specifier: "%.1f")")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                // Кухня
                HStack(spacing: 4) {
                    Image(systemName: "fork.knife")
                        .foregroundColor(brandColors.accent)
                        .font(.system(size: 12))
                    Text(restaurant.cuisine)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Статус работы
                HStack(spacing: 4) {
                    Circle()
                        .fill(restaurant.workingHours.isOpen() ? .green : .red)
                        .frame(width: 8, height: 8)
                    Text(restaurant.workingHours.isOpen() ? "Открыто" : "Закрыто")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            // Кнопки действий
            HStack(spacing: 12) {
                // Маршрут
                Button(action: {
                    HapticManager.shared.buttonPress()
                    
                    if let url = YandexMapsConfig.routeURL(
                        to: (restaurant.location.latitude, restaurant.location.longitude), 
                        name: restaurant.name
                    ) {
                        if YandexMapsConfig.isYandexMapsInstalled {
                            UIApplication.shared.open(url)
                        } else {
                            if let webUrl = YandexMapsConfig.webURL(
                                for: (restaurant.location.latitude, restaurant.location.longitude), 
                                name: restaurant.name
                            ) {
                                UIApplication.shared.open(webUrl)
                            }
                        }
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "location.fill")
                        Text("Маршрут")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(brandColors.accent.opacity(0.5), lineWidth: 1.5)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.ultraThinMaterial)
                            )
                    )
                }
                
                // Подробнее
                Button(action: {
                    HapticManager.shared.buttonPress()
                    onViewDetails()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle.fill")
                        Text("Подробнее")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [brandColors.accent, brandColors.primary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(10)
                    .shadow(color: brandColors.accent.opacity(0.4), radius: 6, x: 0, y: 3)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    brandColors.accent.opacity(0.4),
                                    brandColors.accent.opacity(0.2),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        )
    }
}