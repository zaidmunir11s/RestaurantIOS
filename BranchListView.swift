import SwiftUI

struct BranchListView: View {
    let restaurantName: String
    // Dummy branch data
    let branches = ["Branch 1", "Branch 2", "Branch 3"]
    @State private var navigateToCreateBranch = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "EFF1FA")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 0) {
                    // Top bar with back button
                    HStack {
                        Button(action: {
                                                    dismiss()
                                                }) {
                                                    HStack(spacing: 5) {
                                                        Image(systemName: "chevron.left")
                                                        Text("Back")
                                                    }
                                                    .foregroundColor(Color(hex: "29B5FE"))
                                                    .font(.system(size: 16, weight: .medium))
                                                }
                                                
                                                Spacer()
                                            }
                                            .padding(.horizontal, 20)
                                            .padding(.top, 20)
                                            
                                            // Restaurant Title Card
                                            ZStack(alignment: .topTrailing) {
                                                VStack(alignment: .leading, spacing: 8) {
                                                    Text("Branches")
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
                                                .padding(.horizontal, 20)
                                                .padding(.top, 10)
                                            }
                                        }
                                        .padding(.bottom, 20)
                                        
                                        // Branch List
                                        ScrollView {
                                            VStack(spacing: 16) {
                                                ForEach(branches, id: \.self) { branch in
                                                    NavigationLink(destination: MenuScreenView(branchName: branch)) {
                                                        BranchCard(branchName: branch)
                                                    }
                                                }
                                                
                                                // Add New Branch Button
                                                Button(action: {
                                                    navigateToCreateBranch = true
                                                }) {
                                                    HStack {
                                                        Image(systemName: "plus.circle.fill")
                                                            .font(.title3)
                                                        Text("Add New Branch")
                                                            .font(.headline)
                                                    }
                                                    .padding()
                                                    .frame(maxWidth: .infinity)
                                                    .background(Color(hex: "4D52C7"))
                                                    .foregroundColor(.white)
                                                    .cornerRadius(16)
                                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                                                }
                                                .padding(.top, 10)
                                            }
                                            .padding(.horizontal, 20)
                                            .padding(.bottom, 20)
                                        }
                                    }
                                    .navigationDestination(isPresented: $navigateToCreateBranch) {
                                        CreateBranchView(restaurantName: restaurantName)
                                    }
                                }
                                .navigationBarHidden(true)
                            }
                        }

                        // Branch Card Component
                        struct BranchCard: View {
                            let branchName: String
                            
                            var body: some View {
                                HStack {
                                    // Branch Icon
                                    Circle()
                                        .fill(Color(hex: "4D52C7").opacity(0.9))
                                        .frame(width: 50, height: 50)
                                        .overlay(
                                            Image(systemName: "building.2")
                                                .foregroundColor(.white)
                                                .font(.system(size: 20))
                                        )
                                    
                                    // Branch Info
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(branchName)
                                            .font(.headline)
                                            .foregroundColor(Color(hex: "333333"))
                                        
                                        Text("Tap to view menu")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.leading, 5)
                                    
                                    Spacer()
                                    
                                    // Action Buttons
                                    HStack(spacing: 15) {
                                        Button(action: {
                                            // Edit branch action
                                        }) {
                                            Image(systemName: "pencil")
                                                .foregroundColor(Color(hex: "4D52C7"))
                                                .font(.system(size: 16))
                                                .padding(8)
                                                .background(Circle().fill(Color(hex: "EFF1FA")))
                                        }
                                        
                                        Button(action: {
                                            // Delete branch action
                                        }) {
                                            Image(systemName: "trash")
                                                .foregroundColor(Color.red)
                                                .font(.system(size: 16))
                                                .padding(8)
                                                .background(Circle().fill(Color(hex: "EFF1FA")))
                                        }
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            }
                        }

                        // Note: Color hex extension is imported from ColorExtension.swift

                        struct BranchListView_Previews: PreviewProvider {
                            static var previews: some View {
                                BranchListView(restaurantName: "Restaurant A")
                            }
                        }
