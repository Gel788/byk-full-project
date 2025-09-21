import SwiftUI

struct Reservation: Identifiable {
    let id: UUID
    let restaurant: Restaurant
    let date: Date
    let guestCount: Int
    var status: Status
    let tableNumber: Int
    var specialRequests: String?
    let createdAt: Date
    
    init(
        id: UUID = UUID(),
        restaurant: Restaurant,
        date: Date,
        guestCount: Int,
        status: Status = .pending,
        tableNumber: Int,
        specialRequests: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.restaurant = restaurant
        self.date = date
        self.guestCount = guestCount
        self.status = status
        self.tableNumber = tableNumber
        self.specialRequests = specialRequests
        self.createdAt = createdAt
    }
    
    enum Status: String, CaseIterable {
        case pending = "Ожидает подтверждения"
        case confirmed = "Подтверждено"
        case completed = "Завершено"
        case cancelled = "Отменено"
        
        var icon: String {
            switch self {
            case .pending: return "clock"
            case .confirmed: return "checkmark.circle"
            case .completed: return "star.fill"
            case .cancelled: return "xmark.circle"
            }
        }
        
        var color: Color {
            switch self {
            case .pending: return .orange
            case .confirmed: return .green
            case .completed: return .gray
            case .cancelled: return Colors.appError
            }
        }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var formattedCreatedAt: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }
    
    static var mockReservations: [Reservation] {
        [
            Reservation(
                restaurant: .mock,
                date: Date().addingTimeInterval(86400),
                guestCount: 4,
                status: .confirmed,
                tableNumber: 12,
                specialRequests: "Столик у окна, пожалуйста"
            ),
            Reservation(
                restaurant: .mock,
                date: Date().addingTimeInterval(172800),
                guestCount: 2,
                status: .pending,
                tableNumber: 5
            ),
            Reservation(
                restaurant: .mock,
                date: Date().addingTimeInterval(-86400),
                guestCount: 6,
                status: .completed,
                tableNumber: 8,
                specialRequests: "День рождения"
            ),
            Reservation(
                restaurant: .mock,
                date: Date().addingTimeInterval(-172800),
                guestCount: 3,
                status: .cancelled,
                tableNumber: 15
            )
        ]
    }
    
    static let mockActiveReservations: [Reservation] = [
        Reservation(
            restaurant: .mock,
            date: Date().addingTimeInterval(86400),
            guestCount: 4,
            status: .confirmed,
            tableNumber: 12,
            specialRequests: "Столик у окна, пожалуйста"
        ),
        Reservation(
            restaurant: .mock,
            date: Date().addingTimeInterval(172800),
            guestCount: 2,
            status: .pending,
            tableNumber: 5
        )
    ]
    
    static let mockPastReservations: [Reservation] = [
        Reservation(
            restaurant: .mock,
            date: Date().addingTimeInterval(-86400),
            guestCount: 6,
            status: .completed,
            tableNumber: 8,
            specialRequests: "День рождения"
        ),
        Reservation(
            restaurant: .mock,
            date: Date().addingTimeInterval(-172800),
            guestCount: 3,
            status: .cancelled,
            tableNumber: 15
        )
    ]
} 