import SwiftUI
import PhotosUI

struct CreatePostView: View {
    @ObservedObject var postService: PostService
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedMedia: [PostMedia] = []
    @State private var content = ""
    @State private var selectedRestaurant: Restaurant?
    @State private var hashtags: [String] = []
    @State private var showingRestaurantPicker = false
    @State private var showingMediaPicker = false
    @State private var isCreating = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingPreview = false
    @State private var showingTemplates = false
    @State private var selectedTemplate: PostTemplate?
    @State private var showingFilters = false
    @State private var selectedMediaIndex: Int?
    @State private var draftSaved = false
    
    private let currentUser = User.mock // Временно используем мок пользователя
    
    // Популярные хештеги
    private let popularHashtags = [
        "бык", "стейк", "мясо", "гриль", "барбекю", "пиво", "вино", 
        "москва", "ресторан", "ужин", "обед", "завтрак", "десерт"
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Улучшенный анимированный фон
                EnhancedCreatePostBackgroundView()
                
                VStack(spacing: 0) {
                    // Улучшенная медиа секция
                    EnhancedMediaSection(
                        selectedMedia: $selectedMedia,
                        showingMediaPicker: $showingMediaPicker,
                        showingFilters: $showingFilters,
                        selectedMediaIndex: $selectedMediaIndex,
                        onRemove: { index in
                            selectedMedia.remove(at: index)
                        }
                    )
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            // Улучшенное поле для контента
                            EnhancedContentView(
                                content: $content,
                                hashtags: $hashtags,
                                popularHashtags: popularHashtags
                            )
                            
                            // Улучшенный выбор ресторана
                            EnhancedRestaurantSection(
                                selectedRestaurant: $selectedRestaurant,
                                showingRestaurantPicker: $showingRestaurantPicker
                            )
                            
                            // Улучшенные хештеги
                            EnhancedHashtagsSection(
                                hashtags: $hashtags,
                                popularHashtags: popularHashtags
                            )
                            
                            // Новые функции
                            EnhancedFeaturesSection(
                                showingTemplates: $showingTemplates,
                                showingPreview: $showingPreview,
                                selectedTemplate: $selectedTemplate
                            )
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("🐂 Новая публикация")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        saveDraft()
                        dismiss()
                    }
                    .foregroundColor(Colors.bykAccent)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        // Кнопка предпросмотра
                        Button(action: { showingPreview = true }) {
                            Image(systemName: "eye")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.2))
                                )
                        }
                        .disabled(selectedMedia.isEmpty && content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        
                        // Кнопка публикации
                        Button("Опубликовать") {
                            createPost()
                        }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Colors.bykAccent,
                                            Colors.bykPrimary
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .disabled(selectedMedia.isEmpty || content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isCreating)
                        .opacity((selectedMedia.isEmpty || content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isCreating) ? 0.5 : 1.0)
                    }
                }
            }
        }
        .sheet(isPresented: $showingMediaPicker) {
            EnhancedMediaPickerView(selectedMedia: $selectedMedia)
        }
        .sheet(isPresented: $showingRestaurantPicker) {
            RestaurantPickerView(selectedRestaurant: $selectedRestaurant)
        }
        .sheet(isPresented: $showingPreview) {
            PostPreviewView(
                content: content,
                media: selectedMedia,
                restaurant: selectedRestaurant,
                hashtags: hashtags
            )
        }
        .sheet(isPresented: $showingTemplates) {
            PostTemplatesView(selectedTemplate: $selectedTemplate)
        }
        .sheet(isPresented: $showingFilters) {
            if let index = selectedMediaIndex, index < selectedMedia.count {
                MediaFiltersView(
                    media: $selectedMedia[index],
                    onApply: { showingFilters = false }
                )
            }
        }
        .alert("Ошибка", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .overlay(
            // Улучшенный индикатор загрузки
            Group {
                if isCreating {
                    EnhancedLoadingView()
                }
            }
        )
        .onAppear {
            loadDraft()
        }
        .onChange(of: content) { _, _ in
            autoSaveDraft()
        }
        .onChange(of: selectedMedia) { _, _ in
            autoSaveDraft()
        }
    }
    
    // MARK: - Helper Methods
    
    private func createPost() {
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedContent.isEmpty else {
            alertMessage = "Добавьте описание к публикации"
            showingAlert = true
            return
        }
        
        guard !selectedMedia.isEmpty else {
            alertMessage = "Добавьте фото или видео"
            showingAlert = true
            return
        }
        
        isCreating = true
        
        let post = Post(
            authorId: currentUser.id,
            authorName: currentUser.fullName,
            authorAvatar: currentUser.avatar,
            content: trimmedContent,
            media: selectedMedia,
            taggedRestaurant: selectedRestaurant,
            hashtags: hashtags
        )
        
        Task {
            await postService.createPost(post)
            
            DispatchQueue.main.async {
                isCreating = false
                clearDraft()
                dismiss()
            }
        }
    }
    
    private func autoSaveDraft() {
        // Автосохранение черновика каждые 5 секунд
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            saveDraft()
        }
    }
    
    private func saveDraft() {
        let draft = PostDraft(
            content: content,
            mediaUrls: selectedMedia.map { $0.url },
            restaurantId: selectedRestaurant?.id,
            hashtags: hashtags,
            timestamp: Date()
        )
        
        // Сохранение в UserDefaults (в реальном приложении - в Core Data)
        if let encoded = try? JSONEncoder().encode(draft) {
            UserDefaults.standard.set(encoded, forKey: "postDraft")
            draftSaved = true
        }
    }
    
    private func loadDraft() {
        if let data = UserDefaults.standard.data(forKey: "postDraft"),
           let draft = try? JSONDecoder().decode(PostDraft.self, from: data) {
            content = draft.content
            hashtags = draft.hashtags
            // Восстановление медиа и ресторана требует дополнительной логики
        }
    }
    
    private func clearDraft() {
        UserDefaults.standard.removeObject(forKey: "postDraft")
        draftSaved = false
    }
}

