import SwiftUI

struct SignInView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var navigateToDashboard = false
    @State private var navigateToSignUp = false
    @State private var rememberMe = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(hex: "4D52C7")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top header area
                    VStack(spacing: 0) {
                        // App logo/icon
                        HStack {
                            Spacer()
                            
                            Image(systemName: "fork.knife.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.white)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.2))
                                        .frame(width: 70, height: 70)
                                )
                                .padding(.top, 40)
                            
                            Spacer()
                        }
                        
                        Text("AR Menu App")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.top, 10)
                            .padding(.bottom, 30)
                    }
                    
                    // Main content area with rounded top corners
                    VStack(spacing: 25) {
                        // Welcome text
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Welcome Back")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(Color(hex: "333333"))
                            
                            Text("Sign in to continue managing your restaurants")
                                .font(.subheadline)
                                .foregroundColor(Color.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 30)
                        
                        // Email field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.subheadline)
                                .foregroundColor(Color.gray)
                            
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(Color(hex: "4D52C7"))
                                TextField("Enter your email", text: $email)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .foregroundColor(Color(hex: "333333"))
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                        
                        // Password field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.subheadline)
                                .foregroundColor(Color.gray)
                            
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(Color(hex: "4D52C7"))
                                SecureField("Enter your password", text: $password)
                                    .foregroundColor(Color(hex: "333333"))
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                        
                        // Remember me & Forgot Password
                        HStack {
                            Button(action: {
                                rememberMe.toggle()
                            }) {
                                HStack {
                                    Image(systemName: rememberMe ? "checkmark.square.fill" : "square")
                                        .foregroundColor(Color(hex: "4D52C7"))
                                    
                                    Text("Remember me")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                // Forgot password action
                            }) {
                                Text("Forgot Password?")
                                    .font(.subheadline)
                                    .foregroundColor(Color(hex: "4D52C7"))
                            }
                        }
                        .padding(.vertical, 10)
                        
                        // Sign In Button
                        Button(action: {
                            navigateToDashboard = true
                        }) {
                            Text("Sign In")
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
                        .padding(.top, 10)
                        
                        // Or Divider
                        HStack {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                            
                            Text("OR")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 8)
                            
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                        }
                        .padding(.vertical, 15)
                        
                        // Sign Up button
                        Button(action: {
                            navigateToSignUp = true
                        }) {
                            HStack(spacing: 8) {
                                Text("Don't have an account?")
                                    .foregroundColor(.gray)
                                
                                Text("Sign Up")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(hex: "4D52C7"))
                            }
                            .font(.subheadline)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 30)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(hex: "EFF1FA"))
                    .cornerRadius(30, corners: [.topLeft, .topRight])
                }
                .navigationDestination(isPresented: $navigateToDashboard) {
                    DashboardView()
                }
                .navigationDestination(isPresented: $navigateToSignUp) {
                    SignUpView()
                }
            }
            .navigationBarHidden(true)
            .ignoresSafeArea(.keyboard)
        }
    }
}

// Note: Extension for rounded corners is imported from ColorExtension.swift

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
