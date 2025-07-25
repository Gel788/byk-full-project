import SwiftUI

struct RestaurantsView: View {
    @EnvironmentObject var restaurantService: RestaurantService
    @State private var selectedRestaurant: Restaurant?
    @State private var searchText = ""
    @State private var selectedBrand: Restaurant.Brand? = nil
    @State private var selectedCity: String? = nil
    @State private var showFilters = false
    @State private var showProfile = false
    
    private var availableCities: [String] {
        let cities = Set(restaurantService.restaurants.map { $0.city })
        return Array(cities).sorted()
    }
    
    private func declineCity(_ city: String) -> String {
        switch city.lowercased() {
        case "москва":
            return "Москве"
        case "санкт-петербург", "спб":
            return "Санкт-Петербурге"
        case "екатеринбург":
            return "Екатеринбурге"
        case "новосибирск":
            return "Новосибирске"
        case "казань":
            return "Казани"
        case "нижний новгород":
            return "Нижнем Новгороде"
        case "челябинск":
            return "Челябинске"
        case "самара":
            return "Самаре"
        case "ростов-на-дону":
            return "Ростове-на-Дону"
        case "уфа":
            return "Уфе"
        case "красноярск":
            return "Красноярске"
        case "пермь":
            return "Перми"
        case "воронеж":
            return "Воронеже"
        case "волгоград":
            return "Волгограде"
        case "краснодар":
            return "Краснодаре"
        case "саратов":
            return "Саратове"
        case "тюмень":
            return "Тюмени"
        case "тольятти":
            return "Тольятти"
        case "ижевск":
            return "Ижевске"
        case "барнаул":
            return "Барнауле"
        case "ульяновск":
            return "Ульяновске"
        case "иркутск":
            return "Иркутске"
        case "хабаровск":
            return "Хабаровске"
        case "ярославль":
            return "Ярославле"
        case "владивосток":
            return "Владивостоке"
        case "махачкала":
            return "Махачкале"
        case "томск":
            return "Томске"
        case "оренбург":
            return "Оренбурге"
        case "кемерово":
            return "Кемерово"
        case "новокузнецк":
            return "Новокузнецке"
        case "рязань":
            return "Рязани"
        case "астрахань":
            return "Астрахани"
        case "набережные челны":
            return "Набережных Челнах"
        case "пенза":
            return "Пензе"
        case "липецк":
            return "Липецке"
        case "киров":
            return "Кирове"
        case "чебоксары":
            return "Чебоксарах"
        case "калуга":
            return "Калуге"
        case "тула":
            return "Туле"
        case "курск":
            return "Курске"
        case "ставрополь":
            return "Ставрополе"
        case "улан-удэ":
            return "Улан-Удэ"
        case "сочи":
            return "Сочи"
        case "брянск":
            return "Брянске"
        case "иваново":
            return "Иваново"
        case "магнитогорск":
            return "Магнитогорске"
        case "тверь":
            return "Твери"
        case "белгород":
            return "Белгороде"
        case "архангельск":
            return "Архангельске"
        case "владимир":
            return "Владимире"
        case "севастополь":
            return "Севастополе"
        case "чита":
            return "Чите"
        case "грозный":
            return "Грозном"
        case "калининград":
            return "Калининграде"
        case "вологда":
            return "Вологде"
        case "курган":
            return "Кургане"
        case "орёл":
            return "Орле"
        case "саранск":
            return "Саранске"
        case "владикавказ":
            return "Владикавказе"
        case "мурманск":
            return "Мурманске"
        case "якутск":
            return "Якутске"
        case "горно-алтайск":
            return "Горно-Алтайске"
        case "майкоп":
            return "Майкопе"
        case "элиста":
            return "Элисте"
        case "черкесск":
            return "Черкесске"
        case "петрозаводск":
            return "Петрозаводске"
        case "сыктывкар":
            return "Сыктывкаре"
        case "йошкар-ола":
            return "Йошкар-Оле"
        case "абакан":
            return "Абакане"
        case "магас":
            return "Магасе"
        case "назрань":
            return "Назрани"
        case "кызыл":
            return "Кызыле"
        case "анадырь":
            return "Анадыре"
        case "ереван":
            return "Ереване"
        case "баку":
            return "Баку"
        case "тбилиси":
            return "Тбилиси"
        case "минск":
            return "Минске"
        case "киев":
            return "Киеве"
        case "алматы":
            return "Алматы"
        case "астана":
            return "Астане"
        case "ташкент":
            return "Ташкенте"
        case "бишкек":
            return "Бишкеке"
        case "душанбе":
            return "Душанбе"
        case "ашхабад":
            return "Ашхабаде"
        default:
            // Для неизвестных городов добавляем "в" в начало
            return "в \(city)"
        }
    }
    
