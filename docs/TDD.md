# Tend: Technical Design Document

**Version:** 1.0
**Last Updated:** January 2026
**Status:** MVP Planning

---

## 1. Executive Summary

### 1.1 Technical Vision

Tend is an iOS application that transforms dietary adherence tracking into an emotionally resonant experience through a procedurally-animated entity called the **Radiant Core**. The technical challenge is creating a living, breathing visual element that responds to user behavior with physics-based feedback—all while maintaining 60fps performance and battery efficiency.

The architecture prioritizes:

1. **Responsiveness**: Immediate visual feedback to user actions
2. **Fluidity**: Smooth state interpolation across visual, physics, and haptic properties
3. **Simplicity**: Local-first data model with no backend complexity for MVP
4. **Extensibility**: Clean abstractions for future AI integration and cloud sync

### 1.2 Key Architectural Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Minimum iOS | 17.0+ | Enables SwiftData, @Observable, latest SwiftUI APIs |
| UI Framework | SwiftUI | Declarative, native, excellent iOS integration |
| Core Rendering | SpriteKit | 2D physics, particle systems, proven 60fps performance |
| State Management | @Observable | Clean, native reactive patterns without Combine boilerplate |
| Persistence | SwiftData | Type-safe, modern Core Data replacement |
| Backend | None (MVP) | Local-only reduces complexity; cloud sync as future enhancement |
| Payments | RevenueCat | Abstracts StoreKit 2 complexity, provides analytics |
| AI Integration | Protocol-based | Abstracted interface; provider selection deferred |

---

## 2. Architecture Overview

### 2.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │  SwiftUI    │  │  SpriteKit  │  │   View Models           │  │
│  │  Views      │  │  Scene      │  │   (@Observable)         │  │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                        DOMAIN LAYER                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │  Use Cases  │  │   Models    │  │   Services (Protocols)  │  │
│  │             │  │   (Domain)  │  │                         │  │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                         DATA LAYER                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │  SwiftData  │  │ FileManager │  │   External Services     │  │
│  │  (Meals,    │  │ (Photos)    │  │   (RevenueCat, AI API)  │  │
│  │   Goals)    │  │             │  │                         │  │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 Pattern: MVVM with Clean Architecture

- **View**: SwiftUI views and SpriteKit scene (presentation only)
- **ViewModel**: @Observable classes that expose state and handle user intent
- **Model**: Domain entities (can differ from persistence models)
- **Use Cases**: Business logic encapsulation (e.g., `LogMealUseCase`, `CalculateAdherenceUseCase`)
- **Repository**: Data access abstraction (protocols with SwiftData implementations)

### 2.3 Dependency Injection

Protocol-based DI without third-party frameworks:

```swift
// Protocol definition
protocol MealRepositoryProtocol {
    func save(_ meal: Meal) async throws
    func fetchMeals(for date: Date) async -> [Meal]
    func fetchMeals(forWeekContaining date: Date) async -> [Meal]
}

// Concrete implementation
final class MealRepository: MealRepositoryProtocol {
    private let modelContext: ModelContext
    // ...
}

// Injection via initializer
@Observable
final class CoreViewModel {
    private let mealRepository: MealRepositoryProtocol
    private let adherenceCalculator: AdherenceCalculatorProtocol

    init(
        mealRepository: MealRepositoryProtocol,
        adherenceCalculator: AdherenceCalculatorProtocol
    ) {
        self.mealRepository = mealRepository
        self.adherenceCalculator = adherenceCalculator
    }
}
```

### 2.4 Project Structure

```
Tend/
├── App/
│   ├── TendApp.swift              # @main entry point
│   └── AppState.swift             # Global app state
├── Presentation/
│   ├── Core/
│   │   ├── CoreView.swift         # Main SwiftUI view
│   │   ├── CoreViewModel.swift    # @Observable view model
│   │   └── SpriteKit/
│   │       ├── RadiantCoreScene.swift
│   │       ├── CoreNode.swift
│   │       ├── BreathingController.swift
│   │       └── ParticleManager.swift
│   ├── Progress/
│   │   ├── ProgressView.swift
│   │   └── ProgressViewModel.swift
│   ├── MealLogging/
│   │   ├── CaptureView.swift
│   │   ├── ConfirmationView.swift
│   │   └── MealLoggingViewModel.swift
│   ├── Onboarding/
│   │   └── OnboardingFlow.swift
│   └── Components/
│       └── (Shared UI components)
├── Domain/
│   ├── Models/
│   │   ├── Meal.swift
│   │   ├── DietaryGoal.swift
│   │   └── CoreState.swift
│   ├── UseCases/
│   │   ├── LogMealUseCase.swift
│   │   └── CalculateAdherenceUseCase.swift
│   └── Services/
│       ├── AdherenceCalculator.swift
│       └── CalorieEstimationService.swift
├── Data/
│   ├── Persistence/
│   │   ├── MealEntity.swift       # SwiftData @Model
│   │   ├── GoalEntity.swift
│   │   └── MealRepository.swift
│   ├── Camera/
│   │   └── CameraService.swift
│   ├── Storage/
│   │   └── PhotoStorageService.swift
│   └── External/
│       └── RevenueCatService.swift
├── Engine/
│   ├── Haptics/
│   │   └── HapticsManager.swift
│   └── Audio/
│       └── AudioManager.swift
└── Resources/
    ├── Assets.xcassets
    ├── Sounds/
    └── Particles/                  # .sks files
```

---

## 3. Core Engine (SpriteKit)

The Radiant Core is the heart of the app. This section details its technical implementation.

### 3.1 RadiantCoreScene

The main SpriteKit scene that hosts the Core and manages the render loop.

```swift
final class RadiantCoreScene: SKScene {

    // MARK: - Properties
    private var coreNode: CoreNode!
    private var breathingController: BreathingController!
    private var particleManager: ParticleManager!
    private var physicsManager: PhysicsManager!

    private var currentState: CoreState = .neutral

    // MARK: - Lifecycle
    override func didMove(to view: SKView) {
        setupScene()
        setupCore()
        setupPhysics()
        startBreathing()
    }

    override func update(_ currentTime: TimeInterval) {
        breathingController.update(currentTime: currentTime)
        particleManager.update(currentTime: currentTime)
    }

    // MARK: - State Updates
    func updateState(_ newState: CoreState, animated: Bool = true) {
        let duration = animated ? transitionDuration(from: currentState, to: newState) : 0

        coreNode.interpolateVisuals(to: newState, duration: duration)
        breathingController.updateParameters(for: newState, duration: duration)
        particleManager.updateEmitters(for: newState, duration: duration)
        physicsManager.updatePhysics(for: newState)

        currentState = newState
    }
}
```

