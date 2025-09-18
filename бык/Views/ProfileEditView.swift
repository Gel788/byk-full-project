import SwiftUI

struct ProfileEditView: View {
    let user: User?
    @EnvironmentObject private var userDataService: UserDataService
    @Environment(\.dismiss) private var dismiss
    
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var isSaving = false
    @State private var showSuccessMessage = false
    
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
                        HStack {
                            Text("Редактирование профиля")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.white, Color.white.opacity(0.9)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Фото профиля
                        photoSection
                        
                        // Поля ввода
                        VStack(spacing: 16) {
                            CustomTextField(
                                title: "Полное имя",
                                text: $fullName,
                                placeholder: "Введите ваше имя",
                                icon: "person.fill",
                                brandColors: brandColors
                            )
                            
                            CustomTextField(
                                title: "Email",
                                text: $email,
                                placeholder: "example@email.com",
                                icon: "envelope.fill",
                                brandColors: brandColors,
                                keyboardType: .emailAddress
                            )
                            
                            CustomTextField(
                                title: "Телефон",
                                text: $phone,
                                placeholder: "+7 (___) ___-__-__",
                                icon: "phone.fill",
                                brandColors: brandColors,
                                keyboardType: .phonePad
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        // Кнопка сохранения
                        saveButton
                            .padding(.horizontal, 20)
                            .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                loadUserData()
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePickerView(selectedImage: $selectedImage)
            }
            .overlay(
                // Сообщение об успехе
                successOverlay
            )
        }
    }
    
    // MARK: - Photo Section
    private var photoSection: some View {
        VStack(spacing: 16) {
            ZStack {
                // Фон аватара
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                brandColors.accent.opacity(0.3),
                                brandColors.primary.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        brandColors.accent.opacity(0.5),
                                        brandColors.accent.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                
                // Изображение или инициалы
                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 110, height: 110)
                        .clipShape(Circle())
                } else if let user = user {
                    Text(user.fullName.prefix(1).uppercased())
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                // Кнопка изменения фото
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showingImagePicker = true
                        }) {
                            ZStack {
                                Circle()
                                    .fill(brandColors.accent)
                                    .frame(width: 32, height: 32)
                                    .shadow(color: brandColors.accent.opacity(0.4), radius: 8, x: 0, y: 4)
                                
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .offset(x: -8, y: -8)
                    }
                }
            }
            .frame(width: 120, height: 120)
            
            Text("Нажмите на камеру для изменения фото")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
        }
    }
    
    // MARK: - Save Button
    private var saveButton: some View {
        Button(action: saveProfile) {
            HStack(spacing: 12) {
                if isSaving {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                }
                
                Text(isSaving ? "Сохранение..." : "Сохранить изменения")
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
        .disabled(isSaving || !isFormValid)
        .opacity(isFormValid ? 1.0 : 0.6)
        .scaleEffect(isSaving ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSaving)
    }
    
    // MARK: - Success Overlay
    private var successOverlay: some View {
        Group {
            if showSuccessMessage {
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
                        
                        Text("Профиль обновлен!")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
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
        !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        email.contains("@") &&
        !phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Methods
    private func loadUserData() {
        if let user = user {
            fullName = user.fullName
            email = user.email
            print("ProfileEditView: Загружены данные пользователя - \(user.fullName), \(user.email)")
        } else {
            print("ProfileEditView: Пользователь не найден")
        }
    }
    
    private func saveProfile() {
        guard isFormValid else { return }
        
        isSaving = true
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Симуляция сохранения
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            userDataService.updateUserProfile(
                name: fullName,
                email: email,
                phone: phone
            )
            
            isSaving = false
            
            // Показываем сообщение об успехе
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showSuccessMessage = true
            }
            
            // Скрываем сообщение и закрываем экран
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeOut(duration: 0.3)) {
                    showSuccessMessage = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Image Picker
struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerView
        
        init(_ parent: ImagePickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}