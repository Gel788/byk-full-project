import SwiftUI

struct ProfileSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var notificationsEnabled = true
    @State private var marketingEnabled = false
    @State private var locationEnabled = true
    @State private var biometricEnabled = true
    @State private var darkModeEnabled = true
    @State private var showLogoutAlert = false
    
    private var brandColors: (primary: Color, secondary: Color, accent: Color) {
        (Color("BykPrimary"), Color("BykSecondary"), Color("BykAccent"))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Фон
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        brandColors.accent.opacity(0.1),
                        Color.black.opacity(0.95)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Заголовок
                        headerSection
                        
                        // Уведомления
                        notificationSettings
                        
                        // Безопасность
                        securitySettings
                        
                        // Интерфейс
                        interfaceSettings
                        
                        // О приложении
                        aboutSection
                        
                        // Опасная зона
                        dangerZone
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
            .alert("Выход из аккаунта", isPresented: $showLogoutAlert) {
                Button("Отмена", role: .cancel) { }
                Button("Выйти", role: .destructive) {
                    // Логика выхода
                    dismiss()
                }
            } message: {
                Text("Вы уверены, что хотите выйти из аккаунта?")
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            Button(action: { dismiss() }) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            Spacer()
            
            Text("Настройки")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.white, Color.white.opacity(0.9)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Spacer()
            
            // Placeholder для симметрии
            Circle()
                .fill(Color.clear)
                .frame(width: 40, height: 40)
        }
        .padding(.top, 20)
    }
    
    // MARK: - Notification Settings
    private var notificationSettings: some View {
        VStack(spacing: 16) {
            SettingsSectionHeader(title: "Уведомления", icon: "bell.fill")
            
            VStack(spacing: 12) {
                SettingToggleRow(
                    title: "Push-уведомления",
                    description: "Получать уведомления о заказах и акциях",
                    isOn: $notificationsEnabled,
                    color: brandColors.accent
                )
                
                SettingToggleRow(
                    title: "Маркетинговые уведомления",
                    description: "Персональные предложения и скидки",
                    isOn: $marketingEnabled,
                    color: .blue
                )
                
                SettingToggleRow(
                    title: "Геолокация",
                    description: "Поиск ближайших ресторанов",
                    isOn: $locationEnabled,
                    color: .green
                )
            }
        }
    }
    
    // MARK: - Security Settings
    private var securitySettings: some View {
        VStack(spacing: 16) {
            SettingsSectionHeader(title: "Безопасность", icon: "lock.shield.fill")
            
            VStack(spacing: 12) {
                SettingToggleRow(
                    title: "Биометрическая аутентификация",
                    description: "Face ID / Touch ID для входа в приложение",
                    isOn: $biometricEnabled,
                    color: .purple
                )
                
                SettingActionRow(
                    title: "Изменить пароль",
                    description: "Обновить пароль для входа",
                    icon: "key.fill",
                    color: .orange
                ) {
                    // Действие изменения пароля
                    print("Изменение пароля")
                }
                
                SettingActionRow(
                    title: "Двухфакторная аутентификация",
                    description: "Дополнительная защита аккаунта",
                    icon: "shield.checkered",
                    color: .red
                ) {
                    // Настройка 2FA
                    print("Настройка 2FA")
                }
            }
        }
    }
    
    // MARK: - Interface Settings
    private var interfaceSettings: some View {
        VStack(spacing: 16) {
            SettingsSectionHeader(title: "Интерфейс", icon: "paintbrush.fill")
            
            VStack(spacing: 12) {
                SettingToggleRow(
                    title: "Темная тема",
                    description: "Использовать темное оформление",
                    isOn: $darkModeEnabled,
                    color: .gray
                )
                
                SettingActionRow(
                    title: "Язык приложения",
                    description: "Русский",
                    icon: "globe",
                    color: .cyan
                ) {
                    // Выбор языка
                    print("Выбор языка")
                }
                
                SettingActionRow(
                    title: "Размер шрифта",
                    description: "Стандартный",
                    icon: "textformat.size",
                    color: .indigo
                ) {
                    // Настройка шрифта
                    print("Настройка шрифта")
                }
            }
        }
    }
    
    // MARK: - About Section
    private var aboutSection: some View {
        VStack(spacing: 16) {
            SettingsSectionHeader(title: "О приложении", icon: "info.circle.fill")
            
            VStack(spacing: 12) {
                SettingActionRow(
                    title: "Версия приложения",
                    description: "1.0.0 (Build 1)",
                    icon: "app.badge",
                    color: .mint
                ) {
                    // Показать детали версии
                    print("Детали версии")
                }
                
                SettingActionRow(
                    title: "Условия использования",
                    description: "Ознакомиться с условиями",
                    icon: "doc.text",
                    color: .teal
                ) {
                    // Открыть условия
                    print("Условия использования")
                }
                
                SettingActionRow(
                    title: "Политика конфиденциальности",
                    description: "Как мы защищаем ваши данные",
                    icon: "hand.raised.fill",
                    color: .brown
                ) {
                    // Открыть политику
                    print("Политика конфиденциальности")
                }
            }
        }
    }
    
    // MARK: - Danger Zone
    private var dangerZone: some View {
        VStack(spacing: 16) {
            SettingsSectionHeader(title: "Опасная зона", icon: "exclamationmark.triangle.fill")
            
            VStack(spacing: 12) {
                SettingActionRow(
                    title: "Очистить кэш",
                    description: "Удалить временные файлы приложения",
                    icon: "trash.fill",
                    color: .orange
                ) {
                    // Очистка кэша
                    print("Очистка кэша")
                }
                
                SettingActionRow(
                    title: "Удалить аккаунт",
                    description: "Безвозвратно удалить все данные",
                    icon: "person.badge.minus",
                    color: .red
                ) {
                    // Удаление аккаунта
                    print("Удаление аккаунта")
                }
                
                SettingActionRow(
                    title: "Выйти из аккаунта",
                    description: "Завершить текущую сессию",
                    icon: "rectangle.portrait.and.arrow.right",
                    color: .red
                ) {
                    showLogoutAlert = true
                }
            }
        }
    }
}

// MARK: - Settings Section Header  
struct SettingsSectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))
            
            Text(title)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
            
            Spacer()
        }
    }
}

// MARK: - Setting Toggle Row
struct SettingToggleRow: View {
    let title: String
    let description: String
    @Binding var isOn: Bool
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text(description)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                Toggle("", isOn: $isOn)
                    .toggleStyle(SwitchToggleStyle(tint: color))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Setting Action Row
struct SettingActionRow: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text(description)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}