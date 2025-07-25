import SwiftUI

// Анимации для переходов между экранами
extension AnyTransition {
    static var slideFromRight: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }
    
    static var slideFromBottom: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .top).combined(with: .opacity)
        )
    }
    
    static var fade: AnyTransition {
        .opacity.animation(.easeInOut(duration: 0.2))
    }
}

// Анимации для интерактивных элементов
struct InteractiveSpringAnimation {
    static let tap = Animation.spring(response: 0.4, dampingFraction: 0.8)
    static let bounce = Animation.spring(response: 0.5, dampingFraction: 0.7)
    static let smooth = Animation.spring(response: 0.6, dampingFraction: 0.9)
}

// Модификаторы для анимаций
extension View {
    func pressAnimation(isPressed: Bool) -> some View {
        self.scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isPressed)
    }
    
    func bounceOnAppear() -> some View {
        self.modifier(BounceAnimationModifier())
    }
}

// Модификатор для анимации появления
struct BounceAnimationModifier: ViewModifier {
    @State private var animationAmount = 0.0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(1 + animationAmount)
            .opacity(1 - animationAmount)
            .onAppear {
                withAnimation(InteractiveSpringAnimation.bounce) {
                    animationAmount = 0.0
                }
            }
    }
    
    init() {
        animationAmount = 0.1
    }
}

// Модификатор для плавного появления
struct FadeInModifier: ViewModifier {
    @State private var opacity: Double = 0
    
    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 0.3)) {
                    opacity = 1
                }
            }
    }
}

// Модификатор для анимации загрузки
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .clear,
                            .white.opacity(0.5),
                            .clear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 2)
                    .offset(x: -geometry.size.width + (geometry.size.width * 2) * phase)
                    .blendMode(.screen)
                }
            )
            .onAppear {
                withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
    
    func fadeIn() -> some View {
        modifier(FadeInModifier())
    }
} 