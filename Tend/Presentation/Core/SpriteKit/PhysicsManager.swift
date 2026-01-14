//
//  PhysicsManager.swift
//  Tend
//
//  Manages physics behavior of the Radiant Core.
//  Physics parameters vary with state: buoyant when radiant, heavy when dim.
//

import SpriteKit
import UIKit

/// Manages the physics behavior of the Core based on adherence state.
/// Handles gravity, restitution, damping, and touch interactions.
final class PhysicsManager {

    // MARK: - Physics Parameter Sets

    /// Physics parameters for radiant state (buoyant, responsive)
    static let radiantParams = PhysicsParams(
        gravityMultiplier: 0.3,
        restitution: 0.8,
        linearDamping: 0.1,
        angularDamping: 0.2,
        responseSpeed: 1.0
    )

    /// Physics parameters for dim state (heavy, sluggish)
    static let dimParams = PhysicsParams(
        gravityMultiplier: 2.0,
        restitution: 0.25,
        linearDamping: 0.7,
        angularDamping: 0.8,
        responseSpeed: 0.4
    )

    // MARK: - Current State

    /// Current interpolated parameters
    private(set) var currentParams: PhysicsParams

    /// Reference to the scene for gravity updates
    private weak var scene: SKScene?

    /// Reference to the core node
    private weak var coreNode: CoreNode?

    /// Current adherence for reference
    private var currentAdherence: CGFloat = 0.5

    // MARK: - Natural Motion

    private let wanderSeedX: TimeInterval
    private let wanderSeedY: TimeInterval

    // MARK: - Initialization

    init() {
        // Start with neutral parameters
        currentParams = PhysicsManager.interpolateParams(adherence: 0.5)

        wanderSeedX = TimeInterval.random(in: 0...1000)
        wanderSeedY = TimeInterval.random(in: 0...1000)
    }

    // MARK: - Setup

    /// Attaches the manager to a scene and core node
    /// - Parameters:
    ///   - scene: The SpriteKit scene
    ///   - coreNode: The CoreNode to manage
    func attach(to scene: SKScene, coreNode: CoreNode) {
        self.scene = scene
        self.coreNode = coreNode

        // Set up core physics body
        coreNode.setupPhysicsBody()

        // Apply initial physics
        updatePhysics(for: .neutral)
    }

    // MARK: - State Updates

    /// Updates physics parameters for a new state
    /// - Parameter state: The target CoreState
    func updatePhysics(for state: CoreState) {
        currentAdherence = state.adherencePercentage
        currentParams = PhysicsManager.interpolateParams(adherence: currentAdherence)

        // Update scene gravity
        scene?.physicsWorld.gravity = CGVector(
            dx: 0,
            dy: -9.8 * currentParams.gravityMultiplier
        )

        // Update body properties
        if let body = coreNode?.physicsBody {
            body.restitution = currentParams.restitution
            body.linearDamping = currentParams.linearDamping
            body.angularDamping = currentParams.angularDamping
        }
    }

    // MARK: - Natural Motion

    /// Applies gentle state-dependent forces so the Core feels alive even when untouched.
    /// - Note: This is intentionally subtle and is disabled while the user is actively touching.
    func updateNaturalMotion(
        currentTime: TimeInterval,
        deltaTime: TimeInterval,
        sceneSize: CGSize,
        breathIntensity: CGFloat,
        breathSegment: BreathSegment,
        isUserInteracting: Bool
    ) {
        _ = deltaTime
        _ = breathSegment
        guard !isUserInteracting,
              let node = coreNode,
              let body = node.physicsBody,
              sceneSize.width > 1,
              sceneSize.height > 1
        else { return }

        let adherence = currentAdherence
        let radius = max(8, node.baseRadius)

        // Desired resting height (radiant floats higher, dim settles low)
        let minY = radius + 16
        let maxY = min(sceneSize.height * 0.75, sceneSize.height - radius - 24)
        var targetY = lerp(minY, maxY, easeInOutSine(adherence))

        // Gentle meander (more active when radiant)
        let centerX = sceneSize.width / 2
        let ampX = lerp(sceneSize.width * 0.02, sceneSize.width * 0.12, adherence)
        let ampY = lerp(sceneSize.height * 0.01, sceneSize.height * 0.06, adherence)

        let wanderX = sin(currentTime * 0.12 + wanderSeedX) * ampX
            + sin(currentTime * 0.037 + wanderSeedX * 0.5) * (ampX * 0.35)
        let wanderY = cos(currentTime * 0.10 + wanderSeedY) * ampY
            + sin(currentTime * 0.053 + wanderSeedY * 0.7) * (ampY * 0.25)

        var targetX = centerX + wanderX
        targetY += wanderY

        // Breath-linked drift (per spec: larger when radiant, minimal when dim)
        // Map intensity (0..1) -> drift (0..+amp) so inhale lifts and exhale settles.
        let driftPercent = lerp(0.005, 0.05, adherence)
        targetY += breathIntensity * driftPercent * sceneSize.height

        // Keep targets in reasonable bounds (prevents constant pushing into walls)
        let minX = radius + 12
        let maxX = sceneSize.width - radius - 12
        targetX = targetX.clamped(to: minX...maxX)
        targetY = targetY.clamped(to: (radius + 12)...(sceneSize.height - radius - 12))

        // Spring-like force toward target
        let dx = targetX - node.position.x
        let dy = targetY - node.position.y
        let normalizedDx = dx / sceneSize.width
        let normalizedDy = dy / sceneSize.height

        let baseForce: CGFloat = lerp(25, 95, adherence)
        let response = currentParams.responseSpeed

        // A touch of velocity damping to avoid jitter.
        let v = body.velocity
        let damping: CGFloat = lerp(0.12, 0.05, adherence)

        let fx = (normalizedDx * baseForce - v.dx * damping) * response
        let fy = (normalizedDy * baseForce - v.dy * damping) * response

        body.applyForce(CGVector(dx: fx, dy: fy))
    }

