import SwiftUI

struct CreateBranchView: View {
    let restaurantId: String
    let restaurantName: String
    
    @StateObject private var userSession = UserSession.shared
    @State private var branchName: String = ""
    @State private var address: String = ""
    @State private var city: String = ""
    @State private var state: String = ""
    @State private var zipCode: String = ""
    @State private var phone: String = ""
    @State private var email: String = ""
    @State private var description: String = ""
    @State private var openingTime: String = "08:00"
    @State private var closingTime: String = "22:00"
    @State private var weekdayHours: String = "08:00 AM - 10:00 PM"
    @State private var weekendHours: String = "09:00 AM - 11:00 PM"
    @State private var tableCount: String = "10"
    @State private var includeDefaultMenu: Bool = true
    
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isSuccess = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "EFF1FA")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header Card
                    ZStack(alignment: .topTrailing) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Create New Branch")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text(restaurantName)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(24)
                        .background(
                            ZStack(alignment: .topTrailing) {
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(Color(hex: "4D52C7"))
                                
                                // Decorative circles
                                HStack(spacing: -5) {
                                    Circle()
                                        .fill(Color(hex: "FF8A8A"))
                                        .frame(width: 20, height: 20)
                                        
                                    Circle()
                                        .fill(Color(hex: "F9D56E"))
                                        .frame(width: 40, height: 40)
                                }
                                .padding([.top, .trailing], 15)
                            }
                        )
                    }
                    
                    // Form Fields
                    GroupBox(label: Text("Basic Information").bold()) {
                        VStack(spacing: 20) {
                            InputField(title: "Branch Name", text: $branchName, icon: "building.2.fill")
                            
                            InputField(title: "Description", text: $description, icon: "text.alignleft", isMultiline: true)
                            
                            // Table Count
                            InputField(title: "Number of Tables", text: $tableCount, icon: "tablecells", keyboardType: .numberPad)
                            
                            // Include default menu toggle
                            HStack {
                                Image(systemName: "list.bullet")
                                    .foregroundColor(Color(hex: "4D52C7"))
                                    .frame(width: 24, height: 24)
                                
                                Text("Include Default Menu")
                                    .foregroundColor(Color(hex: "333333"))
                                
                                Spacer()
                                
                                Toggle("", isOn: $includeDefaultMenu)
                                    .toggleStyle(SwitchToggleStyle(tint: Color(hex: "4D52C7")))
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                        .padding(.vertical, 10)
                    }
                    
                    GroupBox(label: Text("Address").bold()) {
                        VStack(spacing: 20) {
                            InputField(title: "Street Address", text: $address, icon: "mappin.circle.fill")
                            
                            InputField(title: "City", text: $city, icon: "building.2")
                            
                            InputField(title: "State", text: $state, icon: "map")
                            
                            InputField(title: "Zip Code", text: $zipCode, icon: "location.circle", keyboardType: .numberPad)
                        }
                        .padding(.vertical, 10)
                    }
                    
                    GroupBox(label: Text("Contact Information").bold()) {
                        VStack(spacing: 20) {
                            InputField(title: "Phone Number", text: $phone, icon: "phone.fill", keyboardType: .phonePad)
                            
                            InputField(title: "Email", text: $email, icon: "envelope.fill", keyboardType: .emailAddress)
                        }
                        .padding(.vertical, 10)
                    }
                    
                    GroupBox(label: Text("Working Hours").bold()) {
                        VStack(spacing: 20) {
                            InputField(title: "Opening Time (24h format)", text: $openingTime, icon: "clock.fill")
                            
                            InputField(title: "Closing Time (24h format)", text: $closingTime, icon: "clock.fill")
                            
                            InputField(title: "Weekday Hours", text: $weekdayHours, icon: "calendar")
                            
                            InputField(title: "Weekend Hours", text: $weekendHours, icon: "calendar")
                        }
                        .padding(.vertical, 10)
                    }
                    
                    // Save Button
                    Button(action: {
                        saveBranch()
                    }) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color(hex: "4D52C7"), Color(hex: "5C65DF")]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                        } else {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Save Branch")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "4D52C7"), Color(hex: "5C65DF")]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: Color(hex: "4D52C7").opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                    }
                    .disabled(isLoading)
                    
                    // Cancel Button
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                            .font(.headline)
                            .foregroundColor(Color(hex: "4D52C7"))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(hex: "4D52C7"), lineWidth: 1)
                            )
                    }
                }
                .padding(20)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(isSuccess ? "Success" : "Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if isSuccess {
                        dismiss()
                    }
                }
            )
        }
        .navigationDestination(isPresented: $isSuccess) {
            BranchListView(
                restaurantId: restaurantId,
                restaurantName: restaurantName
            )
        }
    }
    
    private func saveBranch() {
        // Validation
        if branchName.isEmpty || address.isEmpty || city.isEmpty || state.isEmpty || phone.isEmpty {
            alertMessage = "Please fill in all required fields"
            showAlert = true
            return
        }
        
        guard let token = userSession.authToken else {
            alertMessage = "Authentication error. Please log in again."
            showAlert = true
            return
        }
        
        // Convert tableCount string to Int
        guard let tables = Int(tableCount) else {
            alertMessage = "Please enter a valid number of tables"
            showAlert = true
            return
        }
        
        isLoading = true
        
        let branch = CreateBranchModel(
            name: branchName,
            restaurantId: restaurantId,
            address: address,
            city: city,
            state: state,
            zipCode: zipCode,
            phone: phone,
            email: email,
            managerId: nil,
            openingTime: openingTime,
            closingTime: closingTime,
            weekdayHours: weekdayHours,
            weekendHours: weekendHours,
            description: description,
            imageUrl: nil,
            status: "active",
            tableCount: tables,
            includeDefaultMenu: includeDefaultMenu
        )
        
        Task {
            do {
                let response = try await NetworkService.shared.createBranch(branch: branch, token: token)
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.isSuccess = true
                    self.alertMessage = "Branch created successfully!"
                    self.showAlert = true
                }
            } catch let error as APIError {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.alertMessage = error.message
                    self.showAlert = true
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.alertMessage = "An unexpected error occurred"
                    self.showAlert = true
                }
            }
        }
    }
}
