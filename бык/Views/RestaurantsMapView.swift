import SwiftUI
import WebKit
import Foundation

struct RestaurantsMapView: View {
    @EnvironmentObject private var restaurantService: RestaurantService
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedCity: String? = nil
    @State private var selectedBrands: Set<Restaurant.Brand> = []
    @State private var showingFilters = false
    @State private var mapLoaded = false
    @State private var mapError = false
    @State private var selectedRestaurant: Restaurant? = nil
    
    private var availableCities: [String] {
        let cities = restaurantService.restaurants.map { $0.city }
        return Array(Set(cities)).sorted()
    }
    
    private var availableBrands: [Restaurant.Brand] {
        return Restaurant.Brand.allCases
    }
    
    private var filteredRestaurants: [Restaurant] {
        var restaurants = restaurantService.restaurants
        
        // Фильтр по городу
        if let city = selectedCity {
            restaurants = restaurants.filter { $0.city == city }
        }
        
        // Фильтр по брендам
        if !selectedBrands.isEmpty {
            restaurants = restaurants.filter { selectedBrands.contains($0.brand) }
        }
        
        return restaurants
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Основная карта
                ZStack {
                    RestaurantsYandexMapView(
                        restaurants: filteredRestaurants,
                        onRestaurantSelected: { restaurant in
                            selectedRestaurant = restaurant
                        },
                        onMapLoaded: {
                            mapLoaded = true
                            mapError = false
                        },
                        onMapError: {
                            mapError = true
                            mapLoaded = false
                        }
                    )
                    .ignoresSafeArea(edges: .top)
                    
                    // Состояния загрузки и ошибки
                    if !mapLoaded && !mapError {
                        MapLoadingView()
                            .ignoresSafeArea()
                    }
                    
                    if mapError {
                        MapErrorView {
                            mapError = false
                            mapLoaded = false
                            // Принудительная перезагрузка WebView
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                // Карта перезагрузится автоматически через updateUIView
                            }
                        }
                        .ignoresSafeArea()
                    }
                }
                
                // Панель фильтров
                VStack {
                    MapFiltersPanel(
                        selectedCity: $selectedCity,
                        selectedBrands: $selectedBrands,
                        availableCities: availableCities,
                        availableBrands: availableBrands,
                        restaurantsCount: filteredRestaurants.count,
                        showingFilters: $showingFilters
                    )
                    .opacity(mapLoaded ? 1 : 0)
                    .animation(.easeInOut(duration: 0.3), value: mapLoaded)
                    
                    Spacer()
                }
                
                // Информационная карточка выбранного ресторана
                if let restaurant = selectedRestaurant {
                    VStack {
                        Spacer()
                        
                        RestaurantMapCard(
                            restaurant: restaurant,
                            onClose: { selectedRestaurant = nil },
                            onViewDetails: { selectedRestaurant = nil }
                        )
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: selectedRestaurant)
                }
            }
            .navigationTitle("Рестораны на карте")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { 
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            showingFilters.toggle() 
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                                .font(.system(size: 20))
                            Text("\(filteredRestaurants.count)")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                }
            }
            .sheet(isPresented: $showingFilters) {
                MapFiltersSheet(
                    selectedCity: $selectedCity,
                    selectedBrands: $selectedBrands,
                    availableCities: availableCities,
                    availableBrands: availableBrands
                )
            }
            .fullScreenCover(item: $selectedRestaurant) { restaurant in
                RestaurantDetailView(restaurant: restaurant)
            }
        }
        .background(Color.black)
    }
}

// MARK: - Yandex Map with Multiple Restaurants
struct RestaurantsYandexMapView: UIViewRepresentable {
    let restaurants: [Restaurant]
    let onRestaurantSelected: (Restaurant) -> Void
    let onMapLoaded: () -> Void
    let onMapError: () -> Void
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = true
        
        // Добавляем обработчик для выбора ресторана
        let contentController = webView.configuration.userContentController
        contentController.add(context.coordinator, name: "restaurantSelected")
        contentController.add(context.coordinator, name: "mapLoaded")
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        context.coordinator.parent = self
        
        // Если произошла ошибка, перезагружаем контент
        if context.coordinator.needsReload {
            context.coordinator.needsReload = false
            loadMapContent(webView: webView)
            return
        }
        
