import SwiftUI
import MapKit

struct RestaurantDetailView: View {
    let restaurant: Restaurant
    @Environment(\.dismiss) private var dismiss
    @Namespace private var animation
    @State private var selectedTab: Tab = .menu
    @State private var showMap = false
    
    private let imageHeight: CGFloat = 300
    
    enum Tab: String {
        case menu = "Меню"
        case info = "Информация"
        case reviews = "Отзывы"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                RestaurantImage(restaurant: restaurant, imageHeight: imageHeight)
                
                RestaurantInfo(restaurant: restaurant)
                    .padding(.horizontal)
                
                TabHeader(selectedTab: $selectedTab, animation: animation)
                    .padding(.top)
                
                ContentTabs(selectedTab: selectedTab, restaurant: restaurant)
            }
        }
        .ignoresSafeArea(edges: .top)
        .overlay(alignment: .topLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.white)
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            .padding(.top, 47)
            .padding(.leading)
        }
    }
}

// MARK: - Restaurant Image
private struct RestaurantImage: View {
    let restaurant: Restaurant
    let imageHeight: CGFloat
    
    var body: some View {
        AsyncImage(url: URL(string: restaurant.imageURL)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Color.gray.opacity(0.3)
        }
        .frame(height: imageHeight)
        .clipped()
    }
}

// MARK: - Restaurant Info
private struct RestaurantInfo: View {
    let restaurant: Restaurant
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(restaurant.name)
                .font(.title.weight(.bold))
            
            HStack {
                Label("\(restaurant.rating, specifier: "%.1f")", systemImage: "star.fill")
                    .foregroundColor(.yellow)
                
                Text("•")
                
                Text(restaurant.cuisine)
                
                if let deliveryTime = restaurant.deliveryTime {
                    Text("•")
                    Label("\(deliveryTime) мин", systemImage: "bicycle")
                }
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            
            Text(restaurant.description)
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
        .padding(.top, 16)
    }
}

// MARK: - Tab Header
private struct TabHeader: View {
    @Binding var selectedTab: RestaurantDetailView.Tab
    var animation: Namespace.ID
    
    var body: some View {
        HStack {
            ForEach(RestaurantDetailView.Tab.allCases, id: \.self) { tab in
                VStack {
                    Text(tab.rawValue)
                        .font(.headline)
                        .foregroundColor(selectedTab == tab ? .primary : .secondary)
                    
                    if selectedTab == tab {
                        Rectangle()
                            .fill(Color.accentColor)
                            .frame(height: 2)
                            .matchedGeometryEffect(id: "TAB", in: animation)
                    }
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.spring()) {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Content Tabs
private struct ContentTabs: View {
    let selectedTab: RestaurantDetailView.Tab
    let restaurant: Restaurant
    
    var body: some View {
        Group {
            switch selectedTab {
            case .menu:
                MenuSection(restaurant: restaurant)
            case .info:
                InfoSection(restaurant: restaurant)
            case .reviews:
                ReviewsSection(restaurant: restaurant)
            }
        }
        .padding(.top)
    }
}

// MARK: - Menu Section
private struct MenuSection: View {
    let restaurant: Restaurant
    
    var body: some View {
        LazyVStack(spacing: 16) {
            ForEach(restaurant.menu) { dish in
                DishCard(dish: dish)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Info Section
private struct InfoSection: View {
    let restaurant: Restaurant
    @State private var showMap = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            DescriptionSection(restaurant: restaurant)
            FeaturesSection(features: Array(restaurant.features))
            LocationSection(restaurant: restaurant, showMap: $showMap)
            ContactsSection(restaurant: restaurant)
        }
        .padding(.horizontal)
        .sheet(isPresented: $showMap) {
            RestaurantMapView(restaurant: restaurant)
        }
    }
}

private struct DescriptionSection: View {
    let restaurant: Restaurant
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("О ресторане")
                .font(.title2.weight(.bold))
            
            Text(restaurant.description)
                .foregroundColor(.secondary)
        }
    }
}

private struct FeaturesSection: View {
    let features: [RestaurantFeature]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Особенности")
                .font(.title2.weight(.bold))
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 12) {
                ForEach(features, id: \.self) { feature in
                    Label {
                        Text(feature.rawValue)
                    } icon: {
                        Image(systemName: feature.icon)
                    }
                }
            }
        }
    }
}

private struct LocationSection: View {
    let restaurant: Restaurant
    @Binding var showMap: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Расположение")
                .font(.title2.weight(.bold))
            
            Button {
                showMap = true
            } label: {
                HStack {
                    Text(restaurant.address)
                        .foregroundColor(.secondary)
                    Spacer()
                    Image(systemName: "map")
                        .foregroundColor(.accentColor)
                }
            }
        }
    }
}

private struct ContactsSection: View {
    let restaurant: Restaurant
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Контакты")
                .font(.title2.weight(.bold))
            
            VStack(alignment: .leading, spacing: 12) {
                Link(destination: URL(string: "tel:+74951234567")!) {
                    Label("+ 7 (495) 123-45-67", systemImage: "phone")
                }
                
                Link(destination: URL(string: "mailto:info@thebyk.ru")!) {
                    Label("info@thebyk.ru", systemImage: "envelope")
                }
            }
            .foregroundColor(.secondary)
        }
    }
}

// MARK: - Reviews Section
private struct ReviewsSection: View {
    let restaurant: Restaurant
    
    var body: some View {
        Text("Отзывы")
            .padding(.horizontal)
    }
}

// MARK: - Map View
private struct RestaurantMapView: View {
    let restaurant: Restaurant
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Map(coordinateRegion: .constant(MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: restaurant.location.latitude,
                    longitude: restaurant.location.longitude
                ),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )), annotationItems: [restaurant]) { restaurant in
                MapMarker(
                    coordinate: CLLocationCoordinate2D(
                        latitude: restaurant.location.latitude,
                        longitude: restaurant.location.longitude
                    ),
                    tint: .red
                )
            }
            .navigationTitle(restaurant.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
    }
}

extension RestaurantDetailView.Tab: CaseIterable {}

#Preview {
    RestaurantDetailView(restaurant: .mock)
} 