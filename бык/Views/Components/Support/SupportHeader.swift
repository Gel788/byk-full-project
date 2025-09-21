import SwiftUI

struct SupportHeader: View {
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(spacing: 16) {
            // Иконка поддержки
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [brandColors.accent, brandColors.primary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "headphones.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 8) {
                Text("Служба поддержки")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Мы всегда готовы помочь!")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 20)
    }
}