### 3.2 CoreNode

SKNode subclass implementing the layered visual rendering.

```swift
final class CoreNode: SKNode {

    // MARK: - Visual Layers (bottom to top)
    private let backgroundGlow: SKSpriteNode      // Soft outer halo
    private let outerSurface: SKSpriteNode        // Semi-translucent shell
    private let subsurfaceGlow: SKSpriteNode      // Diffuse inner glow
    private let innerCore: SKSpriteNode           // Bright central point
    private let striationOverlay: SKSpriteNode    // Light channels
    private let effectNode: SKEffectNode          // Blur/glow effects

    // MARK: - State Interpolation
    func interpolateVisuals(to state: CoreState, duration: TimeInterval) {
        let adherence = state.adherencePercentage

        // Color interpolation
        let innerColor = ColorPalette.interpolateInnerCore(adherence: adherence)
        let glowColor = ColorPalette.interpolateGlow(adherence: adherence)
        let surfaceTint = ColorPalette.interpolateSurface(adherence: adherence)

        // Brightness/opacity interpolation
        let innerBrightness = lerp(0.3, 1.0, adherence)
        let glowRadius = lerp(0.5, 1.5, adherence)  // Relative scale
        let striationOpacity = lerp(0.1, 0.8, adherence)

        // Animate transitions
        let colorAction = SKAction.group([
            innerCore.colorizeAction(to: innerColor, duration: duration),
            backgroundGlow.fadeAlphaAction(to: glowRadius, duration: duration),
            subsurfaceGlow.colorizeAction(to: glowColor, duration: duration),
            striationOverlay.fadeAlphaAction(to: striationOpacity, duration: duration)
        ])

        run(colorAction)
    }
}
```

### 3.3 BreathingController

Procedural animation system for the breathing effect.

```swift
final class BreathingController {

    // MARK: - Parameters
    private var cycleDuration: TimeInterval = 12.0  // Radiant default
    private var scaleRange: CGFloat = 0.08          // ±8% scale
    private var brightnessRange: CGFloat = 0.15     // ±15% brightness
    private var verticalDrift: CGFloat = 0.03       // ±3% screen height

    private var irregularity: CGFloat = 0.0         // 0.0 = steady, 1.0 = very irregular
    private var noiseOffset: TimeInterval = 0.0

    private weak var coreNode: CoreNode?
    private weak var hapticsManager: HapticsManager?

    // MARK: - Update Loop
    func update(currentTime: TimeInterval) {
        let phase = calculateBreathPhase(currentTime: currentTime)
        let breathValue = calculateBreathValue(phase: phase, time: currentTime)

        applyBreathToCore(breathValue: breathValue)

        // Sync haptics on breath boundaries
        if isBreathBoundary(phase: phase) {
            hapticsManager?.playBreathPulse(intensity: breathValue)
        }
    }

    private func calculateBreathPhase(currentTime: TimeInterval) -> CGFloat {
        return CGFloat((currentTime.truncatingRemainder(dividingBy: cycleDuration)) / cycleDuration)
    }

    private func calculateBreathValue(phase: CGFloat, time: TimeInterval) -> CGFloat {
        // Base sine wave
        var value = sin(phase * 2 * .pi)

        // Add irregularity for dim states
        if irregularity > 0 {
            let noise = perlinNoise(x: Float(time * 2.0), y: 0)
            value += CGFloat(noise) * irregularity * 0.3

            // Occasional breath catch
            if shouldCatchBreath(time: time) {
                value *= 0.3  // Shallow breath
            }
        }

        return value
    }

    private func applyBreathToCore(breathValue: CGFloat) {
        guard let core = coreNode else { return }

        // Scale
        let scale = 1.0 + (breathValue * scaleRange)
        core.setScale(scale)

        // Brightness
        let brightness = breathValue * brightnessRange
        core.adjustBrightness(by: brightness)

        // Vertical position
        let yOffset = breathValue * verticalDrift
        core.position.y = core.basePosition.y + (yOffset * UIScreen.main.bounds.height)
    }

    // MARK: - Parameter Updates
    func updateParameters(for state: CoreState, duration: TimeInterval) {
        let adherence = state.adherencePercentage

        // Interpolate breathing parameters
        let targetCycleDuration = lerp(4.0, 15.0, adherence)  // Fast when dim, slow when radiant
        let targetScaleRange = lerp(0.02, 0.10, adherence)    // Shallow when dim, deep when radiant
        let targetIrregularity = lerp(0.8, 0.0, adherence)    // Irregular when dim, steady when radiant

        // Animate parameter changes
        animateParameter(\.cycleDuration, to: targetCycleDuration, duration: duration)
        animateParameter(\.scaleRange, to: targetScaleRange, duration: duration)
        animateParameter(\.irregularity, to: targetIrregularity, duration: duration)
    }
}
```

### 3.4 ParticleManager

Manages SKEmitterNode instances for sparks, embers, smoke, and ash.

```swift
final class ParticleManager {

    // MARK: - Emitter Nodes
    private var sparkEmitter: SKEmitterNode?
    private var emberEmitter: SKEmitterNode?
    private var smokeEmitter: SKEmitterNode?
    private var ashEmitter: SKEmitterNode?

    private weak var parentNode: SKNode?

    // MARK: - State-Based Configuration
    func updateEmitters(for state: CoreState, duration: TimeInterval) {
        let adherence = state.adherencePercentage

        // Sparks: Active when radiant, minimal when dim
        sparkEmitter?.particleBirthRate = lerp(0, 15, adherence)
        sparkEmitter?.particleSpeed = lerp(20, 80, adherence)
        sparkEmitter?.particleLifetime = lerp(0.5, 2.0, adherence)
        sparkEmitter?.yAcceleration = lerp(-20, 50, adherence)  // Fall when dim, rise when radiant

        // Embers: Occasional when radiant
        emberEmitter?.particleBirthRate = adherence > 0.6 ? lerp(0, 3, adherence) : 0

        // Smoke: Active when dim
        smokeEmitter?.particleBirthRate = lerp(5, 0, adherence)
        smokeEmitter?.particleAlpha = lerp(0.6, 0, adherence)

        // Ash: Falls when very dim
        ashEmitter?.particleBirthRate = adherence < 0.3 ? lerp(2, 0, adherence / 0.3) : 0
        ashEmitter?.yAcceleration = -50  // Always falls

        // Color transitions
        let sparkColor = ColorPalette.sparkColor(adherence: adherence)
        sparkEmitter?.particleColor = sparkColor
        sparkEmitter?.particleColorBlendFactor = 1.0
    }

    // MARK: - Burst Effects
    func emitSparkBurst(at position: CGPoint, intensity: CGFloat) {
        guard let spark = sparkEmitter?.copy() as? SKEmitterNode else { return }

        spark.position = position
        spark.particleBirthRate = 50 * intensity
        spark.numParticlesToEmit = Int(20 * intensity)
        spark.targetNode = parentNode?.scene

        parentNode?.addChild(spark)

        // Auto-remove after emission
        spark.run(.sequence([
            .wait(forDuration: 0.5),
            .removeFromParent()
        ]))
    }
}
```

