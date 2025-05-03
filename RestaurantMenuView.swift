import SwiftUI

struct RestaurantMenuView: View {
    let restaurantId: String
    let restaurantName: String
    
    @StateObject private var menuViewModel = MenuViewModel()
    @State private var selectedCategory: String = "All"
    @State private var showAddCategorySheet = false
    @State private var navigateToARCapture = false
    @Environment(\.dismiss) private var dismiss
    
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
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Restaurant Title Card
                    ZStack(alignment: .topTrailing) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Restaurant Menu")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text(restaurantName)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(24)
                        .background(
                            ZStack(alignment: .topTrailing) {
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(Color(hex: "4D52C7"))
                                
                                // Decorative circles
                                HStack(spacing: -5) {
                                    Circle()
                                        .fill(Color(hex: "FF8A8A"))
                                        .frame(width: 20, height: 20)
                                        
                                    Circle()
                                        .fill(Color(hex: "F9D56E"))
                                        .frame(width: 40, height: 40)
                                }
                                .padding([.top, .trailing], 15)
                            }
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                    
                    // Category Selector
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(["All"] + menuViewModel.categories, id: \.self) { category in
                                Button(action: {
                                    withAnimation {
                                        selectedCategory = category
                                    }
                                }) {
                                    VStack(spacing: 8) {
                                        Text(category)
                                            .font(.headline)
                                            .foregroundColor(selectedCategory == category ? Color(hex: "4D52C7") : .gray)
                                        
                                        // Indicator bar
                                        Rectangle()
                                            .frame(height: 3)
                                            .foregroundColor(selectedCategory == category ? Color(hex: "4D52C7") : .clear)
                                    }
                                    .padding(.horizontal, 10)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 20)
                }
                .padding(.bottom, 10)
                
                // Menu Content
                if menuViewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                    Spacer()
                } else if let errorMessage = menuViewModel.errorMessage {
                    Spacer()
                    VStack(spacing: 16) {
                        Text("Error Loading Menu")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(errorMessage)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: {
                            menuViewModel.fetchMenuItems(restaurantId: restaurantId)
                            menuViewModel.fetchCategories(restaurantId: restaurantId)
                        }) {
                            Text("Try Again")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color(hex: "4D52C7"))
                                .cornerRadius(10)
                        }
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 25) {
                            // Add Category and Add Item Buttons
                            HStack {
                                // Add Category Button
                                Button(action: {
                                    showAddCategorySheet = true
                                }) {
                                    HStack {
                                        Image(systemName: "folder.badge.plus")
                                        Text("Add Category")
                                    }
                                    .font(.subheadline)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 15)
                                    .background(Color(hex: "4D52C7").opacity(0.1))
                                    .foregroundColor(Color(hex: "4D52C7"))
                                    .cornerRadius(10)
                                }
                                
                                Spacer()
                                
                                // Add Item Button (for AR Capture)
                                Button(action: {
                                    navigateToARCapture = true
                                }) {
                                    HStack {
                                        Image(systemName: "camera.viewfinder")
                                        Text("Capture New Dish")
                                    }
                                    .font(.subheadline)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 15)
                                    .background(Color(hex: "FF8A8A").opacity(0.2))
                                    .foregroundColor(Color(hex: "FF8A8A"))
                                    .cornerRadius(10)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                            
                            // Filter items by category
                            let filteredItems = selectedCategory == "All" ?
                                menuViewModel.menuItems :
                                menuViewModel.menuItems.filter { $0.category == selectedCategory }
                            
                            // Group items by category
                            let groupedItems = Dictionary(grouping: filteredItems) { $0.category }
                            
                            // Display items by category
                            ForEach(groupedItems.keys.sorted(), id: \.self) { category in
                                if let items = groupedItems[category] {
                                    MenuCategorySection(
                                        title: category,
                                        items: items,
                                        onDelete: { itemId in
                                            Task {
                                                await menuViewModel.deleteMenuItem(id: itemId)
                                            }
                                        }
                                    )
                                }
                            }
                            
                            if filteredItems.isEmpty {
                                VStack(spacing: 20) {
                                    Image(systemName: "fork.knife")
                                        .font(.system(size: 50))
                                        .foregroundColor(Color(hex: "4D52C7").opacity(0.5))
                                    
                                    Text("No items found")
                                        .font(.title3)
                                        .fontWeight(.medium)
                                    
                                    Text("Add menu items or select a different category")
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(.vertical, 50)
                            }
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToARCapture) {
                if #available(iOS 17.0, *) {
                    ContentView()
                        .onDisappear {
                            // This will refresh the menu when returning from AR capture
                            menuViewModel.fetchMenuItems(restaurantId: restaurantId)
                        }
                } else {
                    Text("AR Capture requires iOS 17.0 or later")
                }
            }
            .sheet(isPresented: $showAddCategorySheet) {
                AddCategoryView(
                    isPresented: $showAddCategorySheet,
                    restaurantId: restaurantId,
                    branchId: "",
                    onSave: { newCategory in
                        Task {
                            await menuViewModel.addCategory(
                                restaurantId: restaurantId,
                                categoryName: newCategory
                            )
                        }
                    }
                )
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            menuViewModel.fetchMenuItems(restaurantId: restaurantId)
            menuViewModel.fetchCategories(restaurantId: restaurantId)
        }
    }
}

