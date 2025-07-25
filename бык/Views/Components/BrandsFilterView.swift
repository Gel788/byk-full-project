import SwiftUI

struct BrandsFilterView: View {
    let selectedBrand: Restaurant.Brand?
    let onSelect: (Restaurant.Brand?) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                BrandFilterButton(
                    title: "Все бренды",
                    isSelected: selectedBrand == nil,
                    brandColors: Colors.brandColors(for: .theByk),
                    action: { onSelect(nil) }
                )
                
                ForEach(Restaurant.Brand.allCases, id: \.self) { brand in
                    BrandFilterButton(
                        title: brand.rawValue,
                        isSelected: selectedBrand == brand,
                        brandColors: Colors.brandColors(for: brand),
                        action: { onSelect(brand) }
                    )
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct CityFilterView: View {
    let selectedCity: String?
    let cities: [String]
    let onSelect: (String?) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CityFilterButton(
                    title: "Все города",
                    isSelected: selectedCity == nil,
                    action: { onSelect(nil) }
                )
                
                ForEach(cities, id: \.self) { city in
                    CityFilterButton(
                        title: city,
                        isSelected: selectedCity == city,
                        action: { onSelect(city) }
                    )
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct CityFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .white.opacity(0.8))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected ? Color.blue : Color.black.opacity(0.6)
                )
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct BrandFilterButton: View {
    let title: String
    let isSelected: Bool
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : brandColors.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected ? brandColors.accent : Color.black.opacity(0.6)
                )
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? brandColors.accent : Color.clear, lineWidth: 2)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    BrandsFilterView(selectedBrand: nil) { _ in }
        .environmentObject(RestaurantService())
} 