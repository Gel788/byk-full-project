import SwiftUI

struct QuickActionsSection: View {
    @State private var showingCallAlert = false
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Быстрые действия")
                .font(.headline)
                .foregroundColor(.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                // Звонок
                Button(action: {
                    showingCallAlert = true
                }) {
                    QuickActionCard(
                        icon: "phone.fill",
                        title: "Позвонить",
                        subtitle: "+7 (495) 123-45-67",
                        brandColors: brandColors
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // Email
                Button(action: {
                    if let url = URL(string: "mailto:support@byk.ru") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    QuickActionCard(
                        icon: "envelope.fill",
                        title: "Написать",
                        subtitle: "support@byk.ru",
                        brandColors: brandColors
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // Telegram
                Button(action: {
                    if let url = URL(string: "https://t.me/byk_support") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    QuickActionCard(
                        icon: "paperplane.fill",
                        title: "Telegram",
                        subtitle: "@byk_support",
                        brandColors: brandColors
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // FAQ
                NavigationLink(destination: FAQView()) {
                    QuickActionCard(
                        icon: "questionmark.circle.fill",
                        title: "FAQ",
                        subtitle: "Частые вопросы",
                        brandColors: brandColors
                    )
                }
            }
        }
        .alert("Позвонить в поддержку?", isPresented: $showingCallAlert) {
            Button("Позвонить") {
                if let url = URL(string: "tel:+74951234567") {
                    UIApplication.shared.open(url)
                }
            }
            Button("Отмена", role: .cancel) { }
        } message: {
            Text("Вы хотите позвонить в службу поддержки?")
        }
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(brandColors.accent)
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
                .stroke(brandColors.primary.opacity(0.3), lineWidth: 1)
        )
    }
}

struct FAQView: View {
    var body: some View {
        Text("FAQ View")
            .navigationTitle("Частые вопросы")
    }
}
