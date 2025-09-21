import SwiftUI
import MessageUI

struct FeedbackForm: View {
    @State private var selectedTopic: SupportTopic = .general
    @State private var messageText = ""
    @State private var userEmail = ""
    @State private var showingMailComposer = false
    @State private var showingSendSuccess = false
    
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Обратная связь")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 16) {
                // Тема обращения
                VStack(alignment: .leading, spacing: 8) {
                    Text("Тема обращения")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Picker("Тема", selection: $selectedTopic) {
                        ForEach(SupportTopic.allCases, id: \.self) { topic in
                            Text(topic.title).tag(topic)
                        }
                    }
                    .pickerStyle(.menu)
                    .accentColor(brandColors.accent)
                }
                
                // Email
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ваш email")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    TextField("email@example.com", text: $userEmail)
                        .textFieldStyle(SupportTextFieldStyle(brandColors: brandColors))
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                // Сообщение
                VStack(alignment: .leading, spacing: 8) {
                    Text("Сообщение")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    TextField("Опишите вашу проблему...", text: $messageText, axis: .vertical)
                        .textFieldStyle(SupportTextFieldStyle(brandColors: brandColors))
                        .lineLimit(3...6)
                }
                
                // Кнопка отправки
                Button(action: sendFeedback) {
                    HStack {
                        Image(systemName: "paperplane.fill")
                        Text("Отправить")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(brandColors.accent)
                    )
                }
                .disabled(messageText.isEmpty || userEmail.isEmpty)
                .opacity(messageText.isEmpty || userEmail.isEmpty ? 0.6 : 1.0)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .stroke(brandColors.primary.opacity(0.3), lineWidth: 1)
        )
        .sheet(isPresented: $showingMailComposer) {
            MailComposeView(
                topic: selectedTopic,
                message: messageText,
                email: userEmail
            )
        }
        .alert("Сообщение отправлено!", isPresented: $showingSendSuccess) {
            Button("OK") {
                messageText = ""
                userEmail = ""
            }
        } message: {
            Text("Мы получили ваше сообщение и ответим в ближайшее время.")
        }
    }
    
    private func sendFeedback() {
        if MFMailComposeViewController.canSendMail() {
            showingMailComposer = true
        } else {
            showingSendSuccess = true
        }
    }
}

struct SupportTextFieldStyle: TextFieldStyle {
    let brandColors: (primary: Color, secondary: Color, accent: Color)
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .foregroundColor(.white)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.1))
                    .stroke(brandColors.primary.opacity(0.3), lineWidth: 1)
            )
    }
}

enum SupportTopic: CaseIterable {
    case general, order, reservation, technical, complaint, suggestion
    
    var title: String {
        switch self {
        case .general: return "Общие вопросы"
        case .order: return "Заказ"
        case .reservation: return "Бронирование"
        case .technical: return "Техническая поддержка"
        case .complaint: return "Жалоба"
        case .suggestion: return "Предложение"
        }
    }
}

struct MailComposeView: UIViewControllerRepresentable {
    let topic: SupportTopic
    let message: String
    let email: String
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = context.coordinator
        mailComposer.setToRecipients(["support@byk.ru"])
        mailComposer.setSubject("\(topic.title) - БЫК")
        mailComposer.setMessageBody("Email: \(email)\n\n\(message)", isHTML: false)
        return mailComposer
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
