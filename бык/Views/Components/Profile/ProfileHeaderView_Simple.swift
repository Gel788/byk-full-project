import SwiftUI

struct ProfileHeaderView_Simple: View {
    let user: User?
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Аватар
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color("BykAccent"),
                                Color("BykPrimary")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 90, height: 90)
                    .scaleEffect(isAnimating ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
                
                if let user = user, let avatar = user.avatar {
                    AsyncImage(url: URL(string: avatar)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    }
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
            }
            
            // Информация о пользователе
            VStack(spacing: 8) {
                Text(user?.fullName ?? "Гость")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                if let user = user {
                    // Телефон
                    Text(user.phoneNumber)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.1))
                        )
                    
                    // Статус
                    Text("Пользователь")
                        .font(.caption)
                        .foregroundColor(Color("BykAccent"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color("BykAccent").opacity(0.2))
                        )
                }
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}
