import SwiftUI

struct MobileSignUpView: View {
    @State private var email = ""
    @State private var fullName = ""
    @State private var password = ""
    @State private var phoneNumber = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Mobile User Sign Up")) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)

                    TextField("Full Name", text: $fullName)

                    SecureField("Password", text: $password)

                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                }

                Button(action: {
                    // TODO: Handle sign-up logic here.
                    // For example, call your backend or local model to create a user.
                    print("Mobile user sign-up tapped")
                }) {
                    Text("Sign Up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle("Mobile Sign Up")
        }
    }
}
