import SwiftUI

struct MenuBackgroundView: View {
    let restaurant: Restaurant
    @Binding var showShimmer: Bool
    
    var body: some View {
        ZStack {
            // Градиентный фон
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.9),
                    Color.black.opacity(0.7),
                    Color.black
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Декоративные элементы
            GeometryReader { geometry in
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 200, height: 200)
                        .offset(
                            x: geometry.size.width * CGFloat(index) * 0.3,
                            y: geometry.size.height * CGFloat(index) * 0.2
                        )
                        .blur(radius: 20)
                }
            }
            
            // Shimmer эффект
            if showShimmer {
                ShimmerOverlay()
            }
        }
    }
}

struct ShimmerOverlay: View {
    @State private var isAnimating = false
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.clear,
                        Color.white.opacity(0.1),
                        Color.clear
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .rotationEffect(.degrees(isAnimating ? 360 : 0))
            .animation(
                Animation.linear(duration: 2)
                    .repeatForever(autoreverses: false),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}
