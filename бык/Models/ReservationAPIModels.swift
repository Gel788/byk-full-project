import Foundation

// MARK: - API Request Models
struct CreateReservationRequest: Codable {
    let userId: String
    let restaurantId: String
    let restaurantName: String // Добавили обязательное поле
    let date: String // ISO 8601 format
    let guestCount: Int
    let tableNumber: Int
    let specialRequests: String?
    let contactPhone: String?
    let contactName: String?
}

struct UpdateReservationRequest: Codable {
    let status: String
    let specialRequests: String?
}

struct CancelReservationRequest: Codable {
    let reason: String?
}

// MARK: - API Response Models
struct ReservationResponse: Codable {
    let id: String
    let reservationNumber: String
    let restaurantId: String
    let restaurantName: String
    let userId: String
    let date: String // ISO 8601 format
    let guestCount: Int
    let status: String
    let tableNumber: Int
    let specialRequests: String?
    let contactPhone: String?
    let contactName: String?
    let createdAt: String // ISO 8601 format
    let updatedAt: String // ISO 8601 format
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case reservationNumber, restaurantId, restaurantName, userId
        case date, guestCount, status, tableNumber
        case specialRequests, contactPhone, contactName
        case createdAt, updatedAt
    }
}

struct ReservationsListResponse: Codable {
    let success: Bool
    let data: [ReservationResponse]
    let total: Int
    let page: Int
    let limit: Int
}

struct ReservationDetailResponse: Codable {
    let success: Bool
    let data: ReservationResponse
}

struct CreateReservationResponse: Codable {
    let success: Bool
    let message: String
    let data: ReservationResponse
}

struct UpdateReservationResponse: Codable {
    let success: Bool
    let message: String
    let data: ReservationResponse
}

struct CancelReservationResponse: Codable {
    let success: Bool
    let message: String
}

struct AvailableTablesResponse: Codable {
    let success: Bool
    let data: [AvailableTableResponse]
}

struct AvailableTableResponse: Codable {
    let tableNumber: Int
    let capacity: Int
    let location: String
    let isAvailable: Bool
    let availableTimes: [String] // Array of available time slots
}

// MARK: - Reservation Status Enum
enum ReservationAPIStatus: String, CaseIterable, Codable {
    case pending = "pending"
    case confirmed = "confirmed"
    case completed = "completed"
    case cancelled = "cancelled"
    
    var displayName: String {
        switch self {
        case .pending: return "Ожидает подтверждения"
        case .confirmed: return "Подтверждено"
        case .completed: return "Завершено"
        case .cancelled: return "Отменено"
        }
    }
    
    var icon: String {
        switch self {
        case .pending: return "clock"
        case .confirmed: return "checkmark.circle"
        case .completed: return "star.fill"
        case .cancelled: return "xmark.circle"
        }
    }
    
    var color: String {
        switch self {
        case .pending: return "orange"
        case .confirmed: return "green"
        case .completed: return "blue"
        case .cancelled: return "red"
        }
    }
}
