import Foundation
import SwiftUI

class RestaurantViewModel: ObservableObject {
    @Published var restaurants: [RestaurantResponse] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let userSession = UserSession.shared
    
    func fetchRestaurants() {
        guard let token = userSession.authToken else {
            errorMessage = "Authentication error. Please log in again."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetchedRestaurants = try await NetworkService.shared.getRestaurants(token: token)
                
                DispatchQueue.main.async {
                    self.restaurants = fetchedRestaurants
                    self.isLoading = false
                }
            } catch let error as APIError {
                DispatchQueue.main.async {
                    self.errorMessage = error.message
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "An unexpected error occurred"
                    self.isLoading = false
                }
            }
        }
    }
    
    func createRestaurant(restaurant: CreateRestaurantModel) async -> Result<RestaurantResponse, Error> {
        guard let token = userSession.authToken else {
            return .failure(APIError.unauthorized)
        }
        
        do {
            let newRestaurant = try await NetworkService.shared.createRestaurant(restaurant: restaurant, token: token)
            
            await MainActor.run {
                // Refresh the restaurant list
                self.fetchRestaurants()
            }
            
            return .success(newRestaurant)
        } catch {
            return .failure(error)
        }
    }
    
    func deleteRestaurant(id: String) async -> Result<Void, Error> {
        guard let token = userSession.authToken else {
            return .failure(APIError.unauthorized)
        }
        
        do {
            try await NetworkService.shared.deleteRestaurant(id: id, token: token)
            
            await MainActor.run {
                // Remove the restaurant from the list
                self.restaurants.removeAll { $0.id == id }
            }
            
            return .success(())
        } catch {
            return .failure(error)
        }
    }
}
