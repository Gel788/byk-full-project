import SwiftUI

struct SplashScreenView: View {
    @State private var animationState = SplashAnimationState()
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Логотип
                SplashLogoView(state: animationState)
                
                Spacer()
                
                // Автор
                SplashAuthorView(state: animationState)
                
                Spacer()
            }
            .padding(.horizontal, 40)
        }
        .opacity(animationState.screenOpacity)
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 1.5)) {
            animationState.titleOpacity = 1
            animationState.titleScale = 1.0
        }
        
        withAnimation(.easeInOut(duration: 1.5).delay(0.5)) {
            animationState.authorOpacity = 1
            animationState.authorOffset = 0
        }
        
        // Автоматически закрываем через 3 секунды
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeInOut(duration: 0.5)) {
                animationState.screenOpacity = 0
            }
        }
    }
}

// MARK: - Animation State
struct SplashAnimationState {
    var titleOpacity: Double = 0
    var titleScale: CGFloat = 0.85
    var authorOpacity: Double = 0
    var authorOffset: CGFloat = 20
    var screenOpacity: Double = 1.0
}

// MARK: - Logo View
struct SplashLogoView: View {
    let state: SplashAnimationState
    
    var body: some View {
                    VStack(spacing: 12) {
                        Text("Бык")
                            .font(.system(size: 72, weight: .ultraLight, design: .default))
                            .tracking(8)
                            .foregroundColor(.white)
                .opacity(state.titleOpacity)
                .scaleEffect(state.titleScale)
                        
                        Text("Holding")
                            .font(.system(size: 20, weight: .light, design: .default))
                            .tracking(12)
                            .foregroundColor(.white.opacity(0.7))
                .opacity(state.titleOpacity)
                .scaleEffect(state.titleScale)
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 25)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.black.opacity(0.4),
                                    Color("BykPrimary").opacity(0.1),
                                    Color.black.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color("BykAccent").opacity(0.3),
                                            Color.clear
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: Color("BykAccent").opacity(0.2), radius: 10, x: 0, y: 5)
                )
    }
}
                
// MARK: - Author View
struct SplashAuthorView: View {
    let state: SplashAnimationState
                
    var body: some View {
                VStack(spacing: 4) {
                    Text("by Mekhak Galstyan")
                        .font(.system(size: 16, weight: .light, design: .default))
                        .tracking(2)
                        .foregroundColor(.white.opacity(0.6))
                .opacity(state.authorOpacity)
                .offset(y: state.authorOffset)
        }
    }
}

#Preview {
    SplashScreenView()
} 