### 3.5 PhysicsManager

Handles gravity, collision, and movement physics.

```swift
final class PhysicsManager {

    private weak var scene: SKScene?
    private weak var coreNode: CoreNode?

    // MARK: - Physics Parameters
    struct PhysicsParams {
        var gravityMultiplier: CGFloat
        var restitution: CGFloat
        var linearDamping: CGFloat
        var angularDamping: CGFloat
        var responseSpeed: CGFloat
    }

    static let radiantParams = PhysicsParams(
        gravityMultiplier: 0.3,
        restitution: 0.8,
        linearDamping: 0.1,
        angularDamping: 0.2,
        responseSpeed: 1.0
    )

    static let dimParams = PhysicsParams(
        gravityMultiplier: 2.0,
        restitution: 0.25,
        linearDamping: 0.7,
        angularDamping: 0.8,
        responseSpeed: 0.4
    )

    // MARK: - State Updates
    func updatePhysics(for state: CoreState) {
        guard let body = coreNode?.physicsBody, let scene = scene else { return }

        let adherence = state.adherencePercentage
        let params = interpolateParams(adherence: adherence)

        // Update scene gravity
        scene.physicsWorld.gravity = CGVector(
            dx: 0,
            dy: -9.8 * params.gravityMultiplier
        )

        // Update body properties
        body.restitution = params.restitution
        body.linearDamping = params.linearDamping
        body.angularDamping = params.angularDamping
    }

    private func interpolateParams(adherence: CGFloat) -> PhysicsParams {
        return PhysicsParams(
            gravityMultiplier: lerp(Self.dimParams.gravityMultiplier, Self.radiantParams.gravityMultiplier, adherence),
            restitution: lerp(Self.dimParams.restitution, Self.radiantParams.restitution, adherence),
            linearDamping: lerp(Self.dimParams.linearDamping, Self.radiantParams.linearDamping, adherence),
            angularDamping: lerp(Self.dimParams.angularDamping, Self.radiantParams.angularDamping, adherence),
            responseSpeed: lerp(Self.dimParams.responseSpeed, Self.radiantParams.responseSpeed, adherence)
        )
    }

    // MARK: - Touch Interactions
    func applyTapImpulse(at point: CGPoint) {
        guard let body = coreNode?.physicsBody else { return }

        let direction = CGVector(
            dx: point.x - coreNode!.position.x,
            dy: point.y - coreNode!.position.y
        ).normalized

        let strength: CGFloat = 100 * currentParams.responseSpeed
        body.applyImpulse(CGVector(dx: direction.dx * strength, dy: direction.dy * strength))
    }

    func applySwipeVelocity(_ velocity: CGVector) {
        guard let body = coreNode?.physicsBody else { return }

        let scaledVelocity = CGVector(
            dx: velocity.dx * currentParams.responseSpeed,
            dy: velocity.dy * currentParams.responseSpeed
        )

        body.velocity = scaledVelocity
    }
}
```

### 3.6 State Interpolation Functions

Utility functions for smooth property transitions.

```swift
// MARK: - Interpolation Utilities

/// Linear interpolation
func lerp(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat {
    return a + (b - a) * t.clamped(to: 0...1)
}

/// Color interpolation in LAB color space for perceptually uniform transitions
func lerpColor(_ a: UIColor, _ b: UIColor, _ t: CGFloat) -> UIColor {
    var aL: CGFloat = 0, aA: CGFloat = 0, aB: CGFloat = 0, aAlpha: CGFloat = 0
    var bL: CGFloat = 0, bAComponent: CGFloat = 0, bBComponent: CGFloat = 0, bAlpha: CGFloat = 0

    a.getLAB(&aL, &aA, &aB, &aAlpha)
    b.getLAB(&bL, &bAComponent, &bBComponent, &bAlpha)

    return UIColor(
        l: lerp(aL, bL, t),
        a: lerp(aA, bAComponent, t),
        b: lerp(aB, bBComponent, t),
        alpha: lerp(aAlpha, bAlpha, t)
    )
}

/// Eased interpolation for more natural feel
func easeInOutQuad(_ t: CGFloat) -> CGFloat {
    return t < 0.5 ? 2 * t * t : 1 - pow(-2 * t + 2, 2) / 2
}

/// Non-linear interpolation with easing
func lerpEased(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat {
    return lerp(a, b, easeInOutQuad(t))
}
```

---

## 4. Haptics Engine

### 4.1 HapticsManager

CoreHaptics implementation for tactile feedback synchronized to Core state.

