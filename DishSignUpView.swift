import SwiftUI
import QuickLook
import UniformTypeIdentifiers

struct DishSignUpView: View {
    // The captured USDZ file URL.
    let capturedUSDZURL: URL
    
    // Add restaurantId parameter - if provided, we'll pre-select that restaurant
    var restaurantId: String = ""
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) var presentationMode
    
    // View model
    @StateObject private var menuViewModel = MenuViewModel()
    @StateObject private var restaurantViewModel = RestaurantViewModel()
    
    // Dish details.
    @State private var dishTitle: String = ""
    @State private var dishPrice: String = ""
    @State private var dishDescription: String = ""
    @State private var dishCategory: String = ""
    @State private var isVegetarian: Bool = false
    @State private var calories: String = ""
    @State private var ingredients: String = ""
    
    // For restaurant/branch selection
    @State private var selectedRestaurantId: String = ""
    @State private var selectedRestaurantName: String = ""
    @State private var selectedBranchId: String? = nil
    
    // For image preview
    @State private var selectedURL: URL? = nil
    @State private var navigationToDashboard = false
    
    // Form validation
    @State private var showError: Bool = false
    @State private var errorMessage: String? = nil
    @State private var showSuccess: Bool = false
    
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
                        
                        // Restaurant Selection
                        FormCard(title: "Restaurant Information") {
                            if restaurantViewModel.isLoading {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                    Spacer()
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                            } else {
                                // Restaurant Picker
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Restaurant")
                                        .font(.subheadline)
                                        .foregroundColor(Color.gray)
                                    
                                    Picker("Select Restaurant", selection: $selectedRestaurantId) {
                                        Text("Select a restaurant").tag("")
                                        ForEach(restaurantViewModel.restaurants, id: \.id) { restaurant in
                                            Text(restaurant.name).tag(restaurant.id)
                                        }
                                    }
                                    .onChange(of: selectedRestaurantId) { newId in
                                        if let restaurant = restaurantViewModel.restaurants.first(where: { $0.id == newId }) {
                                            selectedRestaurantName = restaurant.name
                                            
                                            // Reset branch selection
                                            selectedBranchId = nil
                                            
                                            // Fetch categories for this restaurant
                                            if !newId.isEmpty {
                                                menuViewModel.fetchCategories(restaurantId: newId)
                                            }
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                }
                            }
                        }
                        
                        // Dish Details Form
                        FormCard(title: "Basic Details") {
                            // Dish Name
                            FormTextField(title: "Dish Name", text: $dishTitle, icon: "fork.knife")
                            
                            // Dish Price
                            FormTextField(title: "Price", text: $dishPrice, icon: "dollarsign.circle", keyboardType: .decimalPad)
                            
                            // Category Picker
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Category")
                                    .font(.subheadline)
                                    .foregroundColor(Color.gray)
                                
                                Picker("Select Category", selection: $dishCategory) {
                                    Text("Select a category").tag("")
                                    ForEach(menuViewModel.categories, id: \.self) { category in
                                        Text(category).tag(category)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            }
                            
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
                        
                        // Success Message
                        if showSuccess {
                            Text("Dish created successfully!")
                                .font(.subheadline)
                                .foregroundColor(.green)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.green.opacity(0.1))
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
        .onAppear {
            // Fetch restaurants when view appears
            restaurantViewModel.fetchRestaurants()
            
            // Pre-select restaurant if ID was provided
            if !restaurantId.isEmpty {
                print("DEBUG: Pre-selecting restaurant with ID: \(restaurantId)")
                selectedRestaurantId = restaurantId
                
                // Set restaurant name and fetch categories
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if let restaurant = restaurantViewModel.restaurants.first(where: { $0.id == restaurantId }) {
                        selectedRestaurantName = restaurant.name
                        print("DEBUG: Found restaurant name: \(restaurant.name)")
                    } else {
                        print("DEBUG: Restaurant with ID \(restaurantId) not found in loaded restaurants")
                    }
                    
                    // Fetch categories for this restaurant
                    menuViewModel.fetchCategories(restaurantId: restaurantId)
                }
            }
        }
    }
    
    private func validateAndSave() {
        // Reset error
        errorMessage = nil
        showError = false
        showSuccess = false
        
        // Validation
        if selectedRestaurantId.isEmpty {
            errorMessage = "Please select a restaurant"
            showError = true
            return
        }
        
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
        
        if dishCategory.isEmpty {
            errorMessage = "Please select a category"
            showError = true
            return
        }
        
        // Price validation
        let priceString = dishPrice.replacingOccurrences(of: "$", with: "")
        guard let price = Double(priceString), price > 0 else {
            errorMessage = "Price must be greater than zero"
            showError = true
            return
        }
        
        // Create the menu item object
        let menuItem = CreateMenuItemModel(
            title: dishTitle,
            description: dishDescription,
            price: price,
            category: dishCategory,
            status: "active",
            restaurantId: selectedRestaurantId,
            branchId: selectedBranchId,
            imageUrl: nil,
            modelUrl: nil, // Will be uploaded separately
            isVegetarian: isVegetarian,
            isVegan: false,
            isGlutenFree: false,
            featured: false
        )
        
        // Get the 3D model data
        guard let modelData = try? Data(contentsOf: capturedUSDZURL) else {
            errorMessage = "Error reading model data"
            showError = true
            return
        }
        
        print("DEBUG: About to save menu item with restaurant ID: \(selectedRestaurantId)")
        print("DEBUG: Model data size: \(modelData.count) bytes")
        
        // Save the menu item
        Task {
            do {
                let result = await menuViewModel.createMenuItem(menuItem: menuItem, modelData: modelData)
                
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        showSuccess = true
                        // Reset form fields after successful save
                        dishTitle = ""
                        dishPrice = ""
                        dishDescription = ""
                        dishCategory = ""
                        isVegetarian = false
                        calories = ""
                        ingredients = ""
                        
                        // Automatically navigate back after short delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            navigationToDashboard = true
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        if let apiError = error as? APIError {
                            errorMessage = apiError.message
                            print("DEBUG: API Error: \(apiError.message)")
                        } else {
                            errorMessage = error.localizedDescription
                            print("DEBUG: General Error: \(error.localizedDescription)")
                        }
                        showError = true
                    }
                }
            }
        }
    }
}
