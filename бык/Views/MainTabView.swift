import SwiftUI

struct MainTabView: View {
    @StateObject private var cartViewModel = CartViewModel(restaurantService: RestaurantService(), menuService: MenuService())
    @StateObject private var reservationService = ReservationService()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            RestaurantsView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Рестораны")
                }
                .tag(0)
            
            MenuListView()
                .tabItem {
                    Image(systemName: "fork.knife")
                    Text("Меню")
                }
                .tag(1)
            
            NewsView_New()
                .tabItem {
                    Image(systemName: "newspaper.fill")
                    Text("Новости")
                }
                .tag(2)
            
            ReservationsView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Бронирование")
                }
                .tag(3)
            
            CartView()
                .tabItem {
                    Image(systemName: "cart.fill")
                    Text("Корзина")
                }
                .tag(4)
        }
        .accentColor(.blue)
        .environmentObject(reservationService)
    }
}

#Preview {
    MainTabView()
        .environmentObject(RestaurantService())
        .environmentObject(MenuService())
        .environmentObject(CartViewModel(restaurantService: RestaurantService(), menuService: MenuService()))
        .environmentObject(ReservationService())
}