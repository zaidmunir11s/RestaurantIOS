import Foundation
import SwiftUI

class UserSession: ObservableObject {
    static let shared = UserSession()
    
    @Published var isLoggedIn = false
    @Published var user: UserResponse?
    @Published var authToken: String?
    @Published var isLoading = false
    @Published var error: String?
    
    private let tokenKey = "authToken"
    private let userKey = "userData"
    
    private init() {
        loadSavedSession()
    }
    
    private func loadSavedSession() {
        if let tokenData = UserDefaults.standard.string(forKey: tokenKey) {
            self.authToken = tokenData
            
            if let userData = UserDefaults.standard.data(forKey: userKey),
               let decodedUser = try? JSONDecoder().decode(UserResponse.self, from: userData) {
                self.user = decodedUser
                self.isLoggedIn = true
            }
        }
    }
    
    func saveSession(token: String, user: UserResponse) {
        UserDefaults.standard.set(token, forKey: tokenKey)
        
        if let encodedUser = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encodedUser, forKey: userKey)
        }
        
        DispatchQueue.main.async {
            self.authToken = token
            self.user = user
            self.isLoggedIn = true
        }
    }
    
    func clearSession() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: userKey)
        
        DispatchQueue.main.async {
            self.authToken = nil
            self.user = nil
            self.isLoggedIn = false
        }
    }
    
    // MARK: - Authentication Methods
    
    func login(email: String, password: String) async {
        DispatchQueue.main.async {
            self.isLoading = true
            self.error = nil
        }
        
        do {
            let response = try await NetworkService.shared.login(email: email, password: password)
            saveSession(token: response.token, user: response.user)
        } catch let error as APIError {
            DispatchQueue.main.async {
                self.error = error.message
            }
        } catch {
            DispatchQueue.main.async {
                self.error = "An unexpected error occurred"
            }
        }
        
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
    
    func register(firstName: String, lastName: String, email: String, password: String) async {
        DispatchQueue.main.async {
            self.isLoading = true
            self.error = nil
        }
        
        do {
            let response = try await NetworkService.shared.register(
                firstName: firstName,
                lastName: lastName,
                email: email,
                password: password
            )
            saveSession(token: response.token, user: response.user)
        } catch let error as APIError {
            DispatchQueue.main.async {
                self.error = error.message
            }
        } catch {
            DispatchQueue.main.async {
                self.error = "An unexpected error occurred"
            }
        }
        
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
    
    func logout() {
        clearSession()
    }
    
    // MARK: - Convenience User Info Methods
    
    var fullName: String {
        guard let user = user else { return "" }
        return "\(user.firstName) \(user.lastName)"
    }
    
    var isOwner: Bool {
        return user?.role == "owner"
    }
    
    var isManager: Bool {
        return user?.role == "manager"
    }
    
    var hasRestaurant: Bool {
        return user?.restaurantId != nil
    }
}
