import SwiftUI

struct ReservationGuestsPicker: View {
    @Binding var selectedGuests: Int
    let guestRange: ClosedRange<Int>
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Количество гостей")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack {
                ForEach(guestRange, id: \.self) { count in
                    Button(action: {
                        selectedGuests = count
                    }) {
                        Text("\(count)")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(selectedGuests == count ? .black : .white)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(selectedGuests == count ? brandColors.accent : Color.clear)
                                    .stroke(brandColors.primary, lineWidth: 1)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
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
