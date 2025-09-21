import SwiftUI

struct RestaurantsView: View {
    @StateObject private var viewModel = RestaurantsViewModel()
    @State private var selectedRestaurant: Restaurant?
    @State private var showProfile = false
    
    private var filteredRestaurants: [Restaurant] {
        return viewModel.filteredRestaurants
    }
    
    private var availableCities: [String] {
        return viewModel.cities
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
        case "ижевск":
            return "Ижевске"
        case "барнаул":
            return "Барнауле"
        case "ульяновск":
            return "Ульяновске"
        case "владивосток":
            return "Владивостоке"
        case "ярославль":
            return "Ярославле"
        case "хабаровск":
            return "Хабаровске"
        case "махачкала":
            return "Махачкале"
        case "томск":
            return "Томске"
        case "оренбург":
            return "Оренбурге"
        case "кемерово":
            return "Кемерово"
        case "рязань":
            return "Рязани"
        case "астрахань":
            return "Астрахани"
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
        case "тамбов":
            return "Тамбове"
        case "стерлитамак":
            return "Стерлитамаке"
        case "грозный":
            return "Грозном"
        case "якутск":
            return "Якутске"
        case "кострома":
            return "Костроме"
        case "комсомольск-на-амуре":
            return "Комсомольске-на-Амуре"
        case "петрозаводск":
            return "Петрозаводске"
        case "таганрог":
            return "Таганроге"
        case "нижневартовск":
            return "Нижневартовске"
        case "йошкар-ола":
            return "Йошкар-Оле"
        case "братск":
            return "Братске"
        case "новороссийск":
            return "Новороссийске"
        case "шахты":
            return "Шахтах"
        case "дзержинск":
            return "Дзержинске"
        case "орск":
            return "Орске"
        case "ангарск":
            return "Ангарске"
        case "благовещенск":
            return "Благовещенске"
        case "прокопьевск":
            return "Прокопьевске"
        case "химки":
            return "Химках"
        case "псков":
            return "Пскове"
        case "бийск":
            return "Бийске"
        case "энгельс":
            return "Энгельсе"
        case "рыбинск":
            return "Рыбинске"
        case "балашиха":
            return "Балашихе"
        case "северодвинск":
            return "Северодвинске"
        case "армавир":
            return "Армавире"
        case "подольск":
            return "Подольске"
        case "королёв":
            return "Королёве"
        case "сыктывкар":
            return "Сыктывкаре"
        case "нижнекамск":
            return "Нижнекамске"
        case "шахтинск":
            return "Шахтинске"
        case "мытищи":
            return "Мытищах"
        case "ялта":
            return "Ялте"
        case "балаково":
            return "Балаково"
        case "электросталь":
            return "Электростали"
        case "альметьевск":
            return "Альметьевске"
        case "железнодорожный":
            return "Железнодорожном"
        case "керчь":
            return "Керчи"
        case "каменск-уральский":
            return "Каменске-Уральском"
        case "ачинск":
            return "Ачинске"
        case "ессентуки":
            return "Ессентуках"
        case "новочеркасск":
            return "Новочеркасске"
        case "нефтеюганск":
            return "Нефтеюганске"
        case "первоуральск":
            return "Первоуральске"
        case "железногорск":
            return "Железногорске"
        case "пятигорск":
            return "Пятигорске"
        case "серпухов":
            return "Серпухове"
        case "оренбург":
            return "Оренбурге"
        case "одинцово":
            return "Одинцово"
        case "камышин":
            return "Камышине"
        case "мурманск":
            return "Мурманске"
        case "кызыл":
            return "Кызыле"
        case "октябрьский":
            return "Октябрьском"
        case "дмитров":
            return "Дмитрове"
        case "невинномысск":
            return "Невинномысске"
        case "пушкино":
            return "Пушкино"
        case "каспийск":
            return "Каспийске"
        case "елец":
            return "Ельце"
        case "хасавюрт":
            return "Хасавюрте"
        case "нальчик":
            return "Нальчике"
        case "долгопрудный":
            return "Долгопрудном"
        case "жуковский":
            return "Жуковском"
        case "реутов":
            return "Реутове"
        case "балашиха":
            return "Балашихе"
        case "химки":
            return "Химках"
        case "подольск":
            return "Подольске"
        case "королёв":
            return "Королёве"
        case "мытищи":
            return "Мытищах"
        case "люберцы":
            return "Люберцах"
        case "электросталь":
            return "Электростали"
        case "житомир":
            return "Житомире"
        case "днепропетровск":
            return "Днепропетровске"
        case "донецк":
            return "Донецке"
        case "харьков":
            return "Харькове"
        case "киев":
            return "Киеве"
        case "одесса":
            return "Одессе"
        case "запорожье":
            return "Запорожье"
        case "львов":
            return "Львове"
        case "кривой рог":
            return "Кривом Роге"
        case "николаев":
            return "Николаеве"
        case "мариуполь":
            return "Мариуполе"
        case "луганск":
            return "Луганске"
        case "макеевка":
            return "Макеевке"
        case "винница":
            return "Виннице"
        case "херсон":
            return "Херсоне"
        case "полтава":
            return "Полтаве"
        case "чернигов":
            return "Чернигове"
        case "черкассы":
            return "Черкассах"
        case "сумы":
            return "Сумах"
        case "житомир":
            return "Житомире"
        case "хмельницкий":
            return "Хмельницком"
        case "черновцы":
            return "Черновцах"
        case "ровно":
            return "Ровно"
        case "кировоград":
            return "Кировограде"
        case "днепродзержинск":
            return "Днепродзержинске"
        case "кременчуг":
            return "Кременчуге"
        case "тернополь":
            return "Тернополе"
        case "ивано-франковск":
            return "Ивано-Франковске"
        case "луцк":
            return "Луцке"
        case "белая церковь":
            return "Белой Церкви"
        case "краматорск":
            return "Краматорске"
        case "мелитополь":
            return "Мелитополе"
        case "керчь":
            return "Керчи"
        case "северодонецк":
            return "Северодонецке"
        case "кременчуг":
            return "Кременчуге"
        case "алчевск":
            return "Алчевске"
        case "павлоград":
            return "Павлограде"
        case "усть-каменогорск":
            return "Усть-Каменогорске"
        case "лисичанск":
            return "Лисичанске"
        case "евпатория":
            return "Евпатории"
        case "енисейск":
            return "Енисейске"
        case "константиновка":
            return "Константиновке"
        case "красный луч":
            return "Красном Луче"
        case "стаханов":
            return "Стаханове"
        case "славянск":
            return "Славянске"
        case "дружковка":
            return "Дружковке"
        case "коломыя":
            return "Коломые"
        case "энгельс":
            return "Энгельсе"
        case "шахтёрск":
            return "Шахтёрске"
        case "измаил":
            return "Измаиле"
        case "артёмовск":
            return "Артёмовске"
        case "усть-илимск":
            return "Усть-Илимске"
        case "снежное":
            return "Снежном"
        case "белгород-днестровский":
            return "Белгороде-Днестровском"
        case "кадиевка":
            return "Кадиевке"
        case "макеевка":
            return "Макеевке"
        case "горловка":
            return "Горловке"
        case "красноармейск":
            return "Красноармейске"
        case "свердловск":
            return "Свердловске"
        case "стаханов":
            return "Стаханове"
        case "славянск":
            return "Славянске"
        case "дружковка":
            return "Дружковке"
        case "коломыя":
            return "Коломые"
        case "энгельс":
            return "Энгельсе"
        case "шахтёрск":
            return "Шахтёрске"
        case "измаил":
            return "Измаиле"
        case "артёмовск":
            return "Артёмовске"
        case "усть-илимск":
            return "Усть-Илимске"
        case "снежное":
            return "Снежном"
        case "белгород-днестровский":
            return "Белгороде-Днестровском"
        case "кадиевка":
            return "Кадиевке"
        default:
            // Для неизвестных городов добавляем "в" в начало
            return "в \(city)"
        }
    }
    
    private func toggleFavorite(_ restaurant: Restaurant) {
        viewModel.toggleFavorite(restaurantId: restaurant.id)
        
        // Haptic feedback
        if viewModel.isFavorite(restaurantId: restaurant.id) {
            HapticManager.shared.successPattern()
        } else {
            HapticManager.shared.warningPattern()
        }
    }
    
    @MainActor
    private func refreshData() async {
        await viewModel.loadData()
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Поиск и фильтры
                RestaurantSearchAndFilters(viewModel: viewModel)
                
                // Список ресторанов
                ScrollView {
                    if filteredRestaurants.isEmpty {
                        // Сообщение когда нет ресторанов
                        VStack(spacing: 24) {
                            Spacer()
                            
                            // Иконка
                            Image(systemName: "fork.knife")
                                .font(.system(size: 80))
                                .foregroundColor(.secondary)
                                .opacity(0.6)
                            
                            // Текст сообщения
                            VStack(spacing: 12) {
                                if let selectedCity = viewModel.selectedCity {
                                    Text("Мы еще не успели построить ресторан \(declineCity(selectedCity))")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.primary)
                                } else if let selectedBrand = viewModel.selectedBrand {
                                    Text("Рестораны \(selectedBrand.displayName) пока не открыты")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.primary)
                                } else if !viewModel.searchText.isEmpty {
                                    Text("По запросу \"\(viewModel.searchText)\" ничего не найдено")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.primary)
                                } else {
                                    Text("Рестораны скоро откроются")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.primary)
                                }
                                
                                Text("Следите за обновлениями в разделе \"Новости\"")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
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
                                    },
                                    onFavoriteToggle: { restaurant in
                                        toggleFavorite(restaurant)
                                    },
                                    isFavorite: viewModel.isFavorite(restaurantId: restaurant.id)
                                )
                                .padding(.horizontal, 16)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                            }
                        }
                .padding(.vertical, 16)
                    }
                }
                .refreshable {
                    await refreshData()
                }
            }
            .navigationTitle("Рестораны")
                    .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showProfile = true
                    }) {
                        Image(systemName: "person.circle")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .sheet(item: $selectedRestaurant) { restaurant in
            RestaurantDetailView(restaurant: restaurant)
        }
            .sheet(isPresented: $showProfile) {
            ProfileView_Simple()
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

// MARK: - Restaurant Search and Filters Component
struct RestaurantSearchAndFilters: View {
    @ObservedObject var viewModel: RestaurantsViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Поиск
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Поиск ресторанов...", text: $viewModel.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Фильтры брендов
            RestaurantBrandFilters(viewModel: viewModel)
            
            // Фильтры городов
            RestaurantCityFilters(viewModel: viewModel)
        }
        .padding(.horizontal)
    }
}

