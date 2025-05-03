import Foundation
import SwiftUI

class BranchViewModel: ObservableObject {
    @Published var branches: [BranchResponse] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let userSession = UserSession.shared
    
    func fetchBranches(restaurantId: String) {
        guard let token = userSession.authToken else {
            errorMessage = "Authentication error. Please log in again."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetchedBranches = try await NetworkService.shared.getBranches(restaurantId: restaurantId, token: token)
                
                DispatchQueue.main.async {
                    self.branches = fetchedBranches
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
    
    func createBranch(branch: CreateBranchModel, imageData: Data? = nil) async -> Result<BranchResponse, Error> {
        guard let token = userSession.authToken else {
            return .failure(APIError.unauthorized)
        }
        
        isLoading = true
        
        do {
            let newBranch: BranchResponse
            if let imageData = imageData {
                newBranch = try await NetworkService.shared.createBranchWithImage(
                    branch: branch,
                    imageData: imageData,
                    token: token
                )
            } else {
                newBranch = try await NetworkService.shared.createBranch(
                    branch: branch,
                    token: token
                )
            }
            
            await MainActor.run {
                self.branches.append(newBranch)
                self.isLoading = false
            }
            
            return .success(newBranch)
        } catch {
            await MainActor.run {
                self.isLoading = false
            }
            return .failure(error)
        }
    }
    
    func deleteBranch(id: String, restaurantId: String) async -> Result<Void, Error> {
        guard let token = userSession.authToken else {
            return .failure(APIError.unauthorized)
        }
        
        isLoading = true
        
        do {
            try await NetworkService.shared.deleteBranch(id: id, token: token)
            
            await MainActor.run {
                self.branches.removeAll { $0.id == id }
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
