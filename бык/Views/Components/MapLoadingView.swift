import SwiftUI

// MARK: - Map Loading View
struct MapLoadingView: View {
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        VStack(spacing: 20) {
            // Анимированная иконка карты
            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "map.circle.fill")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.blue, Color.cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .rotationEffect(.degrees(rotationAngle))
                    .animation(
                        .linear(duration: 2)
                        .repeatForever(autoreverses: false), 
                        value: rotationAngle
                    )
            }
            
            VStack(spacing: 8) {
                Text("Загружаем карту...")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("Подключаемся к Яндекс картам")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            
            // Индикатор загрузки
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                        .scaleEffect(rotationAngle > Double(index * 120) ? 1.0 : 0.6)
                        .animation(
                            .easeInOut(duration: 0.6)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.2),
                            value: rotationAngle
                        )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.8))
        .onAppear {
            rotationAngle = 360
        }
    }
}

// MARK: - Map Error View
struct MapErrorView: View {
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Иконка ошибки
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(.red)
            }
            
            VStack(spacing: 12) {
                Text("Не удалось загрузить карту")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Проверьте подключение к интернету\nи попробуйте еще раз")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            
            Button(action: onRetry) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Повторить")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [Color.blue, Color.cyan],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .shadow(color: Color.blue.opacity(0.4), radius: 8, x: 0, y: 4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.8))
    }
}

#Preview("Загрузка карты") {
    MapLoadingView()
        .preferredColorScheme(.dark)
}

#Preview("Ошибка карты") {
    MapErrorView(onRetry: {})
        .preferredColorScheme(.dark)
}