// MARK: - Data Models

struct PostDraft: Codable {
    let content: String
    let mediaUrls: [String]
    let restaurantId: UUID?
    let hashtags: [String]
    let timestamp: Date
}

struct PostTemplate: Identifiable {
    let id = UUID()
    let name: String
    let content: String
    let hashtags: [String]
    let emoji: String
}

// MARK: - Enhanced Background View
struct EnhancedCreatePostBackgroundView: View {
    @State private var animationPhase = 0
    
    var body: some View {
        ZStack {
            Color.black
            
            // Улучшенные плавающие элементы
            ForEach(0..<6, id: \.self) { index in
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Colors.bykAccent.opacity(0.2),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 100
                            )
                        )
                        .frame(width: CGFloat.random(in: 80...150))
                    
                    Text("🐂")
                        .font(.system(size: CGFloat.random(in: 20...30)))
                        .opacity(0.4)
                }
                .offset(
                    x: CGFloat.random(in: -300...300),
                    y: CGFloat.random(in: -600...600)
                )
                .scaleEffect(animationPhase == index % 3 ? 1.2 : 1.0)
                .animation(
                    .easeInOut(duration: Double.random(in: 4...8))
                    .repeatForever(autoreverses: true)
                    .delay(Double.random(in: 0...3)),
                    value: animationPhase
                )
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                animationPhase = 1
            }
        }
    }
} 

// MARK: - Enhanced Media Section
struct EnhancedMediaSection: View {
    @Binding var selectedMedia: [PostMedia]
    @Binding var showingMediaPicker: Bool
    @Binding var showingFilters: Bool
    @Binding var selectedMediaIndex: Int?
    let onRemove: (Int) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            if selectedMedia.isEmpty {
                EnhancedMediaPlaceholder(onTap: { showingMediaPicker = true })
            } else {
                EnhancedMediaPreview(
                    media: selectedMedia,
                    onRemove: onRemove,
                    onTapFilter: { index in
                        selectedMediaIndex = index
                        showingFilters = true
                    }
                )
            }
        }
    }
}

