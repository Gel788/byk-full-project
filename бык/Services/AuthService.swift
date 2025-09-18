import Foundation
import SwiftUI

class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published var currentUser: User?
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let userDefaults = UserDefaults.standard
    private let userKey = "currentUser"
    
    init() {
        loadUserFromStorage()
    }
    
    // MARK: - Authentication Methods
    
    func register(with data: RegistrationData) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // Имитация задержки сети
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
        await MainActor.run {
            // Проверка существования пользователя
            if getStoredUser(phoneNumber: data.phoneNumber) != nil {
                errorMessage = "Пользователь с таким номером уже существует"
                isLoading = false
                return
            }
            
            // Создание нового пользователя
            let newUser = User(
                username: data.phoneNumber,
                fullName: data.name,
                email: data.email ?? ""
            )
            
            print("AuthService: Регистрируем нового пользователя - \(newUser.fullName), \(newUser.email)")
            
            // Сохранение пользователя
            saveUser(newUser)
            savePassword(phoneNumber: data.phoneNumber, password: data.password)
            saveCurrentUser(newUser)
            
            currentUser = newUser
            isAuthenticated = true
            isLoading = false
            
            print("AuthService: Регистрация завершена успешно")
        }
    }
    
    func login(with credentials: AuthCredentials) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // Имитация задержки сети
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        await MainActor.run {
            // Проверка пользователя
            guard let user = getStoredUser(phoneNumber: credentials.phoneNumber) else {
                errorMessage = "Пользователь не найден"
                isLoading = false
                return
            }
            
            // Проверка пароля
            guard let storedPassword = getStoredPassword(phoneNumber: credentials.phoneNumber),
                  storedPassword == credentials.password else {
                errorMessage = "Неверный пароль"
                isLoading = false
                return
            }
            
            print("AuthService: Вход пользователя - \(user.fullName), \(user.email)")
            
            saveCurrentUser(user)
            currentUser = user
            isAuthenticated = true
            isLoading = false
            
            print("AuthService: Вход выполнен успешно")
        }
    }
    
    func logout() {
        currentUser = nil
        isAuthenticated = false
        userDefaults.removeObject(forKey: userKey)
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
} 