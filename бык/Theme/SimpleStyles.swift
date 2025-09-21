import SwiftUI

// MARK: - Простые стили для быстрой компиляции

struct SimpleButtonStyle: ViewModifier {
    let isSelected: Bool
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color.blue : Color.gray.opacity(0.3))
            )
            .foregroundColor(isSelected ? .white : .primary)
    }
}

struct SimpleCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
            )
    }
}

struct SimpleGradientBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.black)
    }
}

// MARK: - Простые View компоненты

struct SimpleButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .modifier(SimpleButtonStyle(isSelected: isSelected))
    }
}

struct SimpleCard: View {
    let content: AnyView
    
    init<Content: View>(@ViewBuilder content: () -> Content) {
        self.content = AnyView(content())
    }
    
    var body: some View {
        content
            .modifier(SimpleCardStyle())
    }
}

// MARK: - Простые цвета

extension Color {
    static let simpleBlue = Color.blue
    static let simpleGray = Color.gray
    static let simpleWhite = Color.white
    static let simpleBlack = Color.black
    static let simpleRed = Color.red
    static let simpleGreen = Color.green
}

// MARK: - Простые модификаторы

extension View {
    func simpleButton(isSelected: Bool = false) -> some View {
        modifier(SimpleButtonStyle(isSelected: isSelected))
    }
    
    func simpleCard() -> some View {
        modifier(SimpleCardStyle())
    }
    
    func simpleBackground() -> some View {
        modifier(SimpleGradientBackground())
    }
}
