import SwiftUI
import PhotosUI

// MARK: - Create Post State
struct CreatePostState {
    var selectedMedia: [PostMedia] = []
    var content = ""
    var selectedRestaurant: Restaurant?
    var hashtags: [String] = []
    var showingRestaurantPicker = false
    var showingMediaPicker = false
    var isCreating = false
    var showingAlert = false
    var alertMessage = ""
    var showingPreview = false
    var showingTemplates = false
    var selectedTemplate: PostTemplate?
    var showingFilters = false
    var selectedMediaIndex: Int?
    var draftSaved = false
}

struct CreatePostView: View {
    @ObservedObject var postService: PostService
    @Environment(\.dismiss) private var dismiss
    
    @State private var state = CreatePostState()
    
    private let currentUser = User.mock // Временно используем мок пользователя
    
    var body: some View {
        NavigationView {
            ZStack {
                // Фон
                EnhancedCreatePostBackgroundView()
                
                VStack(spacing: 0) {
                    // Медиа секция
                    EnhancedMediaSection(
                        selectedMedia: $state.selectedMedia,
                        showingMediaPicker: $state.showingMediaPicker,
                        showingFilters: $state.showingFilters,
                        selectedMediaIndex: $state.selectedMediaIndex,
                        onRemove: { index in
                            state.selectedMedia.remove(at: index)
                        }
                    )
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // Контент секция
                            EnhancedContentView(
                                content: $state.content,
                                hashtags: $state.hashtags
                            )
                            
                            // Ресторан секция
                            EnhancedRestaurantSection(
                                selectedRestaurant: $state.selectedRestaurant,
                                showingRestaurantPicker: $state.showingRestaurantPicker
                            )
                            
                            // Хештеги секция
                            EnhancedHashtagsSection(hashtags: $state.hashtags)
                            
                            // Дополнительные функции
                            EnhancedFeaturesSection(
                                showingTemplates: $state.showingTemplates,
                                showingPreview: $state.showingPreview
                            )
                        }
                        .padding(.bottom, 100)
                    }
                }
                
                // Загрузочный экран
                if state.isCreating {
                    EnhancedLoadingView()
                }
            }
            .navigationTitle("Создать пост")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Опубликовать") {
                        createPost()
                    }
                    .foregroundColor(.white)
                    .disabled(state.content.isEmpty && state.selectedMedia.isEmpty)
                }
            }
            .alert("Ошибка", isPresented: $state.showingAlert) {
                Button("OK") { }
            } message: {
                Text(state.alertMessage)
            }
            .sheet(isPresented: $state.showingMediaPicker) {
                EnhancedMediaPickerView(
                    selectedMedia: $state.selectedMedia,
                    showingMediaPicker: $state.showingMediaPicker
                )
            }
            .sheet(isPresented: $state.showingRestaurantPicker) {
                PostRestaurantPickerView(
                    selectedRestaurant: $state.selectedRestaurant,
                    showingRestaurantPicker: $state.showingRestaurantPicker
                )
            }
            .sheet(isPresented: $state.showingPreview) {
                PostPreviewView(
                    content: state.content,
                    selectedMedia: state.selectedMedia,
                    selectedRestaurant: state.selectedRestaurant,
                    hashtags: state.hashtags
                )
            }
            .sheet(isPresented: $state.showingTemplates) {
                PostTemplatesView(
                    selectedTemplate: $state.selectedTemplate,
                    showingTemplates: $state.showingTemplates
                ) { template in
                    applyTemplate(template)
                }
            }
            .sheet(isPresented: $state.showingFilters) {
                if let index = state.selectedMediaIndex {
                    MediaFiltersView(
                        media: state.selectedMedia[index],
                        onApply: { filteredMedia in
                            state.selectedMedia[index] = filteredMedia
                            state.showingFilters = false
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - Actions
    private func createPost() {
        state.isCreating = true
        
        Task {
            do {
                let post = Post(
                    id: UUID(),
                    authorId: currentUser.id,
                    authorName: currentUser.fullName,
                    authorAvatar: currentUser.avatar,
                    content: state.content,
                    media: state.selectedMedia,
                    taggedRestaurant: state.selectedRestaurant,
                    hashtags: state.hashtags,
                    likes: 0,
                    comments: 0,
                    isLiked: false,
                    createdAt: Date()
                )
                
                try await postService.createPost(post)
                
                await MainActor.run {
                    state.isCreating = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    state.isCreating = false
                    state.alertMessage = error.localizedDescription
                    state.showingAlert = true
                }
            }
        }
    }
    
    private func applyTemplate(_ template: PostTemplate) {
        state.content = template.content
        state.hashtags = template.hashtags
        state.showingTemplates = false
    }
}

// MARK: - Additional Views

struct EnhancedFeaturesSection: View {
    @Binding var showingTemplates: Bool
    @Binding var showingPreview: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Дополнительно")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 16) {
                FeatureButton(
                    icon: "doc.text",
                    title: "Шаблоны",
                    color: .blue
                ) {
                    showingTemplates = true
                }
                
                FeatureButton(
                    icon: "eye",
                    title: "Предпросмотр",
                    color: .green
                ) {
                    showingPreview = true
                }
                
                FeatureButton(
                    icon: "square.and.arrow.down",
                    title: "Сохранить черновик",
                    color: .orange
                ) {
                    // Сохранение черновика
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

struct FeatureButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(color.opacity(0.5), lineWidth: 1)
                    )
            )
        }
    }
}

#Preview {
    CreatePostView(postService: PostService())
}
