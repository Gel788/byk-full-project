import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @State private var selectedFilters: Set<Filter> = []
    @State private var showFilters = false
    @State private var isSearching = false
    @State private var searchResults: [SearchResult] = []
    @State private var recentSearches: [String] = []
    
    private let filters = [
        Filter(name: "Стейки", icon: "flame.fill"),
        Filter(name: "Бургеры", icon: "takeoutbag.and.cup.and.straw.fill"),
        Filter(name: "Салаты", icon: "leaf.fill"),
        Filter(name: "Супы", icon: "cup.and.saucer.fill"),
        Filter(name: "Десерты", icon: "birthday.cake.fill"),
        Filter(name: "Напитки", icon: "wineglass.fill")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Поисковая строка
                    HStack {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                            
                            TextField("Поиск блюд и ресторанов", text: $searchText)
                                .textFieldStyle(.plain)
                                .submitLabel(.search)
                                .onSubmit {
                                    performSearch()
                                }
                            
                            if !searchText.isEmpty {
                                Button(action: { searchText = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(12)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(12)
                        
                        if !searchText.isEmpty {
                            Button("Отмена") {
                                searchText = ""
                                withAnimation {
                                    isSearching = false
                                }
                            }
                            .foregroundColor(.accentColor)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal)
                    
                    // Фильтры
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(filters, id: \.name) { filter in
                                FilterButton(
                                    filter: filter,
                                    isSelected: selectedFilters.contains(filter)
                                ) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        if selectedFilters.contains(filter) {
                                            selectedFilters.remove(filter)
                                        } else {
                                            selectedFilters.insert(filter)
                                        }
                                        performSearch()
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    if isSearching {
                        // Результаты поиска
                        LazyVStack(spacing: 16) {
                            ForEach(searchResults) { result in
                                SearchResultRow(result: result)
                                    .transition(.opacity)
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        // Недавние поиски
                        if !recentSearches.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Недавние поиски")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                LazyVStack(spacing: 12) {
                                    ForEach(recentSearches, id: \.self) { search in
                                        Button(action: {
                                            searchText = search
                                            performSearch()
                                        }) {
                                            HStack {
                                                Image(systemName: "clock")
                                                    .foregroundColor(.secondary)
                                                Text(search)
                                                    .foregroundColor(.primary)
                                                Spacer()
                                            }
                                            .padding()
                                            .background(Color.black.opacity(0.8))
                                            .cornerRadius(16)
                                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
                                            .padding(.horizontal)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Популярные категории
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Популярные категории")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 16) {
                                ForEach(filters) { filter in
                                    CategoryCard(filter: filter) {
                                        selectedFilters = [filter]
                                        performSearch()
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Поиск")
            .navigationBarTitleDisplayMode(.large)
            .background(Color.black)
        }
        .background(Color.black)
    }
    
    private func performSearch() {
        withAnimation {
            isSearching = !searchText.isEmpty
            // TODO: Implement actual search
            searchResults = []
            
            if !searchText.isEmpty && !recentSearches.contains(searchText) {
                recentSearches.insert(searchText, at: 0)
                if recentSearches.count > 5 {
                    recentSearches.removeLast()
                }
            }
        }
    }
}

struct Filter: Hashable, Identifiable {
    let id = UUID()
    let name: String
    let icon: String
}

struct SearchResult: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let image: String
    let type: ResultType
    
    enum ResultType {
        case dish
        case restaurant
    }
}

struct FilterButton: View {
    let filter: Filter
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: filter.icon)
                Text(filter.name)
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor : Color.black.opacity(0.6))
            .cornerRadius(20)
            .pressAnimation(isPressed: isSelected)
        }
    }
}

struct CategoryCard: View {
    let filter: Filter
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isPressed = false
                action()
            }
        }) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: filter.icon)
                    .font(.system(size: 32))
                    .foregroundColor(.accentColor)
                
                Text(filter.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.black.opacity(0.6))
            .cornerRadius(16)
            .pressAnimation(isPressed: isPressed)
        }
    }
}

struct SearchResultRow: View {
    let result: SearchResult
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: result.type == .dish ? "fork.knife" : "building.2")
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 40, height: 40)
                .background(Color.black.opacity(0.6))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(result.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(result.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.black.opacity(0.8))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}

#Preview {
    SearchView()
} 