import SwiftUI

struct NewsDetailView: View {
    let newsId: UUID
    @ObservedObject var newsService: NewsService
    @Environment(\.dismiss) private var dismiss
    
    @State private var newCommentText = ""
    @State private var animateLike = false
    @State private var showingShare = false
    
    private var newsItem: NewsItem? {
        newsService.getNews(by: newsId)
    }
    
    var body: some View {
        NavigationView {
            if let newsItem = newsItem {
                ScrollView {
                    VStack(spacing: 24) {
                        // Изображение новости
                        Image(newsItem.image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                            .cornerRadius(16)
                            .padding(.horizontal, 20)
                        
                        // Заголовок и дата
                        VStack(spacing: 12) {
                            HStack(spacing: 8) {
                                Text("🐂")
                                    .font(.system(size: 24))
                                
                                Text(newsItem.title)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                            }
                            
                            Text(newsItem.date, style: .date)
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.horizontal, 20)
                        
                        // Описание
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Описание")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(newsItem.description)
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(4)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        
                        // Действия
                        HStack(spacing: 20) {
                            // Кнопка лайка
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    animateLike = true
                                    newsService.likeNews(id: newsItem.id)
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    animateLike = false
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: newsItem.isLiked ? "heart.fill" : "heart")
                                        .font(.system(size: 18))
                                        .foregroundColor(newsItem.isLiked ? .red : .white)
                                        .scaleEffect(animateLike ? 1.3 : 1.0)
                                    
                                    Text("\(newsItem.likes)")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                }
                            }
                            
                            // Кнопка комментариев
                            HStack(spacing: 8) {
                                Image(systemName: "message")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                
                                Text("\(newsItem.comments.count)")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            // Кнопка поделиться
                            Button(action: { showingShare = true }) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        
                        // Комментарии
                        VStack(spacing: 16) {
                            HStack {
                                Text("Комментарии (\(newsItem.comments.count))")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                            
                            if newsItem.comments.isEmpty {
                                VStack(spacing: 20) {
                                    ZStack {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Colors.bykAccent.opacity(0.2),
                                                        Colors.bykPrimary.opacity(0.1)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 80, height: 80)
                                            .overlay(
                                                Circle()
                                                    .stroke(
                                                        LinearGradient(
                                                            gradient: Gradient(colors: [
                                                                Colors.bykAccent.opacity(0.4),
                                                                Colors.bykPrimary.opacity(0.2)
                                                            ]),
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        ),
                                                        lineWidth: 1
                                                    )
                                            )
                                        
                                        Text("🐂")
                                            .font(.system(size: 40))
                                    }
                                    
                                    VStack(spacing: 8) {
                                        Text("Пока нет комментариев")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.white)
                                        
                                        Text("Будьте первым, кто оставит комментарий!")
                                            .font(.system(size: 14))
                                            .foregroundColor(.white.opacity(0.6))
                                            .multilineTextAlignment(.center)
                                    }
                                }
                                .padding(.vertical, 40)
                            } else {
                                LazyVStack(spacing: 12) {
                                    ForEach(newsItem.comments) { comment in
                                        HStack(alignment: .top, spacing: 12) {
                                            // Аватар пользователя
                                            Circle()
                                                .fill(Color.accentColor)
                                                .frame(width: 40, height: 40)
                                                .overlay(
                                                    Text(comment.author.prefix(1).uppercased())
                                                        .font(.system(size: 16, weight: .bold))
                                                        .foregroundColor(.white)
                                                )
                                            
                                            // Содержимое комментария
                                            VStack(alignment: .leading, spacing: 8) {
                                                HStack {
                                                    Text(comment.author)
                                                        .font(.system(size: 14, weight: .semibold))
                                                        .foregroundColor(.white)
                                                    
                                                    Spacer()
                                                    
                                                    Text(comment.date, style: .relative)
                                                        .font(.system(size: 12))
                                                        .foregroundColor(.white.opacity(0.6))
                                                }
                                                
                                                Text(comment.text)
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.white.opacity(0.9))
                                                    .lineSpacing(2)
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(Color.white.opacity(0.05))
                                        .cornerRadius(12)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Форма добавления комментария
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                TextField("Ваш комментарий...", text: $newCommentText)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(12)
                                    .foregroundColor(.white)
                                
                                Button(action: {
                                    let trimmed = newCommentText.trimmingCharacters(in: .whitespacesAndNewlines)
                                    guard !trimmed.isEmpty else { return }
                                    let comment = NewsComment(author: "Вы", text: trimmed)
                                    newsService.addComment(newsId: newsItem.id, comment: comment)
                                    newCommentText = ""
                                }) {
                                    Image(systemName: "paperplane.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(width: 44, height: 44)
                                        .background(newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.accentColor)
                                        .cornerRadius(12)
                                }
                                .disabled(newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
                .background(
                    ZStack {
                        Color.black
                        
                        // Плавающие элементы фона
                        ForEach(0..<4, id: \.self) { index in
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            Colors.bykAccent.opacity(0.15),
                                            Color.clear
                                        ],
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 80
                                    )
                                )
                                .frame(width: CGFloat.random(in: 60...120))
                                .offset(
                                    x: CGFloat.random(in: -250...250),
                                    y: CGFloat.random(in: -500...500)
                                )
                                .animation(
                                    .easeInOut(duration: Double.random(in: 6...10))
                                    .repeatForever(autoreverses: true)
                                    .delay(Double.random(in: 0...4)),
                                    value: UUID()
                                )
                        }
                    }
                )
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Закрыть") {
                            dismiss()
                        }
                        .foregroundColor(.white)
                    }
                }
                .onAppear {
                    newsService.markAsRead(id: newsItem.id)
                }
                .sheet(isPresented: $showingShare) {
                    ShareSheet(activityItems: [newsItem.title, newsItem.description])
                }
            } else {
                NewsDetailLoadingView()
            }
        }
    }
}

// MARK: - News Detail Loading View
struct NewsDetailLoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
            
            Text("Загрузка новости...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
} 