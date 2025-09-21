import SwiftUI

// MARK: - Menu Search Section
struct MenuSearchSection: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("Поиск блюд...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Brand Filter Section
struct MenuBrandFilterSection: View {
    @Binding var selectedBrand: Restaurant.Brand?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // Кнопка "Все"
                MenuFilterButton(
                    title: "Все",
                    isSelected: selectedBrand == nil,
                    colors: (primary: Color("BykPrimary"), secondary: Color("BykAccent"), accent: Color("BykAccent")),
                    action: {
                        HapticManager.shared.buttonPress()
                        selectedBrand = nil
                    }
                )
                
                // Фильтры по брендам
                ForEach(Restaurant.Brand.allCases, id: \.self) { brand in
                    let brandColors = Colors.brandColors(for: brand)
                    MenuFilterButton(
                        title: brand.displayName,
                        isSelected: selectedBrand == brand,
                        colors: brandColors,
                        action: {
                            HapticManager.shared.buttonPress()
                            selectedBrand = brand
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Category Filter Section
struct MenuCategoryFilterSection: View {
    let availableCategories: [String]
    @Binding var selectedCategories: Set<String>
    
    var body: some View {
        if !availableCategories.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Кнопка "Все категории"
                    MenuFilterButton(
                        title: "Все категории",
                        isSelected: selectedCategories.isEmpty,
                        colors: (primary: Color("BykPrimary"), secondary: Color("BykAccent"), accent: Color("BykAccent")),
                        action: {
                            HapticManager.shared.buttonPress()
                            selectedCategories.removeAll()
                        }
                    )
                    
                    // Фильтры по категориям
                    ForEach(availableCategories, id: \.self) { category in
                        MenuFilterButton(
                            title: category,
                            isSelected: selectedCategories.contains(category),
                            colors: (primary: Color("BykPrimary"), secondary: Color("BykAccent"), accent: Color("BykAccent")),
                            action: {
                                HapticManager.shared.buttonPress()
                                if selectedCategories.contains(category) {
                                    selectedCategories.remove(category)
                                } else {
                                    selectedCategories.insert(category)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

// MARK: - Menu Filter Button
struct MenuFilterButton: View {
    let title: String
    let isSelected: Bool
    let colors: (primary: Color, secondary: Color, accent: Color)
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? 
                            AnyShapeStyle(LinearGradient(
                                colors: [colors.accent, colors.primary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )) : 
                            AnyShapeStyle(Color(.systemGray5))
                        )
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
    }
}

// MARK: - Menu Content Section
struct MenuContentSection: View {
    let groupedDishes: [Restaurant.Brand: [String: [Dish]]]
    let onDishTap: (Dish) -> Void
    
    var body: some View {
        if groupedDishes.isEmpty {
            MenuEmptyState()
        } else {
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(Array(groupedDishes.keys.sorted(by: { $0.rawValue < $1.rawValue })), id: \.self) { brand in
                        if let brandDishes = groupedDishes[brand], !brandDishes.isEmpty {
                            MenuBrandSection(
                                brand: brand,
                                brandDishes: brandDishes,
                                onDishTap: onDishTap
                            )
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
        }
    }
}

// MARK: - Menu Brand Section
struct MenuBrandSection: View {
    let brand: Restaurant.Brand
    let brandDishes: [String: [Dish]]
    let onDishTap: (Dish) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Заголовок бренда
            HStack {
                Text(brand.displayName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(brand.emoji)
                    .font(.title2)
            }
            
            // Категории бренда
            ForEach(Array(brandDishes.keys.sorted()), id: \.self) { category in
                if let dishes = brandDishes[category], !dishes.isEmpty {
                    MenuCategorySection(
                        category: category,
                        dishes: dishes,
                        onDishTap: onDishTap
                    )
                }
            }
        }
    }
}

// MARK: - Menu Category Section
struct MenuCategorySection: View {
    let category: String
    let dishes: [Dish]
    let onDishTap: (Dish) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(category)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            ForEach(dishes, id: \.id) { dish in
                MenuDishRow(dish: dish, onTap: { onDishTap(dish) })
            }
        }
    }
}

// MARK: - Menu Dish Row
struct MenuDishRow: View {
    let dish: Dish
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dish.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Text(dish.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Text("\(Int(dish.price)) ₽")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("BykAccent"))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Menu Empty State
struct MenuEmptyState: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "fork.knife")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("Блюда не найдены")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Попробуйте изменить фильтры или поисковый запрос")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
    }
}
