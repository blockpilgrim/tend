//
//  CoreNode.swift
//  Tend
//
//  SKNode subclass implementing the layered visual rendering of the Radiant Core.
//  All visual properties interpolate smoothly based on adherence percentage.
//

import SpriteKit
import UIKit

/// The visual representation of the Radiant Core using layered sprites.
/// Renders 6 layers from bottom to top: background glow, outer surface,
/// subsurface glow, inner core, striation overlay, and effect node.
final class CoreNode: SKNode {

    // MARK: - Configuration

    /// Base diameter of the core (before breathing scale)
    private let baseDiameterValue: CGFloat

    /// Public read-only diameter (used by scene/managers)
    var baseDiameter: CGFloat { baseDiameterValue }

    var baseRadius: CGFloat { baseDiameterValue / 2 }

    /// Visual root (scaled/brightened by breathing) separate from the physics root.
    private let visualRoot = SKNode()

    // MARK: - Visual Layers (bottom to top)

    /// Soft outer halo extending beyond the core
    private let backgroundGlow: SKSpriteNode

    /// The main surface of the core - semi-translucent shell
    private let outerSurface: SKSpriteNode

    /// Diffuse glow between surface and inner core
    private let subsurfaceGlow: SKSpriteNode

    /// Bright central point - the furnace within
    private let innerCore: SKSpriteNode

    /// Light channels crossing the surface
    private let striationOverlay: SKSpriteNode

    /// Container for blur/glow post-processing effects
    private let effectNode: SKEffectNode

    // MARK: - State

    /// Current adherence for reference
    private var currentAdherence: CGFloat = 0.5

    /// Seed for subtle internal drift (inner core float)
    private let driftSeed: CGFloat = CGFloat.random(in: 0...1000)

    private var tapFlashStartTime: TimeInterval?
    private var tapFlashStrength: CGFloat = 0

    // MARK: - Initialization

