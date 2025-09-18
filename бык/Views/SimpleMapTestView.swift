import SwiftUI
import WebKit

// MARK: - Простой тест без Яндекс API
struct SimpleMapTestView: View {
    @State private var testResults: [String] = []
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("🧪 Простой тест карт")
                    .font(.title2)
                    .fontWeight(.bold)
                
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        ForEach(Array(testResults.enumerated()), id: \.offset) { index, result in
                            Text("\(index + 1). \(result)")
                                .font(.system(size: 12, design: .monospaced))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                        }
                    }
                }
                .frame(maxHeight: 200)
                .background(Color.black.opacity(0.05))
                .cornerRadius(8)
                
                // Простая HTML карта без внешних зависимостей
                SimpleWebView { message in
                    addResult(message)
                }
                .frame(height: 250)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                
                Spacer()
                
                Button("Очистить результаты") {
                    testResults.removeAll()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(8)
            }
            .padding()
            .navigationTitle("Тест WebView")
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
            addResult("🚀 Запуск простого теста")
        }
    }
    
    private func addResult(_ message: String) {
        let timestamp = DateFormatter.shortTime.string(from: Date())
        testResults.append("[\(timestamp)] \(message)")
    }
}

// MARK: - Простой WebView без внешних API
struct SimpleWebView: UIViewRepresentable {
    let onMessage: (String) -> Void
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        
        let contentController = webView.configuration.userContentController
        contentController.add(context.coordinator, name: "testMessage")
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let htmlContent = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Simple Test</title>
            <style>
                body, html { 
                    margin: 0; 
                    padding: 0; 
                    height: 100%; 
                    font-family: -apple-system, BlinkMacSystemFont, sans-serif;
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    color: white;
                    text-align: center;
                }
                .container {
                    max-width: 300px;
                    padding: 20px;
                }
                button {
                    background: rgba(255,255,255,0.2);
                    border: 1px solid rgba(255,255,255,0.3);
                    color: white;
                    padding: 10px 20px;
                    border-radius: 8px;
                    cursor: pointer;
                    margin: 10px;
                    font-size: 14px;
                }
                button:hover {
                    background: rgba(255,255,255,0.3);
                }
                .status {
                    margin: 20px 0;
                    padding: 10px;
                    background: rgba(0,0,0,0.2);
                    border-radius: 6px;
                    font-size: 12px;
                }
            </style>
        </head>
        <body>
            <div class="container">
                <h2>📱 WebView Тест</h2>
                <p>Если видишь это - базовый WebView работает!</p>
                
                <div class="status" id="status">Статус: Загружен ✅</div>
                
                <button onclick="testBasic()">Базовый тест</button>
                <button onclick="testNetwork()">Тест сети</button>
                <button onclick="testYandex()">Тест Яндекс</button>
            </div>
            
            <script>
                function log(message) {
                    console.log(message);
                    document.getElementById('status').textContent = 'Статус: ' + message;
                    
                    if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.testMessage) {
                        window.webkit.messageHandlers.testMessage.postMessage(message);
                    }
                }
                
                function testBasic() {
                    log('✅ JavaScript работает нормально!');
                }
                
                function testNetwork() {
                    log('🌐 Тестирую сеть...');
                    
                    fetch('https://httpbin.org/json')
                        .then(response => response.json())
                        .then(data => {
                            log('✅ Сеть работает! Получен JSON');
                        })
                        .catch(error => {
                            log('❌ Ошибка сети: ' + error.message);
                        });
                }
                
                function testYandex() {
                    log('🗺️ Тестирую доступ к Яндекс...');
                    
                    // Создаем script элемент для загрузки Яндекс API
                    var script = document.createElement('script');
                    script.src = 'https://api-maps.yandex.ru/2.1/?apikey=b7c8becc-306b-400c-8fae-a1d18545814f&lang=ru_RU';
                    script.type = 'text/javascript';
                    
                    script.onload = function() {
                        log('✅ Яндекс API загрузился успешно!');
                        
                        // Проверяем доступность ymaps
                        setTimeout(function() {
                            if (typeof ymaps !== 'undefined') {
                                log('✅ ymaps объект доступен!');
                            } else {
                                log('❌ ymaps объект недоступен');
                            }
                        }, 1000);
                    };
                    
                    script.onerror = function() {
                        log('❌ Не удалось загрузить Яндекс API');
                    };
                    
                    document.head.appendChild(script);
                }
                
                // Автоматический запуск при загрузке
                window.onload = function() {
                    log('🚀 HTML загружен, JavaScript активен');
                };
                
                // Обработка ошибок
                window.onerror = function(msg, url, line, col, error) {
                    log('💥 JS Ошибка: ' + msg + ' (строка: ' + line + ')');
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
        var parent: SimpleWebView
        
        init(_ parent: SimpleWebView) {
            self.parent = parent
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "testMessage", let messageBody = message.body as? String {
                DispatchQueue.main.async {
                    self.parent.onMessage(messageBody)
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



#Preview {
    SimpleMapTestView()
}