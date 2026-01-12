//
//  ParticleManager.swift
//  Tend
//
//  Manages particle effects for the Radiant Core.
//  Sparks and embers rise when radiant; smoke and ash fall when dim.
//

import SpriteKit
import UIKit

/// Manages SKEmitterNode instances for state-based particle effects.
/// Creates emitters programmatically for runtime parameter control.
final class ParticleManager {

    // MARK: - Emitter Nodes

    /// Golden-white particles rising (active when radiant)
    private var sparkEmitter: SKEmitterNode?

    /// Larger warm particles drifting (radiant only, adherence > 60%)
    private var emberEmitter: SKEmitterNode?

    /// Grey-amber wisps rising slowly (active when dim)
    private var smokeEmitter: SKEmitterNode?

    /// Dark particles falling (active when very dim, < 30%)
    private var ashEmitter: SKEmitterNode?

    // MARK: - References

    /// Parent node for particles
    private weak var parentNode: SKNode?

    /// Scene for particle targeting
    private weak var scene: SKScene?

    /// Current adherence for reference
    private var currentAdherence: CGFloat = 0.5

    // MARK: - Initialization

    init() {}

    // MARK: - Setup

    /// Attaches the manager to a scene and parent node
    /// - Parameters:
    ///   - scene: The SpriteKit scene
    ///   - parentNode: The node to attach emitters to
    func attach(to scene: SKScene, parentNode: SKNode) {
        self.scene = scene
        self.parentNode = parentNode

        // Create all emitters
        createEmitters()

        // Apply initial state
        updateEmitters(for: .neutral, duration: 0)
    }

    // MARK: - Emitter Creation

    /// Creates all particle emitters with base configuration
    private func createEmitters() {
        sparkEmitter = createSparkEmitter()
        emberEmitter = createEmberEmitter()
        smokeEmitter = createSmokeEmitter()
        ashEmitter = createAshEmitter()

        // Add to parent
        if let spark = sparkEmitter { parentNode?.addChild(spark) }
        if let ember = emberEmitter { parentNode?.addChild(ember) }
        if let smoke = smokeEmitter { parentNode?.addChild(smoke) }
        if let ash = ashEmitter { parentNode?.addChild(ash) }
    }

    /// Creates the spark emitter for radiant states
    private func createSparkEmitter() -> SKEmitterNode {
        let emitter = SKEmitterNode()

        // Texture
        let texture = CoreTextureGenerator.shared.generateParticleTexture(size: CGSize(width: 8, height: 8))
        emitter.particleTexture = texture

        // Emission
        emitter.particleBirthRate = 10
        emitter.numParticlesToEmit = 0  // Continuous

        // Lifetime
        emitter.particleLifetime = 1.5
        emitter.particleLifetimeRange = 0.5

        // Position
        emitter.position = .zero
        emitter.particlePositionRange = CGVector(dx: 50, dy: 30)

        // Movement
        emitter.particleSpeed = 60
        emitter.particleSpeedRange = 20
        emitter.emissionAngle = .pi / 2  // Upward
        emitter.emissionAngleRange = .pi / 6

        // Acceleration (rise)
        emitter.xAcceleration = 0
        emitter.yAcceleration = 30

        // Scale
        emitter.particleScale = 0.5
        emitter.particleScaleRange = 0.2
        emitter.particleScaleSpeed = -0.2  // Shrink over time

        // Alpha
        emitter.particleAlpha = 1.0
        emitter.particleAlphaSpeed = -0.5

        // Color
        emitter.particleColor = ColorPalette.radiantInnerCoreUI
        emitter.particleColorBlendFactor = 1.0

        // Blend mode
        emitter.particleBlendMode = .add

        emitter.zPosition = 10

        return emitter
    }

    /// Creates the ember emitter for highly radiant states
    private func createEmberEmitter() -> SKEmitterNode {
        let emitter = SKEmitterNode()

        let texture = CoreTextureGenerator.shared.generateParticleTexture(size: CGSize(width: 12, height: 12))
        emitter.particleTexture = texture

        emitter.particleBirthRate = 2
        emitter.numParticlesToEmit = 0

        emitter.particleLifetime = 2.5
        emitter.particleLifetimeRange = 0.5

        emitter.position = .zero
        emitter.particlePositionRange = CGVector(dx: 40, dy: 20)

        emitter.particleSpeed = 30
        emitter.particleSpeedRange = 15
        emitter.emissionAngle = .pi / 2
        emitter.emissionAngleRange = .pi / 4

        emitter.xAcceleration = 0
        emitter.yAcceleration = 15

        emitter.particleScale = 0.8
        emitter.particleScaleRange = 0.3
        emitter.particleScaleSpeed = -0.1

        emitter.particleAlpha = 0.9
        emitter.particleAlphaSpeed = -0.3

        emitter.particleColor = ColorPalette.radiantGlowUI
        emitter.particleColorBlendFactor = 1.0

        emitter.particleBlendMode = .add

        emitter.zPosition = 9

        return emitter
    }

    /// Creates the smoke emitter for dim states
    private func createSmokeEmitter() -> SKEmitterNode {
        let emitter = SKEmitterNode()

        let texture = CoreTextureGenerator.shared.generateGlowTexture(size: CGSize(width: 20, height: 20), falloff: 0.6)
        emitter.particleTexture = texture

        emitter.particleBirthRate = 3
        emitter.numParticlesToEmit = 0

        emitter.particleLifetime = 2.0
        emitter.particleLifetimeRange = 0.5

        emitter.position = .zero
        emitter.particlePositionRange = CGVector(dx: 30, dy: 20)

        emitter.particleSpeed = 20
        emitter.particleSpeedRange = 10
        emitter.emissionAngle = .pi / 2
        emitter.emissionAngleRange = .pi / 3

        emitter.xAcceleration = 0
        emitter.yAcceleration = 10

        emitter.particleScale = 0.6
        emitter.particleScaleRange = 0.2
        emitter.particleScaleSpeed = 0.1  // Grow as it dissipates

        emitter.particleAlpha = 0.5
        emitter.particleAlphaSpeed = -0.2

        emitter.particleColor = ColorPalette.dimGlowUI
        emitter.particleColorBlendFactor = 1.0

        emitter.particleBlendMode = .alpha

        emitter.zPosition = 8

        return emitter
    }

