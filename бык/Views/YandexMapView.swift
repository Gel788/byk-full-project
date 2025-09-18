import SwiftUI
import WebKit

struct YandexMapView: UIViewRepresentable {
    let restaurant: Restaurant
    let onMapLoaded: (() -> Void)?
    
    init(restaurant: Restaurant, onMapLoaded: (() -> Void)? = nil) {
        self.restaurant = restaurant
        self.onMapLoaded = onMapLoaded
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = true
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
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
                .restaurant-info {
                    position: absolute;
                    top: 20px;
                    left: 20px;
                    right: 20px;
                    background: rgba(255, 255, 255, 0.95);
                    backdrop-filter: blur(10px);
                    border-radius: 12px;
                    padding: 16px;
                    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
                    z-index: 1000;
                }
                .restaurant-name {
                    font-size: 18px;
                    font-weight: 600;
                    margin-bottom: 8px;
                    color: #333;
                }
                .restaurant-address {
                    font-size: 14px;
                    color: #666;
                    margin-bottom: 12px;
                }
                .restaurant-status {
                    display: inline-block;
                    padding: 4px 12px;
                    border-radius: 20px;
                    font-size: 12px;
                    font-weight: 500;
                }
                .status-open {
                    background: #e8f5e8;
                    color: #2d5a2d;
                }
                .status-closed {
                    background: #ffe8e8;
                    color: #5a2d2d;
                }
            </style>
        </head>
        <body>
            <div id="map"></div>
            <div class="restaurant-info">
                <div class="restaurant-name">\(restaurant.name)</div>
                <div class="restaurant-address">\(restaurant.address)</div>
                <div class="restaurant-status \(restaurant.workingHours.isOpen() ? "status-open" : "status-closed")">
                    \(restaurant.workingHours.isOpen() ? "Открыто" : "Закрыто")
                </div>
            </div>
            
            <script>
                ymaps.ready(function () {
                    var myMap = new ymaps.Map('map', {
                        center: [\(restaurant.location.latitude), \(restaurant.location.longitude)],
                        zoom: 16,
                        controls: ['zoomControl', 'fullscreenControl']
                    });
                    
                    // Добавляем метку ресторана
                    var myPlacemark = new ymaps.Placemark([\(restaurant.location.latitude), \(restaurant.location.longitude)], {
                        balloonContent: '\(restaurant.name)',
                        hintContent: '\(restaurant.address)'
                    }, {
                        preset: 'islands#redDotIcon',
                        iconColor: '#ff0000'
                    });
                    
                    myMap.geoObjects.add(myPlacemark);
                    
                    // Открываем баллун при загрузке
                    myPlacemark.balloon.open();
                    
                    // Уведомляем Swift о загрузке карты
                    window.webkit.messageHandlers.mapLoaded.postMessage('loaded');
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
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: YandexMapView
        
        init(_ parent: YandexMapView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.onMapLoaded?()
        }
    }
}

// MARK: - YandexMapView с кнопками действий
struct YandexMapViewWithActions: View {
    let restaurant: Restaurant
    @Environment(\.dismiss) private var dismiss
    @State private var mapLoaded = false
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color) {
        Colors.brandColors(for: restaurant.brand)
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                YandexMapView(restaurant: restaurant) {
                    mapLoaded = true
                }
                .ignoresSafeArea(edges: .top)
                
                // Кнопки действий
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Button(action: openInYandexMaps) {
                            HStack {
                                Image(systemName: "car.fill")
                                Text("Маршрут")
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    colors: [brandColors.accent, brandColors.primary],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: brandColors.accent.opacity(0.4), radius: 8, x: 0, y: 4)
                            .cornerRadius(12)
                        }
                        
                        Button(action: shareLocation) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Поделиться")
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(brandColors.accent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(brandColors.accent.opacity(0.3), lineWidth: 1.5)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.ultraThinMaterial)
                                    )
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .opacity(mapLoaded ? 1 : 0)
                .animation(.easeInOut(duration: 0.3), value: mapLoaded)
            }
            .navigationTitle(restaurant.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func openInYandexMaps() {
        HapticManager.shared.buttonPress()
        
        if let url = YandexMapsConfig.routeURL(to: (restaurant.location.latitude, restaurant.location.longitude), name: restaurant.name) {
            if YandexMapsConfig.isYandexMapsInstalled {
                UIApplication.shared.open(url)
            } else {
                // Fallback на веб-версию Яндекс Карт
                if let webUrl = YandexMapsConfig.webURL(for: (restaurant.location.latitude, restaurant.location.longitude), name: restaurant.name) {
                    UIApplication.shared.open(webUrl)
                }
            }
        }
    }
    
    private func shareLocation() {
        HapticManager.shared.buttonPress()
        
        let locationString = YandexMapsConfig.shareString(for: (restaurant.location.latitude, restaurant.location.longitude), name: restaurant.name, address: restaurant.address)
        let activityVC = UIActivityViewController(activityItems: [locationString], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

#Preview {
    YandexMapViewWithActions(restaurant: .mock)
} 