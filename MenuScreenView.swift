// MenuScreenView.swift
import SwiftUI

struct MenuScreenView: View {
    let branchId: String
    let branchName: String
    let restaurantId: String
    
    @StateObject private var viewModel = MenuViewModel()
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
                    
                    // Branch Title Card
                    ZStack(alignment: .topTrailing) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Menu")
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
                    
                    // Category Selector
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(["All"] + viewModel.categories, id: \.self) { category in
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
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                    Spacer()
                } else if let errorMessage = viewModel.errorMessage {
                    Spacer()
                    VStack(spacing: 16) {
                        Text("Error Loading Menu")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(errorMessage)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: {
                            viewModel.fetchMenuItems(restaurantId: restaurantId, branchId: branchId)
                            viewModel.fetchCategories(restaurantId: restaurantId, branchId: branchId)
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
                                viewModel.menuItems :
                                viewModel.menuItems.filter { $0.category == selectedCategory }
                            
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
                                                await viewModel.deleteMenuItem(id: itemId)
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
                            viewModel.fetchMenuItems(restaurantId: restaurantId, branchId: branchId)
                        }
                } else {
                    Text("AR Capture requires iOS 17.0 or later")
                }
            }
            .sheet(isPresented: $showAddCategorySheet) {
                AddCategoryView(
                    isPresented: $showAddCategorySheet,
                    restaurantId: restaurantId,
                    branchId: branchId,
                    onSave: { newCategory in
                        Task {
                            await viewModel.addCategory(
                                restaurantId: restaurantId,
                                branchId: branchId,
                                categoryName: newCategory
                            )
                        }
                    }
                )
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.fetchMenuItems(restaurantId: restaurantId, branchId: branchId)
            viewModel.fetchCategories(restaurantId: restaurantId, branchId: branchId)
        }
    }
}

// Menu Category Section
struct MenuCategorySection: View {
    let title: String
    let items: [MenuItemResponse]
    let onDelete: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Section Header
            HStack {
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            // Item List
            VStack(spacing: 12) {
                ForEach(items, id: \.id) { item in
                    NavigationLink(destination: DishDetailView(dish: Dish(title: item.title, price: "$\(String(format: "%.2f", item.price))"))) {
                        MenuItemCard(item: item, onDelete: onDelete)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 10)
    }
}

// Menu Item Card
struct MenuItemCard: View {
    let item: MenuItemResponse
    let onDelete: (String) -> Void
    
    var body: some View {
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
                
                if item.isVegetarian {
                    Text("Vegetarian")
                        .font(.caption)
                        .foregroundColor(.green)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(4)
                }
            }
            .padding(.leading, 10)
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: 15) {
                // If there's a 3D model
                if let modelUrl = item.modelUrl, !modelUrl.isEmpty {
                    Image(systemName: "arkit")
                        .foregroundColor(Color(hex: "4D52C7"))
                        .font(.system(size: 16))
                        .padding(8)
                        .background(Circle().fill(Color(hex: "EFF1FA")))
                }
                
                Button(action: {
                    onDelete(item.id)
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.system(size: 16))
                        .padding(8)
                        .background(Circle().fill(Color(hex: "EFF1FA")))
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// Add Category View
struct AddCategoryView: View {
    @Binding var isPresented: Bool
    let restaurantId: String
    let branchId: String
    let onSave: (String) -> Void
    
    @State private var categoryName: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header
                Text("Add New Category")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                // Category Name Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Category Name")
                        .font(.subheadline)
                        .foregroundColor(Color.gray)
                    
                    TextField("Enter category name", text: $categoryName)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                
                Spacer()
                
                // Save Button
                Button(action: {
                    guard !categoryName.isEmpty else { return }
                    onSave(categoryName)
                    isPresented = false
                }) {
                    Text("Save Category")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "4D52C7"))
                        .cornerRadius(12)
                }
                .disabled(categoryName.isEmpty)
                
                // Cancel Button
                Button(action: {
                    isPresented = false
                }) {
                    Text("Cancel")
                        .font(.headline)
                        .foregroundColor(Color(hex: "4D52C7"))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "4D52C7"), lineWidth: 1)
                        )
                }
            }
            .padding()
            .background(Color(hex: "EFF1FA"))
        }
    }
}
