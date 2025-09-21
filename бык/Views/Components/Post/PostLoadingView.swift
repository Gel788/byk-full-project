import SwiftUI

struct EnhancedLoadingView: View {
    @State private var isAnimating = false
    @State private var rotationAngle: Double = 0
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Полупрозрачный фон
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            // Центральная анимация
            VStack(spacing: 20) {
                // Анимированный логотип или индикатор
                ZStack {
                    // Внешнее кольцо
                    Circle()
                        .stroke(Color.blue.opacity(0.3), lineWidth: 4)
                        .frame(width: 80, height: 80)
                    
                    // Внутреннее кольцо с анимацией
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .purple, .blue]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(rotationAngle))
                        .scaleEffect(scale)
                }
                
                // Текст загрузки
                VStack(spacing: 8) {
                    Text("Создание поста")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Пожалуйста, подождите...")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                // Прогресс-бар
                ProgressBarView(isAnimating: isAnimating)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Анимация вращения
        withAnimation(
            Animation.linear(duration: 2.0)
                .repeatForever(autoreverses: false)
        ) {
            rotationAngle = 360
        }
        
        // Анимация масштабирования
        withAnimation(
            Animation.easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
        ) {
            scale = 1.2
        }
        
        // Анимация прогресс-бара
        withAnimation(
            Animation.easeInOut(duration: 0.5)
                .delay(0.2)
        ) {
            isAnimating = true
        }
    }
}

struct ProgressBarView: View {
    let isAnimating: Bool
    @State private var progress: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Фон прогресс-бара
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 8)
                
                // Заполняющая часть
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress, height: 8)
                    .animation(
                        Animation.easeInOut(duration: 2.0)
                            .repeatForever(autoreverses: true),
                        value: progress
                    )
            }
        }
        .frame(height: 8)
        .onAppear {
            if isAnimating {
                progress = 1.0
            }
        }
    }
}

// Предварительный просмотр для разработки
#Preview {
    EnhancedLoadingView()
}
