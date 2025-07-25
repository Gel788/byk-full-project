import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    @State private var selectedTab = 0
    @State private var previousTab = 0
    
    private let tabs = [
        Tab(title: "Рестораны", icon: "house.fill"),
        Tab(title: "Меню", icon: "fork.knife"),
        Tab(title: "Новости", icon: "newspaper.fill"),
        Tab(title: "Бронирование", icon: "calendar"),
        Tab(title: "Корзина", icon: "cart.fill")
    ]
    
    var body: some View {
        ZStack {
            // Основной контент с анимированными переходами
            TabView(selection: $selectedTab) {
                RestaurantsView()
                    .tag(0)
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
                
                MenuListView()
                    .tag(1)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                
                NewsView()
                    .tag(2)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
                
                ReservationsView()
                    .tag(3)
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
                
                CartView()
                    .tag(4)
                    .transition(.scale.combined(with: .opacity))
            }
            .animation(.easeInOut(duration: 0.3), value: selectedTab)
            
            // Кастомный Tab Bar
            VStack {
                Spacer()
                
                HStack(spacing: 0) {
                    ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                previousTab = selectedTab
                                selectedTab = index
                            }
                            
                            // Haptic feedback
                            HapticManager.shared.impact(.light)
                        }) {
                            VStack(spacing: 3) {
                                Image(systemName: tab.icon)
                                    .font(.system(size: 22, weight: .medium))
                                    .foregroundStyle(
                                        selectedTab == index ?
                                        LinearGradient(
                                            colors: [Color("BykAccent"), Color("BykPrimary")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ) :
                                        LinearGradient(
                                            colors: [Color.gray.opacity(0.6), Color.gray.opacity(0.4)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .scaleEffect(selectedTab == index ? 1.2 : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
                                
                                Text(tab.title)
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundStyle(
                                        selectedTab == index ?
                                        LinearGradient(
                                            colors: [Color("BykAccent"), Color("BykPrimary")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ) :
                                        LinearGradient(
                                            colors: [Color.gray.opacity(0.7), Color.gray.opacity(0.5)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        selectedTab == index ?
                                        LinearGradient(
                                            colors: [
                                                Color("BykAccent").opacity(0.15),
                                                Color("BykPrimary").opacity(0.1)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ) :
                                        LinearGradient(
                                            colors: [
                                                Color.clear,
                                                Color.clear
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                selectedTab == index ?
                                                LinearGradient(
                                                    colors: [Color("BykAccent").opacity(0.3), Color("BykPrimary").opacity(0.2)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ) :
                                                LinearGradient(
                                                    colors: [Color.clear, Color.clear],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: selectedTab == index ? 1 : 0
                                            )
                                    )
                            )
                            .overlay(
                                // Счетчик корзины
                                Group {
                                    if index == 4 && cartViewModel.totalItems > 0 {
                                        Text("\(cartViewModel.totalItems)")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.white)
                                            .frame(width: 18, height: 18)
                                            .background(
                                                LinearGradient(
                                                    colors: [Color.red, Color.orange],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white, lineWidth: 1)
                                            )
                                            .shadow(color: Color.red.opacity(0.5), radius: 2, x: 0, y: 1)
                                            .offset(x: 12, y: -10)
                                            .scaleEffect(cartViewModel.totalItems > 0 ? 1.0 : 0.8)
                                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: cartViewModel.totalItems)
                                    }
                                }
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.black.opacity(0.9),
                                    Color.black.opacity(0.8)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color("BykAccent").opacity(0.3),
                                            Color("BykPrimary").opacity(0.2)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 2)
            }
        }
        .onAppear {
            HapticManager.shared.navigationTransition()
        }
    }
}

struct Tab {
    let title: String
    let icon: String
}

#Preview {
    MainTabView()
        .environmentObject(RestaurantService())
        .environmentObject(CartViewModel(restaurantService: RestaurantService()))
} 