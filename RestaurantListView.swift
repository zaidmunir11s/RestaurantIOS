import SwiftUI

struct RestaurantListView: View {
    // Dummy restaurant data.
    let restaurants = ["Restaurant A", "Restaurant B", "Restaurant C"]
    @State private var navigateToCreateRestaurant = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient for Restaurant list.
                LinearGradient(
                    gradient: Gradient(colors: [Color.orange, Color.red]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack {
                    List {
                        ForEach(restaurants, id: \.self) { restaurant in
                            NavigationLink(destination: BranchListView(restaurantName: restaurant)) {
                                HStack {
                                    Image(systemName: "building.2.fill")
                                        .foregroundColor(.white)
                                    Text(restaurant)
                                        .foregroundColor(.white)
                                        .font(.headline)
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
                    
                    // Button to create a new restaurant.
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
                    
                    // Hidden NavigationLink to CreateRestaurantView.
                    NavigationLink(destination: CreateRestaurantView(), isActive: $navigateToCreateRestaurant) {
                        EmptyView()
                    }
                }
                .padding()
            }
            .navigationTitle("Restaurants")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct RestaurantListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RestaurantListView()
        }
    }
}
