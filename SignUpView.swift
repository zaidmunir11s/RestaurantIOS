import SwiftUI

struct SignUpView: View {
    @StateObject private var userSession = UserSession.shared
    
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var phoneNumber: String = ""
    @State private var agreeToTerms: Bool = false
    @State private var showingAlert = false
    @State private var validationError: String? = nil
    
    @Environment(\.dismiss) private var dismiss
    
    private var firstName: String {
        let components = fullName.components(separatedBy: " ")
        return components.first ?? ""
    }
    
    private var lastName: String {
        let components = fullName.components(separatedBy: " ")
        return components.count > 1 ? components.dropFirst().joined(separator: " ") : ""
    }
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "4D52C7")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top header area
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color.white.opacity(0.2)))
                    }
                    
                    Spacer()
                    
                    Text("Create Account")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Empty view for alignment
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                // Main Content with form
                ScrollView {
                    VStack(spacing: 22) {
                        // Welcome Text
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Hello!")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "333333"))
                            
                            Text("Sign up to start managing your restaurants")
                                .font(.subheadline)
                                .foregroundColor(Color.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 20)
                        
                        // Form Fields
                        SignUpTextField(title: "Full Name", text: $fullName, icon: "person.fill")
                        
                        SignUpTextField(title: "Email", text: $email, icon: "envelope.fill", keyboardType: .emailAddress)
                        
                        SignUpTextField(title: "Phone Number", text: $phoneNumber, icon: "phone.fill", keyboardType: .phonePad)
                        
                        SignUpPasswordField(title: "Password", text: $password, icon: "lock.fill")
                        
                        SignUpPasswordField(title: "Confirm Password", text: $confirmPassword, icon: "lock.fill")
                        
                        // Terms Agreement
                        Button(action: {
                            agreeToTerms.toggle()
                        }) {
                            HStack(alignment: .top) {
                                Image(systemName: agreeToTerms ? "checkmark.square.fill" : "square")
                                    .foregroundColor(Color(hex: "4D52C7"))
                                    .font(.system(size: 20))
                                
                                Text("I agree to the Terms & Conditions and Privacy Policy")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        .padding(.vertical, 5)
                        
                        // Error Message
                        if let errorMessage = validationError ?? userSession.error {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.vertical, 5)
                                .transition(.opacity)
                        }
                        
                        // Sign Up Button
                        Button(action: {
                            validateAndSignUp()
                        }) {
                            if userSession.isLoading {
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
                                    .cornerRadius(12)
                            } else {
                                Text("Sign Up")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color(hex: "4D52C7"), Color(hex: "5C65DF")]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(12)
                                    .shadow(color: Color(hex: "4D52C7").opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                        }
                        .disabled(userSession.isLoading)
                        .padding(.top, 10)
                        
                        // Already have account
                        Button(action: {
                            dismiss()
                        }) {
                            HStack(spacing: 8) {
                                Text("Already have an account?")
                                    .foregroundColor(.gray)
                                
                                Text("Sign In")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(hex: "4D52C7"))
                            }
                            .font(.subheadline)
                        }
                        .padding(.vertical, 15)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(hex: "EFF1FA"))
                .cornerRadius(30, corners: [.topLeft, .topRight])
            }
            .navigationDestination(isPresented: .constant(userSession.isLoggedIn)) {
                DashboardView()
            }
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(validationError ?? userSession.error ?? "Unknown error"),
                    dismissButton: .default(Text("OK")) {
                        validationError = nil
                    }
                )
            }
        }
        .navigationBarHidden(true)
        .ignoresSafeArea(.keyboard)
    }
    
    private func validateAndSignUp() {
        // Reset error
        validationError = nil
        
        // Validation
        if fullName.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty || phoneNumber.isEmpty {
            validationError = "Please fill in all fields"
            showingAlert = true
            return
        }
        
        // Check for first and last name
        if firstName.isEmpty || lastName.isEmpty {
            validationError = "Please enter both first and last name"
            showingAlert = true
            return
        }
        
        if !email.contains("@") || !email.contains(".") {
            validationError = "Please enter a valid email address"
            showingAlert = true
            return
        }
        
        if password.count < 6 {
            validationError = "Password must be at least 6 characters"
            showingAlert = true
            return
        }
        
        if password != confirmPassword {
            validationError = "Passwords do not match"
            showingAlert = true
            return
        }
        
        if !agreeToTerms {
            validationError = "Please agree to the Terms & Conditions"
            showingAlert = true
            return
        }
        
        // If all validation passes, register the user
        Task {
            await userSession.register(
                firstName: firstName,
                lastName: lastName,
                email: email,
                password: password
            )
            
            // Check if there was an error during registration
            if userSession.error != nil {
                showingAlert = true
            }
        }
    }
}

// Custom Text Field Component (Keep these the same)
struct SignUpTextField: View {
    let title: String
    @Binding var text: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(Color.gray)
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color(hex: "4D52C7"))
                
                TextField("Enter \(title.lowercased())", text: $text)
                    .keyboardType(keyboardType)
                    .autocapitalization(keyboardType == .emailAddress ? .none : .words)
                    .foregroundColor(Color(hex: "333333"))
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}

// Custom Password Field Component (Keep these the same)
struct SignUpPasswordField: View {
    let title: String
    @Binding var text: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(Color.gray)
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color(hex: "4D52C7"))
                
                SecureField("Enter \(title.lowercased())", text: $text)
                    .foregroundColor(Color(hex: "333333"))
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}

struct UpdatedSignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
