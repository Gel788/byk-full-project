import SwiftUI

// MARK: - Кнопки
struct BrandButton: View {
    let title: String
    let icon: String?
    let style: ButtonStyle
    let action: () -> Void
    @State private var isPressed = false
    
    private let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    init(
        title: String,
        icon: String? = nil,
        style: ButtonStyle = .primary,
        brand: Restaurant.Brand,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
        self.brandColors = Colors.brandColors(for: brand)
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
                action()
            }
        }) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
            }
            .font(.headline)
            .foregroundColor(style.foregroundColor)
            .frame(maxWidth: .infinity)
            .padding()
            .background(style == .primary ? brandColors.accent : brandColors.secondary.opacity(0.1))
            .foregroundColor(style == .primary ? .white : brandColors.primary)
            .cornerRadius(12)
        }
        .pressAnimation(isPressed: isPressed)
    }
    
    enum ButtonStyle {
        case primary
        case secondary
        
        var foregroundColor: Color {
            switch self {
            case .primary: return .white
            case .secondary: return .primary
            }
        }
    }
}

// MARK: - Карточки
struct BrandCard<Content: View>: View {
    let brand: Restaurant.Brand
    let content: Content
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color) {
        Colors.brandColors(for: brand)
    }
    
    init(brand: Restaurant.Brand, @ViewBuilder content: () -> Content) {
        self.brand = brand
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(Colors.appSurface)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Текстовые поля
struct BrandTextField: View {
    let placeholder: String
    let icon: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType?
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .textContentType(textContentType)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Заголовки
struct BrandSectionHeader: View {
    let title: String
    let icon: String
    let brand: Restaurant.Brand
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color) {
        Colors.brandColors(for: brand)
    }
    
    var body: some View {
        Label(title, systemImage: icon)
            .font(.headline)
            .foregroundColor(brandColors.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
    }
}

// MARK: - Индикаторы загрузки
struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(Color.accentColor, lineWidth: 4)
                .frame(width: 50, height: 50)
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                .animation(
                    Animation.linear(duration: 1)
                        .repeatForever(autoreverses: false),
                    value: isAnimating
                )
                .onAppear { isAnimating = true }
            
            Text("Загрузка...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.8))
    }
}

// MARK: - Сообщения об ошибках
struct ErrorView: View {
    let error: Error
    let action: () -> Void
    @State private var isAnimating = false
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(Colors.appError)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 1)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
                .onAppear { isAnimating = true }
            
            VStack(spacing: 12) {
                Text("Что-то пошло не так")
                    .font(.system(size: 20, weight: .bold))
                
                Text(error.localizedDescription)
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button(action: action) {
                Text("Попробовать снова")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)
                    .cornerRadius(12)
                    .shadow(color: Color.accentColor.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .pressAnimation(isPressed: isPressed)
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isPressed = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPressed = false
                }
            }
        }
        .padding(24)
        .background(Color.black.opacity(0.8))
    }
}

// MARK: - Пустые состояния
struct UIEmptyStateView: View {
    let title: String
    let message: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60, weight: .light))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }
}

// MARK: - SkeletonView
struct SkeletonView: View {
    let width: CGFloat
    let height: CGFloat
    @State private var isAnimating = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.black.opacity(0.6))
            .frame(width: width, height: height)
            .overlay(
                GeometryReader { geometry in
                    Color.black.opacity(0.5)
                        .frame(width: 50)
                        .offset(x: isAnimating ? geometry.size.width : -50)
                        .blur(radius: 8)
                }
            )
            .clipped()
            .onAppear {
                withAnimation(
                    Animation.linear(duration: 1)
                        .repeatForever(autoreverses: false)
                ) {
                    isAnimating = true
                }
            }
    }
}

// MARK: - ToastView
struct ToastView: View {
    let message: String
    let type: ToastType
    @Binding var isPresented: Bool
    
    enum ToastType {
        case success
        case error
        case info
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "exclamationmark.circle.fill"
            case .info: return "info.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .success: return .green
            case .error: return Colors.appError
            case .info: return .blue
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: type.icon)
                .foregroundColor(type.color)
            
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: { isPresented = false }) {
                Image(systemName: "xmark")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.black.opacity(0.8))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

// MARK: - Бейджи
struct BrandBadge: View {
    let text: String
    let brand: Restaurant.Brand
    let style: BadgeStyle
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color) {
        Colors.brandColors(for: brand)
    }
    
    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(style.backgroundColor(brandColors))
            .foregroundColor(style.foregroundColor(brandColors))
            .cornerRadius(8)
    }
    
    enum BadgeStyle {
        case primary
        case secondary
        case accent
        case error
        
        func backgroundColor(_ colors: (primary: Color, secondary: Color, accent: Color)) -> Color {
            switch self {
            case .primary: return colors.primary
            case .secondary: return colors.secondary.opacity(0.1)
            case .accent: return colors.accent
            case .error: return Colors.appError.opacity(0.1)
            }
        }
        
        func foregroundColor(_ colors: (primary: Color, secondary: Color, accent: Color)) -> Color {
            switch self {
            case .primary: return .white
            case .secondary: return colors.primary
            case .accent: return .white
            case .error: return Colors.appError
            }
        }
    }
}

// MARK: - Разделители
struct BrandDivider: View {
    let brand: Restaurant.Brand
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color) {
        Colors.brandColors(for: brand)
    }
    
    var body: some View {
        Rectangle()
            .fill(brandColors.secondary.opacity(0.2))
            .frame(height: 1)
            .padding(.vertical, 8)
    }
} 