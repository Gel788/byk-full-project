import SwiftUI
import AVKit
import AVFoundation
import ObjectiveC

struct NewsCardWithVideo: View {
    let newsItem: NewsItem
    @State private var showingDetail = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Обложка новости (всегда изображение, видео поверх)
            ZStack {
                // Контейнер для изображения с фиксированными размерами
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 350)
                    .overlay(
                        // Всегда показываем изображение как обложку
                        AsyncImage(url: URL(string: newsItem.image)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .clipped()
                            case .failure:
                                Rectangle()
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .overlay(
                                        VStack(spacing: 12) {
                                            Image(systemName: "photo")
                                                .font(.system(size: 32))
                                                .foregroundColor(.gray)
                                            Text("Изображение недоступно")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                                .fontWeight(.medium)
                                        }
                                    )
                            case .empty:
                                Rectangle()
                                    .fill(Color.gray.opacity(0.05))
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .overlay(
                                        VStack(spacing: 12) {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                                                .scaleEffect(1.2)
                                            Text("Загрузка...")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                                .fontWeight(.medium)
                                        }
                                    )
                            @unknown default:
                                Rectangle()
                                    .fill(Color.gray.opacity(0.05))
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                    )
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 20,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 20
                        )
                    )
                
                // Индикатор видео поверх изображения
                if let videoURL = newsItem.videoURL, !videoURL.isEmpty {
                    VStack {
                        HStack {
                            Spacer()
                            HStack(spacing: 6) {
                                Image(systemName: "play.fill")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                Text("ВИДЕО")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.red.opacity(0.8),
                                                Color.orange.opacity(0.7)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                        .padding(.top, 16)
                        .padding(.trailing, 16)
                        Spacer()
                    }
                }
                
                // Градиент для лучшей читаемости
                LinearGradient(
                    gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.6)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 350)
                
                // Информация о новости поверх изображения
                VStack {
                    Spacer()
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(newsItem.brand.rawValue)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(.ultraThinMaterial)
                                )
                            
                            Spacer()
                        }
                        
                        Text(newsItem.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .shadow(color: .black.opacity(0.8), radius: 2, x: 0, y: 1)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .onTapGesture {
                showingDetail = true
            }
            
            // Информация о новости
            VStack(alignment: .leading, spacing: 20) {
                // Заголовок новости
                Text(newsItem.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // Описание
                Text(newsItem.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Статистика
                HStack(spacing: 16) {
                    // Просмотры
                    HStack(spacing: 6) {
                        Image(systemName: "eye.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Text("\(newsItem.views)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.blue.opacity(0.1))
                            .overlay(
                                Capsule()
                                    .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                            )
                    )
                    
                    // Лайки
                    HStack(spacing: 6) {
                        Image(systemName: newsItem.isLiked ? "heart.fill" : "heart")
                            .font(.caption)
                            .foregroundColor(newsItem.isLiked ? .red : .pink)
                        Text("\(newsItem.likes)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.pink.opacity(0.1))
                            .overlay(
                                Capsule()
                                    .stroke(Color.pink.opacity(0.2), lineWidth: 1)
                            )
                    )
                    
                    // Комментарии
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.left.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                        Text("\(newsItem.comments)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.green.opacity(0.1))
                            .overlay(
                                Capsule()
                                    .stroke(Color.green.opacity(0.2), lineWidth: 1)
                            )
                    )
                    
                    Spacer()
                }
            }
            .padding(20)
            .background(
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        Color(.systemBackground).opacity(0.98),
                        Color(.systemGray6).opacity(0.3)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.4),
                            Color.blue.opacity(0.3),
                            Color.purple.opacity(0.2),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
                .shadow(color: Color.blue.opacity(0.3), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.1),
                            Color.clear,
                            Color.black.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .sheet(isPresented: $showingDetail) {
            NewsDetailWithVideoView(newsItem: newsItem)
        }
    }
}
struct NewsDetailWithVideoView: View {
    let newsItem: NewsItem
    @Environment(\.dismiss) private var dismiss
    @State private var player: AVPlayer?
    @State private var isVideoPlaying = false
    @State private var useCustomPlayer = true // Флаг для выбора типа плеера
    
    var body: some View {
        NavigationView {
            ZStack {
                // Фон
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        Color(.systemGroupedBackground).opacity(0.8)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                    // Всегда показываем изображение как обложку
                    ZStack {
                        // Контейнер для изображения с фиксированными размерами
                        Rectangle()
                            .fill(Color.clear)
                            .frame(maxHeight: 450)
                            .overlay(
                                AsyncImage(url: URL(string: newsItem.image)) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    case .failure:
                                        Rectangle()
                                            .fill(Color.red.opacity(0.3))
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            .overlay(
                                                VStack {
                                                    Image(systemName: "photo")
                                                        .font(.system(size: 40))
                                                        .foregroundColor(.red)
                                                    Text("Ошибка загрузки")
                                                        .font(.caption)
                                                        .foregroundColor(.red)
                                                }
                                            )
                                    case .empty:
                                        Rectangle()
                                            .fill(Color.blue.opacity(0.3))
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            .overlay(
                                                VStack {
                                                    ProgressView()
                                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                        .scaleEffect(1.5)
                                                    Text("Загрузка...")
                                                        .font(.subheadline)
                                                        .foregroundColor(.white)
                                                }
                                            )
                                    @unknown default:
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    }
                                }
                            )
                            .cornerRadius(12)
                        
                        // Видео поверх изображения
                        if let videoURL = newsItem.videoURL, !videoURL.isEmpty {
                            VideoOverlayView(videoURL: videoURL, useCustomPlayer: useCustomPlayer)
                                .frame(height: 450)
                                .frame(maxWidth: .infinity)
                                .cornerRadius(12)
                                .clipped()
                        }
                    }
                    
                    // Заголовок и информация
                    VStack(alignment: .leading, spacing: 20) {
                        // Бренд и дата
                        HStack {
                            Text(newsItem.brand.rawValue)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(newsItem.brand.color)
                                        .shadow(color: newsItem.brand.color.opacity(0.3), radius: 4, x: 0, y: 2)
                                )
                            
                            Spacer()
                            
                            Text(newsItem.date, style: .date)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color.gray.opacity(0.1))
                                )
                        }
                        
                        // Заголовок
                        Text(newsItem.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        // Описание
                        Text(newsItem.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 20)
                    
                    // Статистика
                    HStack(spacing: 16) {
                        // Просмотры
                        HStack(spacing: 8) {
                            Image(systemName: "eye.fill")
                                .font(.title3)
                                .foregroundColor(.blue)
                            Text("\(newsItem.views)")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(0.1))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                                )
                        )
                        
                        // Лайки
                        Button(action: {
                            // TODO: Лайк
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: newsItem.isLiked ? "heart.fill" : "heart.fill")
                                    .font(.title3)
                                    .foregroundColor(newsItem.isLiked ? .red : .pink)
                                Text("\(newsItem.likes)")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(Color.pink.opacity(0.1))
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.pink.opacity(0.3), lineWidth: 2)
                                    )
                            )
                        }
                        
                        // Комментарии
                        Button(action: {
                            // TODO: Комментарии
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "bubble.left.fill")
                                    .font(.title3)
                                    .foregroundColor(.green)
                                Text("\(newsItem.comments.count)")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(Color.green.opacity(0.1))
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.green.opacity(0.3), lineWidth: 2)
                                    )
                            )
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    // Комментарии
                    if !newsItem.comments.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Комментарии")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 20)
                            
                            ForEach(newsItem.comments) { comment in
                                CommentView(comment: comment)
                                    .padding(.horizontal, 20)
                            }
                        }
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemGray6).opacity(0.5))
                                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                        )
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.vertical, 20)
                }
            }
            .navigationTitle("Новость")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}