```swift
import CoreHaptics

final class HapticsManager {

    private var engine: CHHapticEngine?
    private var breathPlayer: CHHapticAdvancedPatternPlayer?

    private var isAvailable: Bool {
        CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }

    // MARK: - Initialization
    func start() async throws {
        guard isAvailable else { return }

        engine = try CHHapticEngine()
        engine?.resetHandler = { [weak self] in
            try? self?.engine?.start()
        }

        try await engine?.start()
    }

    // MARK: - Breath Haptics
    func playBreathPulse(intensity: CGFloat) {
        guard isAvailable, let engine = engine else { return }

        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(intensity * 0.3))
        let intensityParam = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(0.3 + intensity * 0.3))

        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [sharpness, intensityParam],
            relativeTime: 0,
            duration: 0.1
        )

        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            // Haptics failed silently
        }
    }

    // MARK: - Interaction Haptics
    func playTap(state: CoreState) {
        let adherence = state.adherencePercentage

        // Radiant: crisp, warm tap
        // Dim: soft, dull tap
        let sharpness: Float = Float(lerp(0.2, 0.8, adherence))
        let intensity: Float = Float(lerp(0.4, 0.7, adherence))

        playTransient(intensity: intensity, sharpness: sharpness)
    }

    func playWallCollision(state: CoreState, velocity: CGFloat) {
        let adherence = state.adherencePercentage

        // Radiant: sharp ping
        // Dim: heavy thud
        let sharpness: Float = Float(lerp(0.1, 0.9, adherence))
        let intensity: Float = Float(min(1.0, velocity / 500) * lerp(0.6, 0.9, adherence))

        playTransient(intensity: intensity, sharpness: sharpness)
    }

    // MARK: - State Transition Haptics
    func playKindling(from oldState: CoreState, to newState: CoreState) {
        // Rising, warming pattern
        playCrescendo(duration: 2.0, startIntensity: 0.3, endIntensity: 0.7, sharpness: 0.6)
    }

    func playBanking(from oldState: CoreState, to newState: CoreState) {
        // Falling, cooling pattern
        playDecrescendo(duration: 3.0, startIntensity: 0.5, endIntensity: 0.2, sharpness: 0.3)
    }

    // MARK: - Primitive Patterns
    private func playTransient(intensity: Float, sharpness: Float) {
        guard isAvailable, let engine = engine else { return }

        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
            ],
            relativeTime: 0
        )

        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {}
    }

    private func playCrescendo(duration: TimeInterval, startIntensity: Float, endIntensity: Float, sharpness: Float) {
        guard isAvailable, let engine = engine else { return }

        var events: [CHHapticEvent] = []
        let steps = 10

        for i in 0..<steps {
            let t = Float(i) / Float(steps - 1)
            let intensity = startIntensity + (endIntensity - startIntensity) * t

            events.append(CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
                ],
                relativeTime: duration * Double(t),
                duration: duration / Double(steps)
            ))
        }

        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {}
    }
}
```

---

## 5. Audio Engine

### 5.1 AudioManager

Manages ambient soundscapes and interaction sounds.

```swift
import AVFoundation

final class AudioManager {

    // MARK: - Audio Players
    private var ambientPlayer: AVAudioPlayer?
    private var cracklePlayer: AVAudioPlayer?
    private var breathPlayer: AVAudioPlayer?

    private var interactionPlayers: [String: AVAudioPlayer] = [:]

    private var isMuted: Bool = false

    // MARK: - Initialization
    func setup() throws {
        try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
        try AVAudioSession.sharedInstance().setActive(true)

        // Preload interaction sounds
        preloadInteractionSounds()
    }

    // MARK: - Ambient Sound
    func updateAmbient(for state: CoreState) {
        let adherence = state.adherencePercentage

        // Crossfade between radiant and dim ambient layers
        ambientPlayer?.volume = Float(lerp(0.2, 0.6, adherence))
        cracklePlayer?.volume = Float(lerp(0.1, 0.5, adherence))

        // Adjust playback rate for subtle pitch shift
        ambientPlayer?.rate = Float(lerp(0.9, 1.0, adherence))
    }

    // MARK: - Interaction Sounds
    func playTap(state: CoreState) {
        guard !isMuted else { return }

        let soundName = state.adherencePercentage > 0.5 ? "tap_warm" : "tap_dull"
        interactionPlayers[soundName]?.play()
    }

    func playCollision(state: CoreState, velocity: CGFloat) {
        guard !isMuted else { return }

        let soundName = state.adherencePercentage > 0.5 ? "bounce_ping" : "bounce_thud"
        let player = interactionPlayers[soundName]

        player?.volume = Float(min(1.0, velocity / 500))
        player?.play()
    }

    // MARK: - State Transitions
    func playKindling() {
        guard !isMuted else { return }
        interactionPlayers["kindle"]?.play()
    }

    func playBanking() {
        guard !isMuted else { return }
        interactionPlayers["bank"]?.play()
    }

    // MARK: - Mute
    func setMuted(_ muted: Bool) {
        isMuted = muted
        if muted {
            ambientPlayer?.volume = 0
            cracklePlayer?.volume = 0
        }
    }
}
```

---

## 6. Data Layer

### 6.1 SwiftData Models

```swift
import SwiftData

@Model
final class MealEntity {
    var id: UUID
    var timestamp: Date
    var isOnTrack: Bool
    var photoFilename: String?
    var textDescription: String?
    var calorieEstimate: Int?
    var proteinEstimate: Int?

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        isOnTrack: Bool,
        photoFilename: String? = nil,
        textDescription: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.isOnTrack = isOnTrack
        self.photoFilename = photoFilename
        self.textDescription = textDescription
    }
}

@Model
final class DietaryGoalEntity {
    var id: UUID
    var name: String
    var isCustom: Bool
    var customDescription: String?
    var createdAt: Date
    var isActive: Bool

    init(
        id: UUID = UUID(),
        name: String,
        isCustom: Bool = false,
        customDescription: String? = nil
    ) {
        self.id = id
        self.name = name
        self.isCustom = isCustom
        self.customDescription = customDescription
        self.createdAt = Date()
        self.isActive = true
    }
}

@Model
final class UserSettingsEntity {
    var id: UUID
    var hasCompletedOnboarding: Bool
    var soundEnabled: Bool
    var hapticsEnabled: Bool
    var calorieTarget: Int?
    var proteinTarget: Int?
    var isPremium: Bool

    init() {
        self.id = UUID()
        self.hasCompletedOnboarding = false
        self.soundEnabled = true
        self.hapticsEnabled = true
        self.isPremium = false
    }
}
```

### 6.2 MealRepository

```swift
protocol MealRepositoryProtocol {
    func save(_ meal: Meal) async throws
    func fetchMeals(for date: Date) async -> [Meal]
    func fetchMeals(forWeekContaining date: Date) async -> [Meal]
    func deleteMeal(_ meal: Meal) async throws
}

final class MealRepository: MealRepositoryProtocol {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func save(_ meal: Meal) async throws {
        let entity = MealEntity(
            id: meal.id,
            timestamp: meal.timestamp,
            isOnTrack: meal.isOnTrack,
            photoFilename: meal.photoFilename,
            textDescription: meal.textDescription
        )

        modelContext.insert(entity)
        try modelContext.save()
    }

    func fetchMeals(for date: Date) async -> [Meal] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let predicate = #Predicate<MealEntity> { meal in
            meal.timestamp >= startOfDay && meal.timestamp < endOfDay
        }

        let descriptor = FetchDescriptor<MealEntity>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )

        do {
            let entities = try modelContext.fetch(descriptor)
            return entities.map { $0.toDomain() }
        } catch {
            return []
        }
    }

    func fetchMeals(forWeekContaining date: Date) async -> [Meal] {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let daysFromMonday = (weekday + 5) % 7  // Monday = 0

        let startOfWeek = calendar.date(byAdding: .day, value: -daysFromMonday, to: calendar.startOfDay(for: date))!
        let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek)!

        let predicate = #Predicate<MealEntity> { meal in
            meal.timestamp >= startOfWeek && meal.timestamp < endOfWeek
        }

        let descriptor = FetchDescriptor<MealEntity>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )

        do {
            let entities = try modelContext.fetch(descriptor)
            return entities.map { $0.toDomain() }
        } catch {
            return []
        }
    }
}
```

