import SwiftUI

struct TestNewsAPI: View {
    @StateObject private var newsService = NewsService()
    
    var body: some View {
        NavigationView {
            VStack {
                if newsService.isLoading {
                    ProgressView("Загрузка новостей...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = newsService.error {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        
                        Text("Ошибка загрузки")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(error)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Повторить") {
                            newsService.loadNewsFromAPI()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if newsService.news.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "newspaper")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("Нет новостей")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Новости пока не загружены")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(newsService.news) { news in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(news.title)
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            Text(news.description)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .lineLimit(3)
                            
                            if !news.image.isEmpty {
                                AsyncImage(url: URL(string: news.image)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxHeight: 200)
                                        .cornerRadius(8)
                                } placeholder: {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 200)
                                        .overlay(
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        )
                                        .cornerRadius(8)
                                }
                            }
                            
                            HStack {
                                Text("Лайки: \(news.likes)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text(news.date, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Тест API Новостей")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await newsService.refreshNews()
            }
        }
    }
}

#Preview {
    TestNewsAPI()
}
