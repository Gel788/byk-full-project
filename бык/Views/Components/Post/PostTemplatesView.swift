import SwiftUI

struct PostTemplatesView: View {
    @Binding var selectedTemplate: PostTemplate?
    @Binding var showingTemplates: Bool
    let onSelect: (PostTemplate) -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                // Заголовок
                VStack(spacing: 8) {
                    Text("Шаблоны постов")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Выберите готовый шаблон для быстрого создания поста")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                // Список шаблонов
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(PostTemplate.templates) { template in
                            PostTemplateCard(
                                template: template,
                                onSelect: {
                                    onSelect(template)
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
            .background(Color.black)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        showingTemplates = false
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

struct PostTemplateCard: View {
    let template: PostTemplate
    let onSelect: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 12) {
                // Заголовок шаблона
                HStack {
                    Text(template.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text(template.category)
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.2))
                        )
                }
                
                // Содержимое шаблона
                Text(template.content)
                    .font(.body)
                    .foregroundColor(.gray)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                
                // Хештеги
                if !template.hashtags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(template.hashtags, id: \.self) { hashtag in
                                Text("#\(hashtag)")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.blue.opacity(0.2))
                                    )
                            }
                        }
                        .padding(.horizontal, 1)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
        }
    }
}

struct MediaFiltersView: View {
    let media: PostMedia
    let onApply: (PostMedia) -> Void
    @State private var brightness: Double = 1.0
    @State private var contrast: Double = 1.0
    @State private var saturation: Double = 1.0
    
    var body: some View {
        NavigationView {
            VStack {
                // Предпросмотр изображения
                if media.type == .image {
                    AsyncImage(url: URL(fileURLWithPath: media.url)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.white)
                            )
                    }
                        .frame(maxHeight: 300)
                        .padding()
                }
                
                // Настройки фильтров
                VStack(spacing: 20) {
                    FilterSlider(
                        title: "Яркость",
                        value: $brightness,
                        range: 0.5...2.0
                    )
                    
                    FilterSlider(
                        title: "Контраст",
                        value: $contrast,
                        range: 0.5...2.0
                    )
                    
                    FilterSlider(
                        title: "Насыщенность",
                        value: $saturation,
                        range: 0.0...2.0
                    )
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Фильтры")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        // Закрыть без применения
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Применить") {
                        // Применить фильтры
                        onApply(media)
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

struct FilterSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(value, specifier: "%.1f")")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Slider(value: $value, in: range)
                .accentColor(.blue)
        }
    }
}

struct PostPreviewView: View {
    let content: String
    let selectedMedia: [PostMedia]
    let selectedRestaurant: Restaurant?
    let hashtags: [String]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Медиа
                    if !selectedMedia.isEmpty {
                        MediaPreviewSection(selectedMedia: selectedMedia)
                    }
                    
                    // Ресторан
                    if let restaurant = selectedRestaurant {
                        HStack(spacing: 12) {
                            AsyncImage(url: URL(string: restaurant.imageURL)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.3))
                            }
                            .frame(width: 50, height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(restaurant.name)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text(restaurant.cuisine)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.1))
                        )
                    }
                    
                    // Контент
                    if !content.isEmpty {
                        Text(content)
                            .font(.body)
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.1))
                            )
                    }
                    
                    // Хештеги
                    if !hashtags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(hashtags, id: \.self) { hashtag in
                                    Text("#\(hashtag)")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.blue.opacity(0.2))
                                        )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding()
            }
            .background(Color.black)
            .navigationTitle("Предпросмотр")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        // Закрыть предпросмотр
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

struct MediaPreviewSection: View {
    let selectedMedia: [PostMedia]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(selectedMedia.indices, id: \.self) { index in
                    MediaPreviewItem(media: selectedMedia[index])
                }
            }
            .padding(.horizontal)
        }
    }
}

struct MediaPreviewItem: View {
    let media: PostMedia
    
    var body: some View {
        if media.type == .image {
            AsyncImage(url: URL(fileURLWithPath: media.url)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.white)
                    )
            }
            .frame(width: 200, height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

#Preview {
    PostTemplatesView(
        selectedTemplate: .constant(nil),
        showingTemplates: .constant(true)
    ) { _ in }
}
