import SwiftUI

struct PremiumProfileHeader: View {
    let user: User?
    
    var body: some View {
        VStack(spacing: 0) {
            // Премиальный градиентный фон
            ZStack {
                // Статичный градиентный фон
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color("BykAccent").opacity(0.3),
                        Color.black.opacity(0.8),
                        Color("BykAccent").opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Премиальный аватар
                    ZStack {
                        // Внешнее свечение
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        Color("BykAccent").opacity(0.4),
                                        Color.clear
                                    ]),
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 80
                                )
                            )
                            .frame(width: 120, height: 120)
                        
                        // Основной аватар
                        Circle()
                            .fill(avatarGradient)
                            .frame(width: 100, height: 100)
                            .overlay(
                                Circle()
                                    .stroke(avatarStrokeGradient, lineWidth: 2)
                            )
                            .shadow(color: Color("BykAccent").opacity(0.5), radius: 20, x: 0, y: 10)
                        
                        // Инициалы пользователя
                        Text(String(user?.fullName.prefix(1) ?? "U").uppercased())
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white,
                                        Color("BykAccent").opacity(0.8)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    
                    // Информация о пользователе
                    VStack(spacing: 12) {
                        // Имя пользователя
                        Text(user?.fullName ?? "Пользователь")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white,
                                        Color.white.opacity(0.9)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        // Контактная информация
                        VStack(spacing: 8) {
                            // Телефон
                            HStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(Color("BykAccent").opacity(0.2))
                                        .frame(width: 24, height: 24)
                                    
                                    Image(systemName: "phone.fill")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(Color("BykAccent"))
                                }
                                
                                Text(user?.username ?? "")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.9))
                                
                                Spacer()
                            }
                            
                            // Email
                            if let email = user?.email {
                                HStack(spacing: 8) {
                                    ZStack {
                                        Circle()
                                            .fill(Color("BykAccent").opacity(0.2))
                                            .frame(width: 24, height: 24)
                                        
                                        Image(systemName: "envelope.fill")
                                            .font(.system(size: 10, weight: .medium))
                                            .foregroundColor(Color("BykAccent"))
                                    }
                                    
                                    Text(email)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    Spacer()
                                }
                            }
                        }
                        
                        // Статус пользователя
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 8, height: 8)
                                .shadow(color: Color.green.opacity(0.5), radius: 3, x: 0, y: 1)
                            
                            Text("Онлайн")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.green)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.green.opacity(0.15))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.green.opacity(0.4), lineWidth: 1)
                                )
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
        }
    }
    
    private var avatarGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.black.opacity(0.95),
                Color.black.opacity(0.85),
                Color.black.opacity(0.75)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var avatarStrokeGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color("BykAccent"),
                Color("BykAccent").opacity(0.7),
                Color("BykAccent").opacity(0.4)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
} 