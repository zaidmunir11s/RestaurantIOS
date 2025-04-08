import SwiftUI

@main
struct GuidedCaptureSampleApp: App {
    static let subsystem: String = "org.sfomuseum.photogrammetry.guidedcapture"
    
    // Use your existing AppDataModel instance if needed.
    @StateObject var appModel = AppDataModel.instance

    var body: some Scene {
        WindowGroup {
            if #available(iOS 17.0, *) {
                RootView()
                    .environmentObject(appModel)  // For your AR capture flow
            }
        }
    }
}
