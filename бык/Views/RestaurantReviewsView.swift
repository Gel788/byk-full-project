import SwiftUI

struct RestaurantReviewsView: View {
    let restaurant: Restaurant
    @Environment(\.dismiss) private var dismiss
    @State private var selectedRating: Int = 0
    @State private var showingAddReview = false
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color) {
        Colors.brandColors(for: restaurant.brand)
    }
    
    // Mock отзывы
    private var reviews: [RestaurantReview] {
        [
            RestaurantReview(
                id: "1",
                userName: "Александр П.",
                userAvatar: "person.circle.fill",
                rating: 5,
                date: Date().addingTimeInterval(-86400),
                comment: "Отличный ресторан! Стейки просто превосходные, обслуживание на высшем уровне. Обязательно вернемся еще раз.",
                isVerified: true,
                photos: ["thebyk_main"]
            ),
            RestaurantReview(
                id: "2", 
                userName: "Мария К.",
                userAvatar: "person.circle.fill",
                rating: 4,
                date: Date().addingTimeInterval(-172800),
                comment: "Очень атмосферное место, вкусная еда. Единственный минус - немного шумно вечером.",
                isVerified: false,
                photos: []
            ),
            RestaurantReview(
                id: "3",
                userName: "Дмитрий С.",
                userAvatar: "person.circle.fill", 
                rating: 5,
                date: Date().addingTimeInterval(-259200),
                comment: "Лучший стейк в городе! Персонал очень внимательный, интерьер шикарный. Рекомендую всем!",
                isVerified: true,
                photos: []
            )
        ]
    }
    
    private var averageRating: Double {
        guard !reviews.isEmpty else { return 0 }
        let total = reviews.reduce(0) { $0 + $1.rating }
        return Double(total) / Double(reviews.count)
    }
    
    private var ratingDistribution: [Int: Int] {
        var distribution: [Int: Int] = [1: 0, 2: 0, 3: 0, 4: 0, 5: 0]
        for review in reviews {
            distribution[review.rating, default: 0] += 1
        }
        return distribution
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Фон
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        brandColors.accent.opacity(0.1),
                        Color.black.opacity(0.95)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Заголовок
                        headerSection
                        
                        // Сводка рейтингов
                        ratingSummarySection
                        
                        // Фильтр по рейтингу
                        ratingFilterSection
                        
                        // Список отзывов
                        reviewsListSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddReview) {
                AddReviewView(restaurant: restaurant)
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: { dismiss() }) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text("Отзывы")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.white, Color.white.opacity(0.9)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text(restaurant.name)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Button(action: { showingAddReview = true }) {
                    ZStack {
                        Circle()
                            .fill(brandColors.accent.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(brandColors.accent)
                    }
                }
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Rating Summary Section
    private var ratingSummarySection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 24) {
                // Средний рейтинг
                VStack(spacing: 8) {
                    Text(String(format: "%.1f", averageRating))
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 2) {
                        ForEach(1...5, id: \.self) { index in
                            Image(systemName: "star.fill")
                                .font(.system(size: 16))
                                .foregroundColor(index <= Int(averageRating.rounded()) ? .yellow : .gray.opacity(0.3))
                        }
                    }
                    
                    Text("\(reviews.count) отзывов")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                // Распределение рейтингов
                VStack(spacing: 8) {
                    ForEach((1...5).reversed(), id: \.self) { rating in
                        HStack(spacing: 8) {
                            Text("\(rating)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                                .frame(width: 12)
                            
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.yellow)
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color.white.opacity(0.2))
                                        .frame(height: 4)
                                    
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(brandColors.accent)
                                        .frame(
                                            width: geometry.size.width * CGFloat(ratingDistribution[rating] ?? 0) / CGFloat(reviews.count),
                                            height: 4
                                        )
                                }
                            }
                            .frame(height: 4)
                            
                            Text("\(ratingDistribution[rating] ?? 0)")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                                .frame(width: 16)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Rating Filter Section
    private var ratingFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ReviewFilterButton(title: "Все", isSelected: selectedRating == 0) {
                    selectedRating = 0
                }
                
                ForEach((1...5).reversed(), id: \.self) { rating in
                    ReviewFilterButton(
                        title: "\(rating) ⭐",
                        isSelected: selectedRating == rating
                    ) {
                        selectedRating = rating
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Reviews List Section
    private var reviewsListSection: some View {
        LazyVStack(spacing: 16) {
            ForEach(filteredReviews, id: \.id) { review in
                ReviewCard(review: review, brandColors: brandColors)
            }
        }
    }
    
    private var filteredReviews: [RestaurantReview] {
        if selectedRating == 0 {
            return reviews
        }
        return reviews.filter { $0.rating == selectedRating }
    }
}

// MARK: - Models
struct RestaurantReview: Identifiable {
    let id: String
    let userName: String
    let userAvatar: String
    let rating: Int
    let date: Date
    let comment: String
    let isVerified: Bool
    let photos: [String]
}

// MARK: - Review Filter Button
struct ReviewFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color) {
        (Color("BykPrimary"), Color("BykSecondary"), Color("BykAccent"))
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? brandColors.accent : Color.white.opacity(0.1))
                        .overlay(
                            Capsule()
                                .stroke(
                                    isSelected ? brandColors.accent : Color.white.opacity(0.2),
                                    lineWidth: 1
                                )
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Review Card
struct ReviewCard: View {
    let review: RestaurantReview
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Заголовок отзыва
            HStack(spacing: 12) {
                // Аватар
                ZStack {
                    Circle()
                        .fill(brandColors.accent.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: review.userAvatar)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(brandColors.accent)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(review.userName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        if review.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.blue)
                        }
                    }
                    
                    HStack(spacing: 8) {
                        // Рейтинг
                        HStack(spacing: 2) {
                            ForEach(1...5, id: \.self) { index in
                                Image(systemName: "star.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(index <= review.rating ? .yellow : .gray.opacity(0.3))
                            }
                        }
                        
                        // Дата
                        Text(timeAgoString(from: review.date))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                
                Spacer()
            }
            
            // Текст отзыва
            Text(review.comment)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(nil)
            
            // Фото (если есть)
            if !review.photos.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(review.photos, id: \.self) { photo in
                            Image(photo)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 60)
                                .clipped()
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 1)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private func timeAgoString(from date: Date) -> String {
        let now = Date()
        let difference = now.timeIntervalSince(date)
        
        if difference < 86400 {
            return "Сегодня"
        } else if difference < 172800 {
            return "Вчера"
        } else {
            let days = Int(difference / 86400)
            return "\(days) дн назад"
        }
    }
}

// MARK: - Add Review View
struct AddReviewView: View {
    let restaurant: Restaurant
    @Environment(\.dismiss) private var dismiss
    @State private var rating = 0
    @State private var comment = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Оставить отзыв")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Как вам понравился \(restaurant.name)?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Рейтинг
                HStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { index in
                        Button(action: { rating = index }) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 24))
                                .foregroundColor(index <= rating ? .yellow : .gray.opacity(0.3))
                        }
                    }
                }
                .padding()
                
                // Комментарий
                TextEditor(text: $comment)
                    .frame(minHeight: 100)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Отправить") {
                        // Логика сохранения отзыва
                        dismiss()
                    }
                    .disabled(rating == 0)
                }
            }
        }
    }
}

#Preview {
    RestaurantReviewsView(restaurant: Restaurant.mock)
}