    private var filteredRestaurants: [Restaurant] {
        var restaurants = restaurantService.restaurants
        
        // Фильтрация по поиску
        if !searchText.isEmpty {
            restaurants = restaurants.filter { restaurant in
                restaurant.name.localizedCaseInsensitiveContains(searchText) ||
                restaurant.description.localizedCaseInsensitiveContains(searchText) ||
                restaurant.address.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Фильтрация по бренду
        if let brand = selectedBrand {
            restaurants = restaurants.filter { $0.brand == brand }
        }
        
        // Фильтрация по городу
        if let city = selectedCity {
            restaurants = restaurants.filter { $0.city == city }
        }
        
        return restaurants
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Поиск и фильтры
                VStack(spacing: 16) {
                    // Поиск
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Поиск ресторанов...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Фильтры брендов
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            // Кнопка "Все"
                            Button(action: {
                                HapticManager.shared.buttonPress()
                                selectedBrand = nil
                            }) {
                                Text("Все")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(selectedBrand == nil ? 
                                                AnyShapeStyle(LinearGradient(
                                                    colors: [Color("BykAccent"), Color("BykPrimary")],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )) : 
                                                AnyShapeStyle(Color(.systemGray5))
                                            )
                                    )
                                    .foregroundColor(selectedBrand == nil ? .white : .primary)
                            }
                            
                            // Фильтры по брендам
                            ForEach(Restaurant.Brand.allCases, id: \.self) { brand in
                                let brandColors = Colors.brandColors(for: brand)
                                Button(action: {
                                    HapticManager.shared.buttonPress()
                                    selectedBrand = brand
                                }) {
                                    Text(brand.displayName)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(selectedBrand == brand ? 
                                                    AnyShapeStyle(LinearGradient(
                                                        colors: [brandColors.accent, brandColors.primary],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )) : 
                                                    AnyShapeStyle(Color(.systemGray5))
                                                )
                                        )
                                        .foregroundColor(selectedBrand == brand ? .white : .primary)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    // Фильтры городов
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            // Кнопка "Все города"
                            Button(action: {
                                HapticManager.shared.buttonPress()
                                selectedCity = nil
                            }) {
                                Text("Все города")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(selectedCity == nil ? 
                                                AnyShapeStyle(LinearGradient(
                                                    colors: [Color("BykAccent"), Color("BykPrimary")],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )) : 
                                                AnyShapeStyle(Color(.systemGray5))
                                            )
                                    )
                                    .foregroundColor(selectedCity == nil ? .white : .primary)
                            }
                            
                            // Фильтры по городам
                            ForEach(availableCities, id: \.self) { city in
                                Button(action: {
                                    HapticManager.shared.buttonPress()
                                    selectedCity = city
                                }) {
                                    Text(city)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(selectedCity == city ? 
                                                    AnyShapeStyle(LinearGradient(
                                                        colors: [Color("BykAccent"), Color("BykPrimary")],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )) : 
                                                    AnyShapeStyle(Color(.systemGray5))
                                                )
                                        )
                                        .foregroundColor(selectedCity == city ? .white : .primary)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                // Список ресторанов
                ScrollView {
                    if filteredRestaurants.isEmpty {
                        // Сообщение когда нет ресторанов
                        VStack(spacing: 24) {
                            Spacer()
                            
                            // Иконка
                            Image(systemName: "building.2")
                                .font(.system(size: 80))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color("BykAccent"), Color("BykPrimary")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .opacity(0.6)
                            
                            // Текст сообщения
                            VStack(spacing: 12) {
                                if let selectedCity = selectedCity {
                                    Text("Мы еще не успели построить ресторан \(declineCity(selectedCity))")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.primary)
                                    
                                    Text("Скоро мы откроемся в вашем городе!")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                } else {
                                    Text("Рестораны не найдены")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.primary)
                                    
                                    Text("Попробуйте изменить фильтры поиска")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                            }
                            .padding(.horizontal, 32)
                            
                            // Кнопка сброса фильтров
                            Button(action: {
                                HapticManager.shared.buttonPress()
                                selectedCity = nil
                                selectedBrand = nil
                                searchText = ""
                            }) {
                                Text("Показать все рестораны")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color("BykAccent"), Color("BykPrimary")],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                    )
                            }
                            
                            Spacer()
                        }
                        .padding(32)
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredRestaurants, id: \.id) { restaurant in
                                RestaurantCard(
                                    restaurant: restaurant,
                                    onTap: {
                                        selectedRestaurant = restaurant
                                    }
                                )
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle("Рестораны")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        HapticManager.shared.buttonPress()
                        showProfile = true
                    }) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color("BykAccent"), Color("BykPrimary")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
            }
        }
        .sheet(item: $selectedRestaurant) { restaurant in
            RestaurantDetailView(restaurant: restaurant)
        }
        .sheet(isPresented: $showProfile) {
            ProfileView()
        }
        .onAppear {
            HapticManager.shared.navigationTransition()
        }
    }
}

#Preview {
    RestaurantsView()
        .environmentObject(RestaurantService())
} 