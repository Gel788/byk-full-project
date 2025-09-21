import SwiftUI

struct MenuSearchBarView: View {
    @Binding var searchText: String
    @Binding var showSearchBar: Bool
    @Binding var searchBarOffset: CGFloat
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        HStack {
            if showSearchBar {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Поиск блюд...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(.white)
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(brandColors.accent, lineWidth: 1)
                        )
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
            }
            
            Spacer()
            
            Button(action: {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    showSearchBar.toggle()
                    searchBarOffset = showSearchBar ? 0 : -100
                }
            }) {
                Image(systemName: showSearchBar ? "xmark" : "magnifyingglass")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(
                        Circle()
                            .fill(brandColors.accent.opacity(0.2))
                            .overlay(
                                Circle()
                                    .stroke(brandColors.accent, lineWidth: 1)
                            )
                    )
            }
        }
        .padding(.horizontal)
        .offset(y: searchBarOffset)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showSearchBar)
    }
}
