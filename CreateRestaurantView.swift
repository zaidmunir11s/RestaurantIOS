import SwiftUI

struct CreateRestaurantView: View {
    @StateObject private var viewModel = RestaurantViewModel()
    
    // Form fields
    @State private var restaurantName: String = ""
    @State private var cuisine: String = ""
    @State private var address: String = ""
    @State private var city: String = ""
    @State private var state: String = ""
    @State private var zipCode: String = ""
    @State private var phone: String = ""
    @State private var email: String = ""
    @State private var website: String = ""
    @State private var description: String = ""
    
    // Image selection
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker = false
    
    // UI state
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isSuccess = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "EFF1FA"), Color(hex: "EFF1FA")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header Card
                    ZStack(alignment: .topTrailing) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Create New")
                                .font(.headline)
                                .foregroundColor(.black.opacity(0.7))
                            
                            Text("Restaurant")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(
                            ZStack(alignment: .topTrailing) {
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(Color(hex: "FFE8CC"))
                                
                                // Decorative circles
                                HStack(spacing: -10) {
                                    Circle()
                                        .fill(Color(hex: "4D52C7"))
                                        .frame(width: 50, height: 50)
                                    
                                    Circle()
                                        .fill(Color(hex: "F9D56E"))
                                        .frame(width: 60, height: 60)
                                        
                                    Circle()
                                        .fill(Color(hex: "FF8A8A"))
                                        .frame(width: 30, height: 30)
                                        .offset(x: 0, y: 20)
                                }
                                .offset(x: -20, y: -10)
                            }
                        )
                    }
                    
                    // Restaurant Image Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Restaurant Image")
                            .font(.headline)
                            .padding(.horizontal, 20)
                        
                        ZStack {
                            if let selectedImage = selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 200)
                                    .frame(maxWidth: .infinity)
                                    .clipped()
                                    .cornerRadius(12)
                                    .overlay(
                                        Button(action: {
                                            self.selectedImage = nil
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.system(size: 22))
                                                .foregroundColor(.white)
                                                .padding(8)
                                                .background(Color.black.opacity(0.6))
                                                .clipShape(Circle())
                                        }
                                        .padding(10),
                                        alignment: .topTrailing
                                    )
                            } else {
                                Button(action: {
                                    showImagePicker = true
                                }) {
                                    VStack(spacing: 12) {
                                        Image(systemName: "photo.on.rectangle.angled")
                                            .font(.system(size: 40))
                                            .foregroundColor(Color(hex: "4D52C7"))
                                        
                                        Text("Tap to add restaurant image")
                                            .font(.headline)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 200)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(hex: "4D52C7").opacity(0.3), lineWidth: 1)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .sheet(isPresented: $showImagePicker) {
                            ImagePicker(selectedImage: $selectedImage)
                        }
                    }
                    
                    // Form Fields
                    GroupBox(label: Text("Basic Information").bold()) {
                        VStack(spacing: 20) {
                            InputField(title: "Restaurant Name", text: $restaurantName, icon: "building.2.fill")
                            
                            InputField(title: "Cuisine Type", text: $cuisine, icon: "fork.knife")
                            
                            InputField(title: "Description", text: $description, icon: "text.alignleft", isMultiline: true)
                        }
                        .padding(.vertical, 10)
                    }
                    
                    GroupBox(label: Text("Contact Information").bold()) {
                        VStack(spacing: 20) {
                            InputField(title: "Phone Number", text: $phone, icon: "phone.fill", keyboardType: .phonePad)
                            
                            InputField(title: "Email", text: $email, icon: "envelope.fill", keyboardType: .emailAddress)
                            
                            InputField(title: "Website", text: $website, icon: "globe")
                        }
                        .padding(.vertical, 10)
                    }
                    
                    GroupBox(label: Text("Address").bold()) {
                        VStack(spacing: 20) {
                            InputField(title: "Street Address", text: $address, icon: "mappin.circle.fill")
                            
                            InputField(title: "City", text: $city, icon: "building.2")
                            
                            InputField(title: "State", text: $state, icon: "map")
                            
                            InputField(title: "Zip Code", text: $zipCode, icon: "location.circle", keyboardType: .numberPad)
                        }
                        .padding(.vertical, 10)
                    }
                    
                    // Save Button
                    Button(action: {
                        saveRestaurant()
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
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
                        } else {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Save Restaurant")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
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
                    }
                    .disabled(viewModel.isLoading)
                    
                    // Cancel Button
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                            .font(.headline)
                            .foregroundColor(Color(hex: "4D52C7"))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(hex: "4D52C7"), lineWidth: 1)
                            )
                    }
                }
                .padding(20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("New Restaurant")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(isSuccess ? "Success" : "Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if isSuccess {
                        dismiss()
                    }
                }
            )
        }
    }
    
    private func saveRestaurant() {
        // Validation
        if restaurantName.isEmpty || address.isEmpty || city.isEmpty || state.isEmpty || phone.isEmpty {
            alertMessage = "Please fill in all required fields"
            showAlert = true
            return
        }
        
        let restaurant = CreateRestaurantModel(
            name: restaurantName,
            cuisine: cuisine,
            address: address,
            city: city,
            state: state,
            zipCode: zipCode,
            phone: phone,
            email: email,
            website: website,
            description: description,
            status: "active",
            imageUrl: nil
        )
        
        // Extract image data if available
        var imageData: Data? = nil
        if let selectedImage = selectedImage {
            imageData = selectedImage.jpegData(compressionQuality: 0.8)
        }
        
        Task {
            let result = await viewModel.createRestaurant(restaurant: restaurant, imageData: imageData)
            
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    isSuccess = true
                    alertMessage = "Restaurant created successfully!"
                    showAlert = true
                    
                case .failure(let error):
                    isSuccess = false
                    if let apiError = error as? APIError {
                        alertMessage = apiError.message
                    } else {
                        alertMessage = "Failed to create restaurant: \(error.localizedDescription)"
                    }
                    showAlert = true
                }
            }
        }
    }
}

// Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