// MARK: - Enhanced Media Placeholder
struct EnhancedMediaPlaceholder: View {
    let onTap: () -> Void
    @State private var isAnimating = false
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Colors.bykAccent.opacity(0.15),
                                Colors.bykPrimary.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 250)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Colors.bykAccent.opacity(0.6),
                                        Colors.bykPrimary.opacity(0.4)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 2, dash: [15])
                            )
                    )
                    .scaleEffect(isAnimating ? 1.02 : 1.0)
                
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Colors.bykAccent, Colors.bykPrimary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                        
                        Text("📷")
                            .font(.system(size: 36))
                    }
                    
                    VStack(spacing: 8) {
                        Text("Добавить фото или видео")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("Нажмите, чтобы выбрать медиа")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding()
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Enhanced Media Preview
struct EnhancedMediaPreview: View {
    let media: [PostMedia]
    let onRemove: (Int) -> Void
    let onTapFilter: (Int) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(Array(media.enumerated()), id: \.element.id) { index, mediaItem in
                    ZStack(alignment: .topTrailing) {
                        // Показываем реальное изображение из документов
                        if let image = loadImageFromDocuments(mediaItem.url) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 140, height: 140)
                                .clipped()
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Colors.bykAccent.opacity(0.3), lineWidth: 1)
                                )
                        } else {
                            // Заглушка если изображение не найдено
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 140, height: 140)
                                .overlay(
                                    Text("📷")
                                        .font(.system(size: 30))
                                        .opacity(0.6)
                                )
                        }
                        
                        // Кнопки действий
                        VStack(spacing: 8) {
                            // Кнопка фильтров
                            Button(action: { onTapFilter(index) }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.black.opacity(0.7))
                                        .frame(width: 28, height: 28)
                                    
                                    Image(systemName: "slider.horizontal.3")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white)
                                }
                            }
                            
                            // Кнопка удаления
                            Button(action: { onRemove(index) }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.red.opacity(0.8))
                                        .frame(width: 28, height: 28)
                                    
                                    Image(systemName: "xmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(8)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 16)
    }
    
    private func loadImageFromDocuments(_ fileName: String) -> UIImage? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        guard let imageData = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: imageData)
    }
}

// MARK: - Enhanced Content View
struct EnhancedContentView: View {
    @Binding var content: String
    @Binding var hashtags: [String]
    let popularHashtags: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("📝 Описание")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(content.count)/500")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(content.count > 450 ? .red : .white.opacity(0.6))
            }
            
            TextField("Поделитесь своими впечатлениями...", text: $content, axis: .vertical)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.system(size: 16))
                .foregroundColor(.white)
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Colors.bykAccent.opacity(0.3),
                                            Colors.bykPrimary.opacity(0.2)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                )
                .lineLimit(5...10)
                .onChange(of: content) { _, newValue in
                    extractHashtags(from: newValue)
                }
            
            // Быстрые хештеги
            if !popularHashtags.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("🔥 Популярные хештеги")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                        ForEach(popularHashtags.prefix(6), id: \.self) { hashtag in
                            Button(action: {
                                if !hashtags.contains(hashtag) {
                                    hashtags.append(hashtag)
                                }
                            }) {
                                Text("#\(hashtag)")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(hashtags.contains(hashtag) ? .white : Colors.bykAccent)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(
                                                hashtags.contains(hashtag) ?
                                                AnyShapeStyle(LinearGradient(
                                                    colors: [Colors.bykAccent, Colors.bykPrimary],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )) :
                                                AnyShapeStyle(Color.white.opacity(0.1))
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(
                                                        hashtags.contains(hashtag) ? Color.clear : Colors.bykAccent.opacity(0.3),
                                                        lineWidth: 1
                                                    )
                                            )
                                    )
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func extractHashtags(from text: String) {
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        let hashtagWords = words.filter { $0.hasPrefix("#") }
        hashtags = hashtagWords.map { String($0.dropFirst()) }
    }
}

// MARK: - Enhanced Restaurant Section
struct EnhancedRestaurantSection: View {
    @Binding var selectedRestaurant: Restaurant?
    @Binding var showingRestaurantPicker: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🏪 Отметить ресторан")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Button(action: { showingRestaurantPicker = true }) {
                HStack {
                    if let restaurant = selectedRestaurant {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Colors.bykAccent, Colors.bykPrimary],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 50, height: 50)
                                
                                Text(restaurant.brand.emoji)
                                    .font(.system(size: 24))
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(restaurant.name)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text(restaurant.address)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                    } else {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: "location")
                                    .font(.system(size: 20))
                                    .foregroundColor(Colors.bykAccent)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Выбрать ресторан")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                
                                Text("Отметьте ресторан в публикации")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Colors.bykAccent.opacity(0.3),
                                            Colors.bykPrimary.opacity(0.2)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// MARK: - Enhanced Hashtags Section
