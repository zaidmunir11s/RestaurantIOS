import SwiftUI
import RealityKit
import ARKit
import Combine

struct ARModeView: UIViewRepresentable {
    let modelURL: URL

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // Configure the AR session for world tracking with horizontal and vertical plane detection.
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        arView.session.run(config)
        
        // Asynchronously load the USDZ model.
        ModelEntity.loadModelAsync(contentsOf: modelURL)
            .sink { loadCompletion in
                // Handle any error during model loading.
                if case let .failure(error) = loadCompletion {
                    print("Error loading model: \(error.localizedDescription)")
                }
            } receiveValue: { modelEntity in
                // Create an anchor for the model.
                let anchor = AnchorEntity(plane: .any)
                modelEntity.generateCollisionShapes(recursive: true)
                anchor.addChild(modelEntity)
                arView.scene.addAnchor(anchor)
            }
            .store(in: &context.coordinator.cancellables)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // No dynamic update required.
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var cancellables: Set<AnyCancellable> = []
    }
}

struct ARModeView_Previews: PreviewProvider {
    static var previews: some View {
        // For preview purposes, we create a dummy URL from the documents directory.
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dummyURL = documentsDirectory.appendingPathComponent("model-mobile.usdz")
        return ARModeView(modelURL: dummyURL)
            .ignoresSafeArea()
    }
}
