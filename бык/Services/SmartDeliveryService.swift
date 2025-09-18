import Foundation
import CoreLocation
import SwiftUI

// MARK: - Delivery Zone Model
struct DeliveryZone: Identifiable, Codable {
    let id = UUID()
    let name: String
    let center: CLLocationCoordinate2D
    let radius: Double // в километрах
    let baseFee: Double
    let freeDeliveryThreshold: Double
    let maxDeliveryTime: Int // в минутах
    let isActive: Bool
    
    enum CodingKeys: String, CodingKey {
        case name, radius, baseFee, freeDeliveryThreshold, maxDeliveryTime, isActive
        case centerLatitude, centerLongitude
    }
    
    init(name: String, center: CLLocationCoordinate2D, radius: Double, baseFee: Double, freeDeliveryThreshold: Double, maxDeliveryTime: Int, isActive: Bool = true) {
        self.name = name
        self.center = center
        self.radius = radius
        self.baseFee = baseFee
        self.freeDeliveryThreshold = freeDeliveryThreshold
        self.maxDeliveryTime = maxDeliveryTime
        self.isActive = isActive
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        radius = try container.decode(Double.self, forKey: .radius)
        baseFee = try container.decode(Double.self, forKey: .baseFee)
        freeDeliveryThreshold = try container.decode(Double.self, forKey: .freeDeliveryThreshold)
        maxDeliveryTime = try container.decode(Int.self, forKey: .maxDeliveryTime)
        isActive = try container.decode(Bool.self, forKey: .isActive)
        
        let latitude = try container.decode(Double.self, forKey: .centerLatitude)
        let longitude = try container.decode(Double.self, forKey: .centerLongitude)
        center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(radius, forKey: .radius)
        try container.encode(baseFee, forKey: .baseFee)
        try container.encode(freeDeliveryThreshold, forKey: .freeDeliveryThreshold)
        try container.encode(maxDeliveryTime, forKey: .maxDeliveryTime)
        try container.encode(isActive, forKey: .isActive)
        try container.encode(center.latitude, forKey: .centerLatitude)
        try container.encode(center.longitude, forKey: .centerLongitude)
    }
}

// MARK: - Delivery Calculation Result
struct DeliveryCalculation {
    let isAvailable: Bool
    let deliveryFee: Double
    let estimatedTime: Int // в минутах
    let zone: DeliveryZone?
    let distance: Double // в километрах
    let isFreeDelivery: Bool
    let reason: String? // причина недоступности
}

// MARK: - Smart Delivery Service
@MainActor
class SmartDeliveryService: ObservableObject {
    @Published var deliveryZones: [DeliveryZone] = []
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var isCalculating = false
    @Published var lastCalculation: DeliveryCalculation?
    
    private let locationManager = LocationManager()
    
    init() {
        setupDeliveryZones()
        setupLocationManager()
    }
    
    // MARK: - Setup Methods
    
    private func setupDeliveryZones() {
        deliveryZones = [
            // Москва - центр
            DeliveryZone(
                name: "Центр Москвы",
                center: CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6173),
                radius: 5.0,
                baseFee: 200,
                freeDeliveryThreshold: 1500,
                maxDeliveryTime: 45
            ),
            
            // Москва - расширенная зона
            DeliveryZone(
                name: "Москва",
                center: CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6173),
                radius: 15.0,
                baseFee: 300,
                freeDeliveryThreshold: 2000,
                maxDeliveryTime: 60
            ),
            
            // Санкт-Петербург
            DeliveryZone(
                name: "Санкт-Петербург",
                center: CLLocationCoordinate2D(latitude: 59.9311, longitude: 30.3609),
                radius: 10.0,
                baseFee: 250,
                freeDeliveryThreshold: 1800,
                maxDeliveryTime: 50
            ),
            
            // Калуга
            DeliveryZone(
                name: "Калуга",
                center: CLLocationCoordinate2D(latitude: 54.5293, longitude: 36.2754),
                radius: 8.0,
                baseFee: 150,
                freeDeliveryThreshold: 1200,
                maxDeliveryTime: 40
            ),
            
