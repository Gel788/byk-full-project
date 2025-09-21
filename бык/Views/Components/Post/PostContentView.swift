import SwiftUI

struct EnhancedContentView: View {
    @Binding var content: String
    @Binding var hashtags: [String]
    @State private var showingHashtagSuggestions = false
    
    private let popularHashtags = [
        "бык", "стейк", "мясо", "гриль", "барбекю", "пиво", "вино", 
        "москва", "ресторан", "ужин", "обед", "завтрак", "десерт"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Заголовок
            HStack {
                Text("Описание")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    showingHashtagSuggestions.toggle()
                }) {
                    Image(systemName: "tag.fill")
                        .foregroundColor(.blue)
                }
            }
            
            // Текстовое поле
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                    .frame(minHeight: 120)
                
                if content.isEmpty {
                    Text("Расскажите о вашем опыте...")
                        .foregroundColor(.gray)
                        .padding()
                }
                
                TextEditor(text: $content)
                    .padding(8)
                    .background(Color.clear)
                    .foregroundColor(.white)
            }
            
            // Хештеги
            if !hashtags.isEmpty {
                HashtagsView(hashtags: hashtags) { tagToRemove in
                    hashtags.removeAll { $0 == tagToRemove }
                }
            }
            
            // Предложения хештегов
            if showingHashtagSuggestions {
                HashtagSuggestionsView(
                    popularHashtags: popularHashtags,
                    selectedHashtags: hashtags
                ) { hashtag in
                    if !hashtags.contains(hashtag) {
                        hashtags.append(hashtag)
                    }
                    showingHashtagSuggestions = false
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

struct HashtagsView: View {
    let hashtags: [String]
    let onRemove: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Хештеги")
                .font(.headline)
                .foregroundColor(.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                ForEach(hashtags, id: \.self) { hashtag in
                    HashtagChip(
                        hashtag: hashtag,
                        onRemove: { _ in onRemove(hashtag) }
                    )
                }
            }
        }
    }
}

struct HashtagChip: View {
    let hashtag: String
    let onRemove: (String) -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text("#\(hashtag)")
                .font(.caption)
                .foregroundColor(.blue)
            
            Button(action: { onRemove(hashtag) }) {
                Image(systemName: "xmark")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.2))
        )
    }
}

struct HashtagSuggestionsView: View {
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
