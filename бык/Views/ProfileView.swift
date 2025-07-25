import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var userDataService: UserDataService
    @State private var showOrderHistory = false
    @State private var showReservations = false
    @State private var showDeliveryHistory = false
    
    private var currentUser: User? {
        userDataService.getCurrentUser()
    }
    
    var body: some View {
        Group {
            if !authService.isAuthenticated {
                AuthView()
                    .environmentObject(authService)
            } else {
                ProfileContentView(
                    user: currentUser,
                    onShowOrderHistory: { showOrderHistory = true },
                    onShowReservations: { showReservations = true },
                    onShowDeliveryHistory: { showDeliveryHistory = true },
                    onLogout: { authService.logout() }
                )
                .sheet(isPresented: $showOrderHistory) {
                    OrderHistoryView()
                }
                .sheet(isPresented: $showReservations) {
                    ReservationsManagementView()
                }
                .sheet(isPresented: $showDeliveryHistory) {
                    DeliveryHistoryView()
                }
            }
        }
    }
}

// MARK: - Profile Content View
struct ProfileContentView: View {
    let user: User?
    let onShowOrderHistory: () -> Void
    let onShowReservations: () -> Void
    let onShowDeliveryHistory: () -> Void
    let onLogout: () -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                // Современный фоновый градиент
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        Color("BykAccent").opacity(0.1),
                        Color("BykPrimary").opacity(0.05),
                        Color.black.opacity(0.95)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Дополнительные декоративные элементы
                GeometryReader { geometry in
                    ZStack {
                        // Плавающие круги
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color("BykAccent").opacity(0.1),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 100
                                )
                            )
                            .frame(width: 200, height: 200)
                            .offset(x: geometry.size.width * 0.8, y: geometry.size.height * 0.1)
                        
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color("BykPrimary").opacity(0.05),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 150
                                )
                            )
                            .frame(width: 300, height: 300)
                            .offset(x: geometry.size.width * 0.1, y: geometry.size.height * 0.8)
                    }
                }
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Заголовок профиля
                        ProfileHeaderView(user: user)
                            .padding(.horizontal, 20)
                        
                        // Статистика
                        StatisticsSectionView(
                            orderCount: 5, // TODO: Получать из сервиса
                            reservationCount: 3,
                            deliveryCount: 8
                        )
                        .padding(.horizontal, 20)
                        
                        // Меню профиля
                        VStack(spacing: 12) {
                            ProfileMenuItemView(
                                title: "Личные данные",
                                icon: "person.circle.fill",
                                color: Color("BykAccent")
                            ) {
                                // TODO: Показать редактирование профиля
                            }
                            
                            ProfileMenuItemView(
                                title: "История заказов",
                                icon: "bag.fill",
                                color: .blue
                            ) {
                                onShowOrderHistory()
                            }
                            
                            ProfileMenuItemView(
                                title: "Мои бронирования",
                                icon: "calendar.badge.clock",
                                color: .green
                            ) {
                                onShowReservations()
                            }
                            
                            ProfileMenuItemView(
                                title: "История доставки",
                                icon: "bicycle",
                                color: .purple
                            ) {
                                onShowDeliveryHistory()
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Кнопка выхода
                        LogoutButtonView(action: onLogout)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
} 