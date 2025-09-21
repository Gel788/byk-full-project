import SwiftUI

struct EnhancedHashtagsSection: View {
    @Binding var hashtags: [String]
    @State private var newHashtag = ""
    @State private var showingSuggestions = false
    
    private let popularHashtags = [
        "бык", "стейк", "мясо", "гриль", "барбекю", "пиво", "вино", 
        "москва", "ресторан", "ужин", "обед", "завтрак", "десерт",
        "вкусно", "рекомендую", "атмосфера", "сервис", "качество"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Заголовок
            HStack {
                Text("Хештеги")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    showingSuggestions.toggle()
                }) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                }
            }
            
            // Поле ввода нового хештега
            HStack {
                TextField("Добавить хештег", text: $newHashtag)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        addHashtag()
                    }
                
                Button("Добавить", action: addHashtag)
                    .buttonStyle(.borderedProminent)
                    .disabled(newHashtag.isEmpty)
            }
            
            // Список хештегов
            if !hashtags.isEmpty {
                HashtagsListView(hashtags: hashtags) { tagToRemove in
                    hashtags.removeAll { $0 == tagToRemove }
                }
            }
            
            // Предложения хештегов
            if showingSuggestions {
                HashtagSuggestionsListView(
                    popularHashtags: popularHashtags,
                    selectedHashtags: hashtags
                ) { hashtag in
                    if !hashtags.contains(hashtag) {
                        hashtags.append(hashtag)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
        )
    }
    
    private func addHashtag() {
        let trimmed = newHashtag.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && !hashtags.contains(trimmed) {
            hashtags.append(trimmed)
            newHashtag = ""
        }
    }
}

struct HashtagsListView: View {
    let hashtags: [String]
    let onRemove: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Добавленные хештеги")
                .font(.headline)
                .foregroundColor(.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(hashtags, id: \.self) { hashtag in
                    HashtagItemView(
                        hashtag: hashtag,
                        onRemove: { _ in onRemove(hashtag) }
                    )
                }
            }
        }
    }
}

struct HashtagItemView: View {
    let hashtag: String
    let onRemove: (String) -> Void
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 6) {
            Text("#\(hashtag)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.blue)
            
            Button(action: { onRemove(hashtag) }) {
                Image(systemName: "xmark")
                    .font(.caption2)
                    .foregroundColor(.red)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.blue.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.blue.opacity(0.5), lineWidth: 1)
                )
        )
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
        }
    }
}

struct HashtagSuggestionsListView: View {
    let popularHashtags: [String]
    let selectedHashtags: [String]
    let onSelect: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Популярные хештеги")
                .font(.headline)
                .foregroundColor(.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                ForEach(popularHashtags, id: \.self) { hashtag in
                    if !selectedHashtags.contains(hashtag) {
                        Button(action: { onSelect(hashtag) }) {
                            Text("#\(hashtag)")
                                .font(.caption)
                                .foregroundColor(.blue)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.blue.opacity(0.2))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                        )
                                )
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.2))
        )
    }
}
