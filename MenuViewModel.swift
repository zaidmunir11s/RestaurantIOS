// MenuViewModel.swift
import Foundation
import SwiftUI
import Combine

class MenuViewModel: ObservableObject {
    @Published var menuItems: [MenuItemResponse] = []
    @Published var categories: [String] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let userSession = UserSession.shared
    
    func fetchMenuItems(restaurantId: String, branchId: String? = nil) {
        guard let token = UserSession.shared.authToken else {
            errorMessage = "Authentication error. Please log in again."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                print("DEBUG: Fetching menu items for restaurant ID: \(restaurantId)")
                let items = try await NetworkService.shared.getMenuItems(
                    restaurantId: restaurantId,
                    branchId: branchId,
                    token: token
                )
                
                DispatchQueue.main.async {
                    self.menuItems = items
                    self.isLoading = false
                    print("DEBUG: Fetched \(items.count) menu items")
                }
            } catch let error as APIError {
                DispatchQueue.main.async {
                    self.errorMessage = error.message
                    self.isLoading = false
                    print("DEBUG: Error fetching menu items: \(error.message)")
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "An unexpected error occurred"
                    self.isLoading = false
                    print("DEBUG: Unexpected error fetching menu items: \(error)")
                }
            }
        }
    }
    
    func fetchCategories(restaurantId: String, branchId: String? = nil) {
        guard let token = userSession.authToken else {
            return
        }
        
        Task {
            do {
                // This would be replaced with actual category fetching once implemented
                // For now simulating by extracting categories from menu items
                let items = try await NetworkService.shared.getMenuItems(
                    restaurantId: restaurantId,
                    branchId: branchId,
                    token: token
                )
                
                let uniqueCategories = Array(Set(items.map { $0.category })).sorted()
                
                DispatchQueue.main.async {
                    self.categories = uniqueCategories
                }
            } catch {
                print("Error fetching categories: \(error)")
            }
        }
    }
    
    func deleteMenuItem(id: String) async {
        guard let token = userSession.authToken else {
            DispatchQueue.main.async {
                self.errorMessage = "Authentication error. Please log in again."
            }
            return
        }
        
        do {
            try await NetworkService.shared.deleteMenuItem(id: id, token: token)
            
            DispatchQueue.main.async {
                self.menuItems.removeAll { $0.id == id }
            }
        } catch let error as APIError {
            DispatchQueue.main.async {
                self.errorMessage = error.message
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "An unexpected error occurred"
            }
        }
    }
    
    func addCategory(restaurantId: String, branchId: String? = nil, categoryName: String) async {
        guard let token = userSession.authToken else {
            DispatchQueue.main.async {
                self.errorMessage = "Authentication error. Please log in again."
            }
            return
        }
        
        // In a real implementation, you would send this to your backend
        // For now, let's just add it to the local categories list
        DispatchQueue.main.async {
            if !self.categories.contains(categoryName) {
                self.categories.append(categoryName)
                self.categories.sort()
            }
        }
    }
    
    func createMenuItem(menuItem: CreateMenuItemModel, modelData: Data? = nil) async -> Result<MenuItemResponse, Error> {
        guard let token = userSession.authToken else {
            return .failure(APIError.unauthorized)
        }
        
        do {
            let newMenuItem = try await NetworkService.shared.createMenuItem(
                menuItem: menuItem,
                token: token,
                modelData: modelData
            )
            
            DispatchQueue.main.async {
                self.menuItems.append(newMenuItem)
            }
            
            return .success(newMenuItem)
        } catch {
            return .failure(error)
        }
    }
}
