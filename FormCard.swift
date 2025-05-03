import SwiftUI
import QuickLook
import UniformTypeIdentifiers
// Form Card Component
struct FormCard<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.headline)
                .foregroundColor(Color(hex: "4D52C7"))
                .padding(.horizontal, 20)
            
            VStack(spacing: 15) {
                content
            }
            .padding(15)
            .background(Color(hex: "F9F9FB"))
            .cornerRadius(20)
            .padding(.horizontal, 20)
        }
    }
}
