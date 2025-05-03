import SwiftUI
import QuickLook
import UniformTypeIdentifiers
// Form Text Field Component
struct FormTextField: View {
    let title: String
    @Binding var text: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(Color.gray)
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color(hex: "4D52C7"))
                    .frame(width: 24, height: 24)
                
                TextField("Enter \(title.lowercased())", text: $text)
                    .keyboardType(keyboardType)
                    .foregroundColor(Color(hex: "333333"))
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}
