import SwiftUI
import AVKit

struct FullScreenVideoPlayer: View {
    let videoURL: String
    @Environment(\.dismiss) private var dismiss
    @State private var player: AVPlayer?
    @State private var isVideoReady = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let player = player {
                VideoPlayer(player: player)
                    .onAppear {
                        // Автоматически воспроизводим видео
                        player.play()
                    }
                    .onDisappear {
                        // Останавливаем видео при закрытии
                        player.pause()
                    }
            } else {
                // Показываем загрузку
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                    
                    Text("Загрузка видео...")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            
            // Кнопка закрытия
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .background(
                                Circle()
                                    .fill(Color.black.opacity(0.6))
                                    .frame(width: 40, height: 40)
                            )
                    }
                    .padding(.top, 50)
                    .padding(.trailing, 20)
                }
                Spacer()
            }
        }
        .onAppear {
            setupVideoPlayer()
        }
    }
    
    private func setupVideoPlayer() {
        guard let url = URL(string: videoURL) else { return }
        
        player = AVPlayer(url: url)
        
        // Настраиваем автоматическое воспроизведение
        player?.isMuted = false // Включаем звук в полноэкранном режиме
        player?.actionAtItemEnd = .none
        
        // Добавляем наблюдатель для завершения видео
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { _ in
            // Автоматически закрываем видео после окончания
            dismiss()
        }
    }
}

#Preview {
    FullScreenVideoPlayer(videoURL: "https://bulladmin.ru/api/upload/uploads/file-1758303297736-773836964.mp4")
}
