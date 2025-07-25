import SwiftUI

struct NewsCard: View {
    let item: NewsItem
    @State private var isBookmarked = false
    @State private var showingShare = false
    @State private var isPressed = false
    @State private var isHovered = false
    @State private var imageScale: CGFloat = 1.0
    @State private var cardOffset: CGFloat = 0
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color) {
        Colors.brandColors(for: item.brand)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Изображение с градиентным наложением и анимацией
            ZStack(alignment: .bottomLeading) {
                // Основное изображение с анимацией
                Image(item.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(16, corners: [.topLeft, .topRight])
                    .scaleEffect(imageScale)
                    .animation(.easeInOut(duration: 0.3), value: imageScale)
                
                // Градиентное наложение
                LinearGradient(
                    gradient: Gradient(colors: [
                        .clear,
                        .black.opacity(0.3),
                        .black.opacity(0.7)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .cornerRadius(16, corners: [.topLeft, .topRight])
                
                // Индикатор прочтения
                if item.isRead {
                    VStack {
                        HStack {
                            Spacer()
                            ZStack {
                                Circle()
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
                                    .frame(width: 24, height: 24)
                                    .shadow(color: Colors.bykAccent.opacity(0.6), radius: 4, x: 0, y: 2)
                                
                                Text("🐂")
                                    .font(.system(size: 12))
                            }
                            .padding(.top, 12)
                            .padding(.trailing, 12)
                        }
                        Spacer()
                    }
                }
                
                // Контент поверх изображения
                VStack(alignment: .leading, spacing: 8) {
                    // Тип новости и дата
                    HStack {
                        Label(item.type.rawValue, systemImage: item.type.icon)
                            .font(.system(size: 11, weight: .semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(brandColors.accent.opacity(0.9))
                            )
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Дата
                        Text(item.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(.black.opacity(0.6))
                            )
                    }
                    
                    // Заголовок
                    Text(item.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                .padding(12)
            }
            
            // Нижняя часть карточки
            VStack(alignment: .leading, spacing: 10) {
                // Описание
                Text(item.description)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // Нижняя панель с брендом и действиями
                HStack {
                    // Бренд
                    HStack(spacing: 4) {
                        Circle()
                            .fill(brandColors.primary)
                            .frame(width: 6, height: 6)
                        Text(item.brand.rawValue)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(brandColors.primary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(brandColors.secondary.opacity(0.15))
                    )
                    
                    Spacer()
                    
                    // Статистика и действия
                    HStack(spacing: 12) {
                        // Лайки с анимацией
                        HStack(spacing: 4) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.red.opacity(0.8))
                                .scaleEffect(item.isLiked ? 1.2 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: item.isLiked)
                            Text("\(item.likes)")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        // Комментарии
                        HStack(spacing: 4) {
                            Image(systemName: "bubble.left.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.blue.opacity(0.8))
                            Text("\(item.comments.count)")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        Spacer()
                        
                        // Кнопки действий с улучшенными анимациями
                        HStack(spacing: 8) {
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    isBookmarked.toggle()
                                }
                            }) {
                                Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                                    .font(.system(size: 12))
                                    .foregroundColor(isBookmarked ? brandColors.accent : .white.opacity(0.6))
                                    .scaleEffect(isBookmarked ? 1.2 : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isBookmarked)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    showingShare = true
                                }
                            }) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.6))
                                    .scaleEffect(isHovered ? 1.1 : 1.0)
                                    .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isHovered)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            .padding(12)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.9),
                    Color.black.opacity(0.7)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            brandColors.accent.opacity(0.3),
                            brandColors.primary.opacity(0.2),
                            Color.clear
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(
            color: Color.black.opacity(isHovered ? 0.6 : 0.3),
            radius: isHovered ? 16 : 12,
            x: 0,
            y: isHovered ? 10 : 6
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .offset(y: cardOffset)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isHovered)

        .onHover { hovering in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isHovered = hovering
                imageScale = hovering ? 1.05 : 1.0
                cardOffset = hovering ? -4 : 0
            }
        }
        .sheet(isPresented: $showingShare) {
            ShareSheet(activityItems: [item.title, item.description])
        }
    }
}



#Preview {
    NewsCard(item: NewsItem.mock)
        .padding()
        .background(Color.black)
} 