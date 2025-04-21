import Foundation
import SwiftUI

class RestaurantListViewModel: ObservableObject {
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
}
