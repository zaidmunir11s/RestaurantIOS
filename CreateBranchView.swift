import SwiftUI

struct CreateBranchView: View {
    let restaurantName: String
    @State private var branchName: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Create Branch for \(restaurantName)")
                .font(.title)
                .bold()
            
            TextField("Branch Name", text: $branchName)
                .textFieldStyle(.roundedBorder)
            
            Button("Save") {
                print("Branch saved: \(branchName) for \(restaurantName)")
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
        }
        .padding()
        .navigationTitle("New Branch")
    }
}

struct CreateBranchView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CreateBranchView(restaurantName: "Restaurant A")
        }
    }
}
