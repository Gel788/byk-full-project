import SwiftUI

struct DeliveryHistoryView: View {
    @StateObject private var deliveryService = DeliveryService()
    @State private var selectedFilter: OrderFilter = .all
    @State private var selectedBrand: Restaurant.Brand? = nil
    @State private var showingOrderDetail: DeliveryOrder? = nil
    @State private var searchText = ""
    
    private var filteredOrders: [DeliveryOrder] {
        var orders = deliveryService.deliveryOrders
        
        // Фильтр по статусу
        if selectedFilter != .all {
            orders = orders.filter { $0.status == selectedFilter.orderStatus }
        }
        
        // Фильтр по бренду
        if let brand = selectedBrand {
            orders = orders.filter { $0.restaurantBrand == brand }
        }
        
        // Поиск
        if !searchText.isEmpty {
            orders = orders.filter { order in
                order.orderNumber.localizedCaseInsensitiveContains(searchText) ||
                order.items.contains { item in
                    item.dish.name.localizedCaseInsensitiveContains(searchText)
                } ||
                order.deliveryAddress.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return orders.sorted { $0.orderDate > $1.orderDate }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Фильтры
                FilterSection(
                    selectedFilter: $selectedFilter,
                    selectedBrand: $selectedBrand
                )
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Статистика
                DeliveryStatisticsSection(deliveryService: deliveryService)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                // Список заказов
                if filteredOrders.isEmpty {
                    DeliveryEmptyStateView()
                        .padding(.top, 50)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredOrders) { order in
                                DeliveryOrderCard(
                                    order: order,
                                    onTap: {
                                        showingOrderDetail = order
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
            .background(Color.black)
            .navigationTitle("История доставки")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $showingOrderDetail) { order in
                DeliveryOrderDetailView(order: order)
            }
        }
        .background(Color.black)
    }
}

// MARK: - Search Bar
struct DeliverySearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Поиск по номеру заказа, блюду...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.6))
        )
    }
}

// MARK: - Filter Section
struct FilterSection: View {
    @Binding var selectedFilter: OrderFilter
    @Binding var selectedBrand: Restaurant.Brand?
    
    var body: some View {
        VStack(spacing: 12) {
            // Фильтр по статусу
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(OrderFilter.allCases, id: \.self) { filter in
                        FilterChip(
                            title: filter.title,
                            isSelected: selectedFilter == filter,
                            color: filter.color
                        ) {
                            selectedFilter = filter
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
            
            // Фильтр по бренду
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    FilterChip(
                        title: "Все бренды",
                        isSelected: selectedBrand == nil,
                        color: .gray
                    ) {
                        selectedBrand = nil
                    }
                    
                    ForEach(Restaurant.Brand.allCases, id: \.self) { brand in
                        let brandColors = Colors.brandColors(for: brand)
                        FilterChip(
                            title: brand.rawValue,
                            isSelected: selectedBrand == brand,
                            color: brandColors.primary
                        ) {
                            selectedBrand = brand
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? color : Color.black.opacity(0.6))
                )
        }
    }
}

// MARK: - Statistics Section
struct DeliveryStatisticsSection: View {
    let deliveryService: DeliveryService
    
    var body: some View {
        HStack(spacing: 12) {
            DeliveryStatCard(
                title: "Всего заказов",
                value: "\(deliveryService.deliveryOrders.count)",
                icon: "bag.fill",
                color: .blue
            )
            
            DeliveryStatCard(
                title: "Потрачено",
                value: "\(Int(deliveryService.getTotalSpent())) ₽",
                icon: "creditcard.fill",
                color: .green
            )
            
            DeliveryStatCard(
                title: "Средний чек",
                value: "\(Int(deliveryService.getAverageOrderValue())) ₽",
                icon: "chart.bar.fill",
                color: .orange
            )
        }
    }
}

struct DeliveryStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(color)
            }
            
            VStack(spacing: 2) {
                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.8))
                .shadow(color: .white.opacity(0.05), radius: 3, x: 0, y: 1)
        )
    }
}

// MARK: - Delivery Order Card
struct DeliveryOrderCard: View {
    let order: DeliveryOrder
    let onTap: () -> Void
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color) {
        Colors.brandColors(for: order.restaurantBrand)
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                // Заголовок карточки
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(order.orderNumber)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text(order.restaurantBrand.rawValue)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(brandColors.primary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(Int(order.totalAmount)) ₽")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text(order.orderDate, style: .date)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                // Статус заказа
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: order.status.icon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(order.status.color))
                        
                        Text(order.status.rawValue)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(order.status.color))
                    }
                    
                    Spacer()
                    
                    Text(order.paymentMethod.rawValue)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.black.opacity(0.6))
                        )
                }
                
                // Блюда
                VStack(spacing: 8) {
                    ForEach(order.items.prefix(2)) { item in
                        HStack {
                            Text("\(item.quantity)x \(item.dish.name)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text("\(Int(item.price)) ₽")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if order.items.count > 2 {
                        Text("+ еще \(order.items.count - 2) блюд")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                // Адрес доставки
                HStack {
                    Image(systemName: "location")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text(order.deliveryAddress)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Spacer()
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.8))
                    .shadow(color: .white.opacity(0.1), radius: 5, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Empty State
struct DeliveryEmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bag")
                .font(.system(size: 60, weight: .light))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("История пуста")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("У вас пока нет заказов доставки")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

// MARK: - Order Filter
enum OrderFilter: CaseIterable {
    case all
    case pending
    case confirmed
    case preparing
    case ready
    case delivering
    case delivered
    case cancelled
    
    var title: String {
        switch self {
        case .all: return "Все"
        case .pending: return "Ожидает"
        case .confirmed: return "Подтвержден"
        case .preparing: return "Готовится"
        case .ready: return "Готов"
        case .delivering: return "В пути"
        case .delivered: return "Доставлен"
        case .cancelled: return "Отменен"
        }
    }
    
    var orderStatus: DeliveryOrderStatus? {
        switch self {
        case .all: return nil
        case .pending: return .pending
        case .confirmed: return .confirmed
        case .preparing: return .preparing
        case .ready: return .ready
        case .delivering: return .delivering
        case .delivered: return .delivered
        case .cancelled: return .cancelled
        }
    }
    
    var color: Color {
        switch self {
        case .all: return .blue
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

#Preview {
    DeliveryHistoryView()
} 