        // Обновляем только если изменились рестораны
        let currentRestaurantsIds = restaurants.map { $0.id }
        if currentRestaurantsIds != context.coordinator.lastRestaurantsIds {
            context.coordinator.lastRestaurantsIds = currentRestaurantsIds
            loadMapContent(webView: webView)
        }
    }
    
    private func loadMapContent(webView: WKWebView) {
        
        let restaurantsJS = restaurants.map { restaurant in
            """
            {
                id: '\(restaurant.id)',
                name: '\(restaurant.name.replacingOccurrences(of: "'", with: "\\'"))',
                address: '\(restaurant.address.replacingOccurrences(of: "'", with: "\\'"))',
                latitude: \(restaurant.location.latitude),
                longitude: \(restaurant.location.longitude),
                brand: '\(restaurant.brand.rawValue)',
                rating: \(restaurant.rating),
                cuisine: '\(restaurant.cuisine)',
                isOpen: \(restaurant.workingHours.isOpen())
            }
            """
        }.joined(separator: ",\n")
        
        let htmlContent = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <script src="https://api-maps.yandex.ru/2.1/?apikey=\(YandexMapsConfig.apiKey)&lang=ru_RU" type="text/javascript"></script>
            <style>
                body, html {
                    margin: 0;
                    padding: 0;
                    height: 100%;
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                }
                #map {
                    width: 100%;
                    height: 100%;
                }
                .restaurant-balloon {
                    padding: 12px;
                    min-width: 200px;
                }
                .restaurant-name {
                    font-size: 16px;
                    font-weight: 600;
                    margin-bottom: 6px;
                    color: #333;
                }
                .restaurant-info {
                    font-size: 13px;
                    color: #666;
                    margin-bottom: 4px;
                }
                .restaurant-status {
                    display: inline-block;
                    padding: 2px 8px;
                    border-radius: 10px;
                    font-size: 11px;
                    font-weight: 500;
                    margin-top: 6px;
                }
                .status-open {
                    background: #e8f5e8;
                    color: #2d5a2d;
                }
                .status-closed {
                    background: #ffe8e8;
                    color: #5a2d2d;
                }
                .brand-badge {
                    display: inline-block;
                    padding: 2px 6px;
                    border-radius: 8px;
                    font-size: 10px;
                    font-weight: 600;
                    margin-bottom: 4px;
                }
                .brand-byk { background: #8B4513; color: white; }
                .brand-pivo { background: #FFD700; color: #333; }
                .brand-mosca { background: #DC143C; color: white; }
                .brand-georgia { background: #800080; color: white; }
                .view-details-btn {
                    background: #007AFF;
                    color: white;
                    border: none;
                    padding: 6px 12px;
                    border-radius: 6px;
                    font-size: 12px;
                    font-weight: 500;
                    cursor: pointer;
                    margin-top: 8px;
                }
            </style>
        </head>
        <body>
            <div id="map"></div>
            
            <script>
                const restaurants = [
                    \(restaurantsJS)
                ];
                
                function getBrandColor(brand) {
                    switch(brand) {
                        case 'theByk': return '#8B4513';
                        case 'thePivo': return '#FFD700';
                        case 'mosca': return '#DC143C';
                        case 'theGeorgia': return '#800080';
                        default: return '#FF0000';
                    }
                }
                
                function getBrandClass(brand) {
                    switch(brand) {
                        case 'theByk': return 'brand-byk';
                        case 'thePivo': return 'brand-pivo';
                        case 'mosca': return 'brand-mosca';
                        case 'theGeorgia': return 'brand-georgia';
                        default: return 'brand-byk';
                    }
                }
                
                function getBrandName(brand) {
                    switch(brand) {
                        case 'theByk': return 'THE БЫК';
                        case 'thePivo': return 'THE ПИВО';
                        case 'mosca': return 'MOSCA';
                        case 'theGeorgia': return 'THE ГРУЗИЯ';
                        default: return 'РЕСТОРАН';
                    }
                }
                
                // Простая проверка загрузки API и таймаут
                var loadingTimeout = setTimeout(function() {
                    console.log('⚠️ Map loading timeout after 8 seconds');
                    if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.mapLoaded) {
                        window.webkit.messageHandlers.mapLoaded.postMessage('error: timeout');
                    }
                }, 8000);
                
                // Ждем готовности Яндекс карт
                ymaps.ready(function () {
                    console.log('✅ Yandex Maps API ready!');
                    clearTimeout(loadingTimeout);
                    
                    try {
                        
                        const centerLat = restaurants.length > 0 ? 
                            restaurants.reduce((sum, r) => sum + r.latitude, 0) / restaurants.length : 55.7558;
                        const centerLng = restaurants.length > 0 ? 
                            restaurants.reduce((sum, r) => sum + r.longitude, 0) / restaurants.length : 37.6176;
                        
                        console.log('🗺️ Creating map with center:', centerLat, centerLng);
                        
                        const myMap = new ymaps.Map('map', {
                            center: [centerLat, centerLng],
                            zoom: restaurants.length > 1 ? 10 : 14,
                            controls: ['zoomControl', 'fullscreenControl']
                        });
                    
                    // Создаем кластеризатор
                    const clusterer = new ymaps.Clusterer({
                        preset: 'islands#invertedVioletClusterIcons',
                        groupByCoordinates: false,
                        clusterDisableClickZoom: false,
                        clusterHideIconOnBalloonOpen: false,
                        geoObjectHideIconOnBalloonOpen: false
                    });
                    
                    const placemarks = restaurants.map(restaurant => {
                        const balloonContent = 
                            '<div class="restaurant-balloon">' +
                                '<div class="brand-badge ' + getBrandClass(restaurant.brand) + '">' + getBrandName(restaurant.brand) + '</div>' +
                                '<div class="restaurant-name">' + restaurant.name + '</div>' +
                                '<div class="restaurant-info">📍 ' + restaurant.address + '</div>' +
                                '<div class="restaurant-info">🍽️ ' + restaurant.cuisine + '</div>' +
                                '<div class="restaurant-info">⭐ ' + restaurant.rating + '/5</div>' +
                                '<div class="restaurant-status ' + (restaurant.isOpen ? 'status-open' : 'status-closed') + '">' +
                                    (restaurant.isOpen ? 'Открыто' : 'Закрыто') +
                                '</div>' +
                                '<button class="view-details-btn" onclick="selectRestaurant(\'' + restaurant.id + '\')">' +
                                    'Подробнее' +
                                '</button>' +
                            '</div>';
                        
                        const placemark = new ymaps.Placemark([restaurant.latitude, restaurant.longitude], {
                            balloonContent: balloonContent,
                            hintContent: restaurant.name
                        }, {
                            preset: 'islands#dotIcon',
                            iconColor: getBrandColor(restaurant.brand)
                        });
                        
                        return placemark;
                    });
                    
                    clusterer.add(placemarks);
                    myMap.geoObjects.add(clusterer);
                    
                    // Подгоняем масштаб под все точки
                    if (restaurants.length > 1) {
                        myMap.setBounds(clusterer.getBounds(), {
                            checkZoomRange: true,
                            zoomMargin: 50
                        });
                    }
                    
                            window.selectRestaurant = function(restaurantId) {
                                console.log('Restaurant selected:', restaurantId);
                                window.webkit.messageHandlers.restaurantSelected.postMessage(restaurantId);
                            };
                    
                        
                    } catch (error) {
                        console.error('💥 Error creating map:', error);
                        if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.mapLoaded) {
                            window.webkit.messageHandlers.mapLoaded.postMessage('error: ' + error.message);
                        }
                    }
                }, function(error) {
                    console.error('💥 ymaps.ready failed:', error);
                    if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.mapLoaded) {
                        window.webkit.messageHandlers.mapLoaded.postMessage('error: ymaps.ready failed');
                    }
                });
            </script>
        </body>
        </html>
        """
        
        webView.loadHTMLString(htmlContent, baseURL: nil)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: RestaurantsYandexMapView
        var needsReload = false
        var lastRestaurantsIds: [UUID] = []
        
        init(_ parent: RestaurantsYandexMapView) {
            self.parent = parent
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            DispatchQueue.main.async {
                if message.name == "restaurantSelected", let restaurantId = message.body as? String {
                    if let restaurant = self.parent.restaurants.first(where: { $0.id.uuidString == restaurantId }) {
                        self.parent.onRestaurantSelected(restaurant)
                    }
                } else if message.name == "mapLoaded" {
                    let messageBody = message.body as? String ?? ""
                    if messageBody.contains("error") || messageBody.contains("timeout") {
                        print("Map loading error: \(messageBody)")
                        self.needsReload = true
                        self.parent.onMapError()
                    } else {
                        print("Map loaded successfully")
                        self.parent.onMapLoaded()
                    }
                }
            }
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("WebView failed to load: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.parent.onMapError()
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("WebView navigation failed: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.parent.onMapError()
            }
        }
    }
}

#Preview {
    NavigationStack {
        RestaurantsMapView()
            .environmentObject(RestaurantService())
    }
}