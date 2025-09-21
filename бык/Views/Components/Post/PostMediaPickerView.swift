import SwiftUI
import PhotosUI

struct EnhancedMediaPickerView: View {
    @Binding var selectedMedia: [PostMedia]
    @Binding var showingMediaPicker: Bool
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Загрузка медиа...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if selectedMedia.isEmpty {
                    // Пустое состояние
                    VStack(spacing: 20) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Выберите фото или видео")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text("Добавьте медиа для создания интересного поста")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Предпросмотр выбранных медиа
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                            ForEach(selectedMedia.indices, id: \.self) { index in
                                MediaPreviewCard(
                                    media: selectedMedia[index],
                                    onRemove: {
                                        selectedMedia.remove(at: index)
                                    }
                                )
                            }
                        }
                        .padding()
                    }
                }
                
                // Кнопка выбора медиа
                PhotosPicker(
                    selection: $selectedItems,
                    maxSelectionCount: 10,
                    matching: .any(of: [.images, .videos])
                ) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Выбрать медиа")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue)
                    )
                }
                .padding()
            }
            .background(Color.black)
            .navigationTitle("Медиа")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        showingMediaPicker = false
                    }
                    .foregroundColor(.white)
                }
            }
            .onChange(of: selectedItems) { items in
                loadMedia(from: items)
            }
        }
    }
    
    private func loadMedia(from items: [PhotosPickerItem]) {
        isLoading = true
        
        Task {
            var newMedia: [PostMedia] = []
            
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    // Сохраняем изображение во временный файл
                    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).jpg")
                    if let imageData = image.jpegData(compressionQuality: 0.8) {
                        try? imageData.write(to: tempURL)
                        newMedia.append(PostMedia(
                            type: .image,
                            url: tempURL.path,
                            width: Int(image.size.width),
                            height: Int(image.size.height)
                        ))
                    }
                }
            }
            
            await MainActor.run {
                selectedMedia = newMedia
                isLoading = false
            }
        }
    }
}

struct MediaPreviewCard: View {
    let media: PostMedia
    let onRemove: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Изображение
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
                                .font(.title)
                                .foregroundColor(.white)
                        )
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 200)
                    .overlay(
                        Image(systemName: "video.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    )
            }
            
            // Кнопка удаления
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.red)
                    .background(Circle().fill(.white))
            }
            .padding(8)
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
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

struct PostRestaurantPickerView: View {
    @Binding var selectedRestaurant: Restaurant?
    @Binding var showingRestaurantPicker: Bool
    @State private var searchText = ""
    
    // Мок данные для демонстрации
    private let restaurants = [
        Restaurant(
            id: UUID(),
            name: "Бык",
            description: "Стейк-хаус премиум класса",
            address: "ул. Тверская, 1",
            city: "Москва",
            imageURL: "",
            rating: 4.8,
            cuisine: "Стейк-хаус",
            deliveryTime: 45,
            brand: .theByk,
            menu: [],
            features: [],
            workingHours: WorkingHours.default,
            location: Location(latitude: 0, longitude: 0),
            tables: [],
            gallery: []
        ),
        Restaurant(
            id: UUID(),
            name: "Грузия",
            description: "Грузинская кухня",
            address: "пр. Мира, 10",
            city: "Москва",
            imageURL: "",
            rating: 4.6,
            cuisine: "Грузинская",
            deliveryTime: 35,
            brand: .theGeorgia,
            menu: [],
            features: [],
            workingHours: WorkingHours.default,
            location: Location(latitude: 0, longitude: 0),
            tables: [],
            gallery: []
        )
    ]
    
    private var filteredRestaurants: [Restaurant] {
        if searchText.isEmpty {
            return restaurants
        } else {
            return restaurants.filter { restaurant in
                restaurant.name.localizedCaseInsensitiveContains(searchText) ||
                restaurant.cuisine.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Поиск
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Поиск ресторана", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(.white)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                )
                .padding()
                
                // Список ресторанов
                List(filteredRestaurants) { restaurant in
                    PostRestaurantPickerRow(
                        restaurant: restaurant,
                        isSelected: selectedRestaurant?.id == restaurant.id
                    ) {
                        selectedRestaurant = restaurant
                        showingRestaurantPicker = false
                    }
                }
                .listStyle(PlainListStyle())
            }
            .background(Color.black)
            .navigationTitle("Выбор ресторана")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Отмена") {
                        showingRestaurantPicker = false
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

struct PostRestaurantPickerRow: View {
    let restaurant: Restaurant
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Изображение ресторана
                AsyncImage(url: URL(string: restaurant.imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                // Информация о ресторане
                VStack(alignment: .leading, spacing: 4) {
                    Text(restaurant.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(restaurant.cuisine)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    HStack {
                        ForEach(0..<Int(restaurant.rating), id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                        }
                        
                        Text("\(restaurant.rating, specifier: "%.1f")")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                // Индикатор выбора
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    EnhancedMediaPickerView(
        selectedMedia: .constant([]),
        showingMediaPicker: .constant(true)
    )
}
