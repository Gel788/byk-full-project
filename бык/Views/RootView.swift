import SwiftUI

struct RootView: View {
    @StateObject private var coordinator = AppCoordinator()
    @State private var selectedTab = 0
    @State private var showProfile = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            switch coordinator.currentState {
            case .splash:
                SplashScreenView()
                    .onAppear {
                        coordinator.startApp()
                    }
                
            case .main:
                // Основное приложение
                MainTabView()
                    .environmentObject(coordinator.services.restaurantService)
                    .environmentObject(coordinator.services.cartViewModel)
                    .environmentObject(coordinator.services.reservationService)
                    .environmentObject(coordinator.services.authService)
                    .environmentObject(coordinator.services.userDataService)
                    .tint(.white)
                    .preferredColorScheme(.dark)
                .sheet(isPresented: $showProfile) {
                    ProfileView_Simple()
                        .environmentObject(coordinator.services.authService)
                        .environmentObject(coordinator.services.userDataService)
                }
                
            case .error(let message):
                ErrorView(error: NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: message])) {
                    coordinator.dismissError()
                }
            }
        }
        .alert("Ошибка", isPresented: .constant(coordinator.errorMessage != nil)) {
            Button("OK") {
                coordinator.dismissError()
            }
        } message: {
            if let errorMessage = coordinator.errorMessage {
                Text(errorMessage)
            }
        }
    }
}

#Preview {
    RootView()
} 