struct BranchMenuView: View {
    let branchId: String
    let branchName: String
    let restaurantId: String
    
    @StateObject private var menuViewModel = MenuViewModel()
    @State private var selectedCategory: String = "All"
    @Environment(\.dismiss) private var dismiss
    
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
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Branch Title Card
                    ZStack(alignment: .topTrailing) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Branch Menu")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text(branchName)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(24)
                        .background(
                            ZStack(alignment: .topTrailing) {
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(Color(hex: "4D52C7"))
                                
                                // Decorative circles
                                HStack(spacing: -5) {
                                    Circle()
                                        .fill(Color(hex: "FF8A8A"))
                                        .frame(width: 20, height: 20)
                                        
                                    Circle()
                                        .fill(Color(hex: "F9D56E"))
                                        .frame(width: 40, height: 40)
                                }
                                .padding([.top, .trailing], 15)
                            }
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                    
                    // Import Menu Button
                    NavigationLink(destination: ImportMenuView(branchId: branchId, branchName: branchName, restaurantId: restaurantId)) {
                        HStack {
                            Image(systemName: "arrow.down.doc")
                            Text("Import Items from Restaurant Menu")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "FF8A8A"), Color(hex: "FF6B6B")]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: Color(hex: "FF8A8A").opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Category Selector
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(["All"] + menuViewModel.categories, id: \.self) { category in
                                Button(action: {
                                    withAnimation {
                                        selectedCategory = category
                                    }
                                }) {
                                    VStack(spacing: 8) {
                                        Text(category)
                                            .font(.headline)
                                            .foregroundColor(selectedCategory == category ? Color(hex: "4D52C7") : .gray)
                                        
                                        // Indicator bar
                                        Rectangle()
                                            .frame(height: 3)
                                            .foregroundColor(selectedCategory == category ? Color(hex: "4D52C7") : .clear)
                                    }
                                    .padding(.horizontal, 10)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 20)
                }
                .padding(.bottom, 10)
                
                // Menu Content
                if menuViewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                    Spacer()
                } else if let errorMessage = menuViewModel.errorMessage {
                    Spacer()
                    VStack(spacing: 16) {
                        Text("Error Loading Menu")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(errorMessage)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: {
                            menuViewModel.fetchMenuItems(restaurantId: restaurantId, branchId: branchId)
                            menuViewModel.fetchCategories(restaurantId: restaurantId, branchId: branchId)
                        }) {
                            Text("Try Again")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color(hex: "4D52C7"))
                                .cornerRadius(10)
                        }
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 25) {
                            // Filter items by category
                            let filteredItems = selectedCategory == "All" ?
                                menuViewModel.menuItems :
                                menuViewModel.menuItems.filter { $0.category == selectedCategory }
                            
                            // Group items by category
                            let groupedItems = Dictionary(grouping: filteredItems) { $0.category }
                            
                            // Display items by category
                            ForEach(groupedItems.keys.sorted(), id: \.self) { category in
                                if let items = groupedItems[category] {
                                    MenuCategorySection(
                                        title: category,
                                        items: items,
                                        onDelete: { itemId in
                                            Task {
                                                await menuViewModel.deleteMenuItem(id: itemId)
                                            }
                                        }
                                    )
                                }
                            }
                            
                            if filteredItems.isEmpty {
                                VStack(spacing: 20) {
                                    Image(systemName: "fork.knife")
                                        .font(.system(size: 50))
                                        .foregroundColor(Color(hex: "4D52C7").opacity(0.5))
                                    
                                    Text("No items found")
                                        .font(.title3)
                                        .fontWeight(.medium)
                                    
                                    Text("Import items from the restaurant menu")
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(.vertical, 50)
                            }
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            menuViewModel.fetchMenuItems(restaurantId: restaurantId, branchId: branchId)
            menuViewModel.fetchCategories(restaurantId: restaurantId, branchId: branchId)
        }
    }
}