    /// Creates a new CoreNode with the specified base diameter
    /// - Parameter baseDiameter: The diameter of the core in points
    init(baseDiameter: CGFloat = 120) {
        self.baseDiameterValue = baseDiameter

        let generator = CoreTextureGenerator.shared

        // Create layers with appropriate sizes
        let glowSize = CGSize(width: baseDiameter * 2.5, height: baseDiameter * 2.5)
        let surfaceSize = CGSize(width: baseDiameter, height: baseDiameter)
        let innerSize = CGSize(width: baseDiameter * 0.5, height: baseDiameter * 0.5)
        let striationSize = CGSize(width: baseDiameter * 0.9, height: baseDiameter * 0.9)

        // Background glow - largest, softest layer
        backgroundGlow = SKSpriteNode(texture: generator.generateGlowTexture(size: glowSize, falloff: 0.3))
        backgroundGlow.size = glowSize
        backgroundGlow.blendMode = .add
        backgroundGlow.alpha = 0.6
        backgroundGlow.zPosition = 0

        // Effect node for glow/blur on inner elements
        effectNode = SKEffectNode()
        effectNode.shouldEnableEffects = true
        effectNode.shouldRasterize = true
        effectNode.zPosition = 1

        // Subsurface glow - diffuse inner light
        subsurfaceGlow = SKSpriteNode(texture: generator.generateGlowTexture(size: surfaceSize, falloff: 0.5))
        subsurfaceGlow.size = CGSize(width: baseDiameter * 1.2, height: baseDiameter * 1.2)
        subsurfaceGlow.blendMode = .add
        subsurfaceGlow.alpha = 0.7
        subsurfaceGlow.zPosition = 2

        // Outer surface - the shell
        outerSurface = SKSpriteNode(texture: generator.generateSurfaceTexture(size: surfaceSize))
        outerSurface.size = surfaceSize
        outerSurface.blendMode = .alpha
        outerSurface.alpha = 0.85
        outerSurface.zPosition = 3

        // Inner core - bright center point
        innerCore = SKSpriteNode(texture: generator.generateInnerCoreTexture(size: innerSize))
        innerCore.size = innerSize
        innerCore.blendMode = .add
        innerCore.alpha = 1.0
        innerCore.zPosition = 4

        // Striation overlay - light channels
        striationOverlay = SKSpriteNode(texture: generator.generateStriationTexture(size: striationSize))
        striationOverlay.size = striationSize
        striationOverlay.blendMode = .add
        striationOverlay.alpha = 0.5
        striationOverlay.zPosition = 5

        super.init()

        addChild(visualRoot)

        // Build layer hierarchy
        visualRoot.addChild(backgroundGlow)
        visualRoot.addChild(effectNode)
        effectNode.addChild(subsurfaceGlow)
        visualRoot.addChild(outerSurface)
        visualRoot.addChild(innerCore)
        visualRoot.addChild(striationOverlay)

        // Set initial colors to neutral state
        applyColors(forAdherence: 0.5)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - State Interpolation

    /// Interpolates all visual properties to match a new state
    /// - Parameters:
    ///   - state: The target CoreState
    ///   - duration: Animation duration in seconds
    func interpolateVisuals(to state: CoreState, duration: TimeInterval) {
        let adherence = state.adherencePercentage
        currentAdherence = adherence

        // Animate color transitions
        animateColors(to: adherence, duration: duration)

        // Animate glow radius
        animateGlowRadius(to: adherence, duration: duration)
    }

    // MARK: - Color Application

    /// Applies colors immediately without animation
    private func applyColors(forAdherence adherence: CGFloat) {
        let innerColor = ColorPalette.interpolateInnerCore(adherence: adherence)
        let glowColor = ColorPalette.interpolateGlow(adherence: adherence)
        let surfaceColor = ColorPalette.interpolateSurface(adherence: adherence)

        innerCore.color = innerColor
        innerCore.colorBlendFactor = 1.0

        subsurfaceGlow.color = glowColor
        subsurfaceGlow.colorBlendFactor = 1.0

        backgroundGlow.color = glowColor
        backgroundGlow.colorBlendFactor = 1.0

        outerSurface.color = surfaceColor
        outerSurface.colorBlendFactor = 0.7

        striationOverlay.color = ColorPalette.sparkColor(adherence: adherence)
        striationOverlay.colorBlendFactor = 1.0
    }

    /// Animates color transitions over duration
    private func animateColors(to adherence: CGFloat, duration: TimeInterval) {
        let innerColor = ColorPalette.interpolateInnerCore(adherence: adherence)
        let glowColor = ColorPalette.interpolateGlow(adherence: adherence)
        let surfaceColor = ColorPalette.interpolateSurface(adherence: adherence)
        let striationColor = ColorPalette.sparkColor(adherence: adherence)

        // Animate inner core color
        innerCore.run(SKAction.colorize(with: innerColor, colorBlendFactor: 1.0, duration: duration))

        // Animate glow colors
        subsurfaceGlow.run(SKAction.colorize(with: glowColor, colorBlendFactor: 1.0, duration: duration))
        backgroundGlow.run(SKAction.colorize(with: glowColor, colorBlendFactor: 1.0, duration: duration))

        // Animate surface color
        outerSurface.run(SKAction.colorize(with: surfaceColor, colorBlendFactor: 0.7, duration: duration))

        // Animate striation color
        striationOverlay.run(SKAction.colorize(with: striationColor, colorBlendFactor: 1.0, duration: duration))
    }

    // MARK: - Glow Radius Animation

    /// Animates glow radius based on adherence
    private func animateGlowRadius(to adherence: CGFloat, duration: TimeInterval) {
        // Glow radius: smaller when dim, larger when radiant
        let glowScale = lerp(0.6, 1.2, adherence)
        let glowSize = CGSize(
            width: baseDiameterValue * 2.5 * glowScale,
            height: baseDiameterValue * 2.5 * glowScale
        )
        backgroundGlow.run(SKAction.resize(toWidth: glowSize.width, height: glowSize.height, duration: duration))

        // Subsurface also scales slightly
        let subsurfaceScale = lerp(0.9, 1.3, adherence)
        let subsurfaceSize = CGSize(
            width: baseDiameterValue * 1.2 * subsurfaceScale,
            height: baseDiameterValue * 1.2 * subsurfaceScale
        )
        subsurfaceGlow.run(SKAction.resize(toWidth: subsurfaceSize.width, height: subsurfaceSize.height, duration: duration))
    }

    // MARK: - Breathing Interface

    /// Sets the scale of all layers (called by BreathingController)
    /// - Parameter scale: Scale factor (1.0 = normal, >1 = expanded, <1 = contracted)
    func setBreathScale(_ scale: CGFloat) {
        // Scale visuals only (physics body remains stable)
        visualRoot.setScale(scale)
    }

    /// Applies breath-driven brightness + subtle internal drift.
    /// - Parameters:
    ///   - intensity: Breath intensity 0...1 (0 = resting/exhale, 1 = peak inhale)
    ///   - brightnessBoost: Brightness boost 0...~0.2 (state-dependent)
    ///   - time: Scene time for drift
    func applyBreath(intensity: CGFloat, brightnessBoost: CGFloat, time: TimeInterval) {
        let i = intensity.clamped(to: 0...1)
        let b = brightnessBoost.clamped(to: 0...0.25)

        var tapFlash: CGFloat = 0
        if let start = tapFlashStartTime {
            let elapsed = time - start
            if elapsed >= 0.18 {
                tapFlashStartTime = nil
                tapFlashStrength = 0
            } else if elapsed >= 0 {
                let t = (1 - CGFloat(elapsed / 0.18)).clamped(to: 0...1)
                tapFlash = tapFlashStrength * t
            }
        }

        // Baseline visibility by state (ensures the Core reads even when "cold")
        let baseInner = lerp(0.55, 1.0, currentAdherence)
        let baseSub = lerp(0.45, 0.9, currentAdherence)
        let baseStriation = lerp(0.18, 0.7, currentAdherence)
        let baseHalo = lerp(0.35, 0.85, currentAdherence)

        let totalBoost = (b + tapFlash * 0.25).clamped(to: 0...0.4)

        innerCore.alpha = (baseInner * (1 + totalBoost)).clamped(to: 0.25...1.0)
        subsurfaceGlow.alpha = (baseSub * (1 + totalBoost * 0.8)).clamped(to: 0.20...1.0)
        striationOverlay.alpha = (baseStriation * (0.85 + 0.25 * i) + totalBoost * 0.10).clamped(to: 0.0...1.0)
        backgroundGlow.alpha = (baseHalo * (0.90 + 0.15 * i) + totalBoost * 0.15).clamped(to: 0.0...1.0)

        // Inner core drift (subtle, more noticeable when radiant)
        let driftAmplitude = baseRadius * lerp(0.010, 0.028, currentAdherence)
        let dx = sin(time * 0.35 + driftSeed) * driftAmplitude
        let dy = cos(time * 0.27 + driftSeed * 1.7) * driftAmplitude
        innerCore.position = CGPoint(x: dx, y: dy)
    }

    // MARK: - Physics Setup

    /// Creates and attaches a physics body for interactions
    func setupPhysicsBody() {
        let radius = baseDiameterValue / 2
        guard radius > 0 else { return }
        physicsBody = SKPhysicsBody(circleOfRadius: radius)
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = true
        physicsBody?.allowsRotation = false
        physicsBody?.mass = 1.0
        physicsBody?.restitution = 0.5
        physicsBody?.linearDamping = 0.3
        physicsBody?.angularDamping = 0.5
        physicsBody?.categoryBitMask = PhysicsCategory.core
        physicsBody?.contactTestBitMask = PhysicsCategory.boundary
        physicsBody?.collisionBitMask = PhysicsCategory.boundary
    }

    // MARK: - Interaction Feedback

    /// Flash effect when tapped
    func flashOnTap(intensity: CGFloat) {
        tapFlashStartTime = CACurrentMediaTime()
        tapFlashStrength = intensity.clamped(to: 0...1)
    }
}

// MARK: - Physics Categories

/// Physics category bitmasks for collision detection
enum PhysicsCategory {
    static let none: UInt32 = 0
    static let core: UInt32 = 0x1 << 0
    static let boundary: UInt32 = 0x1 << 1
}