### 6.3 PhotoStorageService

```swift
protocol PhotoStorageServiceProtocol {
    func save(image: UIImage) async throws -> String
    func load(filename: String) async -> UIImage?
    func delete(filename: String) async throws
}

final class PhotoStorageService: PhotoStorageServiceProtocol {

    private let fileManager = FileManager.default

    private var photosDirectory: URL {
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let photosURL = documentsURL.appendingPathComponent("MealPhotos", isDirectory: true)

        if !fileManager.fileExists(atPath: photosURL.path) {
            try? fileManager.createDirectory(at: photosURL, withIntermediateDirectories: true)
        }

        return photosURL
    }

    func save(image: UIImage) async throws -> String {
        let filename = UUID().uuidString + ".jpg"
        let fileURL = photosDirectory.appendingPathComponent(filename)

        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw StorageError.compressionFailed
        }

        try data.write(to: fileURL)
        return filename
    }

    func load(filename: String) async -> UIImage? {
        let fileURL = photosDirectory.appendingPathComponent(filename)
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: data)
    }

    func delete(filename: String) async throws {
        let fileURL = photosDirectory.appendingPathComponent(filename)
        try fileManager.removeItem(at: fileURL)
    }
}
```

---

## 7. Domain Layer

### 7.1 Domain Models

```swift
// MARK: - Core State
struct CoreState: Equatable {
    let adherencePercentage: CGFloat  // 0.0 to 1.0

    var tier: CoreTier {
        switch adherencePercentage {
        case 0.9...1.0: return .blazing
        case 0.7..<0.9: return .warm
        case 0.5..<0.7: return .smoldering
        case 0.3..<0.5: return .dim
        default: return .cold
        }
    }

    static let neutral = CoreState(adherencePercentage: 0.5)
    static let radiant = CoreState(adherencePercentage: 1.0)
    static let dim = CoreState(adherencePercentage: 0.0)
}

enum CoreTier: String, CaseIterable {
    case blazing
    case warm
    case smoldering
    case dim
    case cold
}

// MARK: - Meal
struct Meal: Identifiable, Equatable {
    let id: UUID
    let timestamp: Date
    let isOnTrack: Bool
    let photoFilename: String?
    let textDescription: String?
    var calorieEstimate: Int?
    var proteinEstimate: Int?

    var displayDescription: String {
        if let text = textDescription, !text.isEmpty {
            return text
        }
        return photoFilename != nil ? "Photo logged" : "Meal logged"
    }
}

// MARK: - Dietary Goal
struct DietaryGoal: Identifiable, Equatable {
    let id: UUID
    let name: String
    let isCustom: Bool
    let customDescription: String?

    static let presets: [DietaryGoal] = [
        DietaryGoal(id: UUID(), name: "Keto / Low-carb", isCustom: false, customDescription: nil),
        DietaryGoal(id: UUID(), name: "Vegetarian", isCustom: false, customDescription: nil),
        DietaryGoal(id: UUID(), name: "Vegan", isCustom: false, customDescription: nil),
        DietaryGoal(id: UUID(), name: "Mediterranean", isCustom: false, customDescription: nil),
        DietaryGoal(id: UUID(), name: "Whole30 / Paleo", isCustom: false, customDescription: nil),
        DietaryGoal(id: UUID(), name: "Low sugar", isCustom: false, customDescription: nil),
        DietaryGoal(id: UUID(), name: "High protein", isCustom: false, customDescription: nil),
        DietaryGoal(id: UUID(), name: "Whole foods", isCustom: false, customDescription: nil),
    ]
}

// MARK: - Adherence Stats
struct AdherenceStats: Equatable {
    let todayPercentage: CGFloat
    let todayCount: (onTrack: Int, total: Int)
    let yesterdayPercentage: CGFloat
    let yesterdayCount: (onTrack: Int, total: Int)
    let weekPercentage: CGFloat
    let weekCount: (onTrack: Int, total: Int)

    static let empty = AdherenceStats(
        todayPercentage: 0.5,
        todayCount: (0, 0),
        yesterdayPercentage: 0.5,
        yesterdayCount: (0, 0),
        weekPercentage: 0.5,
        weekCount: (0, 0)
    )
}
```

### 7.2 AdherenceCalculator

```swift
protocol AdherenceCalculatorProtocol {
    func calculateStats(from meals: [Meal], referenceDate: Date) -> AdherenceStats
    func calculateCoreState(from stats: AdherenceStats) -> CoreState
}

final class AdherenceCalculator: AdherenceCalculatorProtocol {

    private let calendar = Calendar.current

    func calculateStats(from meals: [Meal], referenceDate: Date) -> AdherenceStats {
        let today = calendar.startOfDay(for: referenceDate)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let weekStart = startOfWeek(containing: referenceDate)

        // Today
        let todayMeals = meals.filter { calendar.isDate($0.timestamp, inSameDayAs: today) }
        let todayOnTrack = todayMeals.filter(\.isOnTrack).count
        let todayPercentage = todayMeals.isEmpty ? 0.5 : CGFloat(todayOnTrack) / CGFloat(todayMeals.count)

        // Yesterday
        let yesterdayMeals = meals.filter { calendar.isDate($0.timestamp, inSameDayAs: yesterday) }
        let yesterdayOnTrack = yesterdayMeals.filter(\.isOnTrack).count
        let yesterdayPercentage = yesterdayMeals.isEmpty ? 0.5 : CGFloat(yesterdayOnTrack) / CGFloat(yesterdayMeals.count)

        // This week
        let weekMeals = meals.filter { $0.timestamp >= weekStart }
        let weekOnTrack = weekMeals.filter(\.isOnTrack).count
        let weekPercentage = weekMeals.isEmpty ? 0.5 : CGFloat(weekOnTrack) / CGFloat(weekMeals.count)

        return AdherenceStats(
            todayPercentage: todayPercentage,
            todayCount: (todayOnTrack, todayMeals.count),
            yesterdayPercentage: yesterdayPercentage,
            yesterdayCount: (yesterdayOnTrack, yesterdayMeals.count),
            weekPercentage: weekPercentage,
            weekCount: (weekOnTrack, weekMeals.count)
        )
    }

    func calculateCoreState(from stats: AdherenceStats) -> CoreState {
        // Week percentage is the primary driver
        // If no meals logged, return neutral
        if stats.weekCount.total == 0 {
            return .neutral
        }

        return CoreState(adherencePercentage: stats.weekPercentage)
    }

    private func startOfWeek(containing date: Date) -> Date {
        let weekday = calendar.component(.weekday, from: date)
        let daysFromMonday = (weekday + 5) % 7  // Monday = 0
        return calendar.date(byAdding: .day, value: -daysFromMonday, to: calendar.startOfDay(for: date))!
    }
}
```