struct EnhancedHashtagsSection: View {
    @Binding var hashtags: [String]
    let popularHashtags: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("🏷 Хештеги")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                if !hashtags.isEmpty {
                    Button("Очистить") {
                        hashtags.removeAll()
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Colors.bykAccent)
                }
            }
            
            if hashtags.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Хештеги будут автоматически извлечены из описания")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("Или выберите из популярных выше")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.4))
                }
            } else {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 100))
                ], spacing: 12) {
                    ForEach(hashtags, id: \.self) { hashtag in
                        HStack(spacing: 8) {
                            Text("#\(hashtag)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                            
                            Button(action: {
                                hashtags.removeAll { $0 == hashtag }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        colors: [Colors.bykAccent.opacity(0.3), Colors.bykPrimary.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Colors.bykAccent.opacity(0.5), lineWidth: 1)
                                )
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Enhanced Features Section
struct EnhancedFeaturesSection: View {
    @Binding var showingTemplates: Bool
    @Binding var showingPreview: Bool
    @Binding var selectedTemplate: PostTemplate?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("✨ Дополнительно")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            HStack(spacing: 12) {
                // Шаблоны
                Button(action: { showingTemplates = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 16))
                        
                        Text("Шаблоны")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [Colors.bykAccent.opacity(0.3), Colors.bykPrimary.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Colors.bykAccent.opacity(0.4), lineWidth: 1)
                            )
                    )
                }
                
                // Предпросмотр
                Button(action: { showingPreview = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "eye")
                            .font(.system(size: 16))
                        
                        Text("Предпросмотр")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [Colors.bykAccent.opacity(0.3), Colors.bykPrimary.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Colors.bykAccent.opacity(0.4), lineWidth: 1)
                            )
                    )
                }
            }
        }
    }
}

// MARK: - Enhanced Loading View
struct EnhancedLoadingView: View {
    @State private var isAnimating = false
    @State private var pulseScale = 1.0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                ZStack {
                    // Внешний круг
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Colors.bykAccent.opacity(0.3),
                                    Colors.bykPrimary.opacity(0.2)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 4
                        )
                        .frame(width: 80, height: 80)
                        .scaleEffect(pulseScale)
                    
                    // Вращающийся круг
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Colors.bykAccent,
                                    Colors.bykPrimary
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    
                    // Центральный бык
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Colors.bykAccent, Colors.bykPrimary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                        
                        Text("🐂")
                            .font(.system(size: 24))
                    }
                }
                
                VStack(spacing: 12) {
                    Text("Публикуем...")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Ваша публикация скоро появится в ленте")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                pulseScale = 1.1
            }
        }
    }
}

// MARK: - Enhanced Media Picker View
struct EnhancedMediaPickerView: View {
    @Binding var selectedMedia: [PostMedia]
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var isProcessing = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Заголовок
                    VStack(spacing: 8) {
                        Text("📷 Добавить медиа")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Выберите фото или видео для публикации")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Кнопки выбора
                    VStack(spacing: 16) {
                        // Выбор из галереи
                        PhotosPicker(
                            selection: $selectedPhotos,
                            maxSelectionCount: 10,
                            matching: .any(of: [.images, .videos])
                        ) {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [Colors.bykAccent, Colors.bykPrimary],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 50, height: 50)
                                    
                                    Image(systemName: "photo.on.rectangle")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(.white)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Выбрать из галереи")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Text("До 10 фото или видео")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.1),
                                                Color.white.opacity(0.05)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [
                                                        Colors.bykAccent.opacity(0.4),
                                                        Colors.bykPrimary.opacity(0.3)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1
                                            )
                                    )
                            )
                        }
                        
                        // Сделать фото
                        Button(action: {
                            // Здесь будет камера
                        }) {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [Colors.bykAccent, Colors.bykPrimary],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 50, height: 50)
                                    
                                    Image(systemName: "camera")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(.white)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Сделать фото")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Text("Использовать камеру")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.1),
                                                Color.white.opacity(0.05)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [
                                                        Colors.bykAccent.opacity(0.4),
                                                        Colors.bykPrimary.opacity(0.3)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1
                                            )
                                    )
                            )
                        }
                        .disabled(true) // Пока отключаем камеру
                        .opacity(0.5)
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Кнопка закрытия
                    Button("Закрыть") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Colors.bykAccent)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
        }
        .onChange(of: selectedPhotos) { _, newPhotos in
            processSelectedPhotos(newPhotos)
        }
        .overlay(
            // Индикатор обработки
            Group {
                if isProcessing {
                    ZStack {
                        Color.black.opacity(0.8)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(Colors.bykAccent)
                            
                            Text("Обрабатываем фото...")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        )
    }
    
    private func processSelectedPhotos(_ photos: [PhotosPickerItem]) {
        guard !photos.isEmpty else { return }
        
        isProcessing = true
        
        Task {
            var newMedia: [PostMedia] = []
            
            for photo in photos {
                if let data = try? await photo.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    
                    // Сохраняем изображение в документы приложения
                    if let savedURL = saveImageToDocuments(uiImage) {
                        let media = PostMedia(
                            id: UUID(),
                            type: .image,
                            url: savedURL.lastPathComponent, // Используем только имя файла
                            thumbnail: savedURL.lastPathComponent
                        )
                        newMedia.append(media)
                    }
                }
            }
            
            await MainActor.run {
                selectedMedia.append(contentsOf: newMedia)
                isProcessing = false
                dismiss()
            }
        }
    }
    
    private func saveImageToDocuments(_ image: UIImage) -> URL? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "post_\(UUID().uuidString).jpg"
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Ошибка сохранения изображения: \(error)")
            return nil
        }
    }
}

