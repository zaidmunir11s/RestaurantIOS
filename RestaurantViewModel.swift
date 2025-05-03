// RestaurantViewModel.swift
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
    
    func createRestaurant(restaurant: CreateRestaurantModel, imageData: Data? = nil) async -> Result<RestaurantResponse, Error> {
        guard let token = userSession.authToken else {
            return .failure(APIError.unauthorized)
        }
        
        isLoading = true
        
        do {
            // If image data is provided, use multipart form upload
            let newRestaurant: RestaurantResponse
            if let imageData = imageData {
                newRestaurant = try await NetworkService.shared.createRestaurantWithImage(
                    restaurant: restaurant,
                    imageData: imageData,
                    token: token
                )
            } else {
                newRestaurant = try await NetworkService.shared.createRestaurant(
                    restaurant: restaurant,
                    token: token
                )
            }
            
            await MainActor.run {
                self.restaurants.append(newRestaurant)
                self.isLoading = false
            }
            
            return .success(newRestaurant)
        } catch {
            await MainActor.run {
                self.isLoading = false
            }
            return .failure(error)
        }
    }
    
    func updateRestaurant(id: String, restaurant: CreateRestaurantModel, imageData: Data? = nil) async -> Result<RestaurantResponse, Error> {
        guard let token = userSession.authToken else {
            return .failure(APIError.unauthorized)
        }
        
        isLoading = true
        
        do {
            let updatedRestaurant: RestaurantResponse
            if let imageData = imageData {
                updatedRestaurant = try await NetworkService.shared.updateRestaurantWithImage(
                    id: id,
                    restaurant: restaurant,
                    imageData: imageData,
                    token: token
                )
            } else {
                updatedRestaurant = try await NetworkService.shared.updateRestaurant(
                    id: id,
                    restaurant: restaurant,
                    token: token
                )
            }
            
            await MainActor.run {
                if let index = self.restaurants.firstIndex(where: { $0.id == id }) {
                    self.restaurants[index] = updatedRestaurant
                }
                self.isLoading = false
            }
            
            return .success(updatedRestaurant)
        } catch {
            await MainActor.run {
                self.isLoading = false
            }
            return .failure(error)
        }
    }
    
    func deleteRestaurant(id: String) async -> Result<Void, Error> {
        guard let token = userSession.authToken else {
            return .failure(APIError.unauthorized)
        }
        
        isLoading = true
        
        do {
            try await NetworkService.shared.deleteRestaurant(id: id, token: token)
            
            await MainActor.run {
                self.restaurants.removeAll { $0.id == id }
                self.isLoading = false
            }
            
            return .success(())
        } catch {
            await MainActor.run {
                self.isLoading = false
            }
            return .failure(error)
        }
    }
}