    /// Creates the ash emitter for very dim states
    private func createAshEmitter() -> SKEmitterNode {
        let emitter = SKEmitterNode()

        let texture = CoreTextureGenerator.shared.generateParticleTexture(size: CGSize(width: 6, height: 6))
        emitter.particleTexture = texture

        emitter.particleBirthRate = 1
        emitter.numParticlesToEmit = 0

        emitter.particleLifetime = 3.0
        emitter.particleLifetimeRange = 1.0

        emitter.position = .zero
        emitter.particlePositionRange = CGVector(dx: 40, dy: 10)

        emitter.particleSpeed = 15
        emitter.particleSpeedRange = 5
        emitter.emissionAngle = -.pi / 2  // Downward
        emitter.emissionAngleRange = .pi / 4

        // Fall acceleration
        emitter.xAcceleration = 0
        emitter.yAcceleration = -40

        emitter.particleScale = 0.4
        emitter.particleScaleRange = 0.2
        emitter.particleScaleSpeed = 0

        emitter.particleAlpha = 0.6
        emitter.particleAlphaSpeed = -0.15

        emitter.particleColor = ColorPalette.dimSurfaceUI
        emitter.particleColorBlendFactor = 1.0

        emitter.particleBlendMode = .alpha

        emitter.zPosition = 7

        return emitter
    }

    // MARK: - State Updates

    /// Updates all emitters for a new state
    /// - Parameters:
    ///   - state: The target CoreState
    ///   - duration: Transition duration (unused, transitions are instant for particles)
    func updateEmitters(for state: CoreState, duration: TimeInterval) {
        let adherence = state.adherencePercentage
        currentAdherence = adherence

        // Sparks: Active when radiant, minimal when dim
        sparkEmitter?.particleBirthRate = lerp(0, 15, adherence)
        sparkEmitter?.particleSpeed = lerp(20, 80, adherence)
        sparkEmitter?.particleLifetime = lerp(0.5, 2.0, adherence)
        sparkEmitter?.yAcceleration = lerp(-20, 50, adherence)  // Fall when dim, rise when radiant

        // Update spark color
        let sparkColor = ColorPalette.sparkColor(adherence: adherence)
        sparkEmitter?.particleColor = sparkColor

        // Embers: Only when adherence > 60%
        if adherence > 0.6 {
            emberEmitter?.particleBirthRate = lerp(0, 3, (adherence - 0.6) / 0.4)
        } else {
            emberEmitter?.particleBirthRate = 0
        }

        // Smoke: Active when dim
        smokeEmitter?.particleBirthRate = lerp(5, 0, adherence)
        smokeEmitter?.particleAlpha = lerp(0.6, 0, adherence)

        // Ash: Falls when very dim (< 30%)
        if adherence < 0.3 {
            ashEmitter?.particleBirthRate = lerp(2, 0, adherence / 0.3)
        } else {
            ashEmitter?.particleBirthRate = 0
        }
    }

    // MARK: - Burst Effects

    /// Emits a burst of sparks at a position (for tap interactions)
    /// - Parameters:
    ///   - position: Burst position in parent coordinates
    ///   - intensity: Intensity of the burst (0 to 1)
    func emitSparkBurst(at position: CGPoint, intensity: CGFloat) {
        guard let parent = parentNode, currentAdherence > 0.3 else { return }

        // Create temporary emitter for burst
        let burst = SKEmitterNode()

        let texture = CoreTextureGenerator.shared.generateParticleTexture(size: CGSize(width: 8, height: 8))
        burst.particleTexture = texture

        burst.position = position
        burst.particleBirthRate = 50 * intensity
        burst.numParticlesToEmit = Int(20 * intensity)

        burst.particleLifetime = 0.8
        burst.particleLifetimeRange = 0.2

        burst.particleSpeed = 100 * intensity
        burst.particleSpeedRange = 40
        burst.emissionAngleRange = 2 * .pi  // All directions

        burst.particleScale = 0.4
        burst.particleScaleSpeed = -0.3

        burst.particleAlpha = 1.0
        burst.particleAlphaSpeed = -1.0

        burst.particleColor = ColorPalette.sparkColor(adherence: currentAdherence)
        burst.particleColorBlendFactor = 1.0
        burst.particleBlendMode = .add

        burst.zPosition = 15
        burst.targetNode = scene

        parent.addChild(burst)

        // Remove after emission completes
        burst.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.removeFromParent()
        ]))
    }

    /// Emits a collision effect (sparks if radiant, dust if dim)
    /// - Parameters:
    ///   - position: Collision position
    ///   - velocity: Collision velocity for intensity calculation
    func emitCollisionEffect(at position: CGPoint, velocity: CGVector) {
        let speed = sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy)
        let intensity = (speed / 300).clamped(to: 0...1)

        if currentAdherence > 0.5 {
            // Spark burst for radiant
            emitSparkBurst(at: position, intensity: intensity * currentAdherence)
        }
        // Dim states don't emit collision particles (per spec)
    }

    // MARK: - Update Loop

    /// Called each frame (currently unused, but available for future effects)
    func update(currentTime: TimeInterval) {
        // Reserved for future particle behavior updates
    }
}
