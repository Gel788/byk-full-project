import SwiftUI

struct RestaurantMapView: View {
    let restaurant: Restaurant
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        YandexMapViewWithActions(restaurant: restaurant)
    }
}

#Preview {
    RestaurantMapView(restaurant: .mock)
} 