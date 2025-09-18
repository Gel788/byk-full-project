import SwiftUI
import WebKit

// MARK: - Debug Map View для диагностики
struct DebugMapView: View {
    @State private var logs: [String] = []
    @State private var mapState = "🔄 Инициализация..."
    @Environment(\.dismiss) private var dismiss
    
    private var statusColor: Color {
        if mapState.contains("✅") {
            return .green
        } else if mapState.contains("❌") {
            return .red
        } else {
            return .orange
        }
    }
    
    private var statusSection: some View {
        HStack {
            Text("Статус:")
                .font(.headline)
            Text(mapState)
                .font(.body)
                .foregroundColor(statusColor)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    private var logsSection: some View {
        ScrollView {
            logsList
        }
        .frame(maxHeight: 200)
        .background(Color.black.opacity(0.05))
        .cornerRadius(8)
    }
    
    private var logsList: some View {
        LazyVStack(alignment: .leading, spacing: 4) {
            ForEach(Array(logs.enumerated()), id: \.offset) { index, log in
                logItem(index: index, log: log)
            }
        }
    }
    
    private func logItem(index: Int, log: String) -> some View {
        Text("\(index + 1). \(log)")
            .font(.system(size: 12, design: .monospaced))
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
    }
    
    private var mapSection: some View {
        DebugYandexMapView { message in
            handleMapMessage(message)
        }
        .frame(height: 300)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var controlButtons: some View {
        HStack(spacing: 16) {
            Button("Очистить логи") {
                logs.removeAll()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(8)
            
            Button("Перезагрузить") {
                logs.removeAll()
                mapState = "🔄 Перезагрузка..."
                addLog("Принудительная перезагрузка карты")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.orange.opacity(0.1))
            .foregroundColor(.orange)
            .cornerRadius(8)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                statusSection
                logsSection
                mapSection
                Spacer()
                controlButtons
            }
            .padding()
            .navigationTitle("Диагностика карт")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            addLog("🚀 Запуск диагностики карт")
            addLog("📍 API ключ: b7c8becc-306b-400c-8fae-a1d18545814f")
        }
    }
    
    private func handleMapMessage(_ message: String) {
        addLog(message)
        if message.contains("loaded") {
            mapState = "✅ Карта загружена"
        } else if message.contains("error") || message.contains("timeout") {
            mapState = "❌ Ошибка: \(message)"
        } else if message.contains("ready") {
            mapState = "🔄 API готов, создание карты..."
        } else if message.contains("creating") {
            mapState = "🗺️ Создание карты..."
        }
    }
    
    private func addLog(_ message: String) {
        let timestamp = DateFormatter.shortTime.string(from: Date())
        logs.append("[\(timestamp)] \(message)")
    }
}

// MARK: - Debug Yandex Map
struct DebugYandexMapView: UIViewRepresentable {
    let onMessage: (String) -> Void
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        
        let contentController = webView.configuration.userContentController
        contentController.add(context.coordinator, name: "debugLog")
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let htmlContent = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Debug Map</title>
            <style>
                body, html { 
                    margin: 0; 
                    padding: 0; 
                    height: 100%; 
                    font-family: -apple-system, BlinkMacSystemFont, sans-serif;
                    background: #f0f0f0;
                }
                #map { 
                    width: 100%; 
                    height: 100%; 
                    border: 2px solid #ddd;
                }
                .debug-info {
                    position: absolute;
                    top: 10px;
                    left: 10px;
                    background: rgba(0,0,0,0.8);
                    color: white;
                    padding: 8px 12px;
                    border-radius: 6px;
                    font-size: 12px;
                    z-index: 1000;
                    max-width: 250px;
                    word-wrap: break-word;
                }
            </style>
        </head>
        <body>
            <div class="debug-info" id="debug">Загрузка...</div>
            <div id="map"></div>
            
            <!-- Загружаем Яндекс API -->
            <script src="https://api-maps.yandex.ru/2.1/?apikey=b7c8becc-306b-400c-8fae-a1d18545814f&lang=ru_RU" 
                    type="text/javascript"></script>
            
            <script>
                function log(message) {
                    console.log(message);
                    document.getElementById('debug').textContent = message;
                    
                    if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.debugLog) {
                        window.webkit.messageHandlers.debugLog.postMessage(message);
                    }
                }
                
                // Проверяем доступность API
                log('🔍 Проверка загрузки Яндекс API...');
                
                // Таймаут для всего процесса
                var globalTimeout = setTimeout(function() {
                    log('⏰ ТАЙМАУТ: Карта не загрузилась за 15 секунд');
                }, 15000);
                
                // Проверяем каждые 100мс доступность ymaps
                var checkAttempts = 0;
                var maxAttempts = 100; // 10 секунд
                
                var apiCheck = setInterval(function() {
                    checkAttempts++;
                    log('🔄 Попытка ' + checkAttempts + '/' + maxAttempts + ': проверка ymaps...');
                    
                    if (typeof ymaps !== 'undefined') {
                        clearInterval(apiCheck);
                        clearTimeout(globalTimeout);
                        log('✅ Яндекс API загружен! Версия: ' + (ymaps.version || 'неизвестно'));
                        initMap();
                    } else if (checkAttempts >= maxAttempts) {
                        clearInterval(apiCheck);
                        log('❌ ОШИБКА: ymaps недоступен после ' + maxAttempts + ' попыток');
                    }
                }, 100);
                
                function initMap() {
                    log('🗺️ Инициализация карты...');
                    
                    try {
                        ymaps.ready(function() {
                            log('🎯 ymaps.ready() выполнен успешно');
                            
                            try {
                                var map = new ymaps.Map('map', {
                                    center: [55.7558, 37.6176], // Москва
                                    zoom: 10,
                                    controls: ['zoomControl']
                                });
                                
                                log('🎉 Карта создана успешно!');
                                
                                // Добавляем тестовую метку
                                var placemark = new ymaps.Placemark([55.7558, 37.6176], {
                                    balloonContent: '🎯 Тестовая метка'
                                });
                                map.geoObjects.add(placemark);
                                
                                log('📍 Метка добавлена');
                                
                                // Успех!
                                setTimeout(function() {
                                    document.getElementById('debug').style.display = 'none';
                                }, 3000);
                                
                            } catch (mapError) {
                                log('❌ Ошибка создания карты: ' + mapError.message);
                            }
                        });
                    } catch (readyError) {
                        log('❌ Ошибка ymaps.ready: ' + readyError.message);
                    }
                }
                
                // Логируем ошибки окна
                window.onerror = function(msg, url, line, col, error) {
                    log('💥 JS Error: ' + msg + ' (line: ' + line + ')');
                };
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
        var parent: DebugYandexMapView
        
        init(_ parent: DebugYandexMapView) {
            self.parent = parent
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "debugLog", let logMessage = message.body as? String {
                DispatchQueue.main.async {
                    self.parent.onMessage(logMessage)
                }
            }
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.onMessage("❌ WebView ошибка загрузки: \(error.localizedDescription)")
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.onMessage("❌ WebView ошибка навигации: \(error.localizedDescription)")
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.onMessage("✅ WebView загрузился успешно")
        }
    }
}

extension DateFormatter {
    static let shortTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
}

#Preview {
    DebugMapView()
}