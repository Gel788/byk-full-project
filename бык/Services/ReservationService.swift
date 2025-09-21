import Foundation
import SwiftUI
import Combine

@MainActor
class ReservationService: ObservableObject {
    @Published var reservations: [Reservation] = []
    @Published var availableTables: [AvailableTableResponse] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    private let apiService = APIService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        Task {
            await fetchReservations()
        }
    }
    
    func fetchReservations() async {
        isLoading = true
        defer { isLoading = false }
        
        print("ReservationService: Загружаем резервации через API")
        
        // Получаем текущего пользователя
        let currentUser = AuthService.shared.getCurrentUser()
        let userId = currentUser?.id.uuidString ?? "guest"
        
        // Загружаем резервации через API
        apiService.fetchUserReservations(userId: userId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        print("ReservationService: Ошибка загрузки резерваций - \(error)")
                        self?.error = error
                        // Убираем fallback на mock данные - показываем только реальные данные
                    }
                },
                receiveValue: { [weak self] response in
                    print("ReservationService: Загружено резерваций через API: \(response.data.count)")
                    self?.reservations = response.data.map { $0.toLocalReservation() }
                    self?.error = nil // Очищаем ошибку при успешной загрузке
                }
            )
            .store(in: &cancellables)
    }
    
    func fetchReservationsForRestaurant(_ restaurant: Restaurant) async {
        isLoading = true
        defer { isLoading = false }
        
        print("ReservationService: Загружаем резервации для ресторана \(restaurant.name)")
        
        // Получаем текущего пользователя
        let currentUser = AuthService.shared.getCurrentUser()
        let userId = currentUser?.id.uuidString ?? "guest"
        
        // Загружаем резервации конкретного ресторана через API
        apiService.fetchUserReservations(userId: userId, restaurantId: restaurant.id.uuidString)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        print("ReservationService: Ошибка загрузки резерваций ресторана - \(error)")
                        self?.error = error
                    }
                },
                receiveValue: { [weak self] response in
                    print("ReservationService: Загружено резерваций для ресторана \(restaurant.name): \(response.data.count)")
                    self?.reservations = response.data.map { $0.toLocalReservation() }
                    self?.error = nil
                }
            )
            .store(in: &cancellables)
    }
    
    private func loadMockData() async {
        // Загружаем тестовые данные если API недоступен
        reservations = [
            Reservation(
                restaurant: Restaurant.mock,
                date: Date().addingTimeInterval(3600 * 24),
                guestCount: 2,
                status: .confirmed,
                tableNumber: 12
            ),
            Reservation(
                restaurant: Restaurant.mock,
                date: Date().addingTimeInterval(3600 * 48),
                guestCount: 4,
                status: .pending,
                 tableNumber: 8,
                specialRequests: "Столик у окна"
            ),
            Reservation(
                restaurant: Restaurant.mock,
                date: Date().addingTimeInterval(-3600 * 24),
                guestCount: 3,
                status: .completed,
                tableNumber: 15
            )                              
        ]
    }
             
    func createReservation(
        restaurant: Restaurant,
        date: Date,
        guestCount: Int,
        tableNumber: Int,
        specialRequests: String? = nil,
        contactName: String? = nil,
        contactPhone: String? = nil
    ) async throws -> Reservation {
        isLoading = true
        defer { isLoading = false }
        
        // Получаем текущего пользователя
        let currentUser = AuthService.shared.getCurrentUser()
        let userId = currentUser?.id.uuidString ?? "guest"
        
        // Создаем запрос для API
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let timeString = dateFormatter.string(from: date)
        
        let request = CreateReservationRequest(
            userId: userId,
            restaurantId: restaurant.id.uuidString,
            restaurantName: restaurant.name, // Добавили обязательное поле
            date: ISO8601DateFormatter().string(from: date),
            time: timeString,
            guestCount: guestCount,
            tableNumber: tableNumber,
            specialRequests: specialRequests,
            contactPhone: contactPhone,
            contactName: contactName
        )
        
        // Отправляем запрос через API
        return try await withCheckedThrowingContinuation { continuation in
            apiService.createReservation(request)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            print("ReservationService: Ошибка создания резервации - \(error)")
                            continuation.resume(throwing: error)
                        }
                    },
                    receiveValue: { [weak self] response in
                        print("ReservationService: Резервация создана через API")
                        let reservation = response.toLocalReservation()
                        self?.reservations.append(reservation)
                        continuation.resume(returning: reservation)
                    }
                )
                .store(in: &cancellables)
        }
    }
    
    func createReservationLocal(
        restaurant: Restaurant,
        date: Date,
        guestCount: Int,
        tableNumber: Int,
        specialRequests: String? = nil
    ) -> Reservation {
        let reservation = Reservation(
            restaurant: restaurant,
            date: date,
            guestCount: guestCount,
            status: .pending,
            tableNumber: tableNumber,
            specialRequests: specialRequests
        )
        reservations.append(reservation)
        return reservation
    }
    
    func addReservation(_ reservation: Reservation) {
        reservations.append(reservation)
    }
    
    func isTableAvailable(
        restaurant: Restaurant,
        tableNumber: Int,
        at date: Date
    ) -> Bool {
        // Проверяем, нет ли других бронирований на этот стол в это время
        !reservations.contains { reservation in
            reservation.restaurant.id == restaurant.id &&
            reservation.tableNumber == tableNumber &&
            reservation.status != .cancelled &&
            Calendar.current.isDate(reservation.date, inSameDayAs: date)
        }
    }
    
    func updateReservation(_ reservation: Reservation, status: Reservation.Status) {
        if let index = reservations.firstIndex(where: { $0.id == reservation.id }) {
            var updatedReservation = reservation
            updatedReservation.status = status
            objectWillChange.send()
            reservations[index] = updatedReservation
        }
    }
    
    func cancelReservation(_ reservation: Reservation) {
        updateReservation(reservation, status: .cancelled)
    }
    
    func confirmReservation(_ reservation: Reservation) {
        updateReservation(reservation, status: .confirmed)
    }
    
    func completeReservation(_ reservation: Reservation) {
        updateReservation(reservation, status: .completed)
    }
    
    func fetchAvailableTables(for restaurantId: String, date: Date) async {
        isLoading = true
        defer { isLoading = false }
        
        // Форматируем дату для API
        let dateFormatter = ISO8601DateFormatter()
        let dateString = dateFormatter.string(from: date)
        
        // Загружаем доступные столы через API
        apiService.fetchAvailableTables(restaurantId: restaurantId, date: dateString)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        print("ReservationService: Ошибка загрузки столов - \(error)")
                        self?.error = error
                        // Убираем fallback на mock данные - показываем только реальные данные
                    }
                },
                receiveValue: { [weak self] response in
                    print("ReservationService: Загружено столов через API: \(response.data.count)")
                    self?.availableTables = response.data
                    self?.error = nil // Очищаем ошибку при успешной загрузке
                }
            )
            .store(in: &cancellables)
    }
    
    private func loadMockTables() {
        // Mock данные для столов
        availableTables = [
            AvailableTableResponse(
                tableNumber: 1,
                capacity: 2,
                location: "Зал",
                isAvailable: true,
                availableTimes: ["18:00", "19:00", "20:00"]
            ),
            AvailableTableResponse(
                tableNumber: 2,
                capacity: 4,
                location: "Зал",
                isAvailable: true,
                availableTimes: ["18:30", "19:30", "20:30"]
            ),
            AvailableTableResponse(
                tableNumber: 3,
                capacity: 6,
                location: "Терраса",
                isAvailable: false,
                availableTimes: []
            ),
            AvailableTableResponse(
                tableNumber: 4,
                capacity: 2,
                location: "У окна",
                isAvailable: true,
                availableTimes: ["18:00", "20:00", "21:00"]
            )
        ]
    }
} 