import SwiftUI

struct AnimatedLogo: View {
    @State private var isAnimating = false
    @State private var rotationAngle: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Внешние кольца
            ForEach(0..<3) { index in
                Circle()
                    .stroke(Color.black.opacity(0.3 - Double(index) * 0.1), lineWidth: 2)
                    .frame(width: 140 + CGFloat(index * 20), height: 140 + CGFloat(index * 20))
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .opacity(isAnimating ? 0.5 : 0.8)
                    .animation(
                        .easeInOut(duration: 2.0)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.2),
                        value: isAnimating
                    )
            }
            
            // Основной круг
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.black.opacity(0.3), Color.black.opacity(0.1)],
                        center: .center,
                        startRadius: 20,
                        endRadius: 60
                    )
                )
                .frame(width: 120, height: 120)
                .scaleEffect(pulseScale)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulseScale)
            
            // Иконка
            Image(systemName: "fork.knife.circle.fill")
                .font(.system(size: 60, weight: .light))
                .foregroundColor(.white)
                .rotationEffect(.degrees(rotationAngle))
                .animation(.linear(duration: 8).repeatForever(autoreverses: false), value: rotationAngle)
            
            // Дополнительные элементы
            ForEach(0..<4) { index in
                Circle()
                    .fill(Color.black.opacity(0.2))
                    .frame(width: 8, height: 8)
                    .offset(
                        x: 70 * cos(Double(index) * .pi / 2),
                        y: 70 * sin(Double(index) * .pi / 2)
                    )
                    .scaleEffect(isAnimating ? 1.5 : 1.0)
                    .opacity(isAnimating ? 0.8 : 0.4)
                    .animation(
                        .easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.3),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
            rotationAngle = 360
            pulseScale = 1.1
        }
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [Colors.bykPrimary, Colors.bykAccent],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        AnimatedLogo()
    }
} 