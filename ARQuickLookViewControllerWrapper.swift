import UIKit
import QuickLook
import UniformTypeIdentifiers

/// A custom view controller that immediately presents a UIDocumentInteractionController
/// to launch Quick Look externally.
class ARQuickLookViewControllerWrapper: UIViewController, UIDocumentInteractionControllerDelegate {
    var fileURL: URL!
    var docController: UIDocumentInteractionController?
    var onDismiss: (() -> Void)?
    private var didPresent = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let fileURL = fileURL, !didPresent else { return }
        didPresent = true
        docController = UIDocumentInteractionController(url: fileURL)
        docController?.uti = UTType.usdz.identifier
        docController?.delegate = self
        
        // Present the Quick Look preview after a short delay.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.docController?.presentPreview(animated: true)
        }
    }
    
    // Called when the preview is dismissed.
    func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
        onDismiss?()
        self.dismiss(animated: true, completion: nil)
    }
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}
