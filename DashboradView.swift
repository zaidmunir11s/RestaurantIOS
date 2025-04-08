import SwiftUI

struct DashboardView: View {
    // For navigation
    @State private var navigateToRestaurants = false
    @State private var navigateToUserManagement = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "4D52C7"), Color(hex: "4D52C7")]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with menu and profile
                    HStack {
                        Button(action: {}) {
                            Image(systemName: "line.3.horizontal")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 36, height: 36)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 20)
                    
                    // Main Content Area (White background)
                    ScrollView {
                        VStack(spacing: 24) {
                            // Welcome Card
                            WelcomeCard()
                                .padding(.top, 20)
                            
                            // Categories Section
                            CategoriesSection(
                                navigateToRestaurants: $navigateToRestaurants,
                                navigateToUserManagement: $navigateToUserManagement
                            )
                            
                            // Popular Restaurants Section
                            PopularRestaurantsSection()
                            
                            Spacer(minLength: 40)
                        }
                        .padding(.horizontal, 20)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color(hex: "EFF1FA"))
                    )
                }
            }
            .navigationDestination(isPresented: $navigateToRestaurants) {
                RestaurantListView()
            }
            .navigationDestination(isPresented: $navigateToUserManagement) {
                UserManagementView()
            }
            .navigationBarHidden(true)
        }
    }
}

// Welcome Card Component
struct WelcomeCard: View {
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Welcome,")
                    .font(.subheadline)
                    .foregroundColor(.black.opacity(0.7))
                
                Text("Find your\ndream Restaurant!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
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
    }
}

// Categories Section Component
struct CategoriesSection: View {
    @Binding var navigateToRestaurants: Bool
    @Binding var navigateToUserManagement: Bool
    
    let categories = ["Restaurants", "Branches", "Dishes", "User Management"]
    let icons = ["building.2.fill", "mappin.and.ellipse", "fork.knife", "person.3.fill"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Explore Categories")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                
                Spacer()
                
                Text("•••")
                    .font(.title3)
                    .foregroundColor(.gray)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    CategoryItem(
                        title: categories[0],
                        icon: icons[0],
                        isSelected: true,
                        action: { navigateToRestaurants = true }
                    )
                    
                    CategoryItem(
                        title: categories[1],
                        icon: icons[1],
                        isSelected: false,
                        action: {}
                    )
                    
                    CategoryItem(
                        title: categories[2],
                        icon: icons[2],
                        isSelected: false,
                        action: {}
                    )
                    
                    CategoryItem(
                        title: categories[3],
                        icon: icons[3],
                        isSelected: false,
                        action: { navigateToUserManagement = true }
                    )
                }
                .padding(.vertical, 8)
            }
        }
    }
}

// Category Item Component
struct CategoryItem: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? .white : .gray)
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(isSelected ? Color(hex: "4D52C7") : Color.white)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
                
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(isSelected ? .black : .gray)
            }
            .frame(width: 80)
        }
    }
}

// Restaurant List Section Component
struct PopularRestaurantsSection: View {
    // Dummy restaurant data
    let restaurants = ["Restaurant A", "Restaurant B", "Restaurant C"]
    @State private var navigateToCreateRestaurant = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Popular Restaurants")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                
                Spacer()
                
                Text("•••")
                    .font(.title3)
                    .foregroundColor(.gray)
            }
            
            // Horizontal Restaurant Cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(restaurants, id: \.self) { restaurant in
                        NavigationLink(destination: BranchListView(restaurantName: restaurant)) {
                            RestaurantCard(restaurantName: restaurant)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Button to create a new restaurant
            Button(action: {
                navigateToCreateRestaurant = true
            }) {
                Label("Create New Restaurant", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "4D52C7").opacity(0.9))
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(radius: 3)
            }
            .padding(.top, 8)
            .navigationDestination(isPresented: $navigateToCreateRestaurant) {
                CreateRestaurantView()
            }
        }
    }
}

// Restaurant Card Component for Horizontal Slider
struct RestaurantCard: View {
    let restaurantName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Spacer()
            
            Text(restaurantName)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Text("Tap to view")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(20)
        .frame(width: 180, height: 140)
        .background(
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(hex: "FFE8CC"))
                
                // Decorative circles
                HStack(spacing: -5) {
                    Circle()
                        .fill(Color(hex: "FF8A8A"))
                        .frame(width: 20, height: 20)
                        
                    Circle()
                        .fill(Color(hex: "4D52C7"))
                        .frame(width: 40, height: 40)
                }
                .padding([.top, .trailing], 15)
            }
        )
    }
}

// Note: Color extension is imported from ColorExtension.swift

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
