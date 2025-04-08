import SwiftUI

struct CreateRestaurantView: View {
    @State private var restaurantName: String = ""
    @State private var location: String = ""
    @State private var description: String = ""
    @State private var phoneNumber: String = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "EFF1FA"), Color(hex: "EFF1FA")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header Card
                    ZStack(alignment: .topTrailing) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Create New")
                                .font(.headline)
                                .foregroundColor(.black.opacity(0.7))
                            
                            Text("Restaurant")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(
                            ZStack(alignment: .topTrailing) {
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(Color(hex: "FFE8CC"))
                                
                                // Decorative circles
                                HStack(spacing: -10) {
                                    Circle()
                                        .fill(Color(hex: "4D52C7"))
                                        .frame(width: 50, height: 50)
                                    
                                    Circle()
                                        .fill(Color(hex: "F9D56E"))
                                        .frame(width: 60, height: 60)
                                        
                                    Circle()
                                        .fill(Color(hex: "FF8A8A"))
                                        .frame(width: 30, height: 30)
                                        .offset(x: 0, y: 20)
                                }
                                .offset(x: -20, y: -10)
                            }
                        )
                    }
                    
                    // Form Fields
                    VStack(spacing: 20) {
                        InputField(title: "Restaurant Name", text: $restaurantName, icon: "building.2.fill")
                        
                        InputField(title: "Location", text: $location, icon: "mappin.circle.fill")
                        
                        InputField(title: "Description", text: $description, icon: "text.alignleft", isMultiline: true)
                        
                        InputField(title: "Phone Number", text: $phoneNumber, icon: "phone.fill", keyboardType: .phonePad)
                    }
                    .padding(.vertical, 10)
                    
                    // Save Button
                    Button(action: {
                        // Save restaurant logic here
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Save Restaurant")
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("New Restaurant")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
        }
    }
}

// Custom Input Field Component
struct InputField: View {
    let title: String
    @Binding var text: String
    let icon: String
    var isMultiline: Bool = false
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack(alignment: isMultiline ? .top : .center, spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(Color(hex: "4D52C7"))
                    .frame(width: 24, height: 24)
                
                if isMultiline {
                    TextEditor(text: $text)
                        .frame(minHeight: 100)
                        .cornerRadius(8)
                } else {
                    TextField("", text: $text)
                        .keyboardType(keyboardType)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}

// Note: Color hex extension is already defined in DashboardView.swift

struct CreateRestaurantView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CreateRestaurantView()
        }
    }
}
