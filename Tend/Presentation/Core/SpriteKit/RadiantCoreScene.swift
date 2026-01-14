//
//  RadiantCoreScene.swift
//  Tend
//
//  The main SpriteKit scene that hosts the Radiant Core.
//  Orchestrates all components: CoreNode, BreathingController, ParticleManager, PhysicsManager.
//

import SpriteKit
import UIKit

/// The main SpriteKit scene hosting the Radiant Core.
/// Manages the render loop and coordinates all engine components.
final class RadiantCoreScene: SKScene, SKPhysicsContactDelegate {

    // MARK: - Components

    /// The visual representation of the Core
    private var coreNode: CoreNode?

    /// Controls the breathing animation
    private var breathingController: BreathingController?

    /// Manages particle effects
    private var particleManager: ParticleManager?

    /// Manages physics behavior
    private var physicsManager: PhysicsManager?

    // MARK: - State

    /// Current Core state
    private var currentState: CoreState = .neutral

    /// Whether apex effects are enabled (perfect adherence + >1 meal today)
    private var isApexEligible: Bool = false

    /// Pending one-shot event if the Core system hasn't been built yet
    private var pendingVFXEvent: CoreVFXEvent?

    /// Last update time for delta calculation
    private var lastUpdateTime: TimeInterval = 0

    // MARK: - Touch State

    /// Whether the user is currently touching the screen
    private var isTouching = false

    /// Time when touch began (for hold detection)
    private var touchStartTime: TimeInterval = 0

    /// Position where touch began
    private var touchStartPosition: CGPoint = .zero

    /// Last touch position (for velocity calculation)
    private var lastTouchPosition: CGPoint = .zero

    /// Hold threshold in seconds
    private let holdThreshold: TimeInterval = 0.3

