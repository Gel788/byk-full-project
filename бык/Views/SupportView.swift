import SwiftUI
import MessageUI

struct SupportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTopic: SupportTopic = .general
    @State private var messageText = ""
    @State private var userEmail = ""
    @State private var showingMailComposer = false
    @State private var showingCallAlert = false
    @State private var showingSendSuccess = false
    @State private var expandedFAQ: Set<String> = []
    
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
                        
                        // Быстрые действия
                        quickActionsSection
                        
                        // Форма обратной связи
                        feedbackFormSection
                        
                        // FAQ секция
                        faqSection
                        
                        // Контактная информация
                        contactInfoSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingMailComposer) {
                if MFMailComposeViewController.canSendMail() {
                    MailComposeView(
                        subject: "Поддержка - \(selectedTopic.title)",
                        messageBody: messageText,
                        recipients: ["support@byk-restaurants.com"]
                    )
                }
            }
            .alert("Позвонить в поддержку", isPresented: $showingCallAlert) {
                Button("Отмена", role: .cancel) { }
                Button("Позвонить") {
                    if let phoneURL = URL(string: "tel:+74951234567") {
                        UIApplication.shared.open(phoneURL)
                    }
                }
            } message: {
                Text("Мы свяжемся с вами в ближайшее время")
            }
            .overlay(
                // Сообщение об успехе
                successOverlay
            )
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
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
            }
            
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    brandColors.accent.opacity(0.3),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 50
                            )
                        )
                        .frame(width: 100, height: 100)
                    
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    brandColors.accent,
                                    brandColors.accent.opacity(0.8)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)
                        .shadow(color: brandColors.accent.opacity(0.4), radius: 12, x: 0, y: 6)
                    
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 30, weight: .medium))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 6) {
                    Text("Центр поддержки")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.white, Color.white.opacity(0.9)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Мы всегда готовы помочь вам!")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Быстрые действия")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
            }
            
            HStack(spacing: 12) {
                QuickActionCard(
                    icon: "phone.fill",
                    title: "Позвонить",
                    subtitle: "Срочная помощь",
                    color: .green
                ) {
                    showingCallAlert = true
                }
                
                QuickActionCard(
                    icon: "message.fill",
                    title: "Чат",
                    subtitle: "Онлайн поддержка",
                    color: .blue
                ) {
                    // Открыть чат
                    print("Открываем чат")
                }
                
                QuickActionCard(
                    icon: "envelope.fill",
                    title: "Email",
                    subtitle: "Написать письмо",
                    color: .purple
                ) {
                    showingMailComposer = true
                }
            }
        }
    }
    
    // MARK: - Feedback Form Section
    private var feedbackFormSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Обратная связь")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
            }
            
            VStack(spacing: 16) {
                // Выбор темы
                VStack(alignment: .leading, spacing: 8) {
                    Text("Тема обращения")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Menu {
                        ForEach(SupportTopic.allCases, id: \.self) { topic in
                            Button(topic.title) {
                                selectedTopic = topic
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: selectedTopic.icon)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(brandColors.accent)
                            
                            Text(selectedTopic.title)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(brandColors.accent.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                }
                
                // Email поле
                CustomTextField(
                    title: "Ваш email",
                    text: $userEmail,
                    placeholder: "example@email.com",
                    icon: "envelope",
                    brandColors: brandColors,
                    keyboardType: .emailAddress
                )
                
                // Поле сообщения
                VStack(alignment: .leading, spacing: 8) {
                    Text("Сообщение")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    TextEditor(text: $messageText)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .padding(16)
                        .frame(minHeight: 120)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(brandColors.accent.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .overlay(
                            // Placeholder
                            VStack {
                                HStack {
                                    if messageText.isEmpty {
                                        Text("Опишите вашу проблему или вопрос...")
                                            .font(.system(size: 16))
                                            .foregroundColor(.white.opacity(0.5))
                                            .padding(.top, 8)
                                            .padding(.leading, 4)
                                    }
                                    Spacer()
                                }
                                Spacer()
                            }
                            .padding(16)
                            .allowsHitTesting(false)
                        )
                }
                
                // Кнопка отправки
                Button(action: sendFeedback) {
                    HStack(spacing: 12) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text("Отправить сообщение")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        brandColors.accent,
                                        brandColors.accent.opacity(0.8)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: brandColors.accent.opacity(0.4), radius: 12, x: 0, y: 6)
                    )
                }
                .disabled(!isFormValid)
                .opacity(isFormValid ? 1.0 : 0.6)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - FAQ Section
    private var faqSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Часто задаваемые вопросы")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
            }
            
            VStack(spacing: 8) {
                ForEach(faqItems, id: \.id) { item in
                    FAQCard(
                        item: item,
                        isExpanded: expandedFAQ.contains(item.id)
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if expandedFAQ.contains(item.id) {
                                expandedFAQ.remove(item.id)
                            } else {
                                expandedFAQ.insert(item.id)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Contact Info Section
    private var contactInfoSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Контактная информация")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
            }
            
            VStack(spacing: 12) {
                ContactInfoRow(
                    icon: "phone.fill",
                    title: "Телефон поддержки",
                    value: "+7 (495) 123-45-67",
                    color: .green
                )
                
                ContactInfoRow(
                    icon: "envelope.fill",
                    title: "Email поддержки",
                    value: "support@byk-restaurants.com",
                    color: .blue
                )
                
                ContactInfoRow(
                    icon: "clock.fill",
                    title: "Часы работы",
                    value: "Ежедневно 9:00 - 23:00",
                    color: .orange
                )
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Success Overlay
    private var successOverlay: some View {
        Group {
            if showingSendSuccess {
                ZStack {
                    Color.black.opacity(0.6)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 60, height: 60)
                                .shadow(color: Color.green.opacity(0.4), radius: 12, x: 0, y: 6)
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 8) {
                            Text("Сообщение отправлено!")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Мы ответим в течение 24 часов")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .opacity
                ))
            }
        }
    }
    
    // MARK: - Computed Properties
    private var isFormValid: Bool {
        !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !userEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        userEmail.contains("@")
    }
    
    // MARK: - Methods
    private func sendFeedback() {
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Симуляция отправки
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showingSendSuccess = true
            }
            
            // Очищаем форму
            messageText = ""
            userEmail = ""
            selectedTopic = .general
            
            // Скрываем сообщение
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeOut(duration: 0.3)) {
                    showingSendSuccess = false
                }
            }
        }
    }
    
    // MARK: - Data
    private var faqItems: [FAQItem] {
        [
            FAQItem(
                id: "1",
                question: "Как отменить заказ?",
                answer: "Заказ можно отменить в течение 5 минут после оформления через приложение в разделе 'Мои заказы'. После этого времени необходимо связаться с поддержкой."
            ),
            FAQItem(
                id: "2",
                question: "Сколько времени занимает доставка?",
                answer: "Среднее время доставки составляет 30-45 минут в зависимости от загруженности ресторана и вашего местоположения. Точное время указывается при оформлении заказа."
            ),
            FAQItem(
                id: "3",
                question: "Можно ли изменить заказ после оформления?",
                answer: "Изменения в заказе возможны только в течение первых 5 минут после оформления. Для внесения изменений обратитесь к администратору ресторана или в службу поддержки."
            ),
            FAQItem(
                id: "4",
                question: "Как работает программа лояльности?",
                answer: "За каждый заказ вы получаете баллы (5% от суммы заказа). Баллами можно оплачивать до 50% от стоимости следующих заказов. Также доступны дополнительные привилегии для постоянных клиентов."
            )
        ]
    }
}

