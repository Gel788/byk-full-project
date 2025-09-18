import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var userDataService: UserDataService
    @State private var showOrderHistory = false
    @State private var showReservations = false
    @State private var showDeliveryHistory = false
    @State private var showProfileEdit = false
    @State private var showSettings = false
    @State private var showNotifications = false
    @State private var showSupport = false
    @State private var showLoyalty = false
    
    private var currentUser: User? {
        // Сначала пробуем получить из AuthService (обновляется в реальном времени)
        if let user = authService.currentUser {
            return user
        }
        // Fallback на UserDataService
        return userDataService.getCurrentUser()
    }
    
    private var userStats: (orders: Int, reservations: Int, deliveries: Int) {
        let orderStats = userDataService.getOrderStats()
        let reservationStats = userDataService.getReservationStats()
        let deliveryCount = userDataService.getOrdersByStatus(.delivered).count
        
        return (orderStats.total, reservationStats.active + reservationStats.completed, deliveryCount)
    }
    
    var body: some View {
        Group {
            if !authService.isAuthenticated {
                AuthView()
                    .environmentObject(authService)
            } else {
                ProfileContentView(
                    user: currentUser,
                    userStats: userStats,
                    onShowOrderHistory: { showOrderHistory = true },
                    onShowReservations: { showReservations = true },
                    onShowDeliveryHistory: { showDeliveryHistory = true },
                    onShowProfileEdit: { showProfileEdit = true },
                    onShowSettings: { showSettings = true },
                    onShowNotifications: { showNotifications = true },
                    onShowSupport: { showSupport = true },
                    onShowLoyalty: { showLoyalty = true },
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
                .sheet(isPresented: $showProfileEdit) {
                    ProfileEditView(user: currentUser)
                        .environmentObject(userDataService)
                }
                .sheet(isPresented: $showSettings) {
                    ProfileSettingsView()
                }
                .sheet(isPresented: $showNotifications) {
                    NotificationsView()
                }
                .sheet(isPresented: $showSupport) {
                    SupportView()
                }
                .sheet(isPresented: $showLoyalty) {
                    LoyaltyProgramView()
                        .environmentObject(userDataService)
                }
            }
        }
    }
}

// MARK: - Profile Content View
struct ProfileContentView: View {
    let user: User?
    let userStats: (orders: Int, reservations: Int, deliveries: Int)
    let onShowOrderHistory: () -> Void
    let onShowReservations: () -> Void
    let onShowDeliveryHistory: () -> Void
    let onShowProfileEdit: () -> Void
    let onShowSettings: () -> Void
    let onShowNotifications: () -> Void
    let onShowSupport: () -> Void
    let onShowLoyalty: () -> Void
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
                            orderCount: userStats.orders,
                            reservationCount: userStats.reservations,
                            deliveryCount: userStats.deliveries
                        )
                        .padding(.horizontal, 20)
                        
                        // Меню профиля
                        VStack(spacing: 12) {
                            ProfileMenuItemView(
                                title: "Личные данные",
                                icon: "person.circle.fill",
                                color: Color("BykAccent")
                            ) {
                                onShowProfileEdit()
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
                            
                            ProfileMenuItemView(
                                title: "Программа лояльности",
                                icon: "star.circle.fill",
                                color: .orange
                            ) {
                                onShowLoyalty()
                            }
                            
                            ProfileMenuItemView(
                                title: "Уведомления",
                                icon: "bell.badge.fill",
                                color: .blue
                            ) {
                                onShowNotifications()
                            }
                            
                            ProfileMenuItemView(
                                title: "Настройки",
                                icon: "gearshape.fill",
                                color: .gray
                            ) {
                                onShowSettings()
                            }
                            
                            ProfileMenuItemView(
                                title: "Поддержка",
                                icon: "questionmark.circle.fill",
                                color: .cyan
                            ) {
                                onShowSupport()
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