struct CommentView: View {
    let comment: NewsComment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(comment.author)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(comment.date, style: .relative)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text(comment.text)
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct AdaptiveVideoPlayerView: View {
    let videoURL: String
    @State private var player: AVPlayer?
    @State private var videoSize: CGSize = CGSize(width: 16, height: 9) // По умолчанию 16:9
    @State private var isVideoReady = false
    
    private func calculateVideoSize(for geometry: GeometryProxy) -> CGSize {
        let aspectRatio = videoSize.width / videoSize.height
        let screenWidth = geometry.size.width
        let screenHeight = geometry.size.height
        
        var videoWidth: CGFloat
        var videoHeight: CGFloat
        
        // Рассчитываем размеры видео для заполнения экрана
        if aspectRatio > 1.0 {
            // Горизонтальное видео - заполняем по ширине экрана
            videoWidth = screenWidth
            videoHeight = screenWidth / aspectRatio
        } else if aspectRatio < 1.0 {
            // Вертикальное видео - заполняем по высоте экрана
            videoHeight = screenHeight
            videoWidth = screenHeight * aspectRatio
        } else {
            // Квадратное видео - используем максимальный размер
            let maxSize = max(screenWidth, screenHeight)
            videoWidth = maxSize
            videoHeight = maxSize
        }
        
        print("DEBUG: Screen: \(screenWidth)x\(screenHeight), Video: \(videoWidth)x\(videoHeight), Aspect: \(String(format: "%.2f", aspectRatio))")
        
        return CGSize(width: videoWidth, height: videoHeight)
    }
    
    var body: some View {
        GeometryReader { geometry in
            if let player = player, isVideoReady {
                let size = calculateVideoSize(for: geometry)
                
                AVPlayerViewControllerRepresentable(player: player)
                    .frame(width: size.width, height: size.height)
                    .onDisappear {
                        player.pause()
                    }
            } else {
                // Показываем загрузку
                Rectangle()
                    .fill(Color.black)
                    .overlay(
                        VStack {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.white)
                            Text("Загрузка видео...")
                                .foregroundColor(.white)
                                .font(.subheadline)
                        }
                    )
            }
        }
        .onAppear {
            setupVideoPlayer()
        }
    }
    
