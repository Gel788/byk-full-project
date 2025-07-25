import Foundation
import SwiftUI

@MainActor
class ReservationService: ObservableObject {
    @Published var reservations: [Reservation] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    init() {
        Task {
            await fetchReservations()
        }
    }
    
    func fetchReservations() async {
        isLoading = true
        defer { isLoading = false }
        
        // Симулируем задержку сети
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Загружаем тестовые данные
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
} 