import SwiftUI

struct DishCard: View {
    let dish: Dish
    let onTap: () -> Void
    @EnvironmentObject var cartViewModel: CartViewModel
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color) {
        Colors.brandColors(for: dish.restaurantBrand)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Изображение
            AsyncImage(url: URL(string: dish.image)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure(_):
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.gray)
                case .empty:
                    ProgressView()
                        .frame(width: 40, height: 40)
                @unknown default:
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.gray)
                }
            }
            .frame(width: UIScreen.main.bounds.width / 2 - 32, height: 160)
            .clipped()
            .cornerRadius(12)
            
            // Информация о блюде
            VStack(alignment: .leading, spacing: 4) {
                Text(dish.name)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Text("\(Int(dish.price)) ₽")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(brandColors.accent)
            }
            .padding(.horizontal, 8)
            
            Spacer()
            
            // Кнопка добавления в корзину
            Button(action: {
                addToCart()
            }) {
                Text("В корзину")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        LinearGradient(
                            colors: [brandColors.accent, brandColors.primary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(8)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .frame(width: UIScreen.main.bounds.width / 2 - 32, height: 280)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .onTapGesture {
            onTap()
        }
    }
    
    private func addToCart() {
        print("🛒 DishCard: Попытка добавить блюдо в корзину")
        print("🛒 DishCard: Блюдо ID = \(dish.id)")
        print("🛒 DishCard: Название = \(dish.name)")
        print("🛒 DishCard: Бренд = \(dish.restaurantBrand)")
        
        let tempRestaurant = Restaurant(
            name: dish.restaurantBrand.rawValue,
            description: "Temporary restaurant for cart",
            address: "Temp Address",
            city: "Moscow",
            imageURL: "94033",
            rating: 4.5,
            cuisine: "Mixed",
            deliveryTime: 30,
            brand: dish.restaurantBrand,
            menu: [],
            features: [],
            workingHours: WorkingHours(openTime: "10:00", closeTime: "22:00", weekdays: Set(WorkingHours.Weekday.allCases)),
            location: Location(latitude: 55.7558, longitude: 37.6176),
            tables: [],
            gallery: [],
            contacts: ContactInfo(),
            averageCheck: 1500,
            atmosphere: ["Casual"]
        )
        
        let result = cartViewModel.addToCart(dish, from: tempRestaurant)
        print("🛒 DishCard: Результат добавления = \(result)")
        print("🛒 DishCard: Текущее количество в корзине = \(cartViewModel.totalItems)")
        
        HapticManager.shared.impact(.light)
    }
}


#Preview {
    DishCard(
        dish: Dish(
            name: "Стейк Рибай",
            description: "Сочный стейк из мраморной говядины",
            price: 2500,
            image: "https://bulladmin.ru/api/upload/uploads/file-1758302996529-58816949.jpeg",
            category: "Стейки",
            restaurantBrand: Restaurant.Brand.theByk
        ),
        onTap: {}
    )
    .environmentObject(CartViewModel(restaurantService: RestaurantService(), menuService: MenuService()))
    .padding()
    .background(Color.black)
}