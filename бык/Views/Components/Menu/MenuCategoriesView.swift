import SwiftUI

struct MenuCategoriesView: View {
    let categories: [String]
    @Binding var selectedCategory: String?
    @Binding var categoryOffset: CGFloat
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // Кнопка "Все"
                CategoryButton(
                    title: "Все",
                    isSelected: selectedCategory == nil,
                    brandColors: brandColors
                ) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        selectedCategory = nil
                    }
                }
                
                // Категории
                ForEach(categories, id: \.self) { category in
                    CategoryButton(
                        title: category,
                        isSelected: selectedCategory == category,
                        brandColors: brandColors
                    ) {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .offset(y: categoryOffset)
        .animation(.spring(response: 0.8, dampingFraction: 0.8), value: categoryOffset)
    }
}

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isSelected ? .black : .white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(isSelected ? brandColors.accent : Color.gray.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(brandColors.accent, lineWidth: isSelected ? 0 : 1)
                        )
                )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}
