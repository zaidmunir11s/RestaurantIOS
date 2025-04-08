import SwiftUI

@available(iOS 17.0, *)
struct RootView: View {
    // Local state only for demonstration purposes.
    @State private var isLoggedIn = false

    var body: some View {
        NavigationStack {
            if !isLoggedIn {
                SignInView()
            } else {
                DashboardView()
            }
        }
    }
}
