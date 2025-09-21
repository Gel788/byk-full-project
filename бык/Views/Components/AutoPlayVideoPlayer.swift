import SwiftUI
import AVKit

struct AutoPlayVideoPlayer: View {
    let videoURL: String
    let thumbnailURL: String
    let autoPlay: Bool
    @State private var player: AVPlayer?
    @State private var isVideoReady = false
    @State private var showControls = true
    @State private var hideControlsTimer: Timer?
    
    init(videoURL: String, thumbnailURL: String, autoPlay: Bool = true) {
        self.videoURL = videoURL
        self.thumbnailURL = thumbnailURL
        self.autoPlay = autoPlay
    }
    
    var body: some View {
        ZStack {
            if let player = player {
                VideoPlayer(player: player)
                    .onAppear {
                        // Автоматически воспроизводим видео если включено
                        if autoPlay {
                            player.play()
                            startHideControlsTimer()
                        }
                    }
                    .onDisappear {
                        // Останавливаем видео при закрытии
                        player.pause()
                        hideControlsTimer?.invalidate()
                    }
                    .onTapGesture {
                        toggleControls()
                    }
                    .overlay(
                        // Кастомные контролы
                        VStack {
                            Spacer()
                            if showControls {
                                HStack {
                                    Button(action: {
                                        if player.timeControlStatus == .playing {
                                            player.pause()
                                        } else {
                                            player.play()
                                        }
                                    }) {
                                        Image(systemName: player.timeControlStatus == .playing ? "pause.circle.fill" : "play.circle.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.white)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        if player.isMuted {
                                            player.isMuted = false
                                        } else {
                                            player.isMuted = true
                                        }
                                    }) {
                                        Image(systemName: player.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .transition(.opacity)
                            }
                        }
                        .animation(.easeInOut(duration: 0.3), value: showControls)
                    )
            } else {
                // Показываем обложку пока видео загружается
                AsyncImage(url: URL(string: thumbnailURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 200)
                        .cornerRadius(12)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 200)
                        .overlay(
                            VStack(spacing: 8) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text("Загрузка видео...")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                        )
                        .cornerRadius(12)
                }
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
        player?.isMuted = true // Начинаем без звука
        player?.actionAtItemEnd = .none
        
        // Добавляем наблюдатель для завершения видео
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { _ in
            // Повторяем видео
            player?.seek(to: .zero)
            player?.play()
        }
    }
    
    private func toggleControls() {
        showControls.toggle()
        if showControls {
            startHideControlsTimer()
        } else {
            hideControlsTimer?.invalidate()
        }
    }
    
    private func startHideControlsTimer() {
        hideControlsTimer?.invalidate()
        hideControlsTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                showControls = false
            }
        }
    }
}

#Preview {
    AutoPlayVideoPlayer(
        videoURL: "https://bulladmin.ru/api/upload/uploads/file-1758303297736-773836964.mp4",
        thumbnailURL: "https://bulladmin.ru/api/upload/uploads/file-1758303306377-535852281.jpg"
    )
    .padding()
}
