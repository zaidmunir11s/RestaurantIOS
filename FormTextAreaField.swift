import SwiftUI
import QuickLook
import UniformTypeIdentifiers

// Form Text Area Field Component
struct FormTextAreaField: View {
    let title: String
    @Binding var text: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(Color.gray)
            
            HStack(alignment: .top) {
                Image(systemName: icon)
                    .foregroundColor(Color(hex: "4D52C7"))
                    .frame(width: 24, height: 24)
                    .padding(.top, 12)
                
                TextEditor(text: $text)
                    .frame(minHeight: 100)
                    .foregroundColor(Color(hex: "333333"))
                    .padding(8)
                    .background(Color.white)
                    .cornerRadius(8)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}