// MARK: - Models
enum SupportTopic: CaseIterable {
    case general
    case order
    case payment
    case delivery
    case technical
    case complaint
    
    var title: String {
        switch self {
        case .general: return "Общий вопрос"
        case .order: return "Проблема с заказом"
        case .payment: return "Проблема с оплатой"
        case .delivery: return "Проблема с доставкой"
        case .technical: return "Техническая проблема"
        case .complaint: return "Жалоба"
        }
    }
    
    var icon: String {
        switch self {
        case .general: return "questionmark.circle"
        case .order: return "bag"
        case .payment: return "creditcard"
        case .delivery: return "bicycle"
        case .technical: return "gear"
        case .complaint: return "exclamationmark.triangle"
        }
    }
}

struct FAQItem {
    let id: String
    let question: String
    let answer: String
}

// MARK: - Quick Action Card
struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 50, height: 50)
                        .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(color)
                }
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - FAQ Card
struct FAQCard: View {
    let item: FAQItem
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: onTap) {
                HStack {
                    Text(item.question)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(16)
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                VStack {
                    Divider()
                        .background(Color.white.opacity(0.2))
                    
                    HStack {
                        Text(item.answer)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                    .padding(16)
                    .padding(.top, 0)
                }
            }
        }
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

// MARK: - Contact Info Row
struct ContactInfoRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
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
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                Text(value)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
    }
}

// MARK: - Mail Compose View
struct MailComposeView: UIViewControllerRepresentable {
    let subject: String
    let messageBody: String
    let recipients: [String]
    
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        composer.setSubject(subject)
        composer.setMessageBody(messageBody, isHTML: false)
        composer.setToRecipients(recipients)
        return composer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailComposeView
        
        init(_ parent: MailComposeView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            parent.dismiss()
        }
    }
}