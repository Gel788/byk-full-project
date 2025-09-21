import SwiftUI
import PhotosUI

struct EnhancedMediaSection: View {
    @Binding var selectedMedia: [PostMedia]
    @Binding var showingMediaPicker: Bool
    @Binding var showingFilters: Bool
    @Binding var selectedMediaIndex: Int?
    let onRemove: (Int) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Заголовок секции
            HStack {
                Text("Медиа")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    showingMediaPicker = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            // Контейнер медиа
            if selectedMedia.isEmpty {
                EnhancedMediaPlaceholder {
                    showingMediaPicker = true
                }
            } else {
                EnhancedMediaPreview(
                    selectedMedia: selectedMedia,
                    onRemove: onRemove,
                    onFilter: { index in
                        selectedMediaIndex = index
                        showingFilters = true
                    }
                )
            }
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
        )
        .padding(.horizontal)
    }
}

struct EnhancedMediaPlaceholder: View {
    let onAdd: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("Добавьте фото или видео")
                .font(.headline)
                .foregroundColor(.gray)
            
            Button("Выбрать медиа", action: onAdd)
                .buttonStyle(.borderedProminent)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [10]))
        )
        .padding(.horizontal)
    }
}

struct EnhancedMediaPreview: View {
    let selectedMedia: [PostMedia]
    let onRemove: (Int) -> Void
    let onFilter: (Int) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(selectedMedia.indices, id: \.self) { index in
                    MediaItemView(
                        media: selectedMedia[index],
                        onRemove: { onRemove(index) },
                        onFilter: { onFilter(index) }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

struct MediaItemView: View {
    let media: PostMedia
    let onRemove: () -> Void
    let onFilter: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Изображение или видео
            Group {
                if media.type == .image {
                    AsyncImage(url: URL(fileURLWithPath: media.url)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.white)
                            )
                    }
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "video.fill")
                                .foregroundColor(.white)
                        )
                }
            }
            .frame(width: 100, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Кнопки управления
            VStack(spacing: 4) {
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .background(Circle().fill(.white))
                }
                
                Button(action: onFilter) {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(.blue)
                        .background(Circle().fill(.white))
                }
            }
        }
    }
}