### 7.3 CalorieEstimationService (Abstracted)

```swift
protocol CalorieEstimationServiceProtocol {
    func estimateCalories(from image: UIImage) async throws -> CalorieEstimate
}

struct CalorieEstimate: Equatable {
    let calories: Int
    let protein: Int?
    let confidence: Float  // 0.0 to 1.0
    let description: String?
}

enum CalorieEstimationError: Error {
    case imageProcessingFailed
    case networkError
    case apiError(String)
    case notAvailable
}

// MARK: - Mock Implementation (Development)
final class MockCalorieEstimator: CalorieEstimationServiceProtocol {
    func estimateCalories(from image: UIImage) async throws -> CalorieEstimate {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_500_000_000)

        // Return random estimate for testing
        return CalorieEstimate(
            calories: Int.random(in: 200...800),
            protein: Int.random(in: 10...40),
            confidence: Float.random(in: 0.7...0.95),
            description: "Estimated meal"
        )
    }
}

// MARK: - Future Implementation Template
/*
final class OpenAICalorieEstimator: CalorieEstimationServiceProtocol {
    private let apiKey: String

    func estimateCalories(from image: UIImage) async throws -> CalorieEstimate {
        // 1. Convert image to base64
        // 2. Call OpenAI Vision API with structured output
        // 3. Parse response
        // 4. Return estimate
    }
}
*/
```

---

## 8. Presentation Layer

### 8.1 App Entry Point

```swift
import SwiftUI
import SwiftData

@main
struct TendApp: App {

    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(for: MealEntity.self, DietaryGoalEntity.self, UserSettingsEntity.self)
        } catch {
            fatalError("Failed to initialize model container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .modelContainer(modelContainer)
        }
    }
}

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var appState = AppState()

    var body: some View {
        Group {
            if appState.hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingFlow()
            }
        }
        .environment(appState)
        .task {
            await appState.loadSettings(context: modelContext)
        }
    }
}
```

### 8.2 AppState

```swift
@Observable
final class AppState {

    var hasCompletedOnboarding: Bool = false
    var currentGoal: DietaryGoal?
    var isPremium: Bool = false
    var soundEnabled: Bool = true
    var hapticsEnabled: Bool = true

    // Core state derived from adherence
    private(set) var coreState: CoreState = .neutral
    private(set) var adherenceStats: AdherenceStats = .empty

    // Services
    private var mealRepository: MealRepositoryProtocol?
    private let adherenceCalculator = AdherenceCalculator()

    func loadSettings(context: ModelContext) async {
        mealRepository = MealRepository(modelContext: context)

        // Load user settings
        let descriptor = FetchDescriptor<UserSettingsEntity>()
        if let settings = try? context.fetch(descriptor).first {
            hasCompletedOnboarding = settings.hasCompletedOnboarding
            soundEnabled = settings.soundEnabled
            hapticsEnabled = settings.hapticsEnabled
            isPremium = settings.isPremium
        }

        // Load current goal
        let goalDescriptor = FetchDescriptor<DietaryGoalEntity>(
            predicate: #Predicate { $0.isActive }
        )
        if let goalEntity = try? context.fetch(goalDescriptor).first {
            currentGoal = goalEntity.toDomain()
        }

        // Calculate initial state
        await refreshCoreState()
    }

    func refreshCoreState() async {
        guard let repository = mealRepository else { return }

        let weekMeals = await repository.fetchMeals(forWeekContaining: Date())
        adherenceStats = adherenceCalculator.calculateStats(from: weekMeals, referenceDate: Date())
        coreState = adherenceCalculator.calculateCoreState(from: adherenceStats)
    }

    func logMeal(_ meal: Meal) async throws {
        try await mealRepository?.save(meal)
        await refreshCoreState()
    }
}
```

### 8.3 MainTabView

```swift
struct MainTabView: View {

    @State private var selectedTab: Tab = .core

    enum Tab {
        case core
        case progress
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            CoreView()
                .tabItem {
                    Label("Core", systemImage: selectedTab == .core ? "flame.fill" : "flame")
                }
                .tag(Tab.core)

            ProgressView()
                .tabItem {
                    Label("Progress", systemImage: selectedTab == .progress ? "chart.bar.fill" : "chart.bar")
                }
                .tag(Tab.progress)
        }
        .tint(Color("AccentPrimary"))
    }
}
```

### 8.4 CoreView

```swift
struct CoreView: View {

    @Environment(AppState.self) private var appState
    @State private var viewModel: CoreViewModel
    @State private var isShowingMealLogger = false

    init() {
        _viewModel = State(initialValue: CoreViewModel())
    }

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color("BackgroundPrimary"), Color("BackgroundPrimary").opacity(0.95)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Core SpriteKit Scene
                SpriteKitContainer(coreState: appState.coreState)
                    .frame(maxWidth: .infinity)
                    .frame(height: UIScreen.main.bounds.height * 0.6)

                // Status text
                Text(statusText)
                    .font(.body)
                    .foregroundStyle(Color("TextSecondary"))
                    .padding(.top, 24)

                Spacer()

                // Log Meal button
                Button(action: { isShowingMealLogger = true }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Log Meal")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(Color("AccentPrimary"))
                    .clipShape(Capsule())
                }
                .padding(.bottom, 24)
            }
        }
        .fullScreenCover(isPresented: $isShowingMealLogger) {
            MealLoggingFlow()
        }
    }

    private var statusText: String {
        let stats = appState.adherenceStats
        if stats.todayCount.total == 0 {
            return "No meals logged yet today."
        }
        return "\(stats.todayCount.onTrack) of \(stats.todayCount.total) meals on track today"
    }
}

// MARK: - SpriteKit Container
struct SpriteKitContainer: UIViewRepresentable {

    let coreState: CoreState

    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        view.ignoresSiblingOrder = true
        view.allowsTransparency = true
        view.backgroundColor = .clear

        let scene = RadiantCoreScene(size: view.bounds.size)
        scene.scaleMode = .resizeFill
        scene.backgroundColor = .clear
        view.presentScene(scene)

        return view
    }

    func updateUIView(_ uiView: SKView, context: Context) {
        if let scene = uiView.scene as? RadiantCoreScene {
            scene.updateState(coreState, animated: true)
        }
    }
}
```

