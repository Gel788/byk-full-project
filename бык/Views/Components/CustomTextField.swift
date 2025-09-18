import SwiftUI

struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let icon: String
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let keyboardType: UIKeyboardType
    let isSecure: Bool
    
    @FocusState private var isFocused: Bool
    
    init(
        title: String,
        text: Binding<String>,
        placeholder: String,
        icon: String,
        brandColors: (primary: Color, secondary: Color, accent: Color),
        keyboardType: UIKeyboardType = .default,
        isSecure: Bool = false
    ) {
        self.title = title
        self._text = text
        self.placeholder = placeholder
        self.icon = icon
        self.brandColors = brandColors
        self.keyboardType = keyboardType
        self.isSecure = isSecure
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Заголовок поля
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            
            // Поле ввода
            HStack(spacing: 12) {
                // Иконка
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isFocused ? brandColors.accent.opacity(0.2) : Color.gray.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(isFocused ? brandColors.accent : .gray)
                }
                .animation(.easeInOut(duration: 0.2), value: isFocused)
                
                // Текстовое поле
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .textFieldStyle()
                } else {
                    TextField(placeholder, text: $text)
                        .textFieldStyle()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isFocused ? brandColors.accent : (text.isEmpty ? Color.gray.opacity(0.3) : brandColors.accent.opacity(0.5)),
                                lineWidth: isFocused ? 2 : 1
                            )
                    )
            )
            .focused($isFocused)
            .animation(.easeInOut(duration: 0.2), value: isFocused)
        }
    }
}

// MARK: - TextField Style Extension

private extension TextField {
    func textFieldStyle() -> some View {
        self
            .font(.system(size: 16))
            .foregroundColor(.white)
            .keyboardType(.default)
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
    }
}

private extension SecureField {
    func textFieldStyle() -> some View {
        self
            .font(.system(size: 16))
            .foregroundColor(.white)
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
    }
}

// MARK: - Animated Text Field

struct AnimatedTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let icon: String
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    let keyboardType: UIKeyboardType
    let isRequired: Bool
    let validation: ((String) -> Bool)?
    let onEditingChanged: ((Bool) -> Void)?
    
    @FocusState private var isFocused: Bool
    @State private var hasBeenEdited = false
    
    init(
        title: String,
        text: Binding<String>,
        placeholder: String,
        icon: String,
        brandColors: (primary: Color, secondary: Color, accent: Color),
        keyboardType: UIKeyboardType = .default,
        isRequired: Bool = false,
        validation: ((String) -> Bool)? = nil,
        onEditingChanged: ((Bool) -> Void)? = nil
    ) {
        self.title = title
        self._text = text
        self.placeholder = placeholder
        self.icon = icon
        self.brandColors = brandColors
        self.keyboardType = keyboardType
        self.isRequired = isRequired
        self.validation = validation
        self.onEditingChanged = onEditingChanged
    }
    
    private var isValid: Bool {
        if let validation = validation {
            return validation(text)
        }
        return !isRequired || !text.isEmpty
    }
    
    private var borderColor: Color {
        if isFocused {
            return brandColors.accent
        } else if hasBeenEdited && !isValid {
            return .red
        } else if !text.isEmpty {
            return brandColors.accent.opacity(0.5)
        } else {
            return Color.gray.opacity(0.3)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Заголовок с индикатором обязательности
        HStack {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                if isRequired {
                    Text("*")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                // Индикатор валидации
                if hasBeenEdited {
                    Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(isValid ? .green : .red)
                }
            }
            
            // Поле ввода с анимацией
            HStack(spacing: 12) {
                // Анимированная иконка
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isFocused ? brandColors.accent.opacity(0.2) : Color.gray.opacity(0.1))
                        .frame(width: 40, height: 40)
                        .scaleEffect(isFocused ? 1.05 : 1.0)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(isFocused ? brandColors.accent : .gray)
                        .scaleEffect(isFocused ? 1.1 : 1.0)
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isFocused)
                
                // Текстовое поле
            TextField(placeholder, text: $text)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                .keyboardType(keyboardType)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(keyboardType == .emailAddress)
                    .onChange(of: text) { _, _ in
                        if !hasBeenEdited {
                            hasBeenEdited = true
                        }
                    }
                    .focused($isFocused)
                    .onTapGesture {
                        isFocused = true
                    }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(isFocused ? 0.08 : 0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(borderColor, lineWidth: isFocused ? 2 : 1)
                    )
            )
            .scaleEffect(isFocused ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isFocused)
            .animation(.easeInOut(duration: 0.2), value: borderColor)
            
            // Сообщение валидации
            if hasBeenEdited && !isValid {
                Text(validationMessage)
                    .font(.system(size: 12))
                    .foregroundColor(.red)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .onChange(of: isFocused) { _, newValue in
            onEditingChanged?(newValue)
        }
    }
    
    private var validationMessage: String {
        if isRequired && text.isEmpty {
            return "Поле обязательно для заполнения"
        } else if let validation = validation, !validation(text) {
            return getValidationMessage()
        }
        return ""
    }
    
    private func getValidationMessage() -> String {
        switch keyboardType {
        case .emailAddress:
            return "Введите корректный email"
        case .phonePad:
            return "Введите корректный номер телефона"
        default:
            return "Некорректное значение"
        }
    }
}

// MARK: - Floating Label Text Field

struct FloatingLabelTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let icon: String
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    @FocusState private var isFocused: Bool
    
    private var shouldFloat: Bool {
        isFocused || !text.isEmpty
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .leading) {
                // Фоновый контейнер
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isFocused ? brandColors.accent : Color.gray.opacity(0.3),
                                lineWidth: isFocused ? 2 : 1
                            )
                    )
                    .frame(height: 56)
                
                HStack(spacing: 12) {
                    // Иконка
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(isFocused ? brandColors.accent : .gray)
                        .frame(width: 20)
                        .padding(.leading, 16)
                    
                    // Поле ввода с плавающим лейблом
                    ZStack(alignment: .leading) {
                        // Плавающий лейбл
                        Text(title)
                            .font(.system(size: shouldFloat ? 12 : 16))
                            .foregroundColor(
                                shouldFloat ?
                                (isFocused ? brandColors.accent : .gray) :
                                .gray.opacity(0.7)
                            )
                            .offset(y: shouldFloat ? -20 : 0)
                            .animation(.easeInOut(duration: 0.2), value: shouldFloat)
                        
                        // Текстовое поле
                        TextField("", text: $text)
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .focused($isFocused)
                            .offset(y: shouldFloat ? 8 : 0)
                            .animation(.easeInOut(duration: 0.2), value: shouldFloat)
                    }
                    .padding(.trailing, 16)
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

#Preview {
    VStack(spacing: 20) {
        CustomTextField(
            title: "Имя",
            text: .constant(""),
            placeholder: "Введите ваше имя",
            icon: "person",
            brandColors: Colors.brandColors(for: .theByk)
        )
        
        AnimatedTextField(
            title: "Email",
            text: .constant(""),
            placeholder: "example@mail.ru",
            icon: "envelope",
            brandColors: Colors.brandColors(for: .theByk),
            keyboardType: .emailAddress,
            isRequired: true,
            validation: { email in
                email.contains("@") && email.contains(".")
            }
        )
        
        FloatingLabelTextField(
            title: "Телефон",
            text: .constant(""),
            placeholder: "",
            icon: "phone",
            brandColors: Colors.brandColors(for: .theByk)
        )
    }
    .padding(20)
    .background(Color.black)
}