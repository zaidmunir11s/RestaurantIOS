import SwiftUI

// MARK: - Models & Enums

/// Generic menu item model used for both dishes and deals.
struct MenuItem: Identifiable {
    let id = UUID()
    let title: String
    let price: String
}

/// Top-level category (Dishes or Deals)
enum MenuCategory: String, CaseIterable, Identifiable {
    case dishes = "Dishes"
    case deals = "Deals"
    
    var id: String { self.rawValue }
}

/// Subcategories within Dishes.
enum DishSubcategory: String, CaseIterable, Identifiable {
    case drinks = "Drinks"
    case fastFood = "Fast Food"
    
    var id: String { self.rawValue }
}

// MARK: - Main MenuScreenView

struct MenuScreenView: View {
    let branchName: String
    
    // Dummy data for Deals.
    let dealItems = [
        MenuItem(title: "Combo Deal", price: "$15"),
        MenuItem(title: "Lunch Special", price: "$9")
    ]
    
    // Dummy data for Dishes, organized by subcategory.
    let dishData: [DishSubcategory: [MenuItem]] = [
        .drinks: [
            MenuItem(title: "Cola", price: "$2"),
            MenuItem(title: "Pepsi", price: "$2")
        ],
        .fastFood: [
            MenuItem(title: "Burger", price: "$5"),
            MenuItem(title: "Pizza", price: "$8")
        ]
    ]
    
    @State private var selectedCategory: MenuCategory = .dishes
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
                    
                    // Menu Category Selector
                    HStack {
                        ForEach(MenuCategory.allCases) { category in
                            Button(action: {
                                withAnimation {
                                    selectedCategory = category
                                }
                            }) {
                                VStack(spacing: 8) {
                                    Text(category.rawValue)
                                        .font(.headline)
                                        .foregroundColor(selectedCategory == category ? Color(hex: "4D52C7") : .gray)
                                    
                                    // Indicator bar
                                    Rectangle()
                                        .frame(height: 3)
                                        .foregroundColor(selectedCategory == category ? Color(hex: "4D52C7") : .clear)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 10)
                
                // Menu Content
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
                        
                        if selectedCategory == .dishes {
                            // Dishes Categories
                            ForEach(DishSubcategory.allCases) { subcategory in
                                MenuCategorySection(
                                    title: subcategory.rawValue,
                                    items: dishData[subcategory] ?? []
                                )
                            }
                        } else {
                            // Deals Section
                            MenuCategorySection(
                                title: "Special Deals",
                                items: dealItems
                            )
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationDestination(isPresented: $navigateToARCapture) {
                if #available(iOS 17.0, *) {
                    ContentView()
                } else {
                    Text("AR Capture requires iOS 17.0 or later")
                }
            }
            .sheet(isPresented: $showAddCategorySheet) {
                AddCategoryView(isPresented: $showAddCategorySheet)
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Supporting Views

// Menu Category Section
struct MenuCategorySection: View {
    let title: String
    let items: [MenuItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Section Header
            HStack {
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    // Edit category action
                }) {
                    Image(systemName: "pencil")
                        .foregroundColor(.gray)
                }
                
                Button(action: {
                    // Delete category action
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal, 20)
            
            // Item List
            VStack(spacing: 12) {
                ForEach(items) { item in
                    NavigationLink(destination: DishDetailView(dish: Dish(title: item.title, price: item.price))) {
                        MenuItemCard(item: item)
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
    let item: MenuItem
    
    var body: some View {
        HStack {
            // Preview Image
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "FFE8CC"))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "fork.knife")
                        .foregroundColor(Color(hex: "4D52C7"))
                        .font(.system(size: 24))
                )
            
            // Item Details
            VStack(alignment: .leading, spacing: 5) {
                Text(item.title)
                    .font(.headline)
                    .foregroundColor(Color(hex: "333333"))
                
                Text(item.price)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.leading, 10)
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: 15) {
                Button(action: {
                    // Toggle visibility action
                }) {
                    Image(systemName: "eye")
                        .foregroundColor(Color(hex: "4D52C7"))
                        .font(.system(size: 16))
                        .padding(8)
                        .background(Circle().fill(Color(hex: "EFF1FA")))
                }
                
                Button(action: {
                    // Edit action
                }) {
                    Image(systemName: "pencil")
                        .foregroundColor(Color(hex: "F9D56E"))
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
    @State private var categoryName: String = ""
    @State private var categoryType: String = "Dish"
    let categoryTypes = ["Dish", "Deal"]
    
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
                
                // Category Type Selector
                VStack(alignment: .leading, spacing: 8) {
                    Text("Category Type")
                        .font(.subheadline)
                        .foregroundColor(Color.gray)
                    
                    Picker("Category Type", selection: $categoryType) {
                        ForEach(categoryTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Spacer()
                
                // Save Button
                Button(action: {
                    // Save logic here
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

// Note: Color extension is imported from ColorExtension.swift

struct MenuScreenView_Previews: PreviewProvider {
    static var previews: some View {
        MenuScreenView(branchName: "Main Branch")
    }
}
