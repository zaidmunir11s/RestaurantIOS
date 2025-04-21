import SwiftUI

struct BranchListView: View {
    let restaurantId: String
       let restaurantName: String
    
    @StateObject private var viewModel = BranchViewModel()
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
                
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                    Spacer()
                } else if let errorMessage = viewModel.errorMessage {
                    Spacer()
                    VStack(spacing: 16) {
                        Text("Error Loading Branches")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(errorMessage)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: {
                            viewModel.fetchBranches(restaurantId: restaurantId)
                        }) {
                            Text("Try Again")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color(hex: "4D52C7"))
                                .cornerRadius(10)
                        }
                    }
                    Spacer()
                } else if viewModel.branches.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "building.2")
                            .font(.system(size: 60))
                            .foregroundColor(Color(hex: "4D52C7").opacity(0.5))
                        
                        Text("No Branches Yet")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Create your first branch for this restaurant")
                            .foregroundColor(.gray)
                    }
                    Spacer()
                } else {
                    // Branch List
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(viewModel.branches, id: \.id) { branch in
                                NavigationLink(destination: MenuScreenView(
                                    branchId: branch.id,
                                    branchName: branch.name,
                                    restaurantId: restaurantId
                                )) {
                                    BranchCard(branch: branch)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
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
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .navigationDestination(isPresented: $navigateToCreateBranch) {
                CreateBranchView(restaurantId: restaurantId, restaurantName: restaurantName)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.fetchBranches(restaurantId: restaurantId)
        }
    }
}

// Branch Card Component
struct BranchCard: View {
    let branch: BranchResponse
    
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
                Text(branch.name)
                    .font(.headline)
                    .foregroundColor(Color(hex: "333333"))
                
                if !branch.address.isEmpty {
                    Text(branch.address)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                } else {
                    Text("Tap to view menu")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .padding(.leading, 5)
            
            Spacer()
            
            // Status Indicator
            if branch.status == "active" {
                Circle()
                    .fill(Color.green)
                    .frame(width: 10, height: 10)
            } else if branch.status == "inactive" {
                Circle()
                    .fill(Color.red)
                    .frame(width: 10, height: 10)
            }
            
            // Navigation Arrow
            Image(systemName: "chevron.right")
                .foregroundColor(Color(hex: "4D52C7"))
                .font(.system(size: 14, weight: .semibold))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct BranchListView_Previews: PreviewProvider {
    static var previews: some View {
        BranchListView(restaurantId: "dummyId", restaurantName: "Restaurant A")
    }
}
