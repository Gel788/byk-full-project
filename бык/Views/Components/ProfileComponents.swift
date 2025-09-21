import SwiftUI

// MARK: - Main Profile View
struct ProfileView_Optimized: View {
    @StateObject private var userDataService = UserDataService()
    @State private var showingAuth = false
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        NavigationView {
            ZStack {
                // Градиентный фон
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        Color("BykPrimary").opacity(0.1),
                        Color.black
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Заголовок профиля
                        ProfileHeaderView_Simple(user: authService.currentUser)
                        
                        // Статистика
                        ProfileStatsView(user: authService.currentUser)
                        
                        // Меню профиля
                        ProfileMenuView(user: authService.currentUser)
                        
                        // Кнопка выхода
                        if authService.currentUser != nil {
                            Button(action: signOut) {
                                HStack {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                    Text("Выйти")
                                }
                                .font(.headline)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.red.opacity(0.1))
                                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                )
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAuth = true }) {
                        Image(systemName: "person.circle")
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAuth) {
            AuthView()
        }
    }
    
    private func signOut() {
        Task {
            await authService.logout()
        }
    }
}

// MARK: - Premium Profile View
struct PremiumProfileView_Optimized: View {
    @StateObject private var userDataService = UserDataService()
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        NavigationView {
            ZStack {
                // Премиум фон
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        Color("Gold").opacity(0.1),
                        Color("Platinum").opacity(0.1),
                        Color.black
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Премиум заголовок
                        PremiumProfileHeader_Simple(user: authService.currentUser)
                        
                        // Премиум статистика
                        PremiumStatsView(user: authService.currentUser)
                        
                        // Премиум секции
                        PremiumProfileSections()
                    }
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Премиум профиль")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct PremiumProfileHeader_Simple: View {
    let user: User?
    
    var body: some View {
        VStack(spacing: 16) {
            // Премиум аватар
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color("Gold").opacity(0.3),
                                Color("Platinum").opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color("Gold"),
                                Color("Platinum")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                if let user = user, let avatar = user.avatar {
                    AsyncImage(url: URL(string: avatar)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                    }
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }
            }
            
            VStack(spacing: 8) {
                Text(user?.fullName ?? "Премиум пользователь")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundColor(Color("Gold"))
                    Text("PREMIUM")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color("Gold"))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                    .background(
                        Capsule()
                        .fill(Color("Gold").opacity(0.2))
                        .stroke(Color("Gold"), lineWidth: 1)
                )
            }
        }
        .padding(.vertical, 20)
    }
}

struct PremiumStatsView: View {
    let user: User?
    
    var body: some View {
        HStack(spacing: 16) {
            PremiumStatCard_Simple(
                icon: "person.2.fill",
                title: "Подписчики",
                value: "\(user?.followersCount ?? 0)",
                color: Color("Gold")
            )
            
            PremiumStatCard_Simple(
                icon: "photo.fill",
                title: "Посты",
                value: "\(user?.postsCount ?? 0)",
                color: Color("Platinum")
            )
            
            PremiumStatCard_Simple(
                icon: "trophy.fill",
                title: "Уровень",
                value: "Premium",
                color: Color("BykAccent")
            )
        }
        .padding(.horizontal, 20)
    }
}

struct PremiumStatCard_Simple: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
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
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    ProfileView_Optimized()
}