    private func setupVideoPlayer() {
        guard let url = URL(string: videoURL) else {
            print("ERROR: Invalid video URL: \(videoURL)")
            return
        }
        
        let player = AVPlayer(url: url)
        self.player = player
        
        // Получаем размер видео асинхронно
        Task {
            await getVideoDimensions(from: url)
        }
        
        // Автозапуск через 1 секунду
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isVideoReady = true
        }
    }
    
    private func getVideoDimensions(from url: URL) async {
        let asset = AVAsset(url: url)
        
        do {
            let tracks = try await asset.loadTracks(withMediaType: .video)
            guard let track = tracks.first else {
                print("DEBUG: No video track found")
                await MainActor.run {
                    // Используем размеры по умолчанию
                    self.videoSize = CGSize(width: 16, height: 9)
                }
                return
            }
            
            let size = try await track.load(.naturalSize)
            let transform = try await track.load(.preferredTransform)
            
            // Учитываем трансформацию для правильного размера
            let videoSize = CGSize(
                width: abs(size.width * transform.a) + abs(size.height * transform.c),
                height: abs(size.width * transform.b) + abs(size.height * transform.d)
            )
            
            await MainActor.run {
                self.videoSize = videoSize
                let aspectRatio = videoSize.width / videoSize.height
                let orientation = aspectRatio > 1.0 ? "Горизонтальное" : (aspectRatio < 1.0 ? "Вертикальное" : "Квадратное")
                print("DEBUG: Video dimensions: \(videoSize), aspect ratio: \(String(format: "%.2f", aspectRatio)), orientation: \(orientation)")
            }
        } catch {
            print("DEBUG: Error loading video dimensions: \(error)")
            await MainActor.run {
                // Используем размеры по умолчанию при ошибке
                self.videoSize = CGSize(width: 16, height: 9)
            }
        }
    }
}

struct VideoOverlayView: View {
    let videoURL: String
    let useCustomPlayer: Bool
    @State private var player: AVPlayer?
    @State private var isVideoReady = false
    @State private var videoSize: CGSize = .zero
    @State private var isHorizontalVideo = false
    
