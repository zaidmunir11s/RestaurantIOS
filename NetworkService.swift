import Foundation
import Combine

enum APIError: Error {
    case invalidURL
    case requestFailed(Error)
    case decodingFailed(Error)
    case invalidResponse
    case serverError(String)
    case unauthorized
    case notFound
    case emptyResponse
    
    var message: String {
        switch self {
        case .invalidURL:
            return "Invalid URL - Please check server configuration"
        case .requestFailed(let error):
            return "Request failed: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid server response"
        case .serverError(let message):
            return message
        case .unauthorized:
            return "Unauthorized access - Please log in again"
        case .notFound:
            return "Resource not found"
        case .emptyResponse:
            return "Server returned an empty response"
        }
    }
}

class NetworkService {
    static let shared = NetworkService()
    
    // Configure your base URL here
     let baseURL = "http://192.168.1.50:5000/api"
    
    private init() {}
    
    // Empty body type for requests without a body
    struct EmptyBody: Codable {}
    
    // MARK: - Authentication
    
    func login(email: String, password: String) async throws -> AuthResponse {
        let endpoint = "/auth/login"
        
        struct LoginRequest: Codable {
            let email: String
            let password: String
        }
        
        let body = LoginRequest(email: email, password: password)
        return try await makeRequest(endpoint: endpoint, method: "POST", body: body)
    }
    
    func register(firstName: String, lastName: String, email: String, password: String, role: String = "owner") async throws -> AuthResponse {
        let endpoint = "/auth/register"
        
        struct RegisterRequest: Codable {
            let firstName: String
            let lastName: String
            let email: String
            let password: String
            let role: String
        }
        
        let body = RegisterRequest(
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password,
            role: role
        )
        
        return try await makeRequest(endpoint: endpoint, method: "POST", body: body)
    }
    
    // MARK: - Menu Items Import
    
    func importMenuItems(
        restaurantId: String,
        branchId: String,
        itemIds: [String],
        token: String
    ) async throws -> [MenuItemResponse] {
        guard let url = URL(string: baseURL + "/menu/import") else {
            throw APIError.invalidURL
        }
        
        struct ImportRequest: Codable {
            let restaurantId: String
            let branchId: String
            let itemIds: [String]
        }
        
        let importRequest = ImportRequest(
            restaurantId: restaurantId,
            branchId: branchId,
            itemIds: itemIds
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(token, forHTTPHeaderField: "x-auth-token")
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try encoder.encode(importRequest)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            return try handleResponse(data: data, response: response)
        } catch {
            throw handleError(error)
        }
    }
    
    // MARK: - Branch Creation with Image
    
    func createBranchWithImage(branch: CreateBranchModel, imageData: Data, token: String) async throws -> BranchResponse {
        guard let url = URL(string: baseURL + "/branches") else {
            throw APIError.invalidURL
        }
        
        // Create a multipart form request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Add auth token header
        request.addValue(token, forHTTPHeaderField: "x-auth-token")
        
        // Create body
        var body = Data()
        
        // Add text fields
        let textFields: [String: String] = [
            "name": branch.name,
            "restaurantId": branch.restaurantId,
            "address": branch.address,
            "city": branch.city,
            "state": branch.state,
            "zipCode": branch.zipCode ?? "",
            "phone": branch.phone,
            "email": branch.email ?? "",
            "openingTime": branch.openingTime ?? "08:00",
            "closingTime": branch.closingTime ?? "22:00",
            "weekdayHours": branch.weekdayHours ?? "08:00 AM - 10:00 PM",
            "weekendHours": branch.weekendHours ?? "09:00 AM - 11:00 PM",
            "description": branch.description ?? "",
            "status": branch.status ?? "active",
            "tableCount": String(branch.tableCount ?? 10)
        ]
        
        // Add includeDefaultMenu field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"includeDefaultMenu\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(branch.includeDefaultMenu ?? true)\r\n".data(using: .utf8)!)
        
        for (key, value) in textFields {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        // Add image
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        // Send the request
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            return try handleResponse(data: data, response: response)
        } catch {
            throw handleError(error)
        }
    }
    
