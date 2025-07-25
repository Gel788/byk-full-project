import SwiftUI

struct CustomTextField: View {
    @Binding var text: String
    let icon: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 24)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .keyboardType(keyboardType)
        }
        .padding()
        .background(Color.black.opacity(0.6))
        .cornerRadius(8)
    }
} 