import SwiftUI

struct ProfileMenuView: View {
    let user: User?
    
    var body: some View {
        VStack(spacing: 12) {
            // Основные разделы
            ProfileMenuSection(
                title: "Профиль",
                items: [
                    ProfileMenuItem(
                        icon: "person.circle",
                        title: "Личные данные",
                        destination: AnyView(ProfileEditView(user: user ?? User.mock))
                    ),
                    ProfileMenuItem(
                        icon: "bell",
                        title: "Уведомления",
                        destination: AnyView(NotificationsView())
                    ),
                    ProfileMenuItem(
                        icon: "heart.fill",
                        title: "Избранное",
                        destination: AnyView(Text("Избранное"))
                    )
                ]
            )
            
            // Заказы и бронирования
            ProfileMenuSection(
                title: "Заказы",
                items: [
                    ProfileMenuItem(
                        icon: "bag",
                        title: "История заказов",
                        destination: AnyView(OrderHistoryView())
                    ),
                    ProfileMenuItem(
                        icon: "calendar",
                        title: "Мои бронирования",
                        destination: AnyView(ReservationsView())
                    ),
                    ProfileMenuItem(
                        icon: "gift",
                        title: "Программа лояльности",
                        destination: AnyView(LoyaltyProgramView())
                    )
                ]
            )
            
            // Настройки
            ProfileMenuSection(
                title: "Настройки",
                items: [
                    ProfileMenuItem(
                        icon: "gear",
                        title: "Настройки",
                        destination: AnyView(ProfileSettingsView())
                    ),
                    ProfileMenuItem(
                        icon: "questionmark.circle",
                        title: "Поддержка",
                        destination: AnyView(Text("Поддержка"))
                    ),
                    ProfileMenuItem(
                        icon: "info.circle",
                        title: "О приложении",
                        destination: AnyView(Text("О приложении"))
                    )
                ]
            )
        }
    }
}

struct ProfileMenuSection: View {
    let title: String
    let items: [ProfileMenuItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
            
            VStack(spacing: 1) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    NavigationLink(destination: item.destination) {
                        ProfileMenuRow(item: item)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    if index < items.count - 1 {
                        Divider()
                            .background(Color.white.opacity(0.1))
                            .padding(.leading, 60)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .stroke(Color("BykPrimary").opacity(0.3), lineWidth: 1)
            )
            .padding(.horizontal, 20)
        }
    }
}

struct ProfileMenuItem {
    let icon: String
    let title: String
    let destination: AnyView
}

struct ProfileMenuRow: View {
    let item: ProfileMenuItem
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: item.icon)
                .font(.title3)
                .foregroundColor(Color("BykAccent"))
                .frame(width: 24)
            
            Text(item.title)
                .font(.subheadline)
                .foregroundColor(.white)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}
