import Foundation
import Combine
import SwiftUI

class RestaurantsViewModel: ObservableObject {
    @Published var restaurants: [Restaurant] = []
    @Published var brands: [Restaurant.Brand] = []
    @Published var cities: [String] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedBrand: Restaurant.Brand?
    @Published var selectedCity: String?
    @Published var searchText = ""
    
    private let apiService = APIService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadData()
    }
    
    // MARK: - Data Loading
    func loadData() {
        isLoading = true
        errorMessage = nil
        
        // Загружаем данные параллельно
        Publishers.Zip3(
            apiService.fetchBrands(),
            apiService.fetchCities(),
            apiService.fetchRestaurants()
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            },
            receiveValue: { [weak self] brands, cities, restaurants in
                self?.brands = brands.map { $0.toLocalBrand() }
                self?.cities = cities.map { $0.name }
                self?.restaurants = restaurants.map { $0.toLocalRestaurant() }
            }
        )
        .store(in: &cancellables)
    }
    
    func refreshData() {
        loadData()
    }
    
    // MARK: - Filtering
    var filteredRestaurants: [Restaurant] {
        var filtered = restaurants
        
        // Фильтр по бренду
        if let selectedBrand = selectedBrand {
            filtered = filtered.filter { $0.brand == selectedBrand }
        }
        
        // Фильтр по городу
        if let selectedCity = selectedCity {
            filtered = filtered.filter { $0.city == selectedCity }
        }
        
        // Фильтр по поиску
        if !searchText.isEmpty {
            filtered = filtered.filter { restaurant in
                restaurant.name.localizedCaseInsensitiveContains(searchText) ||
                restaurant.address.localizedCaseInsensitiveContains(searchText) ||
                restaurant.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered.sorted { $0.rating > $1.rating }
    }
    
    // MARK: - Actions
    func selectBrand(_ brand: Restaurant.Brand?) {
        selectedBrand = brand
    }
    
    func selectCity(_ city: String?) {
        selectedCity = city
    }
    
    func clearFilters() {
        selectedBrand = nil
        selectedCity = nil
        searchText = ""
    }
    
    // MARK: - Restaurant Details
    func loadRestaurantDetails(for restaurant: Restaurant) {
        // Здесь можно загрузить дополнительную информацию о ресторане
        // Например, меню, отзывы, доступные столы
    }
    
    // MARK: - Favorites (если нужно)
    @Published var favoriteRestaurants: Set<String> = []
    
    func toggleFavorite(restaurantId: UUID) {
        let idString = restaurantId.uuidString
        if favoriteRestaurants.contains(idString) {
            favoriteRestaurants.remove(idString)
        } else {
            favoriteRestaurants.insert(idString)
        }
    }
    
    func isFavorite(restaurantId: UUID) -> Bool {
        return favoriteRestaurants.contains(restaurantId.uuidString)
    }
    
    var favoriteRestaurantsList: [Restaurant] {
        return restaurants.filter { favoriteRestaurants.contains($0.id.uuidString) }
    }
}

// MARK: - Restaurant Extensions
extension Restaurant.Brand {
    static func getEmoji(for name: String) -> String {
        switch name.lowercased() {
        case "the бык":
            return "🐂"
        case "the pivo":
            return "🍺"
        case "mosca":
            return "🍝"
        default:
            return "🏪"
        }
    }
}
