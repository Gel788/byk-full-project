import SwiftUI

struct OrderHistoryView: View {
    @EnvironmentObject var userDataService: UserDataService
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFilter: OrderStatus? = nil
    @State private var searchText = ""
    @State private var showingOrderDetail: UserOrder? = nil
    
    private var filteredOrders: [UserOrder] {
        var orders = userDataService.userOrders
        
        if let filter = selectedFilter {
            orders = orders.filter { $0.status == filter }
        }
        
        if !searchText.isEmpty {
            orders = orders.filter { order in
                order.orderNumber.localizedCaseInsensitiveContains(searchText) ||
                order.restaurantName.localizedCaseInsensitiveContains(searchText) ||
                order.items.contains { item in
                    item.dishName.localizedCaseInsensitiveContains(searchText)
                }
            }
        }
        
        return orders.sorted { $0.orderDate > $1.orderDate }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Анимированный градиентный фон
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
                
                VStack(spacing: 0) {
                    // Заголовок с поиском
                    OrderHistoryHeader(
                        searchText: $searchText,
                        orderCount: filteredOrders.count
                    )
                    
                    // Фильтры
                    OrderFilterSection(selectedFilter: $selectedFilter)
                    
                    // Список заказов
                    if filteredOrders.isEmpty {
                        EmptyOrdersView()
                    } else {
                        OrderListSection(
                            orders: filteredOrders,
                            onOrderTap: { order in
                                showingOrderDetail = order
                            }
                        )
                    }
                }
            }
            .navigationTitle("История заказов")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                    .foregroundColor(Color("BykAccent"))
                }
            }
        }
        .sheet(item: $showingOrderDetail) { order in
            OrderDetailView(order: order)
        }
    }
}

struct OrderHistoryHeader: View {
    @Binding var searchText: String
    let orderCount: Int
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("История заказов")
                        .font(.custom("Helvetica Neue", size: 28, relativeTo: .largeTitle))
                        .fontWeight(.light)
                        .foregroundColor(.white)
                    
                    Text("\(orderCount) заказов")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Иконка статистики
                ZStack {
                    Circle()
                        .fill(Color("BykAccent").opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color("BykAccent"))
                }
            }
            

        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
}

struct OrderFilterSection: View {
    @Binding var selectedFilter: OrderStatus?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // Кнопка "Все"
                OrderFilterChip(
                    title: "Все",
                    isSelected: selectedFilter == nil,
                    color: Color("BykAccent")
                ) {
                    selectedFilter = nil
                }
                
                // Фильтры по статусам
                ForEach(OrderStatus.allCases, id: \.self) { status in
                    OrderFilterChip(
                        title: status.rawValue,
                        isSelected: selectedFilter == status,
                        color: Color(status.color)
                    ) {
                        selectedFilter = status
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 20)
    }
}

struct OrderFilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            isSelected ?
                            LinearGradient(
                                gradient: Gradient(colors: [color, color.opacity(0.7)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ) :
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0.05)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    isSelected ? color.opacity(0.5) : Color.white.opacity(0.2),
                                    lineWidth: 1
                                )
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct OrderListSection: View {
    let orders: [UserOrder]
    let onOrderTap: (UserOrder) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(orders) { order in
                    OrderCard(order: order, onTap: {
                        onOrderTap(order)
                    })
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
    }
}

struct OrderCard: View {
    let order: UserOrder
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                // Заголовок заказа
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Заказ #\(order.orderNumber)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(order.restaurantName)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color("BykAccent"))
                    }
                    
                    Spacer()
                    
                    // Статус заказа
                    OrderStatusBadge(status: order.status)
                }
                
                // Блюда
                VStack(spacing: 8) {
                    ForEach(order.items.prefix(3)) { item in
                        HStack {
                            AsyncImage(url: URL(string: item.image)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 40, height: 40)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            } placeholder: {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 40, height: 40)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.dishName)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                
                                Text("×\(item.quantity)")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            Text("\(String(format: "%.0f", item.price)) ₽")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    
                    if order.items.count > 3 {
                        Text("+\(order.items.count - 3) еще")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color("BykAccent"))
                    }
                }
                
                // Итоговая информация
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Итого: \(String(format: "%.0f", order.totalAmount)) ₽")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(order.orderDate, style: .date)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    // Кнопка повтора заказа
                    Button(action: {
                        // Логика повтора заказа
                    }) {
                        Text("Повторить")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color("BykAccent"))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color("BykAccent").opacity(0.2))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color("BykAccent").opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.black.opacity(0.8),
                                Color.black.opacity(0.6)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color("BykAccent").opacity(0.3),
                                        Color("BykAccent").opacity(0.1)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: Color("BykAccent").opacity(0.2), radius: 10, x: 0, y: 5)
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

struct OrderStatusBadge: View {
    let status: OrderStatus
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: status.icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(statusColor)
            
            Text(status.rawValue)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(statusColor)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(statusColor.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(statusColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var statusColor: Color {
        switch status {
        case .pending: return .orange
        case .confirmed: return .blue
        case .preparing: return .purple
        case .ready: return .yellow
        case .delivering: return .green
        case .delivered: return .green
        case .cancelled: return .red
        }
    }
}

struct EmptyOrdersView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Иконка
            ZStack {
                Circle()
                    .fill(Color("BykAccent").opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "bag.circle")
                    .font(.system(size: 60))
                    .foregroundColor(Color("BykAccent"))
            }
            
            VStack(spacing: 8) {
                Text("История заказов пуста")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Здесь будут отображаться все ваши заказы")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            
            // Кнопка перехода к меню
            Button(action: {
                // Переход к меню
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text("Сделать первый заказ")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color("BykAccent"),
                                    Color("BykAccent").opacity(0.8)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
                .shadow(color: Color("BykAccent").opacity(0.3), radius: 8, x: 0, y: 4)
            }
            
            Spacer()
        }
        .padding(40)
    }
}

#Preview {
    OrderHistoryView()
        .environmentObject(UserDataService())
} 