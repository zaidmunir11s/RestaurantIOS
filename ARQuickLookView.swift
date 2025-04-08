import SwiftUI

/// A SwiftUI wrapper for ARQuickLookViewControllerWrapper.
struct ARQuickLookView: UIViewControllerRepresentable {
    let fileURL: URL
    var onDismiss: () -> Void = { }

    func makeUIViewController(context: Context) -> ARQuickLookViewControllerWrapper {
        let vc = ARQuickLookViewControllerWrapper()
        vc.fileURL = fileURL
        vc.onDismiss = onDismiss
        return vc
    }
    
    func updateUIViewController(_ uiViewController: ARQuickLookViewControllerWrapper, context: Context) {
        // No update needed.
    }
}
