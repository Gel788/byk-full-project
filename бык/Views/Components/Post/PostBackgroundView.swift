import SwiftUI

struct EnhancedCreatePostBackgroundView: View {
    @State private var animateGradient = false
    @State private var animateParticles = false
    
    var body: some View {
        ZStack {
            // Основной градиентный фон
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color.black.opacity(0.95),
                    Color.black.opacity(0.9),
                    Color.black
                ]),
                startPoint: animateGradient ? .topLeading : .bottomTrailing,
                endPoint: animateGradient ? .bottomTrailing : .topLeading
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 3.0)
                        .repeatForever(autoreverses: true)
                ) {
                    animateGradient.toggle()
                }
            }
            
            // Декоративные частицы
            GeometryReader { geometry in
                ForEach(0..<15, id: \.self) { index in
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.blue.opacity(0.1),
                                    Color.purple.opacity(0.05),
                                    Color.clear
                                ]),
                                startPoint: .center,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(
                            width: CGFloat.random(in: 20...60),
                            height: CGFloat.random(in: 20...60)
                        )
                        .offset(
                            x: geometry.size.width * CGFloat.random(in: 0...1),
                            y: geometry.size.height * CGFloat.random(in: 0...1)
                        )
                        .blur(radius: 15)
                        .opacity(animateParticles ? 0.8 : 0.3)
                        .animation(
                            Animation.easeInOut(duration: Double.random(in: 2...4))
                                .repeatForever(autoreverses: true)
                                .delay(Double.random(in: 0...2)),
                            value: animateParticles
                        )
                }
            }
            .onAppear {
                animateParticles = true
            }
            
            // Сетка для текстуры
            GeometryReader { geometry in
                Path { path in
                    let spacing: CGFloat = 30
                    let rows = Int(geometry.size.height / spacing)
                    let cols = Int(geometry.size.width / spacing)
                    
                    for row in 0...rows {
                        for col in 0...cols {
                            let x = CGFloat(col) * spacing
                            let y = CGFloat(row) * spacing
                            path.move(to: CGPoint(x: x, y: y))
                            path.addLine(to: CGPoint(x: x + 1, y: y + 1))
                        }
                    }
                }
                .stroke(Color.white.opacity(0.03), lineWidth: 0.5)
            }
        }
    }
}

// Расширение для создания случайных цветов
extension Color {
    static func random() -> Color {
        Color(
            red: Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue: Double.random(in: 0...1)
        )
    }
}

// Расширение для создания градиента к краю
extension Gradient {
    static func radialToEdge(colors: [Color]) -> Gradient {
        Gradient(colors: colors)
    }
}
