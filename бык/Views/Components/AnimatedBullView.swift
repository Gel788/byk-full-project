import SwiftUI

struct AnimatedBullView: View {
    @State private var isAnimating = false
    @State private var breathingScale: CGFloat = 1.0
    @State private var eyeBlink = false
    @State private var tailWag = false
    @State private var appearOffset: CGFloat = 100
    @State private var headTilt = false
    
    var body: some View {
        ZStack {
            // Основное тело быка
            VStack(spacing: 0) {
                // Голова
                ZStack {
                    // Морда (основа)
                    Ellipse()
                        .fill(Color.brown)
                        .frame(width: 90, height: 70)
                        .scaleEffect(breathingScale)
                    
                    // Нос и ноздри
                    VStack(spacing: 2) {
                        // Нос
                        Ellipse()
                            .fill(Color.black)
                            .frame(width: 20, height: 12)
                        
                        // Ноздри
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.black)
                                .frame(width: 6, height: 6)
                            Circle()
                                .fill(Color.black)
                                .frame(width: 6, height: 6)
                        }
                    }
                    .offset(y: 20)
                    
                    // Глаза
                    HStack(spacing: 35) {
                        // Левый глаз
                        ZStack {
                            // Белок глаза
                            Ellipse()
                                .fill(Color.white)
                                .frame(width: 16, height: 12)
                            
                            // Зрачок
                            Circle()
                                .fill(Color.black)
                                .frame(width: eyeBlink ? 2 : 8, height: eyeBlink ? 2 : 8)
                        }
                        
                        // Правый глаз
                        ZStack {
                            // Белок глаза
                            Ellipse()
                                .fill(Color.white)
                                .frame(width: 16, height: 12)
                            
                            // Зрачок
                            Circle()
                                .fill(Color.black)
                                .frame(width: eyeBlink ? 2 : 8, height: eyeBlink ? 2 : 8)
                        }
                    }
                    .offset(y: -8)
                    
                    // Уши
                    HStack(spacing: 50) {
                        // Левое ухо
                        Ellipse()
                            .fill(Color.brown)
                            .frame(width: 15, height: 25)
                            .rotationEffect(.degrees(-20))
                            .offset(x: isAnimating ? -3 : 0, y: isAnimating ? -2 : 0)
                        
                        // Правое ухо
                        Ellipse()
                            .fill(Color.brown)
                            .frame(width: 15, height: 25)
                            .rotationEffect(.degrees(20))
                            .offset(x: isAnimating ? 3 : 0, y: isAnimating ? -2 : 0)
                    }
                    .offset(y: -30)
                    
                    // Рога (мощные и изогнутые)
                    HStack(spacing: 40) {
                        // Левый рог
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: 0))
                            path.addCurve(
                                to: CGPoint(x: -8, y: -25),
                                control1: CGPoint(x: -5, y: -10),
                                control2: CGPoint(x: -10, y: -18)
                            )
                            path.addCurve(
                                to: CGPoint(x: -5, y: -35),
                                control1: CGPoint(x: -6, y: -30),
                                control2: CGPoint(x: -3, y: -35)
                            )
                        }
                        .stroke(Color.gray, lineWidth: 8)
                        .frame(width: 20, height: 40)
                        .offset(x: isAnimating ? -2 : 0)
                        
                        // Правый рог
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: 0))
                            path.addCurve(
                                to: CGPoint(x: 8, y: -25),
                                control1: CGPoint(x: 5, y: -10),
                                control2: CGPoint(x: 10, y: -18)
                            )
                            path.addCurve(
                                to: CGPoint(x: 5, y: -35),
                                control1: CGPoint(x: 6, y: -30),
                                control2: CGPoint(x: 3, y: -35)
                            )
                        }
                        .stroke(Color.gray, lineWidth: 8)
                        .frame(width: 20, height: 40)
                        .offset(x: isAnimating ? 2 : 0)
                    }
                    .offset(y: -40)
                }
                .rotationEffect(.degrees(headTilt ? 2 : -2))
                
                // Шея (мощная)
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.brown)
                    .frame(width: 60, height: 40)
                    .scaleEffect(breathingScale)
                
                // Тело (массивное)
                RoundedRectangle(cornerRadius: 50)
                    .fill(Color.brown)
                    .frame(width: 140, height: 100)
                    .scaleEffect(breathingScale)
                
                // Ноги (мощные)
                HStack(spacing: 25) {
                    // Передние ноги
                    VStack(spacing: 5) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.brown)
                            .frame(width: 12, height: 35)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.brown)
                            .frame(width: 12, height: 35)
                    }
                    
                    // Задние ноги
                    VStack(spacing: 5) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.brown)
                            .frame(width: 12, height: 35)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.brown)
                            .frame(width: 12, height: 35)
                    }
                }
                .offset(y: -10)
                
                // Хвост (с кисточкой)
                VStack(spacing: 0) {
                    // Основание хвоста
                    Capsule()
                        .fill(Color.brown)
                        .frame(width: 6, height: 25)
                        .rotationEffect(.degrees(tailWag ? 20 : -20))
                    
                    // Кисточка хвоста
                    Ellipse()
                        .fill(Color.brown)
                        .frame(width: 12, height: 8)
                }
                .offset(x: 55, y: -25)
            }
            .offset(y: appearOffset)
            .shadow(color: .black.opacity(0.4), radius: 15, x: 0, y: 8)
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Появление
        withAnimation(.easeOut(duration: 1.2)) {
            appearOffset = 0
        }
        
        // Дыхание
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
            breathingScale = 1.03
        }
        
        // Общая анимация
        withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
            isAnimating = true
        }
        
        // Наклон головы
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            headTilt = true
        }
        
        // Моргание
        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.15)) {
                eyeBlink = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut(duration: 0.15)) {
                    eyeBlink = false
                }
            }
        }
        
        // Виляние хвостом
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            tailWag = true
        }
    }
}

#Preview {
    AnimatedBullView()
        .frame(width: 250, height: 250)
        .background(Color.blue.opacity(0.1))
} 