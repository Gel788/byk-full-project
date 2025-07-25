import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var showMainApp = false
    
    private let pages = [
        OnboardingPage(
            title: "Добро пожаловать в\nTHE БЫК",
            subtitle: "Откройте для себя мир премиальной кухни",
            description: "Насладитесь лучшими стейками, крафтовым пивом и аутентичной итальянской кухней в атмосфере настоящего ресторана",
            image: "thebyk_main",
            brand: .theByk,
            icon: "flame.fill",
            accentText: "ПРЕМИУМ СТЕЙКИ"
        ),
        OnboardingPage(
            title: "THE ПИВО",
            subtitle: "Крафтовое пиво и закуски",
            description: "Попробуйте эксклюзивные сорта пива от лучших пивоварен в уютной атмосфере",
            image: "pretzel",
            brand: .thePivo,
            icon: "drop.fill",
            accentText: "КРАФТОВОЕ ПИВО"
        ),
        OnboardingPage(
            title: "MOSCA",
            subtitle: "Аутентичная итальянская кухня",
            description: "Настоящая пицца, паста и вино из Италии в атмосфере средиземноморского гостеприимства",
            image: "pizza_margherita",
            brand: .mosca,
            icon: "leaf.fill",
            accentText: "ИТАЛЬЯНСКАЯ КУХНЯ"
        )
    ]
    
    var body: some View {
        ZStack {
            // Простой градиентный фон
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Colors.brandColors(for: pages[currentPage].brand).primary.opacity(0.3),
                    Color.black
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Логотип
                VStack(spacing: 16) {
                    Image(systemName: pages[currentPage].icon)
                        .font(.system(size: 60))
                        .foregroundColor(Colors.brandColors(for: pages[currentPage].brand).accent)
                    
                    Text(pages[currentPage].accentText)
                        .font(.caption)
                        .fontWeight(.bold)
                        .tracking(2)
                        .foregroundColor(Colors.brandColors(for: pages[currentPage].brand).accent)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Colors.brandColors(for: pages[currentPage].brand).accent.opacity(0.1))
                        )
                }
                .transition(.scale.combined(with: .opacity))
                
                // Контент страницы
                VStack(spacing: 24) {
                    Text(pages[currentPage].title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text(pages[currentPage].subtitle)
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                    
                    Text(pages[currentPage].description)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
                
                // Изображение
                Image(pages[currentPage].image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    .transition(.scale.combined(with: .opacity))
                
                Spacer()
                
                // Индикаторы страниц
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Colors.brandColors(for: pages[currentPage].brand).accent : Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(index == currentPage ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: currentPage)
                    }
                }
                
                // Кнопки
                VStack(spacing: 16) {
                    PrimaryButton(title: currentPage == pages.count - 1 ? "Начать" : "Далее") {
                        if currentPage == pages.count - 1 {
                            showMainApp = true
                        } else {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentPage += 1
                            }
                        }
                    }
                    
                    if currentPage < pages.count - 1 {
                        SecondaryButton(title: "Пропустить") {
                            showMainApp = true
                        }
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
            }
        }
        .onChange(of: showMainApp) { newValue in
            if newValue {
                // Завершаем онбординг
            }
        }
    }
}

struct OnboardingPage {
    let title: String
    let subtitle: String
    let description: String
    let image: String
    let brand: Restaurant.Brand
    let icon: String
    let accentText: String
}

#Preview {
    OnboardingView()
} 