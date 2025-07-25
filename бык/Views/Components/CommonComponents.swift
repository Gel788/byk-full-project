import SwiftUI

// MARK: - Common Enums

enum DeliveryMethod: String, CaseIterable {
    case delivery = "Доставка"
    case pickup = "Самовывоз"
    
    var icon: String {
        switch self {
        case .delivery: return "car"
        case .pickup: return "bag"
        }
    }
}

enum PaymentMethod: String, CaseIterable {
    case card = "Банковская карта"
    case cash = "Наличными"
    case online = "Онлайн оплата"
    
    var icon: String {
        switch self {
        case .card: return "creditcard"
        case .cash: return "banknote"
        case .online: return "globe"
        }
    }
}

// Общий компонент поисковой строки
struct SearchBar: View {
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(.white)
            
            if !text.isEmpty {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        text = ""
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
}

// Общий компонент для шаринга
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct DetailRow: View {
    let icon: String?
    let title: String
    let value: String
    let color: Color?
    
    init(icon: String? = nil, title: String, value: String, color: Color? = nil) {
        self.icon = icon
        self.title = title
        self.value = value
        self.color = color
    }
    
    var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(color ?? .accentColor)
                    .frame(width: 20)
            }
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            Spacer()
            Text(value)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 4)
    }
} 