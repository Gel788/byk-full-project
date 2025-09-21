import SwiftUI
import Combine

// MARK: - App State
enum AppState {
    case splash
    case main
    case error(String)
}

// MARK: - App Services
@MainActor
class AppServices: ObservableObject {
    let authService = AuthService.shared  // Используем shared instance
    let restaurantService = RestaurantService()
    let menuService = MenuService()
    let cartViewModel: CartViewModel
    let reservationService = ReservationService()
    let userDataService = UserDataService()
    
    init() {
        self.cartViewModel = CartViewModel(restaurantService: restaurantService, menuService: menuService)
        // Связываем UserDataService с AuthService
        self.userDataService.setAuthService(authService)
    }
}

// MARK: - App Coordinator
@MainActor
class AppCoordinator: ObservableObject {
    @Published var currentState: AppState = .splash
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    let services: AppServices
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.services = AppServices()
        setupErrorHandling()
    }
    
    // MARK: - State Management
    func startApp() {
        isLoading = true
        
        // Имитация загрузки данных с временем для анимации
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 секунды для анимации
            await MainActor.run {
                self.isLoading = false
                self.currentState = .main
            }
        }
    }
    
    func showError(_ message: String) {
        errorMessage = message
        currentState = .error(message)
    }
    
    func dismissError() {
        errorMessage = nil
        if case .error = currentState {
            currentState = .main
        }
    }
    
    // MARK: - Error Handling
    private func setupErrorHandling() {
        // Подписываемся на ошибки от сервисов
        services.restaurantService.$error
            .compactMap { $0 }
            .sink { [weak self] error in
                self?.showError(error)
            }
            .store(in: &cancellables)
        
        services.cartViewModel.$error
            .compactMap { $0 }
            .sink { [weak self] error in
                self?.showError(error)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Navigation
    func navigateToRestaurant(_ restaurant: Restaurant) {
        // Логика навигации к ресторану
    }
    
    func navigateToCart() {
        // Логика навигации к корзине
    }
    
    func navigateToProfile() {
        // Логика навигации к профилю
    }
}

// MARK: - Error Types
enum AppError: LocalizedError {
    case networkError
    case dataError
    case authenticationError
    case cartError(String)
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Ошибка сети. Проверьте подключение к интернету."
        case .dataError:
            return "Ошибка загрузки данных. Попробуйте еще раз."
        case .authenticationError:
            return "Ошибка авторизации. Войдите в систему."
        case .cartError(let message):
            return "Ошибка корзины: \(message)"
        }
    }
} 