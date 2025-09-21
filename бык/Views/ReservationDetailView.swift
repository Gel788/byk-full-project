import SwiftUI

struct ReservationDetailView: View {
    let reservation: Reservation
    @Environment(\.dismiss) private var dismiss
    @State private var showingCancelAlert = false
    @State private var showingEditReservation = false
    @State private var showingMap = false
    @State private var showingQRCode = false
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color) {
        Colors.brandColors(for: reservation.restaurant.brand)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Заголовок с изображением ресторана
                    RestaurantHeaderSection(restaurant: reservation.restaurant, brandColors: brandColors)
                    
                    // Статус бронирования
                    ReservationStatusSection(reservation: reservation, brandColors: brandColors)
                    
                    // Детали бронирования
                    ReservationDetailsSection(reservation: reservation, brandColors: brandColors)
                    
                    // Особые пожелания (если есть)
                    if let specialRequests = reservation.specialRequests, !specialRequests.isEmpty {
                        ReservationSpecialRequestsSection(specialRequests: specialRequests, brandColors: brandColors)
                    }
                    
                    // Информация о ресторане
                    ReservationRestaurantInfoSection(restaurant: reservation.restaurant, brandColors: brandColors)
                    
                    // Карта
                    MapSection(restaurant: reservation.restaurant, showingMap: $showingMap)
                    
                    // QR-код
                    QRCodeSection(reservation: reservation, showingQRCode: $showingQRCode, brandColors: brandColors)
                    
                    // Кнопки действий
                    ActionButtonsSection(
                        reservation: reservation,
                        brandColors: brandColors,
                        onCancel: { showingCancelAlert = true },
                        onEdit: { showingEditReservation = true }
                    )
                }
                .padding()
            }
            .navigationTitle("Детали бронирования")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.black)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
            .alert("Отменить бронирование?", isPresented: $showingCancelAlert) {
                Button("Отмена", role: .cancel) { }
                Button("Отменить", role: .destructive) {
                    // TODO: Отмена бронирования
                    dismiss()
                }
            } message: {
                Text("Это действие нельзя отменить")
            }
            .sheet(isPresented: $showingEditReservation) {
                ReservationFormView(restaurant: reservation.restaurant)
            }
            .sheet(isPresented: $showingMap) {
                RestaurantMapDetailView(restaurant: reservation.restaurant)
            }
            .sheet(isPresented: $showingQRCode) {
                QRCodeDetailView(reservation: reservation, brandColors: brandColors)
            }
        }
        .background(Color.black)
    }
}