    private var didStopMotionForTouch = false

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        setupScene()
        setupPhysicsWorld()
        setupBoundaries()
        rebuildCoreSystemIfNeeded(force: true)
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)

        setupBoundaries()
        rebuildCoreSystemIfNeeded(force: false)

        // Keep the Core centered on size changes (e.g. rotation)
        if let coreNode {
            coreNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        }
    }

    // MARK: - Setup

    /// Configures the scene properties
    private func setupScene() {
        backgroundColor = .clear
        scaleMode = .resizeFill
    }

    /// Configures physics world.
    /// Note: Core-specific physics is configured when the Core system is built.
    private func setupPhysicsWorld() {
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsWorld.contactDelegate = self
    }

    /// Creates physics boundaries at screen edges
    private func setupBoundaries() {
        // Remove existing boundary
        childNode(withName: "boundary")?.removeFromParent()

        // Create edge loop boundary
        let boundaryRect = CGRect(
            x: 0,
            y: 0,
            width: size.width,
            height: size.height
        )

        let boundary = SKNode()
        boundary.name = "boundary"
        boundary.physicsBody = SKPhysicsBody(edgeLoopFrom: boundaryRect)
        boundary.physicsBody?.categoryBitMask = PhysicsCategory.boundary
        boundary.physicsBody?.contactTestBitMask = PhysicsCategory.core
        boundary.physicsBody?.collisionBitMask = PhysicsCategory.core
        boundary.physicsBody?.friction = 0.2
        boundary.physicsBody?.restitution = 0.5

        addChild(boundary)

        updateBoundaryPhysics(adherence: currentState.adherencePercentage)
    }

    private func updateBoundaryPhysics(adherence: CGFloat) {
        guard let boundary = childNode(withName: "boundary"),
              let body = boundary.physicsBody
        else { return }

        let t = easeInOutCubic(adherence.clamped(to: 0...1))
        body.restitution = lerp(0.25, 0.9, t)
        body.friction = lerp(0.45, 0.08, t)
    }

    /// Builds or rebuilds the Core system when we have a valid scene size.
    /// SwiftUI often creates the underlying SKView with `bounds = .zero`.
    /// We intentionally defer Core creation until the scene is resized to a real size.
    private func rebuildCoreSystemIfNeeded(force: Bool) {
        guard size.width > 1, size.height > 1 else { return }

        let desiredDiameter = desiredCoreDiameter(for: size)
        let needsRebuild: Bool

        if force {
            needsRebuild = true
        } else if let existing = coreNode {
            needsRebuild = abs(existing.baseDiameter - desiredDiameter) > 0.5
        } else {
            needsRebuild = true
        }

        guard needsRebuild else {
            breathingController?.setScreenHeight(size.height)
            return
        }

        coreNode?.removeFromParent()

        let core = CoreNode(baseDiameter: desiredDiameter)
        core.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(core)
        coreNode = core

        // Recreate managers (they hold references to the CoreNode)
        physicsManager = PhysicsManager()
        physicsManager?.attach(to: self, coreNode: core)

        particleManager = ParticleManager()
        particleManager?.attach(to: self, coreNode: core)

        breathingController = BreathingController()
        breathingController?.attach(to: core)
        breathingController?.setScreenHeight(size.height)

        core.setApexEligible(isApexEligible, animated: false)
        particleManager?.setApexEligible(isApexEligible, animated: false)

        // Apply the currently-known state immediately
        updateState(currentState, animated: false)

        if let event = pendingVFXEvent {
            pendingVFXEvent = nil
            handleVFXEvent(event)
        }
    }

    private func desiredCoreDiameter(for sceneSize: CGSize) -> CGFloat {
        // Spec target: ~15–20% of screen width.
        let byWidth = sceneSize.width * 0.18
        let byHeight = sceneSize.height * 0.25
        let raw = min(byWidth, byHeight)
        return raw.clamped(to: 64...180)
    }

    // MARK: - Update Loop

    override func update(_ currentTime: TimeInterval) {
        // Calculate delta time
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        guard let breathingController, let physicsManager else { return }

        // Update breathing animation with actual delta time
        breathingController.update(currentTime: currentTime, deltaTime: deltaTime)

        if breathingController.didPeakInhale {
            let intensity = currentState.adherencePercentage
            coreNode?.triggerStriationPulse(intensity: intensity)

            if let coreNode {
                if isApexEligible {
                    coreNode.triggerApexInhaleFlare(intensity: 1.0)
                    particleManager?.emitApexBreathMicroBurst(at: coreNode.position, intensity: intensity)
                } else {
                    particleManager?.emitBreathMicroBurst(at: coreNode.position, intensity: intensity)
                }
            }
        }

        // Natural motion + breath drift (skip when user is actively touching)
        physicsManager.updateNaturalMotion(
            currentTime: currentTime,
            deltaTime: deltaTime,
            sceneSize: size,
            breathIntensity: breathingController.currentBreathIntensity,
            breathSegment: breathingController.currentSegment,
            isUserInteracting: isTouching
        )

        // Update particles
        particleManager?.update(currentTime: currentTime)

        // Handle hold gesture attraction
        if isTouching && (currentTime - touchStartTime) > holdThreshold {
            if !didStopMotionForTouch {
                physicsManager.stopMotion()
                didStopMotionForTouch = true
            }
            physicsManager.applyHoldAttraction(toward: lastTouchPosition)
        }
    }

    // MARK: - State Updates

    /// Updates the Core to a new state with animation
    /// - Parameters:
    ///   - newState: The target CoreState
    ///   - animated: Whether to animate the transition
    func updateState(_ newState: CoreState, animated: Bool = true) {
        let oldState = currentState
        currentState = newState

        // If the Core hasn't been built yet (scene still sizing), defer application.
        guard let coreNode, let breathingController, let particleManager, let physicsManager else { return }

        let duration = animated ? transitionDuration(from: oldState, to: newState) : 0

        // Update all components
        coreNode.interpolateVisuals(to: newState, duration: duration)
        breathingController.updateParameters(for: newState, duration: duration)
        particleManager.updateEmitters(for: newState, duration: duration)
        physicsManager.updatePhysics(for: newState)

        updateBoundaryPhysics(adherence: newState.adherencePercentage)
    }

    /// Updates whether apex effects are enabled.
    func setApexEligible(_ eligible: Bool, animated: Bool = true) {
        isApexEligible = eligible
        coreNode?.setApexEligible(eligible, animated: animated)
        particleManager?.setApexEligible(eligible, animated: animated)
    }

    /// Plays a one-shot VFX event (meal logging reward, apex ignition).
    func handleVFXEvent(_ event: CoreVFXEvent) {
        // If the Core hasn't been built yet (scene still sizing), defer.
        guard let coreNode else {
            pendingVFXEvent = event
            return
        }

        switch event.kind {
        case .mealOnTrack:
            coreNode.triggerEventFlash(strength: lerp(0.45, 1.0, currentState.adherencePercentage))
            coreNode.triggerScalePop(strength: lerp(0.06, 0.11, currentState.adherencePercentage))

            emitRing(
                color: ColorPalette.radiantHaloUI,
                blendMode: .add,
                baseScale: 0.65,
                finalScale: 1.75,
                duration: 0.52
            )

            particleManager?.emitMealOnTrackCelebration(
                at: coreNode.position,
                intensity: currentState.adherencePercentage
            )

        case .mealOffTrack:
            coreNode.triggerEventFlash(strength: 0.18)

            emitRing(
                color: ColorPalette.dimGlowUI,
                blendMode: .alpha,
                baseScale: 0.75,
                finalScale: 1.55,
                duration: 0.65
            )

            particleManager?.emitMealOffTrackPuff(
                at: coreNode.position,
                intensity: 1 - currentState.adherencePercentage
            )

        case .apexIgnition:
            coreNode.triggerEventFlash(strength: 1.0)
            coreNode.triggerScalePop(strength: 0.14)

            emitRing(
                color: ColorPalette.radiantHaloUI,
                blendMode: .add,
                baseScale: 0.55,
                finalScale: 2.15,
                duration: 0.60
            )
            emitRing(
                color: ColorPalette.radiantGlowUI,
                blendMode: .add,
                baseScale: 0.80,
                finalScale: 2.55,
                duration: 0.78
            )

            particleManager?.emitApexIgnition(
                at: coreNode.position,
                intensity: 1.0
            )
        }
    }

    private func emitRing(
        color: UIColor,
        blendMode: SKBlendMode,
        baseScale: CGFloat,
        finalScale: CGFloat,
        duration: TimeInterval
    ) {
        guard let coreNode else { return }

        let texture = CoreTextureGenerator.shared.generateRingTexture(size: CGSize(width: 256, height: 256))
        let ring = SKSpriteNode(texture: texture)
        ring.position = .zero
        ring.size = CGSize(width: coreNode.baseDiameter * 1.15, height: coreNode.baseDiameter * 1.15)
        ring.blendMode = blendMode
        ring.color = color
        ring.colorBlendFactor = 1.0
        ring.alpha = 0
        ring.setScale(baseScale)
        ring.zPosition = 60

        coreNode.addChild(ring)

        let popIn = SKAction.group([
            .fadeAlpha(to: blendMode == .add ? 0.95 : 0.55, duration: 0.03),
            .scale(to: baseScale * 0.98, duration: 0.03)
        ])

        let expand = SKAction.group([
            .scale(to: finalScale, duration: duration),
            .fadeOut(withDuration: duration)
        ])
        expand.timingMode = .easeOut

        ring.run(.sequence([
            popIn,
            expand,
            .removeFromParent()
        ]))
    }

    /// Calculates transition duration based on direction
    private func transitionDuration(from oldState: CoreState, to newState: CoreState) -> TimeInterval {
        // Kindling (improving): 2-3 seconds
        // Banking (declining): 3-4 seconds (slower for emotional impact)
        if newState.adherencePercentage > oldState.adherencePercentage {
            return 2.5  // Kindling
        } else {
            return 3.5  // Banking
        }
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        isTouching = true
        touchStartTime = CACurrentMediaTime()
        touchStartPosition = location
        lastTouchPosition = location

        didStopMotionForTouch = false
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        lastTouchPosition = location
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let timeSinceTouch = CACurrentMediaTime() - touchStartTime

        isTouching = false
        didStopMotionForTouch = false

        if timeSinceTouch < holdThreshold {
            // Tap gesture
            handleTap(at: location)
        } else {
            // End of hold/drag - calculate release velocity
            let velocity = calculateVelocity(from: touchStartPosition, to: location, duration: timeSinceTouch)
            handleRelease(velocity: velocity)
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouching = false
        didStopMotionForTouch = false
    }

    // MARK: - Gesture Handling

    /// Handles a tap gesture
    private func handleTap(at location: CGPoint) {
        // Apply impulse toward tap location
        physicsManager?.applyTapImpulse(at: location)

        // Visual feedback
        coreNode?.flashOnTap(intensity: currentState.adherencePercentage)

        // Particle burst (only if somewhat radiant)
        if currentState.adherencePercentage > 0.3 {
            if let coreNode {
                particleManager?.emitSparkBurst(at: coreNode.position, intensity: currentState.adherencePercentage)
            }
        }
    }

    /// Handles release after hold/drag
    private func handleRelease(velocity: CGVector) {
        // Apply swipe velocity
        physicsManager?.applySwipeVelocity(velocity)
    }

    /// Calculates velocity from touch movement
    private func calculateVelocity(from start: CGPoint, to end: CGPoint, duration: TimeInterval) -> CGVector {
        guard duration > 0 else { return .zero }

        return CGVector(
            dx: (end.x - start.x) / CGFloat(duration),
            dy: (end.y - start.y) / CGFloat(duration)
        )
    }

    // MARK: - Physics Contact Delegate

    func didBegin(_ contact: SKPhysicsContact) {
        // Determine which body is the core
        let coreBody = contact.bodyA.categoryBitMask == PhysicsCategory.core ? contact.bodyA : contact.bodyB
        let otherBody = contact.bodyA.categoryBitMask == PhysicsCategory.core ? contact.bodyB : contact.bodyA

        // Wall collision
        if otherBody.categoryBitMask == PhysicsCategory.boundary {
            handleWallCollision(contact: contact, coreBody: coreBody)
        }
    }

    /// Handles collision with screen boundary
    private func handleWallCollision(contact: SKPhysicsContact, coreBody: SKPhysicsBody) {
        let velocity = coreBody.velocity
        let intensity = physicsManager?.collisionIntensity(velocity: velocity) ?? 0

        // Only emit effects for significant collisions
        guard intensity > 0.1 else { return }

        // Particle effect at contact point
        particleManager?.emitCollisionEffect(at: contact.contactPoint, velocity: velocity)

        // Future: Haptic feedback integration point
        // hapticsManager?.playWallCollision(state: currentState, velocity: intensity)
    }
}

// MARK: - Public Interface for SwiftUI

extension RadiantCoreScene {
    /// Creates a scene configured for the given size
    static func create(size: CGSize) -> RadiantCoreScene {
        let scene = RadiantCoreScene(size: size)
        scene.scaleMode = .resizeFill
        scene.backgroundColor = .clear
        return scene
    }
}
