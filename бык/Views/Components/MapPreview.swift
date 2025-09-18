import SwiftUI
import Foundation

#Preview("Карта ресторанов") {
    NavigationStack {
        RestaurantsMapView()
            .environmentObject(RestaurantService())
    }
    .preferredColorScheme(.dark)
}

#Preview("Фильтры карты") {
    MapFiltersSheet(
        selectedCity: Binding.constant("Москва"),
        selectedBrands: Binding.constant([Restaurant.Brand.theByk, Restaurant.Brand.thePivo]),
        availableCities: ["Москва", "Санкт-Петербург", "Казань"],
        availableBrands: Restaurant.Brand.allCases
    )
    .preferredColorScheme(.dark)
}

#Preview("Карточка ресторана") {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack {
            Spacer()
            RestaurantMapCard(
                restaurant: Restaurant.mock,
                onClose: {},
                onViewDetails: {}
            )
            .padding()
        }
    }
    .preferredColorScheme(.dark)
}