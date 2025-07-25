import SwiftUI

struct CommentsView: View {
    let postId: UUID
    @ObservedObject var postService: PostService
    @Environment(\.dismiss) private var dismiss
    
    @State private var newComment = ""
    @State private var comments: [PostComment] = []
    @State private var isLoading = false
    
    private let currentUser = User.mock // Временно используем мок пользователя
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Список комментариев
                    if isLoading {
                        CommentsLoadingView()
                    } else if comments.isEmpty {
                        CommentsEmptyView()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(comments) { comment in
                                    CommentRow(
                                        comment: comment,
                                        postService: postService
                                    )
                                }
                            }
                            .padding()
                        }
                    }
                    
                    // Поле для нового комментария
                    CommentInputView(
                        newComment: $newComment,
                        onSend: addComment
                    )
                }
            }
            .navigationTitle("Комментарии")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                    .foregroundColor(Colors.bykAccent)
                }
            }
        }
        .onAppear {
            loadComments()
        }
    }
    
    private func loadComments() {
        isLoading = true
        
        // Имитация загрузки комментариев
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.comments = [
                PostComment.mock,
                PostComment.mockWithReplies,
                PostComment(
                    postId: postId,
                    userId: UUID(),
                    username: "food_lover",
                    userAvatar: nil,
                    text: "Выглядит потрясающе! 😍 Обязательно попробую!",
                    likes: 3,
                    isLiked: false
                ),
                PostComment(
                    postId: postId,
                    userId: UUID(),
                    username: "chef_mike",
                    userAvatar: nil,
                    text: "Спасибо за отзыв! Рады, что вам понравилось! 🐂",
                    likes: 7,
                    isLiked: true
                )
            ]
            self.isLoading = false
        }
    }
    
    private func addComment() {
        let trimmed = newComment.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let comment = PostComment(
            postId: postId,
            userId: currentUser.id,
            username: currentUser.username,
            userAvatar: currentUser.avatar,
            text: trimmed
        )
        
        Task {
            await postService.addComment(comment, to: postId)
            comments.insert(comment, at: 0)
            newComment = ""
        }
    }
}

// MARK: - Comment Row
struct CommentRow: View {
    let comment: PostComment
    @ObservedObject var postService: PostService
    @State private var isLiked = false
    @State private var showingReplies = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                // Аватар пользователя
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
                        .frame(width: 32, height: 32)
                    
                    if let avatar = comment.userAvatar {
                        AsyncImage(url: URL(string: avatar)) { image in
                            image.resizable()
                                .clipShape(Circle())
                        } placeholder: {
                            Text(comment.username.prefix(1).uppercased())
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                    } else {
                        Text(comment.username.prefix(1).uppercased())
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    // Имя пользователя и время
                    HStack {
                        Text(comment.username)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text(comment.createdAt, style: .relative)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    
                    // Текст комментария
                    Text(comment.text)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .lineSpacing(2)
                    
                    // Действия
                    HStack(spacing: 16) {
                        Button(action: { toggleLike() }) {
                            HStack(spacing: 4) {
                                Image(systemName: isLiked ? "heart.fill" : "heart")
                                    .font(.system(size: 12))
                                    .foregroundColor(isLiked ? .red : .gray)
                                
                                Text("\(comment.likes)")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button("Ответить") {
                            // Показать поле ответа
                        }
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                Spacer()
            }
            
            // Ответы
            if let replies = comment.replies, !replies.isEmpty {
                VStack(spacing: 8) {
                    ForEach(replies) { reply in
                        HStack(alignment: .top, spacing: 12) {
                            // Отступ для ответов
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 2)
                                .frame(height: 20)
                            
                            CommentRow(comment: reply, postService: postService)
                        }
                    }
                }
                .padding(.leading, 20)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private func toggleLike() {
        isLiked.toggle()
    }
}

// MARK: - Comment Input View
struct CommentInputView: View {
    @Binding var newComment: String
    let onSend: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            TextField("Добавить комментарий...", text: $newComment)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
                .foregroundColor(.white)
            
            Button(action: onSend) {
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
                        .frame(width: 44, height: 44)
                        .shadow(color: Colors.bykAccent.opacity(0.5), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .disabled(newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.95),
                    Color.black.opacity(0.9)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

// MARK: - Comments Loading View
struct CommentsLoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
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
                        lineWidth: 3
                    )
                    .frame(width: 40, height: 40)
                
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
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 40, height: 40)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(.linear(duration: 1.0).repeatForever(autoreverses: false), value: isAnimating)
            }
            
            Text("Загрузка комментариев...")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Comments Empty View
struct CommentsEmptyView: View {
    var body: some View {
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    CommentsView(postId: UUID(), postService: PostService())
} 