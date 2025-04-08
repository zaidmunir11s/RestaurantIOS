import SwiftUI
import UIKit
import QuickLook
import UniformTypeIdentifiers

/// This view controller representable wraps UIDocumentInteractionController so that
/// when presented, it launches the system Quick Look UI (which displays the AR button).
struct ARQuickLookLauncher: UIViewControllerRepresentable {
    let fileURL: URL

    func makeUIViewController(context: Context) -> UIViewController {
        // Create a dummy container view controller.
        return UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        let docController = UIDocumentInteractionController(url: fileURL)
        docController.delegate = context.coordinator
        // Set the Uniform Type Identifier so iOS recognizes the file as a USDZ model.
        docController.uti = UTType.usdz.identifier
        
        // Present the document interaction preview.
        DispatchQueue.main.async {
            if let rootVC = uiViewController.view.window?.rootViewController {
                // This should launch the Quick Look UI which, on a real device,
                // shows the AR button in the top-right corner.
                docController.presentPreview(animated: true)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, UIDocumentInteractionControllerDelegate {
        func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
            // Return the top-most view controller.
            UIApplication.shared.windows.first?.rootViewController ?? UIViewController()
        }
    }
}