// MARK: - Restaurant Header Section
private struct RestaurantHeaderSection: View {
    let restaurant: Restaurant
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Изображение ресторана
            AsyncImage(url: URL(string: restaurant.imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 200)
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } placeholder: {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 200)
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    )
            }
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .clear,
                            brandColors.primary.opacity(0.3)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            VStack(alignment: .leading, spacing: 8) {
                Text(restaurant.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(brandColors.primary)
                
                Text(restaurant.address)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 16) {
                    Label(
                        String(format: "%.1f", restaurant.rating),
                        systemImage: "star.fill"
                    )
                    .foregroundColor(.yellow)
                    
                    Label(
                        "\(restaurant.deliveryTime) мин",
                        systemImage: "clock"
                    )
                    .foregroundColor(.secondary)
                }
                .font(.caption)
            }
        }
        .padding()
        .background(Color.black.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Reservation Status Section
private struct ReservationStatusSection: View {
    let reservation: Reservation
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: reservation.status.icon)
                    .font(.title2)
                    .foregroundColor(reservation.status.color)
                
                Text(reservation.status.rawValue)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(reservation.status.color)
            }
            
            Text(statusDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(reservation.status.color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var statusDescription: String {
        switch reservation.status {
        case .pending:
            return "Ваше бронирование ожидает подтверждения от ресторана"
        case .confirmed:
            return "Бронирование подтверждено! Ждем вас в указанное время"
        case .completed:
            return "Бронирование завершено. Спасибо за посещение!"
        case .cancelled:
            return "Бронирование было отменено"
        }
    }
}

// MARK: - Reservation Details Section
private struct ReservationDetailsSection: View {
    let reservation: Reservation
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Детали бронирования", systemImage: "info.circle")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(brandColors.primary)
            
            VStack(spacing: 12) {
                DetailRow(
                    icon: "calendar",
                    title: "Дата и время",
                    value: formatDate(reservation.date),
                    color: brandColors.accent
                )
                
                DetailRow(
                    icon: "person.2",
                    title: "Количество гостей",
                    value: "\(reservation.guestCount) \(guestCountText(reservation.guestCount))",
                    color: brandColors.accent
                )
                
                DetailRow(
                    icon: "number",
                    title: "Номер стола",
                    value: "Стол №\(reservation.tableNumber)",
                    color: brandColors.accent
                )
                
                DetailRow(
                    icon: "clock",
                    title: "Создано",
                    value: formatCreatedDate(reservation.createdAt),
                    color: brandColors.accent
                )
            }
        }
        .padding()
        .background(Color.black.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatCreatedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func guestCountText(_ count: Int) -> String {
        switch count {
        case 1: return "гость"
        case 2...4: return "гостя"
        default: return "гостей"
        }
    }
}

// MARK: - Special Requests Section
private struct ReservationSpecialRequestsSection: View {
    let specialRequests: String
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Особые пожелания", systemImage: "text.bubble")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(brandColors.primary)
            
            Text(specialRequests)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding()
                .background(brandColors.secondary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding()
        .background(Color.black.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Restaurant Info Section
private struct ReservationRestaurantInfoSection: View {
    let restaurant: Restaurant
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Информация о ресторане", systemImage: "building.2")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(brandColors.primary)
            
            VStack(spacing: 12) {
                ReservationInfoRow(
                    icon: "clock",
                    title: "Часы работы",
                    value: "\(restaurant.workingHours.openTime) - \(restaurant.workingHours.closeTime)",
                    brandColors: brandColors
                )
                
                ReservationInfoRow(
                    icon: "creditcard",
                    title: "Средний чек",
                    value: "\(restaurant.averageCheck) ₽",
                    brandColors: brandColors
                )
                
                ReservationInfoRow(
                    icon: "phone",
                    title: "Телефон",
                    value: restaurant.contacts.phone,
                    brandColors: brandColors
                )
                
                if !restaurant.contacts.email.isEmpty {
                    ReservationInfoRow(
                        icon: "envelope",
                        title: "Email",
                        value: restaurant.contacts.email,
                        brandColors: brandColors
                    )
                }
            }
        }
        .padding()
        .background(Color.black.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Map Section
private struct MapSection: View {
    let restaurant: Restaurant
    @Binding var showingMap: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Расположение", systemImage: "map")
                .font(.title3)
                .fontWeight(.bold)
            
            Button(action: { showingMap = true }) {
                YandexMapView(restaurant: restaurant)
                    .frame(height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
            .buttonStyle(PlainButtonStyle())
            
            Text("Нажмите для просмотра на карте")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.black.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

// MARK: - QR Code Section
private struct QRCodeSection: View {
    let reservation: Reservation
    @Binding var showingQRCode: Bool
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(spacing: 12) {
            Label("QR-код бронирования", systemImage: "qrcode")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(brandColors.primary)
            
            Button(action: { showingQRCode = true }) {
                VStack(spacing: 8) {
                    Image(systemName: "qrcode")
                        .font(.system(size: 60))
                        .foregroundColor(brandColors.accent)
                    
                    Text("Нажмите для просмотра")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(brandColors.accent.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(PlainButtonStyle())
            
            Text("Номер бронирования: \(reservation.id.uuidString.prefix(8).uppercased())")
                .font(.caption)
                .foregroundColor(.secondary)
                .monospaced()
        }
        .padding()
        .background(Color.black.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Action Buttons Section
private struct ActionButtonsSection: View {
    let reservation: Reservation
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let onCancel: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            if reservation.status == .pending || reservation.status == .confirmed {
                Button(action: onEdit) {
                    Label("Изменить бронирование", systemImage: "pencil")
                        .font(.headline)
                        .foregroundColor(brandColors.primary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(brandColors.secondary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            
            if reservation.status == .pending || reservation.status == .confirmed {
                Button(action: onCancel) {
                    Label("Отменить бронирование", systemImage: "xmark.circle")
                        .font(.headline)
                        .foregroundColor(Colors.appError)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Colors.appError.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
}



// MARK: - Info Row
private struct ReservationInfoRow: View {
    let icon: String
    let title: String
    let value: String
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(brandColors.accent)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
    }
}

// MARK: - Restaurant Map Detail View
private struct RestaurantMapDetailView: View {
    let restaurant: Restaurant
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            YandexMapViewWithActions(restaurant: restaurant)
        }
    }
}

// MARK: - QR Code Detail View
private struct QRCodeDetailView: View {
    let reservation: Reservation
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "qrcode")
                        .font(.system(size: 200))
                        .foregroundColor(brandColors.accent)
                    
                    Text("QR-код бронирования")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(brandColors.primary)
                    
                    Text("Номер бронирования:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(reservation.id.uuidString.prefix(8).uppercased())
                        .font(.title)
                        .fontWeight(.bold)
                        .monospaced()
                        .foregroundColor(brandColors.accent)
                }
                
                VStack(spacing: 8) {
                    Text("Покажите этот QR-код администратору ресторана")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Text("Дата: \(formatDate(reservation.date))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .navigationTitle("QR-код")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

extension Reservation {
    static let mock = Reservation(
        id: UUID(),
        restaurant: Restaurant.mock,
        date: Date().addingTimeInterval(24 * 3600),
        guestCount: 4,
        status: .confirmed,
        tableNumber: 12,
        specialRequests: "Столик у окна, пожалуйста"
    )
}

#Preview {
    ReservationDetailView(reservation: Reservation.mock)
} 