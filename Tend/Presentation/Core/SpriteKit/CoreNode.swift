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

    /// Base size of the core (before breathing scale)
    private let baseSize: CGFloat

    /// Base position (center of screen, used for breathing drift)
    private(set) var basePosition: CGPoint = .zero

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

    /// Current brightness adjustment from breathing
    private var currentBrightnessAdjustment: CGFloat = 0

    /// Current adherence for reference
    private var currentAdherence: CGFloat = 0.5

    // MARK: - Initialization

    /// Creates a new CoreNode with the specified base size
    /// - Parameter baseSize: The diameter of the core in points
    init(baseSize: CGFloat = 120) {
        self.baseSize = baseSize

        let generator = CoreTextureGenerator.shared

        // Create layers with appropriate sizes
        let glowSize = CGSize(width: baseSize * 2.5, height: baseSize * 2.5)
        let surfaceSize = CGSize(width: baseSize, height: baseSize)
        let innerSize = CGSize(width: baseSize * 0.5, height: baseSize * 0.5)
        let striationSize = CGSize(width: baseSize * 0.9, height: baseSize * 0.9)

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
        subsurfaceGlow.size = CGSize(width: baseSize * 1.2, height: baseSize * 1.2)
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

        // Build layer hierarchy
        addChild(backgroundGlow)
        addChild(effectNode)
        effectNode.addChild(subsurfaceGlow)
        addChild(outerSurface)
        addChild(innerCore)
        addChild(striationOverlay)

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

        // Animate brightness/opacity transitions
        animateOpacity(to: adherence, duration: duration)

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

    // MARK: - Opacity Animation

    /// Animates opacity/brightness based on adherence
    private func animateOpacity(to adherence: CGFloat, duration: TimeInterval) {
        // Inner core brightness: 0.4 (dim) to 1.0 (radiant)
        let innerAlpha = lerp(0.4, 1.0, adherence)
        innerCore.run(SKAction.fadeAlpha(to: innerAlpha, duration: duration))

        // Subsurface glow intensity
        let subsurfaceAlpha = lerp(0.3, 0.8, adherence)
        subsurfaceGlow.run(SKAction.fadeAlpha(to: subsurfaceAlpha, duration: duration))

        // Striation visibility: barely visible when dim, prominent when radiant
        let striationAlpha = lerp(0.1, 0.7, adherence)
        striationOverlay.run(SKAction.fadeAlpha(to: striationAlpha, duration: duration))

        // Background glow intensity
        let glowAlpha = lerp(0.2, 0.7, adherence)
        backgroundGlow.run(SKAction.fadeAlpha(to: glowAlpha, duration: duration))
    }

    // MARK: - Glow Radius Animation

    /// Animates glow radius based on adherence
    private func animateGlowRadius(to adherence: CGFloat, duration: TimeInterval) {
        // Glow radius: smaller when dim, larger when radiant
        let glowScale = lerp(0.6, 1.2, adherence)
        let glowSize = CGSize(
            width: baseSize * 2.5 * glowScale,
            height: baseSize * 2.5 * glowScale
        )
        backgroundGlow.run(SKAction.resize(toWidth: glowSize.width, height: glowSize.height, duration: duration))

        // Subsurface also scales slightly
        let subsurfaceScale = lerp(0.9, 1.3, adherence)
        let subsurfaceSize = CGSize(
            width: baseSize * 1.2 * subsurfaceScale,
            height: baseSize * 1.2 * subsurfaceScale
        )
        subsurfaceGlow.run(SKAction.resize(toWidth: subsurfaceSize.width, height: subsurfaceSize.height, duration: duration))
    }

    // MARK: - Breathing Interface

    /// Sets the scale of all layers (called by BreathingController)
    /// - Parameter scale: Scale factor (1.0 = normal, >1 = expanded, <1 = contracted)
    func setBreathScale(_ scale: CGFloat) {
        // Scale the entire node
        self.setScale(scale)
    }

    /// Adjusts brightness for breathing effect
    /// - Parameter adjustment: Brightness adjustment (-1 to 1)
    func adjustBrightness(by adjustment: CGFloat) {
        currentBrightnessAdjustment = adjustment

        // Apply brightness as alpha modulation
        let baseAlpha = lerp(0.4, 1.0, currentAdherence)
        let adjustedAlpha = (baseAlpha + adjustment * 0.2).clamped(to: 0.2...1.0)
        innerCore.alpha = adjustedAlpha

        // Also modulate subsurface glow
        let baseSubsurface = lerp(0.3, 0.8, currentAdherence)
        let adjustedSubsurface = (baseSubsurface + adjustment * 0.15).clamped(to: 0.2...1.0)
        subsurfaceGlow.alpha = adjustedSubsurface
    }

    /// Sets base position for breathing drift calculation
    func setBasePosition(_ position: CGPoint) {
        basePosition = position
        self.position = position
    }

    // MARK: - Physics Setup

    /// Creates and attaches a physics body for interactions
    func setupPhysicsBody() {
        let radius = baseSize / 2
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
        let brighten = SKAction.run { [weak self] in
            self?.innerCore.alpha = 1.0
            self?.subsurfaceGlow.alpha = 1.0
        }

        let wait = SKAction.wait(forDuration: 0.1)

        let restore = SKAction.run { [weak self] in
            guard let self = self else { return }
            let baseInner = lerp(0.4, 1.0, self.currentAdherence)
            let baseSub = lerp(0.3, 0.8, self.currentAdherence)
            self.innerCore.alpha = baseInner
            self.subsurfaceGlow.alpha = baseSub
        }

        run(SKAction.sequence([brighten, wait, restore]))
    }
}

// MARK: - Physics Categories

/// Physics category bitmasks for collision detection
enum PhysicsCategory {
    static let none: UInt32 = 0
    static let core: UInt32 = 0x1 << 0
    static let boundary: UInt32 = 0x1 << 1
}
