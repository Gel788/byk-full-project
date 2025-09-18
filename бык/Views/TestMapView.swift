import SwiftUI
import WebKit

// MARK: - Simple Test Map View
struct TestMapView: View {
    @State private var mapStatus = "Загрузка..."
    @State private var showError = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Тест Яндекс карт")
                        .font(.title)
                        .foregroundColor(.white)
                    
                    Text(mapStatus)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                    
                    if showError {
                        Button("Перезагрузить") {
                            showError = false
                            mapStatus = "Перезагрузка..."
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    // Простая карта
                    SimpleYandexMapView { status in
                        mapStatus = status
                        if status.contains("Ошибка") {
                            showError = true
                        }
                    }
                    .frame(height: 300)
                    .cornerRadius(20)
                    .padding()
                }
            }
            .navigationTitle("Тест карты")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        // Placeholder for dismiss
                    } 
                }
            }
        }
    }
}

// MARK: - Simple Yandex Map
struct SimpleYandexMapView: UIViewRepresentable {
    let onStatusChange: (String) -> Void
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        let contentController = webView.configuration.userContentController
        contentController.add(context.coordinator, name: "mapStatus")
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let htmlContent = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Test Map</title>
            <script src="https://api-maps.yandex.ru/2.1/?apikey=b7c8becc-306b-400c-8fae-a1d18545814f&lang=ru_RU" type="text/javascript"></script>
            <style>
                body, html { margin: 0; padding: 0; height: 100%; }
                #map { width: 100%; height: 100%; }
                .status { 
                    position: absolute; 
                    top: 10px; 
                    left: 10px; 
                    background: rgba(0,0,0,0.8); 
                    color: white; 
                    padding: 10px; 
                    border-radius: 5px;
                    font-family: Arial, sans-serif;
                    z-index: 1000;
                }
            </style>
        </head>
        <body>
            <div class="status" id="status">Загрузка API...</div>
            <div id="map"></div>
            
            <script>
                function updateStatus(message) {
                    document.getElementById('status').textContent = message;
                    if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.mapStatus) {
                        window.webkit.messageHandlers.mapStatus.postMessage(message);
                    }
                }
                
                // Таймаут для проверки загрузки API
                var apiTimeout = setTimeout(function() {
                    updateStatus('Ошибка: API не загрузился за 15 секунд');
                }, 15000);
                
                // Проверяем загрузку Яндекс API
                if (typeof ymaps === 'undefined') {
                    updateStatus('Ждем загрузки Яндекс API...');
                    
                    // Проверяем каждые 500мс
                    var checkInterval = setInterval(function() {
                        if (typeof ymaps !== 'undefined') {
                            clearInterval(checkInterval);
                            clearTimeout(apiTimeout);
                            initializeMap();
                        }
                    }, 500);
                } else {
                    clearTimeout(apiTimeout);
                    initializeMap();
                }
                
                function initializeMap() {
                    updateStatus('API загружен. Инициализация карты...');
                    
                    ymaps.ready(function () {
                        updateStatus('Создание карты...');
                        
                        try {
                            var myMap = new ymaps.Map('map', {
                                center: [55.7558, 37.6176], // Москва
                                zoom: 10,
                                controls: ['zoomControl']
                            });
                            
                            // Добавляем тестовую метку
                            var placemark = new ymaps.Placemark([55.7558, 37.6176], {
                                balloonContent: 'Тестовая метка в Москве'
                            });
                            myMap.geoObjects.add(placemark);
                            
                            updateStatus('✅ Карта успешно загружена!');
                            
                            // Скрываем статус через 3 секунды
                            setTimeout(function() {
                                document.getElementById('status').style.display = 'none';
                            }, 3000);
                            
                        } catch (error) {
                            updateStatus('Ошибка создания карты: ' + error.message);
                        }
                    });
                }
            </script>
        </body>
        </html>
        """
        
        webView.loadHTMLString(htmlContent, baseURL: nil)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKScriptMessageHandler {
        var parent: SimpleYandexMapView
        
        init(_ parent: SimpleYandexMapView) {
            self.parent = parent
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "mapStatus", let status = message.body as? String {
                DispatchQueue.main.async {
                    self.parent.onStatusChange(status)
                }
            }
        }
    }
}

#Preview {
    TestMapView()
}