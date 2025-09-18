import SwiftUI

struct RestaurantPhotoGalleryView: View {
    let restaurant: Restaurant
    @Environment(\.dismiss) private var dismiss
    @State private var selectedImageIndex = 0
    @State private var showFullscreen = false
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color) {
        Colors.brandColors(for: restaurant.brand)
    }
    
    // Mock галерея изображений
    private var galleryImages: [String] {
        [
            restaurant.imageURL,
            "thebyk_interior1",
            "thebyk_interior2", 
            "thebyk_interior3",
            "thebyk_interior4"
        ]
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Фон
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Основное изображение
                    TabView(selection: $selectedImageIndex) {
                        ForEach(0..<galleryImages.count, id: \.self) { index in
                            ZStack {
                                Image(galleryImages[index])
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipped()
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                            showFullscreen = true
                                        }
                                    }
                                
                                // Индикатор zoom
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        
                        VStack(spacing: 4) {
                            Image(systemName: "viewfinder")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text("Нажмите для\nполного экрана")
                                .font(.caption2)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.black.opacity(0.6))
                        )
                        .padding()
                    }
                }
                .opacity(selectedImageIndex == index ? 1.0 : 0.0)
                .animation(.easeInOut, value: selectedImageIndex)
            }
            .tag(index)
        }
    }
    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
    .frame(height: 400)
    
                    // Миниатюры
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(0..<galleryImages.count, id: \.self) { index in
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedImageIndex = index
                                    }
                                }) {
                                    Image(galleryImages[index])
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 80, height: 60)
                                        .clipped()
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(
                                                    selectedImageIndex == index ? brandColors.accent : Color.clear,
                                                    lineWidth: selectedImageIndex == index ? 3 : 0
                                                )
                                        )
                                        .scaleEffect(selectedImageIndex == index ? 1.1 : 1.0)
                                        .shadow(
                                            color: selectedImageIndex == index ? brandColors.accent.opacity(0.4) : Color.clear,
                                            radius: selectedImageIndex == index ? 8 : 0,
                                            x: 0,
                                            y: 4
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 16)
                    
                    // Информация о фото
                    VStack(alignment: .leading, spacing: 12) {
                        Text(getPhotoDescription(for: selectedImageIndex))
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        
                        Text("\(selectedImageIndex + 1) из \(galleryImages.count)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
            }
            .navigationTitle("Фото \(restaurant.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .fullScreenCover(isPresented: $showFullscreen) {
                FullscreenImageView(
                    images: galleryImages,
                    selectedIndex: selectedImageIndex,
                    restaurant: restaurant
                )
            }
        }
    }
    
    private func getPhotoDescription(for index: Int) -> String {
        switch index {
        case 0:
            return "Главное фото ресторана"
        case 1:
            return "Основной зал"
        case 2:
            return "Барная стойка"
        case 3:
            return "VIP-зал"
        case 4:
            return "Летняя терраса"
        default:
            return "Интерьер ресторана"
        }
    }
}

// MARK: - Fullscreen Image View
struct FullscreenImageView: View {
    let images: [String]
    @State var selectedIndex: Int
    let restaurant: Restaurant
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            TabView(selection: $selectedIndex) {
                ForEach(0..<images.count, id: \.self) { index in
                    ZStack {
                        Image(images[index])
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .scaleEffect(scale)
                            .offset(offset)
                            .gesture(
                                SimultaneousGesture(
                                    MagnificationGesture()
                                        .onChanged { value in
                                            scale = lastScale * value
                                        }
                                        .onEnded { _ in
                                            withAnimation(.spring()) {
                                                if scale < 1 {
                                                    scale = 1
                                                    offset = .zero
                                                } else if scale > 3 {
                                                    scale = 3
                                                }
                                            }
                                            lastScale = scale
                                        },
                                    
                                    DragGesture()
                                        .onChanged { value in
                                            if scale > 1 {
                                                offset = CGSize(
                                                    width: lastOffset.width + value.translation.width,
                                                    height: lastOffset.height + value.translation.height
                                                )
                                            }
                                        }
                                        .onEnded { _ in
                                            lastOffset = offset
                                        }
                                )
                            )
                            .onTapGesture(count: 2) {
                                withAnimation(.spring()) {
                                    if scale == 1 {
                                        scale = 2
                                    } else {
                                        scale = 1
                                        offset = .zero
                                        lastOffset = .zero
                                    }
                                }
                                lastScale = scale
                            }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // Закрыть и счетчик
            VStack {
                HStack {
                    Button("Закрыть") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.6))
                    )
                    
                    Spacer()
                    
                    Text("\(selectedIndex + 1)/\(images.count)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.6))
                        )
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                
                Spacer()
                
                // Индикаторы внизу
                HStack(spacing: 8) {
                    ForEach(0..<images.count, id: \.self) { index in
                        Circle()
                            .fill(selectedIndex == index ? Color.white : Color.white.opacity(0.4))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .onTapGesture {
            dismiss()
        }
    }
}

#Preview {
    RestaurantPhotoGalleryView(restaurant: Restaurant.mock)
}