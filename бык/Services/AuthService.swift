import Foundation
import SwiftUI
import Combine

class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published var currentUser: User?
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // Токены для API
    @Published var accessToken: String?
    @Published var refreshToken: String?
    
    private let userDefaults = UserDefaults.standard
    private let userKey = "currentUser"
    private let accessTokenKey = "accessToken"
    private let refreshTokenKey = "refreshToken"
    
    private let apiService = APIService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadUserFromStorage()
        loadTokensFromStorage()
    }
    
    // MARK: - Authentication Methods
    
    func register(with data: RegistrationData) async {
        print("🔐 AuthService: Начинаем регистрацию пользователя")
        print("  - Имя: \(data.name)")
        print("  - Телефон: \(data.phoneNumber)")
        print("  - Email: \(data.email ?? "не указан")")
        print("  - Пароль: [СКРЫТ]")
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // Создаем запрос для API
        let registerRequest = RegisterRequest(
            phoneNumber: data.phoneNumber,
            password: data.password,
            fullName: data.name,
            email: data.email
        )
        
        print("🔐 AuthService: Отправляем запрос регистрации на сервер...")
        
        do {
            // Отправляем запрос на сервер
            let response = try await withCheckedThrowingContinuation { continuation in
                apiService.register(registerRequest)
                    .sink(
                        receiveCompletion: { completion in
                            if case .failure(let error) = completion {
                                continuation.resume(throwing: error)
                            }
                        },
                        receiveValue: { response in
                            continuation.resume(returning: response)
                        }
                    )
                    .store(in: &cancellables)
            }
            
            await MainActor.run {
                if response.success, let userAPI = response.user, let token = response.token, let refreshToken = response.refreshToken {
                    // Логируем данные с сервера
                    print("AuthService: Получены данные с сервера:")
                    print("  - ID: \(userAPI.id)")
                    print("  - Phone: \(userAPI.phoneNumber)")
                    print("  - Name: \(userAPI.fullName)")
                    print("  - Email: \(userAPI.email ?? "nil")")
                    
                    // Преобразуем API модель в локальную
                    let newUser = userAPI.toLocalUser()
                    
                    // Логируем локальную модель
                    print("AuthService: Преобразовано в локальную модель:")
                    print("  - ID: \(newUser.id)")
                    print("  - Phone: \(newUser.phoneNumber)")
                    print("  - Name: \(newUser.fullName)")
                    print("  - Email: \(newUser.email)")
                    
                    // Сохраняем данные
                    self.currentUser = newUser
                    self.accessToken = token
                    self.refreshToken = refreshToken
                    self.isAuthenticated = true
                    
                    // Сохраняем в локальное хранилище
                    self.saveCurrentUser(newUser)
                    self.saveTokens(token: token, refreshToken: refreshToken)
                    
                    print("AuthService: Регистрация завершена успешно через API")
                } else {
                    self.errorMessage = response.message
                }
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                print("AuthService: Ошибка регистрации - \(error)")
                self.errorMessage = "Ошибка сети при регистрации"
                self.isLoading = false
            }
        }
    }
    
    func login(with credentials: AuthCredentials) async {
        print("🔐 AuthService: Начинаем вход пользователя")
        print("  - Телефон: \(credentials.phoneNumber)")
        print("  - Пароль: [СКРЫТ]")
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // Создаем запрос для API
        let loginRequest = LoginRequest(
            phoneNumber: credentials.phoneNumber,
            password: credentials.password
        )
        
        print("🔐 AuthService: Отправляем запрос входа на сервер...")
        
        do {
            // Отправляем запрос на сервер
            let response = try await withCheckedThrowingContinuation { continuation in
                apiService.login(loginRequest)
                    .sink(
                        receiveCompletion: { completion in
                            if case .failure(let error) = completion {
                                continuation.resume(throwing: error)
                            }
                        },
                        receiveValue: { response in
                            continuation.resume(returning: response)
                        }
                    )
                    .store(in: &cancellables)
            }
            
            await MainActor.run {
                if response.success, let userAPI = response.user, let token = response.token, let refreshToken = response.refreshToken {
                    // Преобразуем API модель в локальную
                    let user = userAPI.toLocalUser()
                    
                    // Сохраняем данные
                    self.currentUser = user
                    self.accessToken = token
                    self.refreshToken = refreshToken
                    self.isAuthenticated = true
                    
                    // Сохраняем в локальное хранилище
                    self.saveCurrentUser(user)
                    self.saveTokens(token: token, refreshToken: refreshToken)
                    
                    print("AuthService: Вход выполнен успешно через API - \(user.fullName)")
                } else {
                    self.errorMessage = response.message
                }
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                print("AuthService: Ошибка входа - \(error)")
                self.errorMessage = "Ошибка сети при входе"
                self.isLoading = false
            }
        }
    }
    
    func logout() async {
        print("🔐 AuthService: Начинаем выход пользователя")
        print("  - Текущий пользователь: \(currentUser?.fullName ?? "неизвестен")")
        print("  - Есть токен: \(accessToken != nil)")
        
        // Если есть токен, отправляем запрос на сервер
        if let token = accessToken {
            print("🔐 AuthService: Отправляем запрос выхода на сервер...")
            let logoutRequest = LogoutRequest(token: token)
            
            do {
                let response = try await withCheckedThrowingContinuation { continuation in
                    apiService.logout(logoutRequest)
                        .sink(
                            receiveCompletion: { completion in
                                if case .failure(let error) = completion {
                                    continuation.resume(throwing: error)
                                }
                            },
                            receiveValue: { response in
                                continuation.resume(returning: response)
                            }
                        )
                        .store(in: &cancellables)
                }
                
                print("🔐 AuthService: Выход выполнен через API - \(response.message)")
            } catch {
                print("🔐 AuthService: Ошибка выхода через API - \(error)")
            }
        } else {
            print("🔐 AuthService: Нет токена, пропускаем API запрос")
        }
        
        // Очищаем локальные данные
        await MainActor.run {
            print("🔐 AuthService: Очищаем локальные данные пользователя")
            currentUser = nil
            isAuthenticated = false
            accessToken = nil
            refreshToken = nil
            
            // Очищаем хранилище
            userDefaults.removeObject(forKey: userKey)
            userDefaults.removeObject(forKey: accessTokenKey)
            userDefaults.removeObject(forKey: refreshTokenKey)
            
            print("🔐 AuthService: Локальные данные и хранилище очищены")
            print("  - isAuthenticated: \(isAuthenticated)")
            print("  - currentUser: \(currentUser?.fullName ?? "nil")")
        }
    }
    
    // MARK: - User Data Methods
    
    func getCurrentUser() -> User? {
        return currentUser
    }
    
    func updateCurrentUser(_ user: User) {
        print("AuthService: Обновляем данные пользователя - \(user.fullName), \(user.email)")
        currentUser = user
        saveCurrentUser(user)
        // Также обновляем в основном хранилище
        saveUser(user)
        print("AuthService: Данные пользователя сохранены")
    }
    
    // MARK: - Storage Methods
    
    private func saveUser(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            userDefaults.set(encoded, forKey: "user_\(user.username)")
        }
    }
    
    private func getStoredUser(phoneNumber: String) -> User? {
        guard let data = userDefaults.data(forKey: "user_\(phoneNumber)"),
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            return nil
        }
        return user
    }
    
    private func savePassword(phoneNumber: String, password: String) {
        userDefaults.set(password, forKey: "password_\(phoneNumber)")
    }
    
    private func getStoredPassword(phoneNumber: String) -> String? {
        return userDefaults.string(forKey: "password_\(phoneNumber)")
    }
    
    private func loadUserFromStorage() {
        guard let data = userDefaults.data(forKey: userKey),
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            print("AuthService: Нет сохраненного пользователя")
            return
        }
        print("AuthService: Загружен пользователь из хранилища - \(user.fullName)")
        currentUser = user
        isAuthenticated = true
    }
    
    private func saveCurrentUser(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            userDefaults.set(encoded, forKey: userKey)
        }
    }
    
    // MARK: - Token Management
    
    private func loadTokensFromStorage() {
        accessToken = userDefaults.string(forKey: accessTokenKey)
        refreshToken = userDefaults.string(forKey: refreshTokenKey)
        
        // Если есть токены, считаем пользователя авторизованным
        if accessToken != nil && refreshToken != nil && currentUser != nil {
            isAuthenticated = true
        }
    }
    
    private func saveTokens(token: String, refreshToken: String) {
        userDefaults.set(token, forKey: accessTokenKey)
        userDefaults.set(refreshToken, forKey: refreshTokenKey)
    }
    
    // MARK: - Token Refresh
    
    func refreshAccessToken() async -> Bool {
        guard let refreshToken = refreshToken else {
            print("AuthService: Нет refresh токена")
            return false
        }
        
        do {
            let response = try await withCheckedThrowingContinuation { continuation in
                apiService.refreshToken(refreshToken)
                    .sink(
                        receiveCompletion: { completion in
                            if case .failure(let error) = completion {
                                continuation.resume(throwing: error)
                            }
                        },
                        receiveValue: { response in
                            continuation.resume(returning: response)
                        }
                    )
                    .store(in: &cancellables)
            }
            
            if response.success, let newToken = response.token, let newRefreshToken = response.refreshToken {
                await MainActor.run {
                    self.accessToken = newToken
                    self.refreshToken = newRefreshToken
                    self.saveTokens(token: newToken, refreshToken: newRefreshToken)
                }
                print("AuthService: Токен обновлен успешно")
                return true
            }
        } catch {
            print("AuthService: Ошибка обновления токена - \(error)")
        }
        
        return false
    }
    
    // MARK: - Profile Management
    
    func updateProfile(_ user: User) async {
        guard let token = accessToken else {
            print("AuthService: Нет токена для обновления профиля")
            return
        }
        
        // Создаем UserAPI из локального User
        let userAPI = UserAPI(
            id: user.id.uuidString,
            phoneNumber: user.username,
            fullName: user.fullName,
            email: user.email.isEmpty ? nil : user.email,
            avatar: user.avatar.isEmpty ? nil : user.avatar,
            isVerified: user.isVerified,
            followersCount: user.followersCount,
            followingCount: user.followingCount,
            postsCount: user.postsCount,
            createdAt: ISO8601DateFormatter().string(from: user.createdAt),
            updatedAt: ISO8601DateFormatter().string(from: Date()),
            role: "user",
            isActive: true
        )
        
        do {
            let updatedUser = try await withCheckedThrowingContinuation { continuation in
                apiService.updateProfile(token: token, user: userAPI)
                    .sink(
                        receiveCompletion: { completion in
                            if case .failure(let error) = completion {
                                continuation.resume(throwing: error)
                            }
                        },
                        receiveValue: { userAPI in
                            continuation.resume(returning: userAPI)
                        }
                    )
                    .store(in: &cancellables)
            }
            
            await MainActor.run {
                self.currentUser = updatedUser.toLocalUser()
                self.saveCurrentUser(self.currentUser!)
                print("AuthService: Профиль обновлен через API")
            }
        } catch {
            print("AuthService: Ошибка обновления профиля - \(error)")
        }
    }
} 