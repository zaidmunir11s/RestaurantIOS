import SwiftUI

struct RestaurantListView: View {
    @StateObject private var viewModel = RestaurantViewModel()
    @State private var navigateToCreateRestaurant = false
    @State private var showDeleteAlert = false
    @State private var restaurantToDelete: RestaurantResponse?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient for Restaurant list
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "4D52C7"), Color(hex: "5C65DF")]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack {
                    if viewModel.isLoading {
                        // Loading spinner
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                            .padding()
                    } else if let errorMessage = viewModel.errorMessage {
                        // Error view
                        VStack {
                            Text("Error")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding()
                            
                            Text(errorMessage)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding()
                            
                            Button(action: {
                                viewModel.fetchRestaurants()
                            }) {
                                Text("Try Again")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.black.opacity(0.3))
                                    .cornerRadius(10)
                            }
                        }
                        .padding()
                    } else if viewModel.restaurants.isEmpty {
                        // Empty state
                        VStack {
                            Text("No Restaurants")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding()
                            
                            Text("You haven't created any restaurants yet")
                                .foregroundColor(.white)
                                .padding()
                            
                            Button(action: {
                                navigateToCreateRestaurant = true
                            }) {
                                Label("Create Your First Restaurant", systemImage: "plus.circle.fill")
                                    .font(.headline)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.black.opacity(0.3))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                            }
                            .padding(.horizontal)
                        }
                        .padding()
                    } else {
                        // Restaurant list
                        List {
                            ForEach(viewModel.restaurants, id: \.id) { restaurant in
                                NavigationLink(destination: BranchListView(restaurantId: restaurant.id, restaurantName: restaurant.name)) {
                                    HStack {
                                        Image(systemName: "building.2.fill")
                                            .foregroundColor(.white)
                                        VStack(alignment: .leading) {
                                            Text(restaurant.name)
                                                .foregroundColor(.white)
                                                .font(.headline)
                                            
                                            if !restaurant.cuisine.isEmpty {
                                                Text(restaurant.cuisine)
                                                    .foregroundColor(.white.opacity(0.8))
                                                    .font(.subheadline)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            restaurantToDelete = restaurant
                                            showDeleteAlert = true
                                        }) {
                                            Image(systemName: "trash")
                                                .foregroundColor(.red)
                                                .padding(8)
                                                .background(Circle().fill(Color.white.opacity(0.2)))
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.black.opacity(0.4))
                                    )
                                    .shadow(radius: 2)
                                }
                                .listRowBackground(Color.clear)
                            }
                        }
                        .listStyle(PlainListStyle())
                        
                        // Button to create a new restaurant
                        Button(action: {
                            navigateToCreateRestaurant = true
                        }) {
                            Label("Create New Restaurant", systemImage: "plus.circle.fill")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.black.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }
            }
            .navigationTitle("My Restaurants")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.fetchRestaurants()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.white)
                    }
                }
            }
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Delete Restaurant"),
                    message: Text("Are you sure you want to delete \(restaurantToDelete?.name ?? "this restaurant")? This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        if let restaurant = restaurantToDelete {
                            Task {
                                let result = await viewModel.deleteRestaurant(id: restaurant.id)
                                if case .failure(let error) = result {
                                    print("Error deleting restaurant: \(error)")
                                }
                            }
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .navigationDestination(isPresented: $navigateToCreateRestaurant) {
                CreateRestaurantView()
            }
            .onAppear {
                viewModel.fetchRestaurants()
            }
        }
    }
}

struct RestaurantListView_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantListView()
    }
}
