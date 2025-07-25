import SwiftUI

struct PostsListView: View {
    let posts: [Post]
    @Binding var selectedPost: Post?
    @Binding var showingPostDetail: Bool
    @ObservedObject var postService: PostService
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(Array(posts.enumerated()), id: \.element.id) { index, post in
                    PostCard(post: post, postService: postService)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                selectedPost = post
                                showingPostDetail = true
                            }
                        }
                        .scaleEffect(selectedPost?.id == post.id ? 0.98 : 1.0)
                        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: selectedPost?.id)
                        .padding(.horizontal)
                        .offset(y: 0)
                        .opacity(1.0)
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.8)
                            .delay(Double(index) * 0.1),
                            value: posts.count
                        )
                }
            }
            .padding(.vertical, 20)
        }
    }
}

#Preview {
    PostsListView(
        posts: Post.mockMultiple,
        selectedPost: .constant(nil),
        showingPostDetail: .constant(false),
        postService: PostService()
    )
    .background(Color.black)
} 