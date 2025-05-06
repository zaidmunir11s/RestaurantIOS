import SwiftUI

struct MenuListView: View {
    let restaurantId: String
    let restaurantName: String
    
    @StateObject private var viewModel = MenuViewModel()
    @State private var navigateToCapture = false
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
                        
                        // Fix for ContentView argument issue
                        if #available(iOS 17.0, *) {
                            NavigationLink(destination: ContentView().environmentObject(AppDataModel.instance)) {
                                Button(action: {
                                    navigateToCapture = true
                                }) {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Add Dish")
                                    }
                                    .foregroundColor(Color(hex: "4D52C7"))
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Restaurant Title Card
                    ZStack(alignment: .topTrailing) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Menu")
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
                }
                .padding(.bottom, 20)
                
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
                            viewModel.fetchMenuItems(restaurantId: restaurantId)
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
                } else if viewModel.menuItems.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "fork.knife")
                            .font(.system(size: 60))
                            .foregroundColor(Color(hex: "4D52C7").opacity(0.5))
                        
                        Text("No Menu Items Yet")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Capture your first dish for this restaurant")
                            .foregroundColor(.gray)
                            
                        // Fix for ContentView argument
                        if #available(iOS 17.0, *) {
                            NavigationLink(destination: ContentView().environmentObject(AppDataModel.instance)) {
                                Text("Capture Dish")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color(hex: "FF8A8A"))
                                    .cornerRadius(10)
                            }
                        }
                    }
                    Spacer()
                } else {
                    // Group menu items by category
                    let groupedItems = Dictionary(grouping: viewModel.menuItems) { $0.category }
                    
                    ScrollView {
                        ForEach(groupedItems.keys.sorted(), id: \.self) { category in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(category)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 20)
                                    .padding(.top, 15)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 15) {
                                        ForEach(groupedItems[category] ?? [], id: \.id) { item in
                                            MenuItemCardView(item: item)
                                                .frame(width: 180, height: 220)
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.fetchMenuItems(restaurantId: restaurantId)
        }
    }
}

// Renamed to avoid redeclaration
struct MenuItemCardView: View {
    let item: MenuItemResponse
    @State private var showARView = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            VStack(spacing: 8) {
                // Model preview area
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "FFE8CC"))
                        .frame(height: 120)
                    
                    if item.modelUrl != nil {
                        Button(action: {
                            showARView = true
                        }) {
                            VStack {
                                Image(systemName: "arkit")
                                    .font(.system(size: 30))
                                    .foregroundColor(Color(hex: "4D52C7"))
                                
                                Text("View in AR")
                                    .font(.caption)
                                    .foregroundColor(Color(hex: "333333"))
                            }
                        }
                    } else {
                        Image(systemName: "fork.knife")
                            .font(.system(size: 30))
                            .foregroundColor(Color(hex: "4D52C7"))
                    }
                }
                
                // Item details
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.headline)
                        .foregroundColor(Color(hex: "333333"))
                        .lineLimit(1)
                    
                    Text(item.category)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                    
                    if item.price > 0 {
                        Text("$\(String(format: "%.2f", item.price))")
                            .font(.subheadline)
                            .foregroundColor(Color(hex: "4D52C7"))
                            .fontWeight(.bold)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
            }
            .padding(8)
        }
        .sheet(isPresented: $showARView) {
            if let modelUrl = item.modelUrl, let url = URL(string: modelUrl) {
                ARQuickLookView(fileURL: url)
            }
        }
    }
}
