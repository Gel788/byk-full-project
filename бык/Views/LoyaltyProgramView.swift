import SwiftUI

struct LoyaltyProgramView: View {
    @EnvironmentObject private var userDataService: UserDataService
    @Environment(\.dismiss) private var dismiss
    @State private var isAnimating = false
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color) {
        (Color("BykPrimary"), Color("BykSecondary"), Color("BykAccent"))
    }
    
    private var loyaltyData: (current: Int, next: Int, progress: Double) {
        userDataService.getLoyaltyProgress()
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Фон
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        Color.orange.opacity(0.1),
                        brandColors.accent.opacity(0.05),
                        Color.black.opacity(0.95)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Декоративные элементы
                GeometryReader { geometry in
                    ZStack {
                        // Плавающие звезды
                        ForEach(0..<15, id: \.self) { index in
                            Image(systemName: "star.fill")
                                .font(.system(size: CGFloat.random(in: 8...16), weight: .light))
                                .foregroundColor(.orange.opacity(Double.random(in: 0.1...0.3)))
                                .position(
                                    x: CGFloat.random(in: 0...geometry.size.width),
                                    y: CGFloat.random(in: 0...geometry.size.height)
                                )
                                .rotationEffect(.degrees(isAnimating ? Double.random(in: 0...360) : 0))
                                .animation(.linear(duration: Double.random(in: 20...40)).repeatForever(autoreverses: false), value: isAnimating)
                        }
                    }
                }
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Заголовок
                        headerSection
                        
                        // Текущий уровень
                        currentLevelCard
                        
                        // Прогресс до следующего уровня
                        progressSection
                        
                        // Награды и привилегии
                        rewardsSection
                        
                        // История баллов
                        pointsHistorySection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0)) {
                    isAnimating = true
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: { dismiss() }) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Spacer()
                
                VStack(alignment: .center, spacing: 4) {
                    Text("Программа лояльности")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.white, Color.white.opacity(0.9)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("⭐ БЫК REWARDS ⭐")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.orange, Color.yellow],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                
                Spacer()
                
                // Placeholder для симметрии
                Circle()
                    .fill(Color.clear)
                    .frame(width: 40, height: 40)
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Current Level Card
    private var currentLevelCard: some View {
        VStack(spacing: 20) {
            // Иконка уровня
            ZStack {
                // Внешнее свечение
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.orange.opacity(0.4),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
                
                // Основной круг
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.orange,
                                Color.yellow.opacity(0.8),
                                Color.orange.opacity(0.6)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.4),
                                        Color.clear,
                                        Color.white.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: Color.orange.opacity(0.5), radius: 20, x: 0, y: 10)
                
                // Корона
                Image(systemName: "crown.fill")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color.white,
                                Color.yellow.opacity(0.9)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            // Информация об уровне
            VStack(spacing: 8) {
                Text("ЗОЛОТОЙ УРОВЕНЬ")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.orange, Color.yellow],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("\(loyaltyData.current) баллов")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("До платинового уровня: \(loyaltyData.next - loyaltyData.current) баллов")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.1),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.orange.opacity(0.3),
                                    Color.orange.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
        )
        .shadow(color: Color.orange.opacity(0.2), radius: 20, x: 0, y: 10)
    }
    
    // MARK: - Progress Section
    private var progressSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Прогресс до следующего уровня")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
            }
            
            VStack(spacing: 12) {
                // Прогресс бар
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Фон прогресс бара
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 24)
                        
                        // Заполненная часть
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.orange,
                                        Color.yellow,
                                        Color.orange.opacity(0.8)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * loyaltyData.progress, height: 24)
                            .shadow(color: Color.orange.opacity(0.5), radius: 8, x: 0, y: 4)
                    }
                }
                .frame(height: 24)
                
                // Подписи прогресса
                HStack {
                    Text("\(loyaltyData.current)")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.orange)
                    
                    Spacer()
                    
                    Text("\(Int(loyaltyData.progress * 100))%")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(loyaltyData.next)")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Rewards Section
    private var rewardsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Ваши привилегии")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                RewardCard(
                    icon: "percent",
                    title: "Скидка 10%",
                    description: "На все заказы",
                    color: .green,
                    isActive: true
                )
                
                RewardCard(
                    icon: "gift.fill",
                    title: "Бесплатная доставка",
                    description: "При заказе от 1500₽",
                    color: .blue,
                    isActive: true
                )
                
                RewardCard(
                    icon: "calendar.badge.plus",
                    title: "Приоритет",
                    description: "При бронировании",
                    color: .purple,
                    isActive: true
                )
                
                RewardCard(
                    icon: "star.circle.fill",
                    title: "Двойные баллы",
                    description: "В день рождения",
                    color: .orange,
                    isActive: false
                )
            }
        }
    }
    
    // MARK: - Points History Section
    private var pointsHistorySection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Недавние начисления")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
            }
            
            VStack(spacing: 8) {
                PointsHistoryRow(
                    title: "Заказ BY-2024-001",
                    points: "+125",
                    date: "Сегодня",
                    color: .green
                )
                
                PointsHistoryRow(
                    title: "Заказ BY-2024-002",
                    points: "+85",
                    date: "Вчера",
                    color: .green
                )
                
                PointsHistoryRow(
                    title: "Бронирование BR-2024-003",
                    points: "+50",
                    date: "3 дня назад",
                    color: .blue
                )
                
                PointsHistoryRow(
                    title: "Отзыв о ресторане",
                    points: "+25",
                    date: "5 дней назад",
                    color: .purple
                )
            }
        }
    }
}

// MARK: - Reward Card Component
struct RewardCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let isActive: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                color.opacity(isActive ? 0.3 : 0.1),
                                color.opacity(isActive ? 0.1 : 0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(isActive ? color : color.opacity(0.5))
            }
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(isActive ? .white : .white.opacity(0.6))
                
                Text(description)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(isActive ? 0.08 : 0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            color.opacity(isActive ? 0.3 : 0.1),
                            lineWidth: 1
                        )
                )
        )
        .opacity(isActive ? 1.0 : 0.6)
    }
}

// MARK: - Points History Row
struct PointsHistoryRow: View {
    let title: String
    let points: String
    let date: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Image(systemName: "plus")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                Text(date)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            Text(points)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}