struct PostPreviewView: View {
    let content: String
    let media: [PostMedia]
    let restaurant: Restaurant?
    let hashtags: [String]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Заголовок
                    Text("Предпросмотр поста")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    // Медиа
                    if !media.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("📷 Медиа (\(media.count))")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(media, id: \.id) { mediaItem in
                                        if let image = loadImageFromDocuments(mediaItem.url) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 200, height: 200)
                                                .clipped()
                                                .cornerRadius(16)
                                        } else {
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(width: 200, height: 200)
                                                .overlay(
                                                    Text("📷")
                                                        .font(.system(size: 40))
                                                        .opacity(0.6)
                                                )
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Контент
                    VStack(alignment: .leading, spacing: 12) {
                        Text("📝 Описание")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text(content.isEmpty ? "Нет описания" : content)
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.1))
                            )
                    }
                    .padding(.horizontal)
                    
                    // Ресторан
                    if let restaurant = restaurant {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("🏪 Ресторан")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            
                            HStack(spacing: 12) {
                                Text(restaurant.brand.emoji)
                                    .font(.system(size: 24))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(restaurant.name)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                    
                                    Text(restaurant.address)
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                
                                Spacer()
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.1))
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Хештеги
                    if !hashtags.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("🏷 Хештеги")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                                ForEach(hashtags, id: \.self) { hashtag in
                                    Text("#\(hashtag)")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Colors.bykAccent)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Colors.bykAccent.opacity(0.2))
                                        )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .navigationTitle("Предпросмотр")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                    .foregroundColor(Colors.bykAccent)
                }
            }
        }
    }
    
    private func loadImageFromDocuments(_ fileName: String) -> UIImage? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        guard let imageData = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: imageData)
    }
}

struct PostTemplatesView: View {
    @Binding var selectedTemplate: PostTemplate?
    @Environment(\.dismiss) private var dismiss
    
    private let templates = [
        PostTemplate(name: "Отличный ужин", content: "Потрясающий ужин в @restaurant! 🍽", hashtags: ["ужин", "ресторан"], emoji: "🍽"),
        PostTemplate(name: "Стейк", content: "Лучший стейк в городе! 🥩", hashtags: ["стейк", "мясо"], emoji: "🥩"),
        PostTemplate(name: "Пиво", content: "Отличное пиво и атмосфера! 🍺", hashtags: ["пиво", "бар"], emoji: "🍺")
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Шаблоны постов")
                    .font(.title)
                    .foregroundColor(.white)
                
                ForEach(templates) { template in
                    Button(action: {
                        selectedTemplate = template
                        dismiss()
                    }) {
                        HStack {
                            Text(template.emoji)
                                .font(.title2)
                            
                            VStack(alignment: .leading) {
                                Text(template.name)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text(template.content)
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .navigationTitle("Шаблоны")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct MediaFiltersView: View {
    @Binding var media: PostMedia
    let onApply: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Фильтры для медиа")
                    .font(.title)
                    .foregroundColor(.white)
                
                Text("Здесь будут фильтры")
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .navigationTitle("Фильтры")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Применить") {
                        onApply()
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    CreatePostView(postService: PostService())
} 