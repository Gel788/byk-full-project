import SwiftUI

struct SplashScreenView: View {
    @State private var titleOpacity: Double = 0
    @State private var titleScale: CGFloat = 0.85
    @State private var glow: Bool = false
    @State private var authorOpacity: Double = 0
    @State private var authorOffset: CGFloat = 20
    
    // Элегантная анимация масла
    @State private var oilBubbles: [OilBubble] = []
    @State private var steamParticles: [SteamParticle] = []
    @State private var heatGlow: Bool = false
    @State private var oilSurface: Bool = false
    @State private var mysteriousGlow: Bool = false
    @State private var backgroundPulse: Bool = false
    
    // Эффект молнии
    @State private var lightningFlash: Bool = false
    @State private var lightningBranches: [LightningBranch] = []
    @State private var screenOpacity: Double = 1.0
    @State private var isClosing: Bool = false
    
    var body: some View {
        ZStack {
            // Минималистичный черный фон
            Color.black
                .ignoresSafeArea()
            

            

            

            
            // Контент
            VStack(spacing: 40) {
                Spacer()
                
                // Минималистичный и элегантный дизайн
                VStack(spacing: 24) {
                    // Основной логотип
                    VStack(spacing: 12) {
                        Text("Бык")
                            .font(.system(size: 72, weight: .ultraLight, design: .default))
                            .tracking(8)
                            .foregroundColor(.white)
                            .opacity(titleOpacity)
                            .scaleEffect(titleScale)
                        
                        Text("Holding")
                            .font(.system(size: 20, weight: .light, design: .default))
                            .tracking(12)
                            .foregroundColor(.white.opacity(0.7))
                            .opacity(titleOpacity)
                            .scaleEffect(titleScale)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 25)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.black.opacity(0.4),
                                    Color("BykPrimary").opacity(0.1),
                                    Color.black.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color("BykAccent").opacity(0.3),
                                            Color.clear
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: Color("BykAccent").opacity(0.2), radius: 10, x: 0, y: 5)
                )
                
                Spacer()
                
                // Минималистичный автор
                VStack(spacing: 4) {
                    Text("by Mekhak Galstyan")
                        .font(.system(size: 16, weight: .light, design: .default))
                        .tracking(2)
                        .foregroundColor(.white.opacity(0.6))
                        .opacity(authorOpacity)
                        .offset(y: authorOffset)
                }
                
                Spacer()
            }
            .padding(.horizontal, 40)
            

        }
        .opacity(screenOpacity)
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Простые и элегантные анимации
        withAnimation(.easeInOut(duration: 2.0)) {
            titleOpacity = 1
            titleScale = 1.0
        }
        
        withAnimation(.easeInOut(duration: 2.0).delay(0.5)) {
            authorOpacity = 1
            authorOffset = 0
        }
    }
    
    private func createOilBubble() {
        let bubble = OilBubble(
            id: UUID(),
            x: Double.random(in: -150...150),
            y: Double.random(in: -300...300),
            size: max(2, Double.random(in: 2...6)),
            duration: max(1, Double.random(in: 6.0...10.0))
        )
        oilBubbles.append(bubble)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + bubble.duration) {
            oilBubbles.removeAll { $0.id == bubble.id }
        }
    }
    
    private func createSteamParticle() {
        let particle = SteamParticle(
            id: UUID(),
            x: Double.random(in: -120...120),
            y: Double.random(in: -250...250),
            size: max(1, Double.random(in: 1...4)),
            duration: max(1, Double.random(in: 8.0...12.0))
        )
        steamParticles.append(particle)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + particle.duration) {
            steamParticles.removeAll { $0.id == particle.id }
        }
    }
    
    private func cleanupOldElements() {
        oilBubbles.removeAll { $0.id == oilBubbles.first?.id }
        steamParticles.removeAll { $0.id == steamParticles.first?.id }
    }
    
    private func startLightningEffect() {
        print("⚡ Создаем ветви молнии...")
        
        // Создаем множественные ветви молнии
        createLightningBranches()
        
        print("⚡ Ветви созданы: \(lightningBranches.count)")
        
        // Вспышка молнии
        withAnimation(.easeInOut(duration: 0.1)) {
            lightningFlash = true
        }
        
        print("⚡ Вспышка активирована!")
        
        // Haptic feedback для эффекта
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        
        // Скрываем экран через 0.5 секунды (увеличиваем время)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            print("⚡ Скрываем экран...")
            withAnimation(.easeInOut(duration: 0.3)) {
                screenOpacity = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                print("⚡ Очищаем молнию...")
                lightningFlash = false
                lightningBranches.removeAll()
            }
        }
    }
    
    private func createLightningBranches() {
        lightningBranches.removeAll()
        
        // Создаем несколько ветвей молнии
        for i in 0..<8 { // Увеличиваем количество ветвей
            let startPoint = CGPoint(
                x: Double.random(in: -200...200),
                y: Double.random(in: -400...(-50))
            )
            
            let endPoint = CGPoint(
                x: Double.random(in: -200...200),
                y: Double.random(in: 50...400)
            )
            
            let branch = LightningBranch(
                id: UUID(),
                start: startPoint,
                end: endPoint,
                thickness: Double.random(in: 3...8), // Увеличиваем толщину
                color: Color.white.opacity(Double.random(in: 0.8...1.0)),
                duration: Double.random(in: 0.3...0.6) // Увеличиваем длительность
            )
            
            lightningBranches.append(branch)
            print("⚡ Создана ветвь \(i+1): от \(startPoint) до \(endPoint)")
        }
    }
}

