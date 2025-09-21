import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismiss) private var dismiss
    @State private var isLoginMode = true
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        Color("BykAccent").opacity(0.3),
                        Color.black
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    Spacer()
                    
                    // Логотип
                    VStack(spacing: 8) {
                        Text("Бык")
                            .font(.custom("Helvetica Neue", size: 48, relativeTo: .largeTitle))
                            .fontWeight(.ultraLight)
                            .tracking(6)
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color("BykAccent"),
                                        Color.white.opacity(0.9),
                                        Color("BykAccent")
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("Holding")
                            .font(.custom("Helvetica Neue", size: 20, relativeTo: .title3))
                            .fontWeight(.light)
                            .tracking(8)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    // Форма авторизации
                    VStack(spacing: 24) {
                        if isLoginMode {
                            LoginFormView(authService: authService, onSuccess: {
                                dismiss()
                            })
                        } else {
                            RegistrationFormView(authService: authService, onSuccess: {
                                dismiss()
                            })
                        }
                        
                        // Переключение режимов
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isLoginMode.toggle()
                            }
                        }) {
                            Text(isLoginMode ? "Нет аккаунта? Зарегистрироваться" : "Уже есть аккаунт? Войти")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                                .underline()
                        }
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
        .onChange(of: authService.isAuthenticated) { isAuthenticated in
            if isAuthenticated {
                dismiss()
            }
        }
    }
}

struct LoginFormView: View {
    @ObservedObject var authService: AuthService
    let onSuccess: () -> Void
    @State private var phoneNumber = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Вход в аккаунт")
                .font(.custom("Helvetica Neue", size: 28, relativeTo: .title))
                .fontWeight(.light)
                .foregroundColor(.white)
            
            VStack(spacing: 16) {
                // Номер телефона
                VStack(alignment: .leading, spacing: 8) {
                    Text("Номер телефона")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    TextField("+7 (999) 123-45-67", text: $phoneNumber)
                        .keyboardType(.phonePad)
                        .textFieldStyle(CustomTextFieldStyle())
                }
                
                // Пароль
                VStack(alignment: .leading, spacing: 8) {
                    Text("Пароль")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    HStack {
                        if isPasswordVisible {
                            TextField("Введите пароль", text: $password)
                                .textFieldStyle(CustomTextFieldStyle())
                        } else {
                            SecureField("Введите пароль", text: $password)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        Button(action: {
                            isPasswordVisible.toggle()
                        }) {
                            Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
            }
            
            // Кнопка входа
            Button(action: {
                print("📱 LoginFormView: Пользователь нажал кнопку входа")
                print("  - Телефон: \(phoneNumber)")
                print("  - Пароль: [СКРЫТ]")
                
                Task {
                    await authService.login(with: AuthCredentials(
                        phoneNumber: phoneNumber,
                        password: password
                    ))
                    if authService.isAuthenticated {
                        print("📱 LoginFormView: Вход успешен, закрываем форму")
                        onSuccess()
                    } else {
                        print("📱 LoginFormView: Вход не удался")
                    }
                }
            }) {
                HStack {
                    if authService.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Text("Войти")
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color("BykAccent"), Color("BykAccent").opacity(0.8)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(authService.isLoading || phoneNumber.isEmpty || password.isEmpty)
            .opacity((phoneNumber.isEmpty || password.isEmpty) ? 0.6 : 1.0)
            
            // Ошибка
            if let errorMessage = authService.errorMessage {
                Text(errorMessage)
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

struct RegistrationFormView: View {
    @ObservedObject var authService: AuthService
    let onSuccess: () -> Void
    @State private var phoneNumber = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var name = ""
    @State private var email = ""
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Регистрация")
                .font(.custom("Helvetica Neue", size: 28, relativeTo: .title))
                .fontWeight(.light)
                .foregroundColor(.white)
            
            VStack(spacing: 16) {
                // Имя
                VStack(alignment: .leading, spacing: 8) {
                    Text("Имя")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    TextField("Введите ваше имя", text: $name)
                        .textFieldStyle(CustomTextFieldStyle())
                }
                
                // Email (опционально)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email (необязательно)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    TextField("example@email.com", text: $email)
                        .keyboardType(.emailAddress)
                        .textFieldStyle(CustomTextFieldStyle())
                }
                
                // Номер телефона
                VStack(alignment: .leading, spacing: 8) {
                    Text("Номер телефона")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    TextField("+7 (999) 123-45-67", text: $phoneNumber)
                        .keyboardType(.phonePad)
                        .textFieldStyle(CustomTextFieldStyle())
                }
                
                // Пароль
                VStack(alignment: .leading, spacing: 8) {
                    Text("Пароль")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    HStack {
                        if isPasswordVisible {
                            TextField("Введите пароль", text: $password)
                                .textFieldStyle(CustomTextFieldStyle())
                        } else {
                            SecureField("Введите пароль", text: $password)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        Button(action: {
                            isPasswordVisible.toggle()
                        }) {
                            Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
                
                // Подтверждение пароля
                VStack(alignment: .leading, spacing: 8) {
                    Text("Подтвердите пароль")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    HStack {
                        if isConfirmPasswordVisible {
                            TextField("Повторите пароль", text: $confirmPassword)
                                .textFieldStyle(CustomTextFieldStyle())
                        } else {
                            SecureField("Повторите пароль", text: $confirmPassword)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        Button(action: {
                            isConfirmPasswordVisible.toggle()
                        }) {
                            Image(systemName: isConfirmPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
            }
            
            // Кнопка регистрации
            Button(action: {
                print("📱 RegistrationFormView: Пользователь нажал кнопку регистрации")
                print("  - Имя: \(name)")
                print("  - Телефон: \(phoneNumber)")
                print("  - Email: \(email.isEmpty ? "не указан" : email)")
                print("  - Пароль: [СКРЫТ]")
                
                Task {
                    await authService.register(with: RegistrationData(
                        phoneNumber: phoneNumber,
                        password: password,
                        name: name,
                        email: email.isEmpty ? nil : email
                    ))
                    if authService.isAuthenticated {
                        print("📱 RegistrationFormView: Регистрация успешна, закрываем форму")
                        onSuccess()
                    } else {
                        print("📱 RegistrationFormView: Регистрация не удалась")
                    }
                }
            }) {
                HStack {
                    if authService.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Text("Зарегистрироваться")
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color("BykAccent"), Color("BykAccent").opacity(0.8)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(authService.isLoading || !isFormValid)
            .opacity(isFormValid ? 1.0 : 0.6)
            
            // Ошибка
            if let errorMessage = authService.errorMessage {
                Text(errorMessage)
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var isFormValid: Bool {
        !name.isEmpty && !phoneNumber.isEmpty && !password.isEmpty && 
        !confirmPassword.isEmpty && password == confirmPassword && password.count >= 6
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.1))
            .cornerRadius(8)
            .foregroundColor(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthService())
} 