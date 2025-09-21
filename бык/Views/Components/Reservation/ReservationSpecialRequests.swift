import SwiftUI

struct ReservationSpecialRequests: View {
    @Binding var specialRequests: String
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Особые пожелания")
                .font(.headline)
                .foregroundColor(.white)
            
            TextField("Дополнительные пожелания...", text: $specialRequests, axis: .vertical)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(.white)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.1))
                        .stroke(brandColors.primary.opacity(0.3), lineWidth: 1)
                )
                .lineLimit(3...6)
        }
    }
}
