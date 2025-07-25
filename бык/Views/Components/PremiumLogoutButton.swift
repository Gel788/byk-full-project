import SwiftUI

struct PremiumLogoutButton: View {
    let onLogout: () -> Void
    @State private var isPressed = false
    @State private var showConfirmation = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Кнопка выхода
            Button(action: {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                    showConfirmation = true
                }
            }) {
                HStack(spacing: 12) {
                    // Иконка выхода
                    ZStack {
                        // Основной фон иконки
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.red.opacity(0.3),
                                        Color.red.opacity(0.1)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.red.opacity(0.6),
                                                Color.red.opacity(0.3)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                            )
                            .scaleEffect(isPressed ? 0.95 : 1.0)
                        
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.red,
                                        Color.red.opacity(0.8)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .scaleEffect(isPressed ? 0.9 : 1.0)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Выйти из аккаунта")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white,
                                        Color.white.opacity(0.9)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("Завершить текущую сессию")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    // Стрелка
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                        .rotationEffect(.degrees(isPressed ? 90 : 0))
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.black.opacity(0.8),
                                    Color.black.opacity(0.6),
                                    Color.black.opacity(0.4)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.red.opacity(0.4),
                                            Color.red.opacity(0.1)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                )
                .shadow(color: Color.red.opacity(0.3), radius: 15, x: 0, y: 8)
                .scaleEffect(isPressed ? 0.98 : 1.0)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .alert("Подтверждение выхода", isPresented: $showConfirmation) {
            Button("Отмена", role: .cancel) { }
            Button("Выйти", role: .destructive) {
                onLogout()
            }
        } message: {
            Text("Вы уверены, что хотите выйти из аккаунта?")
        }
    }
}

struct UnauthenticatedProfileView: View {
    @State private var showingAuthView = false
    @State private var animateContent = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Градиентный фон
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        Color("BykAccent").opacity(0.1),
                        Color.black
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Декоративные элементы
                GeometryReader { geometry in
                    ZStack {
                        Circle()
                            .fill(Color("BykAccent").opacity(0.1))
                            .frame(width: 200, height: 200)
                            .offset(x: geometry.size.width * 0.8, y: geometry.size.height * 0.1)
                            .blur(radius: 20)
                        
                        Circle()
                            .fill(Color("BykAccent").opacity(0.05))
                            .frame(width: 150, height: 150)
                            .offset(x: geometry.size.width * 0.1, y: geometry.size.height * 0.3)
                            .blur(radius: 15)
                    }
                }
                
                ScrollView {
                    VStack(spacing: 40) {
                        // Иконка профиля
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color("BykAccent").opacity(0.3),
                                            Color("BykAccent").opacity(0.1)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                                .shadow(color: Color("BykAccent").opacity(0.3), radius: 20, x: 0, y: 10)
                                .scaleEffect(animateContent ? 1.0 : 0.8)
                                .opacity(animateContent ? 1.0 : 0.0)
                            
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(Color("BykAccent"))
                                .scaleEffect(animateContent ? 1.1 : 0.9)
                                .opacity(animateContent ? 1.0 : 0.0)
                        }
                        
                        // Заголовок
                        VStack(spacing: 16) {
                            Text("Добро пожаловать!")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                                .opacity(animateContent ? 1.0 : 0.0)
                                .offset(y: animateContent ? 0 : 20)
                            
                            Text("Войдите в аккаунт, чтобы получить доступ к личному кабинету и всем возможностям приложения")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                                .opacity(animateContent ? 1.0 : 0.0)
                                .offset(y: animateContent ? 0 : 20)
                        }
                        
                        // Преимущества
                        VStack(spacing: 20) {
                            PremiumFeatureRow(
                                icon: "bag.fill",
                                title: "История заказов",
                                description: "Отслеживайте все ваши заказы и их статус",
                                color: Color("BykAccent"),
                                delay: 0.2
                            )
                            
                            PremiumFeatureRow(
                                icon: "calendar",
                                title: "Бронирования",
                                description: "Управляйте бронированиями столов",
                                color: .blue,
                                delay: 0.3
                            )
                            
                            PremiumFeatureRow(
                                icon: "star.fill",
                                title: "Программа лояльности",
                                description: "Получайте бонусы и скидки",
                                color: .yellow,
                                delay: 0.4
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        // Кнопка входа
                        Button(action: {
                            showingAuthView = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                                
                                Text("Войти в аккаунт")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color("BykAccent"),
                                                Color("BykAccent").opacity(0.8)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color("BykAccent").opacity(0.5),
                                                        Color("BykAccent").opacity(0.3)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1
                                            )
                                    )
                            )
                            .shadow(color: Color("BykAccent").opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 20)
                        .opacity(animateContent ? 1.0 : 0.0)
                        .offset(y: animateContent ? 0 : 20)
                    }
                    .padding(.vertical, 40)
                }
            }
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear {
                withAnimation(.easeOut(duration: 1.0)) {
                    animateContent = true
                }
            }
            .sheet(isPresented: $showingAuthView) {
                AuthView()
            }
        }
    }
}

struct PremiumFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let delay: Double
    @State private var animateRow = false
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .scaleEffect(animateRow ? 1.0 : 0.8)
                    .opacity(animateRow ? 1.0 : 0.0)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(color)
                    .scaleEffect(animateRow ? 1.1 : 0.9)
                    .opacity(animateRow ? 1.0 : 0.0)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.6),
                            Color.black.opacity(0.4)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    color.opacity(0.3),
                                    color.opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: color.opacity(0.2), radius: 10, x: 0, y: 5)
        .opacity(animateRow ? 1.0 : 0.0)
        .offset(x: animateRow ? 0 : -20)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(delay)) {
                animateRow = true
            }
        }
    }
} 