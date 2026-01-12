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
    private var coreNode: CoreNode!

    /// Controls the breathing animation
    private var breathingController: BreathingController!

    /// Manages particle effects
    private var particleManager: ParticleManager!

    /// Manages physics behavior
    private var physicsManager: PhysicsManager!

    // MARK: - State

    /// Current Core state
    private var currentState: CoreState = .neutral

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

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        setupScene()
        setupCore()
        setupPhysics()
        setupParticles()
        startBreathing()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)

        // Update core position to center
        if let core = coreNode {
            let centerPosition = CGPoint(x: size.width / 2, y: size.height / 2)
            core.setBasePosition(centerPosition)
        }

        // Update boundaries
        setupBoundaries()

        // Update breathing controller screen height
        breathingController?.setScreenHeight(size.height)
    }

    // MARK: - Setup

    /// Configures the scene properties
    private func setupScene() {
        backgroundColor = .clear
        scaleMode = .resizeFill
    }

    /// Creates and positions the CoreNode
    private func setupCore() {
        // Create core with appropriate size
        let coreSize: CGFloat = min(size.width, size.height) * 0.3
        coreNode = CoreNode(baseSize: coreSize)

        // Position at center
        let centerPosition = CGPoint(x: size.width / 2, y: size.height / 2)
        coreNode.setBasePosition(centerPosition)

        addChild(coreNode)
    }

    /// Configures physics world and boundaries
    private func setupPhysics() {
        // Configure physics world
        physicsWorld.gravity = CGVector(dx: 0, dy: -2.9)  // Reduced gravity
        physicsWorld.contactDelegate = self

        // Create physics manager
        physicsManager = PhysicsManager()
        physicsManager.attach(to: self, coreNode: coreNode)

        // Set up screen boundaries
        setupBoundaries()
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
    }

    /// Sets up particle manager
    private func setupParticles() {
        particleManager = ParticleManager()
        particleManager.attach(to: self, parentNode: coreNode)
    }

    /// Initializes and starts the breathing controller
    private func startBreathing() {
        breathingController = BreathingController()
        breathingController.attach(to: coreNode)
        breathingController.setScreenHeight(size.height)
        breathingController.updateParameters(for: currentState, duration: 0)
    }

    // MARK: - Update Loop

    override func update(_ currentTime: TimeInterval) {
        // Calculate delta time
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        // Update breathing animation
        breathingController.update(currentTime: currentTime)

        // Update particles
        particleManager.update(currentTime: currentTime)

        // Handle hold gesture attraction
        if isTouching && (currentTime - touchStartTime) > holdThreshold {
            physicsManager.applyHoldAttraction(toward: lastTouchPosition)
        }
    }

    // MARK: - State Updates

    /// Updates the Core to a new state with animation
    /// - Parameters:
    ///   - newState: The target CoreState
    ///   - animated: Whether to animate the transition
    func updateState(_ newState: CoreState, animated: Bool = true) {
        let duration = animated ? transitionDuration(from: currentState, to: newState) : 0

        // Update all components
        coreNode.interpolateVisuals(to: newState, duration: duration)
        breathingController.updateParameters(for: newState, duration: duration)
        particleManager.updateEmitters(for: newState, duration: duration)
        physicsManager.updatePhysics(for: newState)

        currentState = newState
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

        // Stop any existing motion when starting a new touch
        physicsManager.stopMotion()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // If holding, core follows finger (for drag)
        let timeSinceTouch = CACurrentMediaTime() - touchStartTime
        if timeSinceTouch > holdThreshold {
            // Update core position directly for drag behavior
            coreNode.position = location
            coreNode.setBasePosition(location)
        }

        lastTouchPosition = location
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let timeSinceTouch = CACurrentMediaTime() - touchStartTime

        isTouching = false

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
    }

    // MARK: - Gesture Handling

    /// Handles a tap gesture
    private func handleTap(at location: CGPoint) {
        // Apply impulse toward tap location
        physicsManager.applyTapImpulse(at: location)

        // Visual feedback
        coreNode.flashOnTap(intensity: currentState.adherencePercentage)

        // Particle burst (only if somewhat radiant)
        if currentState.adherencePercentage > 0.3 {
            particleManager.emitSparkBurst(at: .zero, intensity: currentState.adherencePercentage)
        }
    }

    /// Handles release after hold/drag
    private func handleRelease(velocity: CGVector) {
        // Apply swipe velocity
        physicsManager.applySwipeVelocity(velocity)

        // Reset base position to current position
        coreNode.setBasePosition(coreNode.position)
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
        let intensity = physicsManager.collisionIntensity(velocity: velocity)

        // Only emit effects for significant collisions
        guard intensity > 0.1 else { return }

        // Particle effect at contact point
        particleManager.emitCollisionEffect(at: contact.contactPoint, velocity: velocity)

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
