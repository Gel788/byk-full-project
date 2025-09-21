import SwiftUI

struct SupportView_Optimized: View {
    @Environment(\.dismiss) private var dismiss
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color) {
        (Color("BykPrimary"), Color("BykSecondary"), Color("BykAccent"))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Фон
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        brandColors.accent.opacity(0.1),
                        Color.black.opacity(0.95)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Заголовок
                        SupportHeader(brandColors: brandColors)
                        
                        // Быстрые действия
                        QuickActionsSection(brandColors: brandColors)
                        
                        // Форма обратной связи
                        FeedbackForm(brandColors: brandColors)
                        
                        // Контактная информация
                        ContactInfoSection(brandColors: brandColors)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Поддержка")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

struct ContactInfoSection: View {
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
                Text("Контактная информация")
                .font(.headline)
                    .foregroundColor(.white)
            
            VStack(spacing: 12) {
                ContactInfoRow(
                    icon: "phone.fill",
                    title: "Телефон",
                    value: "+7 (495) 123-45-67",
                    action: {
                        if let url = URL(string: "tel:+74951234567") {
                            UIApplication.shared.open(url)
                        }
                    }
                )
                
                ContactInfoRow(
                    icon: "envelope.fill",
                    title: "Email",
                    value: "support@byk.ru",
                    action: {
                        if let url = URL(string: "mailto:support@byk.ru") {
                            UIApplication.shared.open(url)
                        }
                    }
                )
                
                ContactInfoRow(
                    icon: "clock.fill",
                    title: "Время работы",
                    value: "Пн-Вс: 09:00 - 22:00",
                    action: nil
                )
                
                ContactInfoRow(
                    icon: "location.fill",
                    title: "Адрес",
                    value: "Москва, ул. Тверская, 1",
                    action: nil
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .stroke(brandColors.primary.opacity(0.3), lineWidth: 1)
        )
    }
}

struct ContactInfoRow: View {
    let icon: String
    let title: String
    let value: String
    let action: (() -> Void)?
    
    var body: some View {
        Button(action: action ?? {}) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(Color("BykAccent"))
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.gray)
                
                Text(value)
                        .font(.subheadline)
                    .foregroundColor(.white)
            }
            
            Spacer()
                
                if action != nil {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(action == nil)
    }
}

#Preview {
    SupportView_Optimized()
}
