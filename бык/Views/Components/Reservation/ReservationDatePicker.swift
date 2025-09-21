import SwiftUI

struct ReservationDatePicker: View {
    @Binding var selectedDate: Date
    @Binding var selectedTime: Date
    let dateRange: ClosedRange<Date>
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Дата и время")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                // Выбор даты
                DatePicker(
                    "Дата",
                    selection: $selectedDate,
                    in: dateRange,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .colorScheme(.dark)
                .accentColor(brandColors.accent)
                
                // Выбор времени
                DatePicker(
                    "Время",
                    selection: $selectedTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.compact)
                .colorScheme(.dark)
                .accentColor(brandColors.accent)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .stroke(brandColors.primary.opacity(0.3), lineWidth: 1)
            )
        }
    }
}
