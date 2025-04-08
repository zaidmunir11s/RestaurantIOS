import SwiftUI

// Dummy model for a user.
struct User: Identifiable {
    let id = UUID()
    var userID: String
    var password: String
}

struct UserManagementView: View {
    // Dummy list of users.
    @State private var users: [User] = [
        User(userID: "owner1", password: "pass123"),
        User(userID: "owner2", password: "pass456")
    ]
    
    // Control the presentation of the Create User sheet.
    @State private var showCreateUserSheet = false
    // Set to track expanded rows.
    @State private var expandedUserIDs: Set<UUID> = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient.
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.7), Color.blue.opacity(0.7)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    // List of users displayed as expandable cards.
                    List {
                        ForEach(users) { user in
                            DisclosureGroup(
                                isExpanded: Binding(
                                    get: { expandedUserIDs.contains(user.id) },
                                    set: { isExpanded in
                                        if isExpanded {
                                            expandedUserIDs.insert(user.id)
                                        } else {
                                            expandedUserIDs.remove(user.id)
                                        }
                                    }
                                )
                            ) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("User ID: \(user.userID)")
                                    Text("Password: \(user.password)")
                                }
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.leading, 8)
                            } label: {
                                Text(user.userID)
                                    .font(.headline)
                                    .foregroundColor(.black)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.9))
                            )
                            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 2)
                            .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.clear)
                    
                    // Button to create a new user.
                    Button(action: {
                        showCreateUserSheet = true
                    }) {
                        Text("Create New User")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.green, Color.blue]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 4)
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("Manage Users")
            .sheet(isPresented: $showCreateUserSheet) {
                CreateUserView { newUser in
                    users.append(newUser)
                    showCreateUserSheet = false
                }
            }
        }
    }
}

struct CreateUserView: View {
    var onSave: (User) -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var userID: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("New User Details").font(.headline)) {
                    TextField("User ID", text: $userID)
                    SecureField("Password", text: $password)
                    SecureField("Re-enter Password", text: $confirmPassword)
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    Button("Save") {
                        if userID.isEmpty || password.isEmpty || confirmPassword.isEmpty {
                            errorMessage = "Please fill in all fields."
                        } else if password != confirmPassword {
                            errorMessage = "Passwords do not match."
                        } else {
                            let newUser = User(userID: userID, password: password)
                            onSave(newUser)
                        }
                    }
                }
            }
            .navigationTitle("Create User")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct UserManagementView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            UserManagementView()
        }
    }
}