// MARK: - Restaurant Brand Filters
struct RestaurantBrandFilters: View {
    @ObservedObject var viewModel: RestaurantsViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // Кнопка "Все"
                Button(action: {
                    HapticManager.shared.buttonPress()
                    viewModel.selectBrand(nil)
                }) {
                    Text("Все")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(viewModel.selectedBrand == nil ? 
                                    AnyShapeStyle(LinearGradient(
                                        colors: [Color("BykAccent"), Color("BykPrimary")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )) : 
                                    AnyShapeStyle(Color(.systemGray5))
                                )
                        )
                        .foregroundColor(viewModel.selectedBrand == nil ? .white : .primary)
                }
                
                // Фильтры по брендам
                ForEach(viewModel.brands, id: \.self) { brand in
                    let brandColors = Colors.brandColors(for: brand)
                    Button(action: {
                        HapticManager.shared.buttonPress()
                        viewModel.selectBrand(brand)
                    }) {
                        Text(brand.displayName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(viewModel.selectedBrand == brand ? 
                                        AnyShapeStyle(LinearGradient(
                                            colors: [brandColors.accent, brandColors.primary],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )) : 
                                        AnyShapeStyle(Color(.systemGray5))
                                    )
                            )
                            .foregroundColor(viewModel.selectedBrand == brand ? .white : .primary)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Restaurant City Filters
struct RestaurantCityFilters: View {
    @ObservedObject var viewModel: RestaurantsViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // Кнопка "Все города"
                Button(action: {
                    HapticManager.shared.buttonPress()
                    viewModel.selectCity(nil)
                }) {
                    Text("Все города")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(viewModel.selectedCity == nil ? 
                                    AnyShapeStyle(LinearGradient(
                                        colors: [Color("BykAccent"), Color("BykPrimary")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )) : 
                                    AnyShapeStyle(Color(.systemGray5))
                                )
                        )
                        .foregroundColor(viewModel.selectedCity == nil ? .white : .primary)
                }
                
                // Фильтры по городам
                ForEach(viewModel.cities, id: \.self) { city in
                    Button(action: {
                        HapticManager.shared.buttonPress()
                        viewModel.selectCity(city)
                    }) {
                        Text(city)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(viewModel.selectedCity == city ? 
                                        AnyShapeStyle(LinearGradient(
                                            colors: [Color("BykAccent"), Color("BykPrimary")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )) : 
                                        AnyShapeStyle(Color(.systemGray5))
                                    )
                            )
                            .foregroundColor(viewModel.selectedCity == city ? .white : .primary)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}
