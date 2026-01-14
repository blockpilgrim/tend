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

    /// Occasional streak sparks (radiant only)
    private var streakEmitter: SKEmitterNode?

    /// Larger warm particles drifting (radiant only, adherence > 60%)
    private var emberEmitter: SKEmitterNode?

    /// Grey-amber wisps rising slowly (active when dim)
    private var smokeEmitter: SKEmitterNode?

    /// Dark particles falling (active when very dim, < 30%)
    private var ashEmitter: SKEmitterNode?

    // MARK: - References

    /// Core node for continuous emitters (moves with physics)
    private weak var coreNode: CoreNode?

    /// Scene for particle targeting
    private weak var scene: SKScene?

    /// Current adherence for reference
    private var currentAdherence: CGFloat = 0.5

    private var apexBoost: CGFloat = 0

    // MARK: - Initialization

    init() {}

    // MARK: - Setup

    /// Attaches the manager to a scene and parent node
    /// - Parameters:
    ///   - scene: The SpriteKit scene
    ///   - parentNode: The node to attach emitters to
    func attach(to scene: SKScene, coreNode: CoreNode) {
        self.scene = scene
        self.coreNode = coreNode

        // Create all emitters
        createEmitters()

        // Apply initial state
        updateEmitters(for: .neutral, duration: 0)
    }

    func setApexEligible(_ eligible: Bool, animated: Bool = true) {
        _ = animated
        apexBoost = eligible ? 1 : 0
    }

    // MARK: - Emitter Creation

    /// Creates all particle emitters with base configuration
    private func createEmitters() {
        let radius = coreNode?.baseRadius ?? 60

        sparkEmitter = createSparkEmitter(coreRadius: radius)
        streakEmitter = createStreakEmitter(coreRadius: radius)
        emberEmitter = createEmberEmitter(coreRadius: radius)
        smokeEmitter = createSmokeEmitter(coreRadius: radius)
        ashEmitter = createAshEmitter(coreRadius: radius)

        // Add to parent
        if let spark = sparkEmitter { coreNode?.addChild(spark) }
        if let streak = streakEmitter { coreNode?.addChild(streak) }
        if let ember = emberEmitter { coreNode?.addChild(ember) }
        if let smoke = smokeEmitter { coreNode?.addChild(smoke) }
        if let ash = ashEmitter { coreNode?.addChild(ash) }
    }

    /// Creates the spark emitter for radiant states
    private func createSparkEmitter(coreRadius: CGFloat) -> SKEmitterNode {
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
        emitter.particlePositionRange = CGVector(dx: coreRadius * 0.9, dy: coreRadius * 0.5)

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

    private func createStreakEmitter(coreRadius: CGFloat) -> SKEmitterNode {
        let emitter = SKEmitterNode()

        let texture = CoreTextureGenerator.shared.generateStreakParticleTexture(size: CGSize(width: 18, height: 6))
        emitter.particleTexture = texture

        emitter.particleBirthRate = 0
        emitter.numParticlesToEmit = 0

        emitter.particleLifetime = 0.9
        emitter.particleLifetimeRange = 0.3

        emitter.position = .zero
        emitter.particlePositionRange = CGVector(dx: coreRadius * 0.8, dy: coreRadius * 0.45)

        emitter.particleSpeed = 85
        emitter.particleSpeedRange = 35
        emitter.emissionAngle = .pi / 2
        emitter.emissionAngleRange = .pi / 8

        emitter.xAcceleration = 0
        emitter.yAcceleration = 45

        emitter.particleScale = 0.45
        emitter.particleScaleRange = 0.18
        emitter.particleScaleSpeed = -0.25

        emitter.particleAlpha = 0.8
        emitter.particleAlphaSpeed = -0.9

        emitter.particleRotationRange = .pi / 3

        emitter.particleColor = ColorPalette.radiantInnerCoreUI
        emitter.particleColorBlendFactor = 1.0
        emitter.particleBlendMode = .add

        emitter.zPosition = 11

        return emitter
    }

    /// Creates the ember emitter for highly radiant states
    private func createEmberEmitter(coreRadius: CGFloat) -> SKEmitterNode {
        let emitter = SKEmitterNode()

        let texture = CoreTextureGenerator.shared.generateParticleTexture(size: CGSize(width: 12, height: 12))
        emitter.particleTexture = texture

        emitter.particleBirthRate = 2
        emitter.numParticlesToEmit = 0

        emitter.particleLifetime = 2.5
        emitter.particleLifetimeRange = 0.5

        emitter.position = .zero
        emitter.particlePositionRange = CGVector(dx: coreRadius * 0.7, dy: coreRadius * 0.35)

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
    private func createSmokeEmitter(coreRadius: CGFloat) -> SKEmitterNode {
        let emitter = SKEmitterNode()

        let texture = CoreTextureGenerator.shared.generateGlowTexture(size: CGSize(width: 20, height: 20), falloff: 0.6)
        emitter.particleTexture = texture

        emitter.particleBirthRate = 3
        emitter.numParticlesToEmit = 0

        emitter.particleLifetime = 2.0
        emitter.particleLifetimeRange = 0.5

        emitter.position = .zero
        emitter.particlePositionRange = CGVector(dx: coreRadius * 0.5, dy: coreRadius * 0.35)

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
    private func createAshEmitter(coreRadius: CGFloat) -> SKEmitterNode {
        let emitter = SKEmitterNode()

        let texture = CoreTextureGenerator.shared.generateParticleTexture(size: CGSize(width: 6, height: 6))
        emitter.particleTexture = texture

        emitter.particleBirthRate = 1
        emitter.numParticlesToEmit = 0

        emitter.particleLifetime = 3.0
        emitter.particleLifetimeRange = 1.0

        emitter.position = .zero
        emitter.particlePositionRange = CGVector(dx: coreRadius * 0.7, dy: coreRadius * 0.2)

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

        // Streak sparks (variety + energy)
        if adherence > 0.6 {
            let t = ((adherence - 0.6) / 0.4).clamped(to: 0...1)
            let base = lerp(0, 3.5, t)
            streakEmitter?.particleBirthRate = base * (1 + 0.35 * apexBoost)
        } else {
            streakEmitter?.particleBirthRate = 0
        }
        streakEmitter?.particleSpeed = lerp(40, 120, adherence) * (1 + 0.08 * apexBoost)
        streakEmitter?.yAcceleration = lerp(-10, 70, adherence)
        streakEmitter?.particleColor = sparkColor

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
        guard let scene, currentAdherence > 0.3 else { return }

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

        scene.addChild(burst)

        // Remove after emission completes
        burst.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.removeFromParent()
        ]))
    }

    func emitBreathMicroBurst(at position: CGPoint, intensity: CGFloat) {
        guard let scene, currentAdherence > 0.55 else { return }

        let a = currentAdherence.clamped(to: 0...1)
        let strength = intensity.clamped(to: 0...1)

        let burst = SKEmitterNode()
        burst.particleTexture = CoreTextureGenerator.shared.generateStreakParticleTexture(size: CGSize(width: 18, height: 6))
        burst.position = position
        burst.targetNode = scene

        burst.particleBirthRate = 600
        burst.numParticlesToEmit = Int(lerp(6, 16, a) * lerp(0.7, 1.0, strength))

        burst.particleLifetime = lerp(0.25, 0.55, a)
        burst.particleLifetimeRange = 0.18

        burst.particleSpeed = lerp(45, 120, a)
        burst.particleSpeedRange = lerp(25, 65, a)
        burst.emissionAngle = .pi / 2
        burst.emissionAngleRange = .pi / 10

        burst.xAcceleration = 0
        burst.yAcceleration = lerp(15, 95, a)

        burst.particleScale = 0.35
        burst.particleScaleRange = 0.18
        burst.particleScaleSpeed = -0.35

        burst.particleAlpha = 0.85
        burst.particleAlphaRange = 0.15
        burst.particleAlphaSpeed = -2.0

        burst.particleRotationRange = .pi / 2

        burst.particleColor = ColorPalette.sparkColor(adherence: a)
        burst.particleColorBlendFactor = 1.0
        burst.particleBlendMode = .add
        burst.zPosition = 16

        scene.addChild(burst)
        burst.run(.sequence([
            .wait(forDuration: 0.9),
            .removeFromParent()
        ]))
    }

    func emitApexBreathMicroBurst(at position: CGPoint, intensity: CGFloat) {
        guard let scene else { return }

        let strength = intensity.clamped(to: 0...1)

        let burst = SKEmitterNode()
        burst.particleTexture = CoreTextureGenerator.shared.generateStreakParticleTexture(size: CGSize(width: 22, height: 7))
        burst.position = position
        burst.targetNode = scene

        burst.particleBirthRate = 900
        burst.numParticlesToEmit = Int(lerp(14, 26, strength))

        burst.particleLifetime = lerp(0.30, 0.65, strength)
        burst.particleLifetimeRange = 0.22

        burst.particleSpeed = lerp(80, 170, strength)
        burst.particleSpeedRange = 85
        burst.emissionAngle = .pi / 2
        burst.emissionAngleRange = .pi / 5

        burst.xAcceleration = 0
        burst.yAcceleration = lerp(45, 120, strength)

        burst.particleScale = 0.40
        burst.particleScaleRange = 0.22
        burst.particleScaleSpeed = -0.40

        burst.particleAlpha = 0.95
        burst.particleAlphaRange = 0.10
        burst.particleAlphaSpeed = -2.2

        burst.particleRotationRange = .pi

        burst.particleColor = ColorPalette.sparkColor(adherence: 1.0)
        burst.particleColorBlendFactor = 1.0
        burst.particleBlendMode = .add
        burst.zPosition = 17

        scene.addChild(burst)
        burst.run(.sequence([
            .wait(forDuration: 1.05),
            .removeFromParent()
        ]))
    }

    func emitMealOnTrackCelebration(at position: CGPoint, intensity: CGFloat) {
        guard let scene else { return }

        let a = currentAdherence.clamped(to: 0...1)
        let strength = intensity.clamped(to: 0...1)
        let sparkleColor = ColorPalette.sparkColor(adherence: a)

        let dot = SKEmitterNode()
        dot.particleTexture = CoreTextureGenerator.shared.generateParticleTexture(size: CGSize(width: 8, height: 8))
        dot.position = position
        dot.targetNode = scene

        dot.particleBirthRate = 1400
        dot.numParticlesToEmit = Int(lerp(26, 74, strength))

        dot.particleLifetime = lerp(0.55, 0.95, strength)
        dot.particleLifetimeRange = 0.25

        dot.particleSpeed = lerp(160, 320, strength)
        dot.particleSpeedRange = 140
        dot.emissionAngle = .pi / 2
        dot.emissionAngleRange = .pi * 0.95

        dot.yAcceleration = lerp(-170, -90, strength)

        dot.particleScale = 0.42
        dot.particleScaleRange = 0.22
        dot.particleScaleSpeed = -0.55

        dot.particleAlpha = 1.0
        dot.particleAlphaSpeed = -1.25

        dot.particleColor = sparkleColor
        dot.particleColorBlendFactor = 1.0
        dot.particleBlendMode = .add
        dot.zPosition = 18

        scene.addChild(dot)
        dot.run(.sequence([
            .wait(forDuration: 1.25),
            .removeFromParent()
        ]))

        let streak = SKEmitterNode()
        streak.particleTexture = CoreTextureGenerator.shared.generateStreakParticleTexture(size: CGSize(width: 18, height: 6))
        streak.position = position
        streak.targetNode = scene

        streak.particleBirthRate = 1200
        streak.numParticlesToEmit = Int(lerp(10, 28, strength))

        streak.particleLifetime = lerp(0.22, 0.58, strength)
        streak.particleLifetimeRange = 0.18

        streak.particleSpeed = lerp(140, 280, strength)
        streak.particleSpeedRange = 110
        streak.emissionAngle = .pi / 2
        streak.emissionAngleRange = .pi / 3

        streak.yAcceleration = lerp(-150, -80, strength)

        streak.particleScale = 0.45
        streak.particleScaleRange = 0.25
        streak.particleScaleSpeed = -0.40

        streak.particleAlpha = 0.9
        streak.particleAlphaSpeed = -1.8

        streak.particleRotationRange = .pi / 2

        streak.particleColor = sparkleColor
        streak.particleColorBlendFactor = 1.0
        streak.particleBlendMode = .add
        streak.zPosition = 19

        scene.addChild(streak)
        streak.run(.sequence([
            .wait(forDuration: 1.0),
            .removeFromParent()
        ]))
    }

    func emitMealOffTrackPuff(at position: CGPoint, intensity: CGFloat) {
        guard let scene else { return }

        let strength = intensity.clamped(to: 0...1)

        let puff = SKEmitterNode()
        puff.particleTexture = CoreTextureGenerator.shared.generateGlowTexture(size: CGSize(width: 26, height: 26), falloff: 0.55)
        puff.position = position
        puff.targetNode = scene

        puff.particleBirthRate = 900
        puff.numParticlesToEmit = Int(lerp(8, 18, strength))

        puff.particleLifetime = lerp(0.75, 1.25, strength)
        puff.particleLifetimeRange = 0.35

        puff.particleSpeed = lerp(18, 42, strength)
        puff.particleSpeedRange = 18
        puff.emissionAngle = .pi / 2
        puff.emissionAngleRange = .pi / 2

        puff.yAcceleration = 12

        puff.particleScale = 0.55
        puff.particleScaleRange = 0.25
        puff.particleScaleSpeed = 0.20

        puff.particleAlpha = 0.45
        puff.particleAlphaRange = 0.15
        puff.particleAlphaSpeed = -0.35

        puff.particleColor = ColorPalette.dimGlowUI
        puff.particleColorBlendFactor = 1.0
        puff.particleBlendMode = .alpha
        puff.zPosition = 17

        scene.addChild(puff)
        puff.run(.sequence([
            .wait(forDuration: 1.8),
            .removeFromParent()
        ]))
    }

    func emitApexIgnition(at position: CGPoint, intensity: CGFloat) {
        guard let scene else { return }

        let strength = intensity.clamped(to: 0...1)
        let sparkleColor = ColorPalette.sparkColor(adherence: 1.0)

        let dot = SKEmitterNode()
        dot.particleTexture = CoreTextureGenerator.shared.generateParticleTexture(size: CGSize(width: 8, height: 8))
        dot.position = position
        dot.targetNode = scene

        dot.particleBirthRate = 2000
        dot.numParticlesToEmit = Int(lerp(70, 110, strength))

        dot.particleLifetime = lerp(0.65, 1.15, strength)
        dot.particleLifetimeRange = 0.35

        dot.particleSpeed = lerp(220, 380, strength)
        dot.particleSpeedRange = 180
        dot.emissionAngle = .pi / 2
        dot.emissionAngleRange = 2 * .pi

        dot.yAcceleration = -90

        dot.particleScale = 0.45
        dot.particleScaleRange = 0.28
        dot.particleScaleSpeed = -0.60

        dot.particleAlpha = 1.0
        dot.particleAlphaSpeed = -1.05

        dot.particleColor = sparkleColor
        dot.particleColorBlendFactor = 1.0
        dot.particleBlendMode = .add
        dot.zPosition = 20

        scene.addChild(dot)
        dot.run(.sequence([
            .wait(forDuration: 1.6),
            .removeFromParent()
        ]))

        let streak = SKEmitterNode()
        streak.particleTexture = CoreTextureGenerator.shared.generateStreakParticleTexture(size: CGSize(width: 18, height: 6))
        streak.position = position
        streak.targetNode = scene

        streak.particleBirthRate = 2000
        streak.numParticlesToEmit = Int(lerp(26, 46, strength))

        streak.particleLifetime = lerp(0.30, 0.70, strength)
        streak.particleLifetimeRange = 0.25

        streak.particleSpeed = lerp(180, 340, strength)
        streak.particleSpeedRange = 160
        streak.emissionAngle = .pi / 2
        streak.emissionAngleRange = .pi / 1.6

        streak.yAcceleration = -80

        streak.particleScale = 0.52
        streak.particleScaleRange = 0.28
        streak.particleScaleSpeed = -0.45

        streak.particleAlpha = 0.95
        streak.particleAlphaSpeed = -1.55

        streak.particleRotationRange = .pi

        streak.particleColor = sparkleColor
        streak.particleColorBlendFactor = 1.0
        streak.particleBlendMode = .add
        streak.zPosition = 21

        scene.addChild(streak)
        streak.run(.sequence([
            .wait(forDuration: 1.2),
            .removeFromParent()
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