            // Ереван
            DeliveryZone(
                name: "Ереван",
                center: CLLocationCoordinate2D(latitude: 40.1792, longitude: 44.4991),
                radius: 12.0,
                baseFee: 300,
                freeDeliveryThreshold: 1500,
                maxDeliveryTime: 55
            )
        ]
    }
    
    private func setupLocationManager() {
        locationManager.onLocationUpdate = { [weak self] location in
            self?.currentLocation = location.coordinate
        }
    }
    
    // MARK: - Public Methods
    
    func calculateDelivery(
        to address: String,
        coordinate: CLLocationCoordinate2D?,
        restaurant: Restaurant,
        orderAmount: Double
    ) async -> DeliveryCalculation {
        
        isCalculating = true
        defer { isCalculating = false }
        
        // Используем координаты или геокодируем адрес
        let deliveryCoordinate: CLLocationCoordinate2D
        
        if let coord = coordinate {
            deliveryCoordinate = coord
        } else {
            // Геокодирование адреса
            deliveryCoordinate = await geocodeAddress(address) ?? restaurant.location.coordinate
        }
        
        // Ищем подходящую зону доставки
        let availableZone = findDeliveryZone(for: deliveryCoordinate, restaurant: restaurant)
        
        guard let zone = availableZone else {
            let calculation = DeliveryCalculation(
                isAvailable: false,
                deliveryFee: 0,
                estimatedTime: 0,
                zone: nil,
                distance: 0,
                isFreeDelivery: false,
                reason: "Доставка в данный район недоступна"
            )
            lastCalculation = calculation
            return calculation
        }
        
        // Расчет расстояния
        let distance = calculateDistance(
            from: restaurant.location.coordinate,
            to: deliveryCoordinate
        )
        
        // Расчет стоимости доставки
        let deliveryFee = calculateDeliveryFee(
            distance: distance,
            zone: zone,
            orderAmount: orderAmount
        )
        
        // Расчет времени доставки
        let estimatedTime = calculateDeliveryTime(
            distance: distance,
            zone: zone,
            restaurant: restaurant
        )
        
        let calculation = DeliveryCalculation(
            isAvailable: true,
            deliveryFee: deliveryFee,
            estimatedTime: estimatedTime,
            zone: zone,
            distance: distance,
            isFreeDelivery: deliveryFee == 0,
            reason: nil
        )
        
        lastCalculation = calculation
        return calculation
    }
    
    func getAvailableZones(for restaurant: Restaurant) -> [DeliveryZone] {
        return deliveryZones.filter { zone in
            let distance = calculateDistance(
                from: restaurant.location.coordinate,
                to: zone.center
            )
            return distance <= zone.radius && zone.isActive
        }
    }
    
    func requestLocationPermission() {
        locationManager.requestLocationPermission()
    }
    
    func getCurrentLocation() async -> CLLocationCoordinate2D? {
        return await locationManager.getCurrentLocation()?.coordinate
    }
    
    // MARK: - Private Methods
    
    private func findDeliveryZone(
        for coordinate: CLLocationCoordinate2D,
        restaurant: Restaurant
    ) -> DeliveryZone? {
        
        return deliveryZones
            .filter { $0.isActive }
            .sorted { $0.radius < $1.radius } // Сначала более точные зоны
            .first { zone in
                let distanceFromZoneCenter = calculateDistance(
                    from: zone.center,
                    to: coordinate
                )
                let distanceFromRestaurant = calculateDistance(
                    from: restaurant.location.coordinate,
                    to: coordinate
                )
                
                return distanceFromZoneCenter <= zone.radius &&
                       distanceFromRestaurant <= zone.radius
            }
    }
    
    private func calculateDistance(
        from: CLLocationCoordinate2D,
        to: CLLocationCoordinate2D
    ) -> Double {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLocation.distance(from: toLocation) / 1000.0 // в километрах
    }
    
    private func calculateDeliveryFee(
        distance: Double,
        zone: DeliveryZone,
        orderAmount: Double
    ) -> Double {
        
        // Бесплатная доставка при превышении порога
        if orderAmount >= zone.freeDeliveryThreshold {
            return 0
        }
        
        // Базовая стоимость + доплата за расстояние
        let baseFee = zone.baseFee
        let distanceFee = max(0, (distance - 3.0)) * 50 // 50₽ за каждый км свыше 3км
        
        return baseFee + distanceFee
    }
    
    private func calculateDeliveryTime(
        distance: Double,
        zone: DeliveryZone,
        restaurant: Restaurant
    ) -> Int {
        
        // Базовое время приготовления
        let preparationTime = restaurant.deliveryTime
        
        // Время в пути (примерно 2 км за 5 минут в городе)
        let travelTime = Int(distance * 2.5)
        
        // Дополнительное время в зависимости от загруженности
        let currentHour = Calendar.current.component(.hour, from: Date())
        let rushHourMultiplier: Double
        
        switch currentHour {
        case 12...14, 18...20: // Часы пик
            rushHourMultiplier = 1.3
        case 11, 15...17, 21: // Умеренная загруженность
            rushHourMultiplier = 1.1
        default: // Спокойное время
            rushHourMultiplier = 1.0
        }
        
        let totalTime = Int(Double(preparationTime + travelTime) * rushHourMultiplier)
        
        return min(totalTime, zone.maxDeliveryTime)
    }
    
    private func geocodeAddress(_ address: String) async -> CLLocationCoordinate2D? {
        let geocoder = CLGeocoder()
        
        do {
            let placemarks = try await geocoder.geocodeAddressString(address)
            return placemarks.first?.location?.coordinate
        } catch {
            print("Ошибка геокодирования: \(error)")
            return nil
        }
    }
}

// MARK: - Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    var onLocationUpdate: ((CLLocation) -> Void)?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func getCurrentLocation() async -> CLLocation? {
        return await withCheckedContinuation { continuation in
            guard locationManager.authorizationStatus == .authorizedWhenInUse ||
                  locationManager.authorizationStatus == .authorizedAlways else {
                continuation.resume(returning: nil)
                return
            }
            
            locationManager.requestLocation()
            
            // Таймаут на случай если геолокация не отвечает
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                continuation.resume(returning: nil)
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        onLocationUpdate?(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Ошибка геолокации: \(error)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        default:
            break
        }
    }
}