    // MARK: - Parameter Interpolation

    /// Interpolates physics parameters based on adherence
    private static func interpolateParams(adherence: CGFloat) -> PhysicsParams {
        return PhysicsParams(
            gravityMultiplier: lerp(dimParams.gravityMultiplier, radiantParams.gravityMultiplier, adherence),
            restitution: lerp(dimParams.restitution, radiantParams.restitution, adherence),
            linearDamping: lerp(dimParams.linearDamping, radiantParams.linearDamping, adherence),
            angularDamping: lerp(dimParams.angularDamping, radiantParams.angularDamping, adherence),
            responseSpeed: lerp(dimParams.responseSpeed, radiantParams.responseSpeed, adherence)
        )
    }

    // MARK: - Touch Interactions

    /// Applies an impulse from a tap at the given point
    /// - Parameter point: Location of the tap in scene coordinates
    func applyTapImpulse(at point: CGPoint) {
        guard let body = coreNode?.physicsBody,
              let corePosition = coreNode?.position else { return }

        // Calculate direction from core to tap point
        let direction = CGVector(
            dx: point.x - corePosition.x,
            dy: point.y - corePosition.y
        ).normalized

        // Apply impulse scaled by response speed
        let strength: CGFloat = 80 * currentParams.responseSpeed
        body.applyImpulse(CGVector(dx: direction.dx * strength, dy: direction.dy * strength))
    }

    /// Applies velocity from a swipe gesture
    /// - Parameter velocity: Swipe velocity in points per second
    func applySwipeVelocity(_ velocity: CGVector) {
        guard let body = coreNode?.physicsBody else { return }

        // Scale velocity by response speed
        let scaledVelocity = CGVector(
            dx: velocity.dx * currentParams.responseSpeed * 0.5,
            dy: velocity.dy * currentParams.responseSpeed * 0.5
        )

        // Clamp to reasonable maximum
        let maxSpeed: CGFloat = 800
        let clampedVelocity = CGVector(
            dx: scaledVelocity.dx.clamped(to: -maxSpeed...maxSpeed),
            dy: scaledVelocity.dy.clamped(to: -maxSpeed...maxSpeed)
        )

        body.velocity = clampedVelocity
    }

    /// Applies a gentle attraction toward a point (for hold gesture)
    /// - Parameter point: Target point to attract toward
    func applyHoldAttraction(toward point: CGPoint) {
        guard let body = coreNode?.physicsBody,
              let corePosition = coreNode?.position else { return }

        // Calculate direction to point
        let direction = CGVector(
            dx: point.x - corePosition.x,
            dy: point.y - corePosition.y
        )

        // Apply gentle force (not impulse) for smooth orbiting
        let strength: CGFloat = 2.0 * currentParams.responseSpeed
        body.applyForce(CGVector(dx: direction.dx * strength, dy: direction.dy * strength))
    }

    /// Stops all motion (called on drag start)
    func stopMotion() {
        coreNode?.physicsBody?.velocity = .zero
        coreNode?.physicsBody?.angularVelocity = 0
    }

    // MARK: - Collision Handling

    /// Calculates collision intensity based on velocity
    /// - Parameter velocity: Collision velocity
    /// - Returns: Normalized intensity (0 to 1)
    func collisionIntensity(velocity: CGVector) -> CGFloat {
        let speed = sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy)
        return (speed / 500).clamped(to: 0...1)
    }
}

// MARK: - Physics Parameters

/// Container for physics parameter values
struct PhysicsParams {
    /// Multiplier for gravity (< 1 = buoyant, > 1 = heavy)
    var gravityMultiplier: CGFloat

    /// Bounciness on collision (0 = no bounce, 1 = full bounce)
    var restitution: CGFloat

    /// Resistance to linear motion (0 = none, 1 = high)
    var linearDamping: CGFloat

    /// Resistance to rotation (0 = none, 1 = high)
    var angularDamping: CGFloat

    /// Speed of response to interactions (0 = sluggish, 1 = quick)
    var responseSpeed: CGFloat
}

// MARK: - CGVector Extension

extension CGVector {
    /// Returns a normalized version of the vector
    var normalized: CGVector {
        let length = sqrt(dx * dx + dy * dy)
        guard length > 0 else { return .zero }
        return CGVector(dx: dx / length, dy: dy / length)
    }
}