    // Helper function for USDZ file upload
    func getModelData(from url: URL) -> Data? {
        do {
            let data = try Data(contentsOf: url)
            return data
        } catch {
            print("Error reading model file: \(error)")
            return nil
        }
    }
    
    // MARK: - Menu Item with Model
    
    func uploadMenuItemWithModel(
        menuItem: CreateMenuItemModel,
        modelData: Data,
        token: String,
        endpoint: String = "/menu",
        method: String = "POST"
    ) async throws -> MenuItemResponse {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        print("📡 Uploading model to: \(method) \(url.absoluteString)")
        
        // Create a multipart form request
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Add auth token header
        request.addValue(token, forHTTPHeaderField: "x-auth-token")
        
        // Create body
        var body = Data()
        
        // Add the menu item JSON data
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let menuItemData = try encoder.encode(menuItem)
        let menuItemString = String(data: menuItemData, encoding: .utf8)!
        
        print("📤 Menu item JSON: \(menuItemString)")
        
        // Add JSON fields
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"title\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(menuItem.title)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"description\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(menuItem.description)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"price\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(menuItem.price)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"category\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(menuItem.category)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"status\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(menuItem.status ?? "active")\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"restaurantId\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(menuItem.restaurantId)\r\n".data(using: .utf8)!)
        
        if let branchId = menuItem.branchId {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"branchId\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(branchId)\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"isVegetarian\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(menuItem.isVegetarian ?? false)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"isVegan\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(menuItem.isVegan ?? false)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"isGlutenFree\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(menuItem.isGlutenFree ?? false)\r\n".data(using: .utf8)!)
        
        // Add model file
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"modelUrl\"; filename=\"model.usdz\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)
        body.append(modelData)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        // Print body size
        print("📤 Request body size: \(body.count) bytes")
        
        // Send the request
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            print("📥 Response status code: \(httpResponse.statusCode)")
            
            // Debug: Print response body
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 Response data: \(responseString)")
            }
            
            return try handleResponse(data: data, response: response)
        } catch {
            print("❌ Error uploading model: \(error)")
            throw handleError(error)
        }
    }
    
    // MARK: - Restaurants
    
    func createRestaurantWithImage(restaurant: CreateRestaurantModel, imageData: Data, token: String) async throws -> RestaurantResponse {
        guard let url = URL(string: baseURL + "/restaurants") else {
            throw APIError.invalidURL
        }
        
        // Create a multipart form request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Add auth token header
        request.addValue(token, forHTTPHeaderField: "x-auth-token")
        
        // Create body
        var body = Data()
        
        // Add text fields
        let textFields: [String: String] = [
            "name": restaurant.name,
            "cuisine": restaurant.cuisine,
            "address": restaurant.address,
            "city": restaurant.city,
            "state": restaurant.state,
            "zipCode": restaurant.zipCode,
            "phone": restaurant.phone,
            "email": restaurant.email,
            "website": restaurant.website,
            "description": restaurant.description,
            "status": restaurant.status ?? "active"
        ]
        
        for (key, value) in textFields {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        // Add image
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        // Send the request
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            return try handleResponse(data: data, response: response)
        } catch {
            throw handleError(error)
        }
    }
    
    func updateRestaurant(id: String, restaurant: CreateRestaurantModel, token: String) async throws -> RestaurantResponse {
        guard let url = URL(string: baseURL + "/restaurants/\(id)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(token, forHTTPHeaderField: "x-auth-token")
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try encoder.encode(restaurant)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            return try handleResponse(data: data, response: response)
        } catch {
            throw handleError(error)
        }
    }
    
    func updateRestaurantWithImage(id: String, restaurant: CreateRestaurantModel, imageData: Data, token: String) async throws -> RestaurantResponse {
        guard let url = URL(string: baseURL + "/restaurants/\(id)") else {
            throw APIError.invalidURL
        }
        
        // Create a multipart form request
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Add auth token header
        request.addValue(token, forHTTPHeaderField: "x-auth-token")
        
        // Create body
        var body = Data()
        
        // Add text fields
        let textFields: [String: String] = [
            "name": restaurant.name,
            "cuisine": restaurant.cuisine,
            "address": restaurant.address,
            "city": restaurant.city,
            "state": restaurant.state,
            "zipCode": restaurant.zipCode,
            "phone": restaurant.phone,
            "email": restaurant.email,
            "website": restaurant.website,
            "description": restaurant.description,
            "status": restaurant.status ?? "active"
        ]
        
        for (key, value) in textFields {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        // Add image
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        // Send the request
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            return try handleResponse(data: data, response: response)
        } catch {
            throw handleError(error)
        }
    }
    
    func createRestaurant(restaurant: CreateRestaurantModel, token: String) async throws -> RestaurantResponse {
        let endpoint = "/restaurants"
        return try await makeRequest(endpoint: endpoint, method: "POST", body: restaurant, token: token)
    }
    
    func getRestaurants(token: String) async throws -> [RestaurantResponse] {
        let endpoint = "/restaurants"
        return try await makeRequest(endpoint: endpoint, token: token)
    }
    
    func deleteRestaurant(id: String, token: String) async throws {
        let endpoint = "/restaurants/\(id)"
        return try await makeRequestWithoutResponse(endpoint: endpoint, method: "DELETE", token: token)
    }
    
    // MARK: - Branches
    
    func createBranch(branch: CreateBranchModel, token: String) async throws -> BranchResponse {
        let endpoint = "/branches"
        
        // Debug the restaurantId to ensure it matches what's expected
        print("DEBUG: Creating branch with restaurant ID: '\(branch.restaurantId)'")
        
        // Create a modified model with restaurantId as String to match web app
        var modifiedBranch = branch
        
        // Convert restaurantId to ensure proper format (matching web approach)
        if var jsonData = try? JSONEncoder().encode(branch),
           var jsonObj = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
            // Ensure restaurantId is a string
            if let restaurantId = jsonObj["restaurantId"] {
                jsonObj["restaurantId"] = String(describing: restaurantId)
            }
            
            // Re-encode with modified restaurantId
            if let updatedJsonData = try? JSONSerialization.data(withJSONObject: jsonObj),
               let updatedBranch = try? JSONDecoder().decode(CreateBranchModel.self, from: updatedJsonData) {
                modifiedBranch = updatedBranch
            }
        }
        
        // Make the request with the modified branch data
        return try await makeRequest(endpoint: endpoint, method: "POST", body: modifiedBranch, token: token)
    }
    
    func getBranches(restaurantId: String? = nil, token: String) async throws -> [BranchResponse] {
        var endpoint = "/branches"
        if let id = restaurantId {
            endpoint += "?restaurantId=\(id)"
        }
        return try await makeRequest(endpoint: endpoint, token: token)
    }
    
    func deleteBranch(id: String, token: String) async throws {
        let endpoint = "/branches/\(id)"
        return try await makeRequestWithoutResponse(endpoint: endpoint, method: "DELETE", token: token)
    }
    
    // MARK: - Menu Items
    
    func createMenuItem(menuItem: CreateMenuItemModel, token: String, modelData: Data? = nil) async throws -> MenuItemResponse {
        let endpoint = "/menu"
        
        // If we have model data, use multipart form upload
        if let modelData = modelData {
            return try await uploadMenuItemWithModel(menuItem: menuItem, modelData: modelData, token: token)
        }
        
        // Otherwise, regular JSON request
        return try await makeRequest(endpoint: endpoint, method: "POST", body: menuItem, token: token)
    }
    
    func updateMenuItem(id: String, menuItem: CreateMenuItemModel, token: String, modelData: Data? = nil) async throws -> MenuItemResponse {
        let endpoint = "/menu/\(id)"
        
        // If we have model data, use multipart form upload
        if let modelData = modelData {
            return try await uploadMenuItemWithModel(
                menuItem: menuItem,
                modelData: modelData,
                token: token,
                endpoint: endpoint,
                method: "PUT"
            )
        }
        
        // Otherwise, regular JSON request
        return try await makeRequest(endpoint: endpoint, method: "PUT", body: menuItem, token: token)
    }
    
    func deleteMenuItem(id: String, token: String) async throws {
        let endpoint = "/menu/\(id)"
        return try await makeRequestWithoutResponse(endpoint: endpoint, method: "DELETE", token: token)
    }
    
    func getMenuItems(restaurantId: String? = nil, branchId: String? = nil, token: String) async throws -> [MenuItemResponse] {
        var params: [String] = []
        if let id = restaurantId {
            params.append("restaurantId=\(id)")
        }
        if let id = branchId {
            params.append("branchId=\(id)")
        }
        
        var endpoint = "/menu"
        if !params.isEmpty {
            endpoint += "?" + params.joined(separator: "&")
        }
        
        return try await makeRequest(endpoint: endpoint, token: token)
    }
    
    // MARK: - Generic Request Methods
    
    // Overloaded version for GET requests with no body
    private func makeRequest<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        token: String? = nil
    ) async throws -> T {
        return try await makeRequest(endpoint: endpoint, method: method, body: nil as EmptyBody?, token: token)
    }
    
    // Method for requests without expected response data (like DELETE)
    private func makeRequestWithoutResponse(
        endpoint: String,
        method: String,
        token: String? = nil
    ) async throws {
        _ = try await makeRequest(endpoint: endpoint, method: method, body: nil as EmptyBody?, token: token) as EmptyBody
    }
    
    // Main request method with body parameter
    func makeRequest<T: Decodable, U: Encodable>(
        endpoint: String,
        method: String,
        body: U?,
        token: String? = nil
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        let fullURL = baseURL + endpoint
        print("📡 Request: \(method) \(fullURL)")
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = token {
            request.addValue(token, forHTTPHeaderField: "x-auth-token")
        }
        
        if let body = body {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            let jsonData = try encoder.encode(body)
            request.httpBody = jsonData
            
            // Debug: Print request body
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("📤 Request body: \(jsonString)")
            }
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            return try handleResponse(data: data, response: response)
        } catch {
            throw handleError(error)
        }
    }
    
    // Helper to handle response data and validation
    private func handleResponse<T: Decodable>(data: Data, response: URLResponse) throws -> T {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        print("📥 Response status code: \(httpResponse.statusCode)")
        
        // Debug: Print response body
        if let responseString = String(data: data, encoding: .utf8) {
            print("📥 Response data: \(responseString)")
        }
        
        // Handle status codes
        switch httpResponse.statusCode {
        case 200...299:
            break // Success range, continue processing
        case 401:
            throw APIError.unauthorized
        case 404:
            throw APIError.notFound
        default:
            // Try to parse error message from server
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw APIError.serverError(errorResponse.message)
            } else {
                throw APIError.serverError("Server error with status code: \(httpResponse.statusCode)")
            }
        }
        
        // Handle empty responses
        if data.isEmpty {
            if T.self == Void.self || T.self == EmptyBody.self {
                return EmptyBody() as! T
            }
            
            // For other cases, create an empty JSON object if possible
            if let emptyObjectData = "{}".data(using: .utf8),
               let result = try? JSONDecoder().decode(T.self, from: emptyObjectData) {
                return result
            }
            
            throw APIError.emptyResponse
        }
        
        // Special handling for RestaurantResponse arrays
        if T.self == [RestaurantResponse].self {
            // Try decoding as array first
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                return try decoder.decode(T.self, from: data)
            } catch {
                // If that fails, try decoding as single item and wrapping in array
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let singleItem = try decoder.decode(RestaurantResponse.self, from: data)
                    return [singleItem] as! T
                } catch {
                    print("⚠️ Failed to decode as array or single item: \(error)")
                    throw APIError.decodingFailed(error)
                }
            }
        }
        
        // Decode the response
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        } catch {
            print("⚠️ Decoding error: \(error)")
            print("⚠️ Failed to decode: \(String(describing: error))")
            throw APIError.decodingFailed(error)
        }
    }
    
    // Helper to standardize error handling
    private func handleError(_ error: Error) -> Error {
        if let apiError = error as? APIError {
            return apiError
        } else {
            print("❌ Request failed with error: \(error)")
            return APIError.requestFailed(error)
        }
    }
}
