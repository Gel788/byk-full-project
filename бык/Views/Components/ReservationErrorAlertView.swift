import SwiftUI

struct ReservationErrorAlertView: View {
    let errorMessage: String
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let onDismiss: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var showAnimation = false
    
    var body: some View {
        ZStack {
            // Элегантный затемненный фон
            Color.black.opacity(showAnimation ? 0.5 : 0.0)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.3), value: showAnimation)
                .onTapGesture {
                    onDismiss()
                }
            
            // Основное окно
            VStack(spacing: 0) {
                // Заголовок
                VStack(spacing: 20) {
                    // Элегантная иконка ошибки
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color("BykAccent").opacity(0.1),
                                        Color("BykPrimary").opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 70, height: 70)
                        
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(Color("BykAccent"))
                    }
                    .scaleEffect(showAnimation ? 1.0 : 0.5)
                    .opacity(showAnimation ? 1.0 : 0.0)
                    
                    // Заголовок
                    Text("Ошибка бронирования")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .opacity(showAnimation ? 1.0 : 0.0)
                        .offset(y: showAnimation ? 0 : 20)
                }
                .padding(.top, 32)
                
                // Сообщение об ошибке
                VStack(spacing: 16) {
                    Text(errorMessage)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .opacity(showAnimation ? 1.0 : 0.0)
                .offset(y: showAnimation ? 0 : 20)
                .padding(.top, 24)
                
                Spacer()
                
                // Кнопка
                VStack(spacing: 12) {
                    Button(action: {
                        HapticManager.shared.impact(.light)
                        onDismiss()
                    }) {
                        Text("Понятно")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color("BykAccent"), Color("BykPrimary")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                    }
                    .scaleEffect(showAnimation ? 1.0 : 0.9)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .frame(maxWidth: 320)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 24)
            .scaleEffect(showAnimation ? 1.0 : 0.8)
            .opacity(showAnimation ? 1.0 : 0.0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showAnimation = true
            }
        }
    }
} 