// MARK: - Elegant Oil Surface View
struct ElegantOilSurfaceView: View {
    let heatGlow: Bool
    let oilSurface: Bool
    let mysteriousGlow: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Основная элегантная поверхность
                Rectangle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.gray.opacity(0.3),
                                Color.gray.opacity(0.1),
                                Color.black.opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: max(geometry.size.width, geometry.size.height) * 0.7
                        )
                    )
                    .scaleEffect(heatGlow ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: heatGlow)
                
                // Мистические слои
                ForEach(0..<2, id: \.self) { index in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.gray.opacity(0.2 - Double(index) * 0.1),
                                    Color.black.opacity(0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: max(geometry.size.width, geometry.size.height) * (0.5 - Double(index) * 0.1)
                            )
                        )
                        .offset(
                            x: oilSurface ? Double(index * 15) : -Double(index * 15),
                            y: oilSurface ? -Double(index * 10) : Double(index * 10)
                        )
                        .scaleEffect(mysteriousGlow ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true), value: oilSurface)
                        .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: mysteriousGlow)
                }
            }
        }
    }
}

// MARK: - Elegant Oil Bubble View
struct ElegantOilBubbleView: View {
    let bubble: OilBubble
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0
    @State private var offset: CGFloat = 0
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        Color.gray.opacity(0.6),
                        Color.gray.opacity(0.3),
                        Color.black.opacity(0.2),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: bubble.size
                )
            )
            .frame(width: bubble.size * 2, height: bubble.size * 2)
            .offset(x: bubble.x, y: bubble.y + offset)
            .opacity(opacity)
            .scaleEffect(scale)
            .blur(radius: 0.3)
            .onAppear {
                withAnimation(.easeOut(duration: bubble.duration * 0.4)) {
                    opacity = 1
                    scale = 1
                }
                
                withAnimation(.easeInOut(duration: bubble.duration).repeatForever(autoreverses: true)) {
                    offset = -15
                }
                
                withAnimation(.easeIn(duration: bubble.duration * 0.3).delay(bubble.duration * 0.7)) {
                    opacity = 0
                    scale = 1.3
                }
            }
    }
}

// MARK: - Mysterious Steam View
struct MysteriousSteamView: View {
    let particle: SteamParticle
    @State private var opacity: Double = 0
    @State private var offset: CGFloat = 0
    @State private var scale: CGFloat = 0
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        Color.white.opacity(0.3),
                        Color.gray.opacity(0.2),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: particle.size
                )
            )
            .frame(width: particle.size * 2, height: particle.size * 2)
            .offset(x: particle.x, y: particle.y + offset)
            .opacity(opacity)
            .scaleEffect(scale)
            .blur(radius: 2.0)
            .onAppear {
                withAnimation(.easeOut(duration: particle.duration * 0.5)) {
                    opacity = 1
                    scale = 1
                }
                
                withAnimation(.easeOut(duration: particle.duration)) {
                    offset = -120
                }
                
                withAnimation(.easeIn(duration: particle.duration * 0.4).delay(particle.duration * 0.6)) {
                    opacity = 0
                    scale = 1.8
                }
            }
    }
}

// MARK: - Data Models
struct OilBubble: Identifiable {
    let id: UUID
    let x: Double
    let y: Double
    let size: Double
    let duration: Double
    
    var position: CGPoint {
        CGPoint(x: x, y: y)
    }
    
    var opacity: Double {
        max(0.1, min(1.0, Double.random(in: 0.5...1.0)))
    }
    
    var scale: CGFloat {
        max(0.1, min(2.0, CGFloat.random(in: 0.8...1.2)))
    }
}

struct SteamParticle: Identifiable {
    let id: UUID
    let x: Double
    let y: Double
    let size: Double
    let duration: Double
    
    var position: CGPoint {
        CGPoint(x: x, y: y)
    }
    
    var opacity: Double {
        max(0.1, min(1.0, Double.random(in: 0.3...0.7)))
    }
}

// MARK: - Lightning Branch View
struct LightningBranchView: View {
    let branch: LightningBranch
    @State private var opacity: Double = 0
    
    var body: some View {
        Path { path in
            path.move(to: branch.start)
            
            // Создаем зигзагообразную линию молнии
            let points = createLightningPath(from: branch.start, to: branch.end)
            for point in points {
                path.addLine(to: point)
            }
        }
        .stroke(
            branch.color,
            style: StrokeStyle(
                lineWidth: branch.thickness,
                lineCap: .round,
                lineJoin: .round
            )
        )
        .shadow(color: Color.white, radius: 2, x: 0, y: 0)
        .shadow(color: Color("BykAccent"), radius: 1, x: 0, y: 0)
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeInOut(duration: branch.duration)) {
                opacity = 1
            }
        }
    }
    
    private func createLightningPath(from start: CGPoint, to end: CGPoint) -> [CGPoint] {
        var points: [CGPoint] = []
        let distance = sqrt(pow(end.x - start.x, 2) + pow(end.y - start.y, 2))
        let segments = Int(distance / 25) // Уменьшаем сегменты для более плавной линии
        
        for i in 1...segments {
            let progress = Double(i) / Double(segments)
            let baseX = start.x + (end.x - start.x) * progress
            let baseY = start.y + (end.y - start.y) * progress
            
            // Добавляем случайное отклонение для эффекта молнии
            let offsetX = Double.random(in: -30...30) // Увеличиваем отклонение
            let offsetY = Double.random(in: -30...30)
            
            points.append(CGPoint(x: baseX + offsetX, y: baseY + offsetY))
        }
        
        points.append(end)
        return points
    }
}

// MARK: - Lightning Branch Model
struct LightningBranch: Identifiable {
    let id: UUID
    let start: CGPoint
    let end: CGPoint
    let thickness: Double
    let color: Color
    let duration: Double
}

#Preview {
    SplashScreenView()
} 