struct ImportMenuView: View {
    let branchId: String
    let branchName: String
    let restaurantId: String
    
    @StateObject private var restaurantMenuViewModel = MenuViewModel()
    @State private var selectedItems: Set<String> = []
    @State private var selectedCategory: String = "All"
    @State private var isImporting = false
    @State private var showSuccessAlert = false
    @State private var errorMessage: String? = nil
    @Environment(\.dismiss) private var dismiss
    
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
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Title Card
                    ZStack(alignment: .topTrailing) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Import Menu Items")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text("Select items to import to \(branchName)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(24)
                        .background(
                            ZStack(alignment: .topTrailing) {
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(Color(hex: "4D52C7"))
                                
                                // Decorative circles
                                HStack(spacing: -5) {
                                    Circle()
                                        .fill(Color(hex: "FF8A8A"))
                                        .frame(width: 20, height: 20)
                                        
                                    Circle()
                                        .fill(Color(hex: "F9D56E"))
                                        .frame(width: 40, height: 40)
                                }
                                .padding([.top, .trailing], 15)
                            }
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                    
                    // Category Selector
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(["All"] + restaurantMenuViewModel.categories, id: \.self) { category in
                                Button(action: {
                                    withAnimation {
                                        selectedCategory = category
                                    }
                                }) {
                                    VStack(spacing: 8) {
                                        Text(category)
                                            .font(.headline)
                                            .foregroundColor(selectedCategory == category ? Color(hex: "4D52C7") : .gray)
                                        
                                        // Indicator bar
                                        Rectangle()
                                            .frame(height: 3)
                                            .foregroundColor(selectedCategory == category ? Color(hex: "4D52C7") : .clear)
                                    }
                                    .padding(.horizontal, 10)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 20)
                }
                .padding(.bottom, 10)
                
                // Menu Content
                if restaurantMenuViewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                    Spacer()
                } else if let errorMessage = restaurantMenuViewModel.errorMessage {
                    Spacer()
                    VStack(spacing: 16) {
                        Text("Error Loading Menu")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(errorMessage)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: {
                            restaurantMenuViewModel.fetchMenuItems(restaurantId: restaurantId)
                            restaurantMenuViewModel.fetchCategories(restaurantId: restaurantId)
                        }) {
                            Text("Try Again")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color(hex: "4D52C7"))
                                .cornerRadius(10)
                        }
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 25) {
                            // Selection summary
                            HStack {
                                Text("\(selectedItems.count) items selected")
                                    .font(.headline)
                                    .foregroundColor(Color(hex: "4D52C7"))
                                
                                Spacer()
                                
                                if !selectedItems.isEmpty {
                                    Button(action: {
                                        selectedItems.removeAll()
                                    }) {
                                        Text("Clear Selection")
                                            .font(.subheadline)
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                            
                            // Filter items by category
                            let filteredItems = selectedCategory == "All" ?
                                restaurantMenuViewModel.menuItems :
                                restaurantMenuViewModel.menuItems.filter { $0.category == selectedCategory }
                            
                            // Display selectable items
                            VStack(spacing: 15) {
                                ForEach(filteredItems, id: \.id) { item in
                                    SelectableMenuItemCard(
                                        item: item,
                                        isSelected: selectedItems.contains(item.id),
                                        onToggle: { isSelected in
                                            if isSelected {
                                                selectedItems.insert(item.id)
                                            } else {
                                                selectedItems.remove(item.id)
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            if filteredItems.isEmpty {
                                VStack(spacing: 20) {
                                    Image(systemName: "fork.knife")
                                        .font(.system(size: 50))
                                        .foregroundColor(Color(hex: "4D52C7").opacity(0.5))
                                    
                                    Text("No items found")
                                                                            .font(.title3)
                                                                            .fontWeight(.medium)
                                                                        
                                                                        Text("No items available in this category")
                                                                            .foregroundColor(.gray)
                                                                            .multilineTextAlignment(.center)
                                                                    }
                                                                    .padding(.vertical, 50)
                                                                }
                                                            }
                                                            .padding(.bottom, 30)
                                                        }
                                                    }
                                                    
                                                    // Import Button
                                                    Button(action: {
                                                        importSelectedItems()
                                                    }) {
                                                        if isImporting {
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
                                                                Image(systemName: "arrow.down.doc")
                                                                Text("Import Selected Items")
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
                                                    .disabled(selectedItems.isEmpty || isImporting)
                                                    .padding(.horizontal, 20)
                                                    .padding(.bottom, 20)
                                                }
                                            }
                                            .alert(isPresented: $showSuccessAlert) {
                                                Alert(
                                                    title: Text(errorMessage == nil ? "Success" : "Error"),
                                                    message: Text(errorMessage ?? "Items have been imported successfully!"),
                                                    dismissButton: .default(Text("OK")) {
                                                        if errorMessage == nil {
                                                            dismiss()
                                                        }
                                                    }
                                                )
                                            }
                                            .navigationBarHidden(true)
                                            .onAppear {
                                                restaurantMenuViewModel.fetchMenuItems(restaurantId: restaurantId)
                                                restaurantMenuViewModel.fetchCategories(restaurantId: restaurantId)
                                            }
                                        }
                                        
                                        private func importSelectedItems() {
                                            guard !selectedItems.isEmpty else { return }
                                            
                                            isImporting = true
                                            
                                            // Here we would call the API to import menu items to the branch
                                            Task {
                                                do {
                                                    // Select the items to import
                                                    let itemsToImport = restaurantMenuViewModel.menuItems.filter { selectedItems.contains($0.id) }
                                                    
                                                    // Call the API for each item
                                                    for item in itemsToImport {
                                                        do {
                                                            // Create a model to import to branch
                                                            let importModel = CreateMenuItemModel(
                                                                title: item.title,
                                                                description: item.description,
                                                                price: item.price,
                                                                category: item.category,
                                                                status: item.status,
                                                                restaurantId: restaurantId,
                                                                branchId: branchId,  // Now setting branch ID
                                                                imageUrl: item.imageUrl,
                                                                modelUrl: item.modelUrl,
                                                                isVegetarian: item.isVegetarian,
                                                                isVegan: item.isVegan,
                                                                isGlutenFree: item.isGlutenFree,
                                                                featured: item.featured
                                                            )
                                                            
                                                            _ = try await NetworkService.shared.createMenuItem(
                                                                menuItem: importModel,
                                                                token: UserSession.shared.authToken ?? ""
                                                            )
                                                        } catch {
                                                            print("Error importing item \(item.title): \(error)")
                                                            // Continue with next item even if one fails
                                                        }
                                                    }
                                                    
                                                    // Success
                                                    await MainActor.run {
                                                        errorMessage = nil
                                                        isImporting = false
                                                        showSuccessAlert = true
                                                    }
                                                } catch {
                                                    await MainActor.run {
                                                        errorMessage = "Error importing items: \(error.localizedDescription)"
                                                        isImporting = false
                                                        showSuccessAlert = true
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    // Selectable Menu Item Card
                                    struct SelectableMenuItemCard: View {
                                        let item: MenuItemResponse
                                        let isSelected: Bool
                                        let onToggle: (Bool) -> Void
                                        
                                        var body: some View {
                                            Button(action: {
                                                onToggle(!isSelected)
                                            }) {
                                                HStack {
                                                    // Preview Image
                                                    if let imageUrl = item.imageUrl, !imageUrl.isEmpty {
                                                        AsyncImage(url: URL(string: imageUrl)) { phase in
                                                            switch phase {
                                                            case .empty:
                                                                RoundedRectangle(cornerRadius: 12)
                                                                    .fill(Color(hex: "FFE8CC"))
                                                                    .frame(width: 60, height: 60)
                                                                    .overlay(ProgressView())
                                                            case .success(let image):
                                                                image
                                                                    .resizable()
                                                                    .aspectRatio(contentMode: .fill)
                                                                    .frame(width: 60, height: 60)
                                                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                                            case .failure:
                                                                RoundedRectangle(cornerRadius: 12)
                                                                    .fill(Color(hex: "FFE8CC"))
                                                                    .frame(width: 60, height: 60)
                                                                    .overlay(
                                                                        Image(systemName: "fork.knife")
                                                                            .foregroundColor(Color(hex: "4D52C7"))
                                                                    )
                                                            @unknown default:
                                                                RoundedRectangle(cornerRadius: 12)
                                                                    .fill(Color(hex: "FFE8CC"))
                                                                    .frame(width: 60, height: 60)
                                                            }
                                                        }
                                                    } else {
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .fill(Color(hex: "FFE8CC"))
                                                            .frame(width: 60, height: 60)
                                                            .overlay(
                                                                Image(systemName: "fork.knife")
                                                                    .foregroundColor(Color(hex: "4D52C7"))
                                                                    .font(.system(size: 24))
                                                            )
                                                    }
                                                    
                                                    // Item Details
                                                    VStack(alignment: .leading, spacing: 5) {
                                                        Text(item.title)
                                                            .font(.headline)
                                                            .foregroundColor(Color(hex: "333333"))
                                                        
                                                        Text("$\(String(format: "%.2f", item.price))")
                                                            .font(.subheadline)
                                                            .foregroundColor(.gray)
                                                        
                                                        Text(item.category)
                                                            .font(.caption)
                                                            .foregroundColor(.blue)
                                                            .padding(.horizontal, 6)
                                                            .padding(.vertical, 2)
                                                            .background(Color.blue.opacity(0.1))
                                                            .cornerRadius(4)
                                                    }
                                                    .padding(.leading, 10)
                                                    
                                                    Spacer()
                                                    
                                                    // Selection indicator
                                                    ZStack {
                                                        Circle()
                                                            .stroke(isSelected ? Color(hex: "4D52C7") : Color.gray.opacity(0.3), lineWidth: 2)
                                                            .frame(width: 24, height: 24)
                                                        
                                                        if isSelected {
                                                            Circle()
                                                                .fill(Color(hex: "4D52C7"))
                                                                .frame(width: 16, height: 16)
                                                        }
                                                    }
                                                    .padding(.trailing, 10)
                                                }
                                                .padding()
                                                .background(isSelected ? Color(hex: "4D52C7").opacity(0.05) : Color.white)
                                                .cornerRadius(16)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .stroke(isSelected ? Color(hex: "4D52C7") : Color.clear, lineWidth: 2)
                                                )
                                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                            }
                                        }
                                    }