    init(videoURL: String, useCustomPlayer: Bool = true) {
        self.videoURL = videoURL
        self.useCustomPlayer = useCustomPlayer
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let player = player, isVideoReady {
                    if useCustomPlayer {
                        // Кастомный плеер с AVPlayerLayer для лучшего контроля
                        CustomVideoPlayerView(
                            player: player,
                            isHorizontalVideo: isHorizontalVideo
                        )
                        .onDisappear {
                            player.pause()
                        }
                    } else {
                        // Стандартный AVPlayerViewController
                        AdaptiveVideoPlayerRepresentable(
                            player: player,
                            videoSize: videoSize,
                            isHorizontalVideo: isHorizontalVideo,
                            containerSize: geometry.size
                        )
                        .onDisappear {
                            player.pause()
                        }
                    }
                } else {
                    // Показываем прозрачный фон пока видео загружается
                    Color.clear
                }
            }
        }
        .onAppear {
            setupVideoPlayer()
        }
    }
    
    private func setupVideoPlayer() {
        guard let url = URL(string: videoURL) else {
            return
        }
        
        let player = AVPlayer(url: url)
        self.player = player
        
        // Получаем размеры видео
        getVideoDimensions(from: url) { size in
            self.videoSize = size
            // Более точное определение ориентации (учитываем соотношение сторон)
            let aspectRatio = size.width / size.height
            self.isHorizontalVideo = aspectRatio > 1.2 // Горизонтальное если соотношение больше 1.2:1
            
            // Автозапуск через 1 секунду
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.isVideoReady = true
            }
        }
    }
    
    private func getVideoDimensions(from url: URL, completion: @escaping (CGSize) -> Void) {
        let asset = AVAsset(url: url)
        
        Task {
            do {
                let tracks = try await asset.loadTracks(withMediaType: .video)
                guard let track = tracks.first else {
                    completion(CGSize(width: 16, height: 9)) // Default aspect ratio
                    return
                }
                
                let size = try await track.load(.naturalSize)
                let transform = try await track.load(.preferredTransform)
                
                // Учитываем поворот видео
                let videoSize = CGSize(
                    width: abs(size.width),
                    height: abs(size.height)
                )
                
                // Проверяем, нужно ли поменять ширину и высоту местами
                // Различные варианты поворота видео
                let isRotated90 = (transform.a == 0 && transform.b == 1 && transform.c == -1 && transform.d == 0)
                let isRotated270 = (transform.a == 0 && transform.b == -1 && transform.c == 1 && transform.d == 0)
                let isRotated = isRotated90 || isRotated270
                
                let finalSize = isRotated ? CGSize(width: videoSize.height, height: videoSize.width) : videoSize
                
                
                await MainActor.run {
                    completion(finalSize)
                }
            } catch {
                print("ERROR loading video dimensions: \(error)")
                await MainActor.run {
                    completion(CGSize(width: 16, height: 9)) // Default aspect ratio
                }
            }
        }
    }
}

struct AdaptiveVideoPlayerRepresentable: UIViewControllerRepresentable {
    let player: AVPlayer
    let videoSize: CGSize
    let isHorizontalVideo: Bool
    let containerSize: CGSize
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = true
        controller.allowsPictureInPicturePlayback = false
        
        // Адаптируем gravity в зависимости от ориентации видео
        let gravity: AVLayerVideoGravity = isHorizontalVideo ? .resizeAspect : .resizeAspectFill
        controller.videoGravity = gravity
        
        // Автозапуск
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            player.play()
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // Не обновляем player здесь, так как это может вызвать проблемы
        // uiViewController.player = player
        
        // Принудительно обновляем gravity
        let gravity: AVLayerVideoGravity = isHorizontalVideo ? .resizeAspect : .resizeAspectFill
        uiViewController.videoGravity = gravity
        
    }
}

// Альтернативный плеер с AVPlayerLayer для лучшего контроля
struct CustomVideoPlayerView: UIViewRepresentable {
    let player: AVPlayer
    let isHorizontalVideo: Bool
    
    func makeUIView(context: Context) -> UIView {
        let view = VideoPlayerView()
        
        let playerLayer = AVPlayerLayer(player: player)
        
        // Адаптируем gravity в зависимости от ориентации видео
        let gravity: AVLayerVideoGravity = isHorizontalVideo ? .resizeAspect : .resizeAspectFill
        playerLayer.videoGravity = gravity
        
        view.layer.addSublayer(playerLayer)
        view.playerLayer = playerLayer
        context.coordinator.playerLayer = playerLayer
        
        // Автозапуск
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            player.play()
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let playerLayer = context.coordinator.playerLayer,
              let videoView = uiView as? VideoPlayerView else { return }
        
        // Обновляем gravity при изменении ориентации
        let gravity: AVLayerVideoGravity = isHorizontalVideo ? .resizeAspect : .resizeAspectFill
        playerLayer.videoGravity = gravity
        
        // Обновляем ссылку на playerLayer в VideoPlayerView
        videoView.playerLayer = playerLayer
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject {
        var playerLayer: AVPlayerLayer?
        
        override init() {
            super.init()
        }
    }
}

// Кастомный UIView для правильной установки размеров
class VideoPlayerView: UIView {
    var playerLayer: AVPlayerLayer?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let playerLayer = playerLayer {
            playerLayer.frame = bounds
        }
    }
}

struct AVPlayerViewControllerRepresentable: UIViewControllerRepresentable {
    let player: AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = true
        controller.videoGravity = .resizeAspectFill
        controller.allowsPictureInPicturePlayback = false
        
        // Автозапуск
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            player.play()
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player
    }
}

#Preview {
    NewsCardWithVideo(newsItem: NewsItem.mock)
        .padding()
}
