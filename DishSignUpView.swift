import SwiftUI
import QuickLook
import UniformTypeIdentifiers

// Custom QLPreviewItem for USDZ files.
class USDZPreviewItem: NSObject, QLPreviewItem {
    let url: URL
    init(url: URL) { self.url = url }
    var previewItemURL: URL? { url }
    var previewItemContentType: String { UTType.usdz.identifier }
}

struct DishSignUpView: View {
    // The captured USDZ file URL.
    let capturedUSDZURL: URL
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) var presentationMode

    // Dish details.
    @State private var dishTitle: String = ""
    @State private var dishPrice: String = ""
    @State private var dishDescription: String = ""
    @State private var dishCategory: String = "Fast Food"
    @State private var isVegetarian: Bool = false
    @State private var calories: String = ""
    @State private var ingredients: String = ""
    
    // For image preview
    @State private var selectedURL: URL? = nil
    @State private var navigationToDashboard = false
    
    // Form validation
    @State private var showError: Bool = false
    @State private var errorMessage: String? = nil
    
    // Available categories
    let categories = ["Fast Food", "Drinks", "Desserts", "Main Course", "Appetizers"]
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "EFF1FA")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 0) {
                    // Top bar with back button
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            HStack(spacing: 5) {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .foregroundColor(Color(hex: "29B5FE"))
                            .font(.system(size: 16, weight: .medium))
                        }
                        
                        Spacer()
                        
                        Text("Add New Dish")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Placeholder for visual balance
                        Circle()
                            .fill(Color.clear)
                            .frame(width: 30, height: 30)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                .frame(height: 80)
                .background(Color(hex: "4D52C7"))
                
                ScrollView {
                    VStack(spacing: 20) {
                        // 3D Model Preview Card
                        ZStack {
                            // 3D Model Preview
                            if FileManager.default.fileExists(atPath: capturedUSDZURL.path) && selectedURL == nil {
                                DishPreviewCard(modelURL: capturedUSDZURL)
                                    .frame(height: 220)
                                    .cornerRadius(20)
                                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                            } else {
                                // Placeholder if no model or external AR view is active
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color(hex: "FFE8CC"))
                                        .frame(height: 220)
                                    
                                    VStack(spacing: 12) {
                                        Image(systemName: "cube.box.fill")
                                            .font(.system(size: 50))
                                            .foregroundColor(Color(hex: "4D52C7"))
                                        
                                        Text(selectedURL != nil ? "View in AR mode active" : "3D Model Preview")
                                            .font(.headline)
                                            .foregroundColor(Color(hex: "333333"))
                                    }
                                }
                                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                            }
                            
                            // AR View Button (overlay)
                            VStack {
                                Spacer()
                                
                                HStack(spacing: 16) {
                                    // View in AR Button
                                    Button(action: {
                                        // Set selectedURL to trigger the external Quick Look
                                        selectedURL = capturedUSDZURL
                                    }) {
                                        HStack {
                                            Image(systemName: "arkit")
                                            Text("View in AR")
                                        }
                                        .font(.system(size: 16, weight: .medium))
                                        .padding(.vertical, 12)
                                        .padding(.horizontal, 20)
                                        .background(Color(hex: "4D52C7"))
                                        .foregroundColor(.white)
                                        .cornerRadius(25)
                                        .shadow(color: Color(hex: "4D52C7").opacity(0.4), radius: 10, x: 0, y: 5)
                                    }
                                    
                                    // Back to Menu Button - Direct approach
                                    Button(action: {
                                        // Force dismiss multiple levels of navigation
                                        DispatchQueue.main.async {
                                            UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true)
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: "arrow.left")
                                            Text("Back to Menu")
                                        }
                                        .font(.system(size: 16, weight: .medium))
                                        .padding(.vertical, 12)
                                        .padding(.horizontal, 20)
                                        .background(Color(hex: "FF8A8A"))
                                        .foregroundColor(.white)
                                        .cornerRadius(25)
                                        .shadow(color: Color(hex: "FF8A8A").opacity(0.4), radius: 10, x: 0, y: 5)
                                    }
                                }
                                .padding(.bottom, 15)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Dish Details Form
                        FormCard(title: "Basic Details") {
                            // Dish Name
                            FormTextField(title: "Dish Name", text: $dishTitle, icon: "fork.knife")
                            
                            // Dish Price
                            FormTextField(title: "Price", text: $dishPrice, icon: "dollarsign.circle", keyboardType: .decimalPad)
                            
                            // Category Picker
                            FormPickerField(title: "Category", selection: $dishCategory, options: categories, icon: "tag")
                            
                            // Vegetarian Toggle
                            HStack {
                                Image(systemName: "leaf.fill")
                                    .foregroundColor(Color(hex: "4D52C7"))
                                    .frame(width: 24, height: 24)
                                
                                Text("Vegetarian")
                                    .foregroundColor(Color(hex: "333333"))
                                
                                Spacer()
                                
                                Toggle("", isOn: $isVegetarian)
                                    .toggleStyle(SwitchToggleStyle(tint: Color(hex: "4D52C7")))
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                        
                        // Description & Nutrition
                        FormCard(title: "Description & Nutrition") {
                            // Description
                            FormTextAreaField(title: "Description", text: $dishDescription, icon: "text.alignleft")
                            
                            // Calories
                            FormTextField(title: "Calories", text: $calories, icon: "flame.fill", keyboardType: .numberPad)
                            
                            // Ingredients
                            FormTextAreaField(title: "Ingredients", text: $ingredients, icon: "list.bullet")
                        }
                        
                        // Error Message
                        if showError, let errorMessage = errorMessage {
                            Text(errorMessage)
                                .font(.subheadline)
                                .foregroundColor(.red)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(10)
                                .padding(.horizontal, 20)
                        }
                        
                        // Save and Cancel Buttons
                        VStack(spacing: 15) {
                            Button(action: {
                                validateAndSave()
                            }) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Save Dish")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color(hex: "4D52C7"), Color(hex: "5C65DF")]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: Color(hex: "4D52C7").opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                            
                            Button(action: {
                                dismiss()
                            }) {
                                Text("Cancel")
                                    .font(.headline)
                                    .foregroundColor(Color(hex: "4D52C7"))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color(hex: "4D52C7"), lineWidth: 1)
                                    )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarHidden(true)
        .quickLookPreview($selectedURL) // Uses the system's Quick Look with AR functionality
        .navigationDestination(isPresented: $navigationToDashboard) {
            DashboardView()
        }
        .interactiveDismissDisabled() // This prevents slide-down dismissal
    }
    
    private func validateAndSave() {
        // Reset error
        errorMessage = nil
        showError = false
        
        // Validation
        if dishTitle.isEmpty {
            errorMessage = "Please enter a dish name"
            showError = true
            return
        }
        
        if dishPrice.isEmpty {
            errorMessage = "Please enter a price"
            showError = true
            return
        }
        
        // Price validation
        if let price = Double(dishPrice.replacingOccurrences(of: "$", with: "")), price <= 0 {
            errorMessage = "Price must be greater than zero"
            showError = true
            return
        }
        
        // Save logic would go here...
        print("Saving dish: \(dishTitle), \(dishPrice), \(dishCategory)")
        
        // Navigate to dashboard or menu after saving
        navigationToDashboard = true
    }
}

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

// Form Picker Field Component
struct FormPickerField: View {
    let title: String
    @Binding var selection: String
    let options: [String]
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(Color.gray)
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color(hex: "4D52C7"))
                    .frame(width: 24, height: 24)
                
                Picker(title, selection: $selection) {
                    ForEach(options, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .foregroundColor(Color(hex: "333333"))
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}

// Dish Preview Card for QuickLook
struct DishPreviewCard: UIViewControllerRepresentable {
    let modelURL: URL
    
    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, QLPreviewControllerDataSource {
        let parent: DishPreviewCard
        
        init(_ parent: DishPreviewCard) {
            self.parent = parent
        }
        
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return 1
        }
        
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            return parent.modelURL as QLPreviewItem
        }
    }
}

// Note: Color extension is imported from ColorExtension.swift

struct DishSignUpView_Previews: PreviewProvider {
    static var previews: some View {
        // For preview purposes, simulate a file URL in the Documents directory.
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dummyURL = documentsDirectory.appendingPathComponent("model-mobile.usdz")
        DishSignUpView(capturedUSDZURL: dummyURL)
    }
}