---

## 9. RevenueCat Integration

### 9.1 RevenueCatService

```swift
import RevenueCat

final class RevenueCatService {

    static let shared = RevenueCatService()

    private init() {}

    // MARK: - Configuration
    func configure() {
        Purchases.logLevel = .debug  // Remove in production
        Purchases.configure(withAPIKey: "your_revenuecat_api_key")
    }

    // MARK: - Entitlements
    func checkPremiumStatus() async -> Bool {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            return customerInfo.entitlements["premium"]?.isActive == true
        } catch {
            return false
        }
    }

    // MARK: - Purchases
    func fetchOfferings() async throws -> Offerings {
        return try await Purchases.shared.offerings()
    }

    func purchase(package: Package) async throws -> Bool {
        let result = try await Purchases.shared.purchase(package: package)
        return result.customerInfo.entitlements["premium"]?.isActive == true
    }

    // MARK: - Restore
    func restorePurchases() async throws -> Bool {
        let customerInfo = try await Purchases.shared.restorePurchases()
        return customerInfo.entitlements["premium"]?.isActive == true
    }
}
```

### 9.2 PaywallView

```swift
struct PaywallView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var offerings: Offerings?
    @State private var isPurchasing = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 48))
                            .foregroundStyle(Color("AccentPrimary"))

                        Text("Unlock Premium")
                            .font(.title.bold())

                        Text("AI-powered calorie tracking without the manual entry")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 32)

                    // Features
                    VStack(alignment: .leading, spacing: 16) {
                        FeatureRow(icon: "camera.viewfinder", title: "AI Calorie Estimation", description: "Snap a photo, get instant estimates")
                        FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Calorie Tracking", description: "See your daily intake vs. target")
                        FeatureRow(icon: "flame.fill", title: "Enhanced Core", description: "Caloric performance affects your Core")
                    }
                    .padding(.horizontal)

                    // Packages
                    if let offerings = offerings, let current = offerings.current {
                        VStack(spacing: 12) {
                            ForEach(current.availablePackages, id: \.identifier) { package in
                                PackageButton(package: package, isPurchasing: isPurchasing) {
                                    await purchase(package: package)
                                }
                            }
                        }
                        .padding()
                    }

                    // Restore
                    Button("Restore Purchases") {
                        Task { await restore() }
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .task {
            offerings = try? await RevenueCatService.shared.fetchOfferings()
        }
    }

    private func purchase(package: Package) async {
        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let success = try await RevenueCatService.shared.purchase(package: package)
            if success {
                dismiss()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func restore() async {
        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let success = try await RevenueCatService.shared.restorePurchases()
            if success {
                dismiss()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

---

## 10. Performance Specifications

### 10.1 Targets

| Metric | Target | Minimum |
|--------|--------|---------|
| Frame rate | 60fps | 30fps |
| App launch (cold) | < 2s | < 3s |
| Meal log flow | < 10s | < 15s |
| Core state transition | < 100ms start | < 200ms |
| Memory usage | < 100MB | < 150MB |

### 10.2 Optimization Strategies

**SpriteKit Rendering:**
- Limit active particle count: 20 sparks max (Radiant), 5 smoke wisps max (Dim)
- Use texture atlases for Core layers
- Pre-render blur/glow at lower resolution
- Disable unnecessary shader calculations in Dim state

**Background Mode:**
- Reduce frame rate to 15fps when backgrounded
- Pause particle systems
- Continue breathing animation at reduced fidelity

**Memory:**
- Lazy load meal photos (thumbnails first)
- Limit photo cache to 20 recent images
- Use JPEG compression (0.8 quality) for storage

**Battery:**
- Reduce animation complexity when battery < 20%
- Offer "Low Power Mode" in settings

### 10.3 Device Support Matrix

| Device | Expected Performance |
|--------|---------------------|
| iPhone 15/14/13/12 | Full 60fps, all effects |
| iPhone 11/XS/XR | 60fps, optional reduced particles |
| iPhone X/8 | 30-60fps, reduced particles recommended |
| Older | Not officially supported (iOS 17 requirement handles this) |

---

## 11. Security & Privacy

### 11.1 Data Storage

| Data Type | Storage | Encryption |
|-----------|---------|------------|
| Meal records | SwiftData (local) | iOS Data Protection |
| Meal photos | Documents directory | iOS Data Protection |
| User settings | SwiftData (local) | iOS Data Protection |
| Premium status | RevenueCat (remote) | TLS 1.3 |

### 11.2 Network Calls

**MVP (Free Tier):** Zero network calls required. Fully offline-capable.

**Premium Tier:**
- RevenueCat: Purchase verification, entitlement checks
- AI API (future): Calorie estimation

All network calls use:
- HTTPS/TLS 1.3
- Certificate pinning (for AI API)
- No PII transmitted without explicit consent

### 11.3 Privacy Manifest

Required for iOS 17+ App Store submission:

```xml
<!-- PrivacyInfo.xcprivacy -->
<dict>
    <key>NSPrivacyTracking</key>
    <false/>
    <key>NSPrivacyCollectedDataTypes</key>
    <array/>
    <key>NSPrivacyAccessedAPITypes</key>
    <array>
        <dict>
            <key>NSPrivacyAccessedAPIType</key>
            <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
            <key>NSPrivacyAccessedAPITypeReasons</key>
            <array><string>CA92.1</string></array>
        </dict>
    </array>
</dict>
```

### 11.4 Permissions

| Permission | Usage | Fallback |
|------------|-------|----------|
| Camera | Meal photo capture | Text-only logging |
| Photo Library | (Not required in MVP) | N/A |

---

## 12. Testing Strategy

### 12.1 Unit Tests

**High Priority:**
- `AdherenceCalculator`: Percentage calculations, edge cases (no meals, week boundaries)
- `CoreState`: Tier determination, interpolation math
- `MealRepository`: CRUD operations, date filtering

```swift
final class AdherenceCalculatorTests: XCTestCase {

