import Foundation

// MARK: - Authentication Models

struct AuthResponse: Codable {
    let token: String
    let user: UserResponse
}

struct UserResponse: Codable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let role: String
    let restaurantId: String?
    let branchId: String?
    let permissions: Permissions?
    let branchPermissions: BranchPermissions?
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id" // If your server returns MongoDB _id
        case firstName, lastName, email, role, restaurantId, branchId
        case permissions, branchPermissions, createdAt
    }
}

struct Permissions: Codable {
    let manageUsers: Bool
    let manageRestaurants: Bool
    let manageBranches: Bool
    let accessPOS: Bool
}

struct BranchPermissions: Codable {
    let menu: [String]
    let tables: [String]
}

// MARK: - Restaurant Models

struct CreateRestaurantModel: Codable {
    let name: String
    let cuisine: String
    let address: String
    let city: String
    let state: String
    let zipCode: String
    let phone: String
    let email: String
    let website: String
    let description: String
    let status: String?
    let imageUrl: String?
}

struct RestaurantResponse: Codable {
    let id: String
    let name: String
    let cuisine: String
    let address: String
    let city: String
    let state: String
    let zipCode: String
    let phone: String
    let email: String
    let website: String
    let description: String
    let status: String
    let imageUrl: String?
    let owner: String?
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, cuisine, address, city, state, zipCode, phone, email
        case website, description, status, imageUrl, owner, createdAt
    }
}

// MARK: - Branch Models

struct CreateBranchModel: Codable {
    let name: String
    let restaurantId: String
    let address: String
    let city: String
    let state: String
    let zipCode: String
    let phone: String
    let email: String
    let managerId: String?
    let openingTime: String?
    let closingTime: String?
    let weekdayHours: String?
    let weekendHours: String?
    let description: String?
    let imageUrl: String?
    let status: String?
    let tableCount: Int?
    let includeDefaultMenu: Bool?
}

struct BranchResponse: Codable {
    let id: String
    let name: String
    let restaurantId: String
    let address: String
    let city: String
    let state: String
    let zipCode: String
    let phone: String
    let email: String
    let managerId: String?
    let openingTime: String
    let closingTime: String
    let weekdayHours: String
    let weekendHours: String
    let description: String
    let imageUrl: String?
    let status: String
    let tableCount: Int
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, restaurantId, address, city, state, zipCode, phone, email
        case managerId, openingTime, closingTime, weekdayHours, weekendHours
        case description, imageUrl, status, tableCount, createdAt
    }
}

// MARK: - Menu Item Models

struct CreateMenuItemModel: Codable {
    let title: String
    let description: String
    let price: Double
    let category: String
    let status: String?
    let restaurantId: String
    let branchId: String?
    let imageUrl: String?
    let modelUrl: String?
    let isVegetarian: Bool?
    let isVegan: Bool?
    let isGlutenFree: Bool?
    let featured: Bool?
}

struct MenuItemResponse: Codable {
    let id: String
    let title: String
    let description: String
    let price: Double
    let category: String
    let status: String
    let restaurantId: String
    let branchId: String?
    let imageUrl: String?
    let modelUrl: String?
    let isVegetarian: Bool
    let isVegan: Bool
    let isGlutenFree: Bool
    let featured: Bool
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title, description, price, category, status, restaurantId, branchId
        case imageUrl, modelUrl, isVegetarian, isVegan, isGlutenFree, featured, createdAt
    }
}

// MARK: - Utility Models

struct ErrorResponse: Codable {
    let message: String
}
