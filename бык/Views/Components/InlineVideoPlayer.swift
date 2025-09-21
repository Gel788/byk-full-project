import SwiftUI
import AVKit

struct InlineVideoPlayer: View {
    let videoURL: String
    let thumbnailURL: String
    @State private var player: AVPlayer?
    @State private var isVideoReady = false
    
    init(videoURL: String, thumbnailURL: String) {
        self.videoURL = videoURL
        self.thumbnailURL = thumbnailURL
    }
    
    var body: some View {
        VStack {
            if let player = player {
                VideoPlayer(player: player)
                    .onAppear {
                        print("DEBUG: InlineVideoPlayer - Starting video playback")
                        player.play()
                    }
                    .onDisappear {
                        print("DEBUG: InlineVideoPlayer - Pausing video")
                        player.pause()
                    }
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
        .frame(maxHeight: 200)
        .cornerRadius(16)
        .onAppear {
            setupVideoPlayer()
        }
    }
    
    private func setupVideoPlayer() {
        print("DEBUG: InlineVideoPlayer.setupVideoPlayer - videoURL: \(videoURL)")
        guard let url = URL(string: videoURL) else { 
            print("ERROR: InlineVideoPlayer.setupVideoPlayer - Invalid video URL: \(videoURL)")
            return 
        }
        
        print("DEBUG: InlineVideoPlayer.setupVideoPlayer - Creating player with URL: \(url)")
        let newPlayer = AVPlayer(url: url)
        newPlayer.isMuted = true // Начинаем без звука
        newPlayer.actionAtItemEnd = .none
        
        // Добавляем наблюдатель для завершения видео
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: newPlayer.currentItem,
            queue: .main
        ) { _ in
            print("DEBUG: InlineVideoPlayer - Video ended, restarting")
            newPlayer.seek(to: .zero)
            newPlayer.play()
        }
        
        // Убираем KVO - struct не может использовать observeValue
        
        self.player = newPlayer
        print("DEBUG: InlineVideoPlayer.setupVideoPlayer - Player created successfully")
    }
    
}

#Preview {
    InlineVideoPlayer(
        videoURL: "https://bulladmin.ru/api/upload/uploads/file-1758303297736-773836964.mp4",
        thumbnailURL: "https://bulladmin.ru/api/upload/uploads/file-1758303306377-535852281.jpg"
    )
    .padding()
}