    func testCalculatesCorrectPercentageWithMixedMeals() {
        let calculator = AdherenceCalculator()
        let meals = [
            Meal(id: UUID(), timestamp: Date(), isOnTrack: true, photoFilename: nil, textDescription: nil),
            Meal(id: UUID(), timestamp: Date(), isOnTrack: true, photoFilename: nil, textDescription: nil),
            Meal(id: UUID(), timestamp: Date(), isOnTrack: false, photoFilename: nil, textDescription: nil),
            Meal(id: UUID(), timestamp: Date(), isOnTrack: true, photoFilename: nil, textDescription: nil),
        ]

        let stats = calculator.calculateStats(from: meals, referenceDate: Date())

        XCTAssertEqual(stats.todayPercentage, 0.75, accuracy: 0.01)
        XCTAssertEqual(stats.todayCount.onTrack, 3)
        XCTAssertEqual(stats.todayCount.total, 4)
    }

    func testReturnsNeutralWithNoMeals() {
        let calculator = AdherenceCalculator()
        let stats = calculator.calculateStats(from: [], referenceDate: Date())
        let state = calculator.calculateCoreState(from: stats)

        XCTAssertEqual(state.adherencePercentage, 0.5)
    }

    func testWeekBoundaryCalculation() {
        // Test that Monday reset works correctly
    }
}
```

### 12.2 Integration Tests

- SwiftData persistence round-trip
- Photo storage save/load cycle
- RevenueCat purchase flow (sandbox)

### 12.3 UI Tests

**Critical Flows:**
1. Onboarding completion
2. Meal logging (photo + tagging)
3. Tab navigation
4. Settings toggle changes

### 12.4 Manual Testing

**Core Animation:**
- Visual inspection of state transitions
- Breathing rhythm feels natural
- Particle behavior matches spec

**Haptics:**
- Device testing required (simulator lacks haptics)
- Test on multiple device models

---

## 13. Development Phases

### Phase 1: Core Foundation (SpriteKit)
- [ ] Set up SpriteKit scene structure
- [ ] Implement CoreNode with layered visuals
- [ ] Implement BreathingController
- [ ] Basic state interpolation (no persistence)
- [ ] Verify 60fps on target devices

### Phase 2: Fidget Interactions + Physics
- [ ] Implement touch gestures (tap, swipe, hold)
- [ ] PhysicsManager with state-based parameters
- [ ] Screen boundary collisions
- [ ] ParticleManager (sparks, smoke, embers)

### Phase 3: Meal Logging + Persistence
- [ ] SwiftData models and repository
- [ ] Camera capture flow
- [ ] Text entry alternative
- [ ] Photo storage service
- [ ] Confirmation screen with tagging

### Phase 4: Adherence → Core State
- [ ] AdherenceCalculator implementation
- [ ] Connect meal logging to Core state updates
- [ ] Real-time state transitions on meal log
- [ ] Weekly reset logic

### Phase 5: Progress View
- [ ] Weekly summary card
- [ ] Time period stats (today/yesterday/week)
- [ ] Meal history list
- [ ] Diet selection card

### Phase 6: Onboarding
- [ ] Welcome screen
- [ ] Diet selection screen
- [ ] "Meet Your Core" interactive tutorial
- [ ] First log prompt

### Phase 7: Haptics + Audio
- [ ] HapticsManager implementation
- [ ] Breath-synced haptics
- [ ] Interaction haptics (tap, collision)
- [ ] Ambient soundscape
- [ ] State transition sounds
- [ ] Sound/haptics toggle in settings

### Phase 8: RevenueCat + Premium
- [ ] RevenueCat SDK integration
- [ ] Paywall UI
- [ ] Entitlement gating
- [ ] Restore purchases flow

### Phase 9: AI Integration (Post-MVP)
- [ ] Finalize AI provider selection
- [ ] Implement CalorieEstimationService
- [ ] Premium onboarding (metrics entry)
- [ ] Calorie target calculation
- [ ] Enhanced data view
- [ ] Caloric modifier on Core state

---

## 14. Appendix

### 14.1 Color Palette (Code Reference)

```swift
enum ColorPalette {

    // MARK: - UI Colors
    static let backgroundPrimary = Color(hex: "#1A1612")
    static let backgroundSecondary = Color(hex: "#2A2520")
    static let accentPrimary = Color(hex: "#F5A623")
    static let accentSecondary = Color(hex: "#8B7355")
    static let textPrimary = Color(hex: "#F5F0EB")
    static let textSecondary = Color(hex: "#A89B8C")

    // MARK: - Core Colors (Radiant)
    static let radiantInnerCore = Color(hex: "#FFF8E7")
    static let radiantInnerCoreBase = Color(hex: "#FFD93D")
    static let radiantGlow = Color(hex: "#F5A623")
    static let radiantSurface = Color(hex: "#D4915D")
    static let radiantStriation = Color(hex: "#FFE566")
    static let radiantHalo = Color(hex: "#FFE4C9")

    // MARK: - Core Colors (Dim)
    static let dimInnerCore = Color(hex: "#B85C2C")
    static let dimInnerCoreBase = Color(hex: "#8B4513")
    static let dimGlow = Color(hex: "#6B4423")
    static let dimSurface = Color(hex: "#4A3C31")
    static let dimStriation = Color(hex: "#7A5C4A")
    static let dimHalo = Color(hex: "#3D3229")

    // MARK: - Interpolation
    static func interpolateInnerCore(adherence: CGFloat) -> Color {
        lerpColor(dimInnerCore, radiantInnerCore, adherence)
    }

    static func interpolateGlow(adherence: CGFloat) -> Color {
        lerpColor(dimGlow, radiantGlow, adherence)
    }

    static func interpolateSurface(adherence: CGFloat) -> Color {
        lerpColor(dimSurface, radiantSurface, adherence)
    }
}
```

### 14.2 Breathing Parameters Reference

| State | Cycle Duration | Scale Range | Brightness Range | Irregularity |
|-------|---------------|-------------|------------------|--------------|
| Blazing (90-100%) | 12-15s | ±8-10% | ±15-20% | 0% |
| Warm (70-89%) | 10-12s | ±6-8% | ±12-15% | 5% |
| Smoldering (50-69%) | 7-10s | ±4-6% | ±8-12% | 15% |
| Dim (30-49%) | 5-7s | ±3-4% | ±5-8% | 40% |
| Cold (0-29%) | 3-5s | ±2-3% | ±3-5% | 70% |

### 14.3 Physics Parameters Reference

| State | Gravity Mult | Restitution | Linear Damping | Angular Damping |
|-------|-------------|-------------|----------------|-----------------|
| Radiant | 0.3 | 0.8 | 0.1 | 0.2 |
| Dim | 2.0 | 0.25 | 0.7 | 0.8 |

---

*End of Technical Design Document*
