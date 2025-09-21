import SwiftUI

struct ProfileStatsView: View {
    let user: User?
    @StateObject private var userDataService = UserDataService()
    
    var body: some View {
        HStack(spacing: 20) {
            // Подписчики
            StatCard(
                icon: "person.2.fill",
                title: "Подписчики",
                value: "\(user?.followersCount ?? 0)",
                color: Color("BykAccent")
            )
            
            // Подписки
            StatCard(
                icon: "person.fill",
                title: "Подписки",
                value: "\(user?.followingCount ?? 0)",
                color: Color("BykPrimary")
            )
            
            // Посты
            StatCard(
                icon: "photo.fill",
                title: "Посты",
                value: "\(user?.postsCount ?? 0)",
                color: Color("Gold")
            )
        }
        .padding(.horizontal, 20)
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}
