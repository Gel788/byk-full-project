import SwiftUI

struct ReservationCardView: View {
    let reservation: Reservation
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Заголовок с рестораном
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(reservation.restaurant.name)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(reservation.restaurant.address)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // Статус
                    StatusBadge(status: reservation.status)
                }
                
                // Детали бронирования
                VStack(spacing: 8) {
                    ReservationCardDetailRow(
                        icon: "calendar",
                        title: "Дата и время",
                        value: reservation.formattedDate
                    )
                    
                    ReservationCardDetailRow(
                        icon: "person.2",
                        title: "Гости",
                        value: "\(reservation.guestCount) чел."
                    )
                    
                    ReservationCardDetailRow(
                        icon: "table.furniture",
                        title: "Стол",
                        value: "№\(reservation.tableNumber)"
                    )
                }
                
                // Особые пожелания
                if let specialRequests = reservation.specialRequests, !specialRequests.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Особые пожелания")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text(specialRequests)
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.2))
                            )
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Status Badge
struct StatusBadge: View {
    let status: Reservation.Status
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.icon)
                .font(.caption)
            
            Text(status.rawValue)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(status.color)
        )
    }
}

// MARK: - Reservation Card Detail Row
struct ReservationCardDetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(Color("BykAccent"))
                .frame(width: 16)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .foregroundColor(.white)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        ReservationCardView(reservation: Reservation.mockReservations[0]) {
            print("Tapped reservation")
        }
        
        ReservationCardView(reservation: Reservation.mockReservations[1]) {
            print("Tapped reservation")
        }
    }
    .padding()
    .background(Color.black)
}
