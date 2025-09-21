import SwiftUI

struct PremiumPersonalDataSection: View {
    @State private var showingEditProfile = false
    
    var body: some View {
        PremiumProfileSection(
            title: "Личные данные",
            icon: "person.circle",
            color: .blue
        ) {
            PremiumPersonalDataContent(showingEditProfile: $showingEditProfile)
        }
        .sheet(isPresented: $showingEditProfile) {
            ProfileEditView(user: User.mock)
        }
    }
}

struct PremiumPersonalDataContent: View {
    @Binding var showingEditProfile: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            PremiumDataRow(
                icon: "person",
                title: "Имя",
                value: "Иван Петров",
                color: .blue
            )
            
            PremiumDataRow(
                icon: "phone",
                title: "Телефон",
                value: "+7 (999) 123-45-67",
                color: .green
            )
            
            PremiumDataRow(
                icon: "envelope",
                title: "Email",
                value: "ivan@example.com",
                color: .orange
            )
            
            PremiumDataRow(
                icon: "calendar",
                title: "Дата рождения",
                value: "15 января 1990",
                color: .purple
            )
            
            Button(action: {
                showingEditProfile = true
            }) {
                HStack {
                    Image(systemName: "pencil")
                    Text("Редактировать профиль")
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.2))
                )
            }
        }
    }
}

struct PremiumDataRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
                
                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
