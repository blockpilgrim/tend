//
//  SpriteKitContainer.swift
//  Tend
//
//  UIViewRepresentable wrapper to embed RadiantCoreScene in SwiftUI.
//

import SwiftUI
import SpriteKit

/// SwiftUI wrapper for the RadiantCoreScene.
/// Bridges SpriteKit to SwiftUI and forwards state changes.
struct SpriteKitContainer: UIViewRepresentable {

    /// The current Core state to display
    let coreState: CoreState

    // MARK: - UIViewRepresentable

    func makeUIView(context: Context) -> SKView {
        let view = SKView()

        // Configure SKView
        view.ignoresSiblingOrder = true
        view.allowsTransparency = true
        view.backgroundColor = .clear

        // Performance options
        view.preferredFramesPerSecond = 60
        view.showsFPS = false
        view.showsNodeCount = false

        // Create and present scene
        let initialSize = view.bounds.size
        let sceneSize = (initialSize.width > 1 && initialSize.height > 1)
            ? initialSize
            : CGSize(width: 1, height: 1)

        let scene = RadiantCoreScene.create(size: sceneSize)
        view.presentScene(scene)

        // Store scene reference in coordinator
        context.coordinator.scene = scene

        // Apply initial state
        scene.updateState(coreState, animated: false)

        return view
    }

    func updateUIView(_ uiView: SKView, context: Context) {
        // Forward state changes to scene
        if let scene = context.coordinator.scene {
            scene.updateState(coreState, animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    // MARK: - Coordinator

    /// Coordinator to maintain scene reference across updates
    class Coordinator {
        var scene: RadiantCoreScene?
    }
}

// MARK: - Preview

#if DEBUG
struct SpriteKitContainer_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color("BackgroundPrimary")
                .ignoresSafeArea()

            VStack {
                Text("Radiant")
                    .foregroundStyle(.white)
                SpriteKitContainer(coreState: .radiant)
                    .frame(height: 300)
            }
        }
        .previewDisplayName("Radiant State")

        ZStack {
            Color("BackgroundPrimary")
                .ignoresSafeArea()

            VStack {
                Text("Neutral")
                    .foregroundStyle(.white)
                SpriteKitContainer(coreState: .neutral)
                    .frame(height: 300)
            }
        }
        .previewDisplayName("Neutral State")

        ZStack {
            Color("BackgroundPrimary")
                .ignoresSafeArea()

            VStack {
                Text("Dim")
                    .foregroundStyle(.white)
                SpriteKitContainer(coreState: .dim)
                    .frame(height: 300)
            }
        }
        .previewDisplayName("Dim State")
    }
}
#endif
