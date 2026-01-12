//
//  BreathingController.swift
//  Tend
//
//  Procedural animation system for the Core's breathing effect.
//  The breath is the Core's heartbeat - autonomous, state-responsive, and hypnotic.
//

import SpriteKit
import UIKit

/// Controls the procedural breathing animation of the Radiant Core.
/// Parameters interpolate based on adherence: slow/deep when radiant, fast/shallow when dim.
final class BreathingController {

    // MARK: - Breath Parameters

    /// Duration of one complete breath cycle in seconds
    private var cycleDuration: TimeInterval = 10.0

    /// Scale range as percentage (0.08 = ±8%)
    private var scaleRange: CGFloat = 0.06

    /// Brightness range as percentage
    private var brightnessRange: CGFloat = 0.12

    /// Vertical drift as percentage of screen height
    private var verticalDrift: CGFloat = 0.02

    /// Irregularity factor (0.0 = steady, 1.0 = very irregular)
    private var irregularity: CGFloat = 0.0

    // MARK: - Target Parameters (for smooth transitions)

    private var targetCycleDuration: TimeInterval = 10.0
    private var targetScaleRange: CGFloat = 0.06
    private var targetBrightnessRange: CGFloat = 0.12
    private var targetIrregularity: CGFloat = 0.0

    // Store starting values for proper interpolation (fixes asymptotic lerp bug)
    private var startCycleDuration: TimeInterval = 10.0
    private var startScaleRange: CGFloat = 0.06
    private var startBrightnessRange: CGFloat = 0.12
    private var startIrregularity: CGFloat = 0.0

    /// Duration to transition between parameter sets
    private var parameterTransitionDuration: TimeInterval = 2.0
    private var parameterTransitionProgress: TimeInterval = 1.0

    // MARK: - State

    /// The CoreNode being animated
    private weak var coreNode: CoreNode?

    /// Screen height for drift calculations
    private var screenHeight: CGFloat = UIScreen.main.bounds.height

    /// Noise seed for irregularity
    private var noiseOffset: TimeInterval = 0

    /// Last recorded breath phase for boundary detection
    private var lastPhase: CGFloat = 0

    /// Time of last breath catch (for limiting frequency)
    private var lastBreathCatchTime: TimeInterval = 0

    // MARK: - Initialization

    init() {
        // Start with random noise offset for variety
        noiseOffset = TimeInterval.random(in: 0...100)
    }

    // MARK: - Setup

    /// Attaches the controller to a CoreNode
    /// - Parameter node: The CoreNode to animate
    func attach(to node: CoreNode) {
        coreNode = node
    }

    /// Sets the screen height for drift calculations
    /// - Parameter height: Screen height in points
    func setScreenHeight(_ height: CGFloat) {
        screenHeight = height
    }

    // MARK: - Update Loop

    /// Called every frame to update breathing animation
    /// - Parameters:
    ///   - currentTime: Current scene time
    ///   - deltaTime: Time since last frame (for frame-rate independent animations)
    func update(currentTime: TimeInterval, deltaTime: TimeInterval) {
        guard let core = coreNode else { return }

        // Update parameter transitions using actual delta time (fixes hardcoded 1/60 assumption)
        updateParameterTransition(deltaTime: deltaTime)

        // Calculate breath phase and value
        let phase = calculateBreathPhase(currentTime: currentTime)
        let breathValue = calculateBreathValue(phase: phase, time: currentTime)

        // Apply breath to core
        applyBreathToCore(breathValue: breathValue, core: core)

        // Track phase for boundary detection
        lastPhase = phase
    }

    // MARK: - Phase Calculation

    /// Calculates the current breath phase (0.0 to 1.0)
    private func calculateBreathPhase(currentTime: TimeInterval) -> CGFloat {
        return CGFloat((currentTime.truncatingRemainder(dividingBy: cycleDuration)) / cycleDuration)
    }

    /// Calculates the breath value (-1 to 1) with optional irregularity
    private func calculateBreathValue(phase: CGFloat, time: TimeInterval) -> CGFloat {
        // Base sine wave for smooth breathing
        var value = sin(phase * 2 * .pi)

        // Add irregularity for dim states
        if irregularity > 0 {
            // Perlin-like noise approximation
            let noise = simplexNoise(x: Float(time * 0.5 + noiseOffset), y: 0)
            value += CGFloat(noise) * irregularity * 0.3

            // Occasional breath catch (shallow breath)
            if shouldCatchBreath(time: time, phase: phase) {
                value *= 0.3
            }
        }

        return value.clamped(to: -1...1)
    }

    /// Determines if a breath catch should occur
    private func shouldCatchBreath(time: TimeInterval, phase: CGFloat) -> Bool {
        // Only catch during inhale phase (0.0 - 0.4)
        guard phase < 0.4 else { return false }

        // Limit frequency of catches
        guard time - lastBreathCatchTime > cycleDuration * 2 else { return false }

        // Random chance based on irregularity
        let catchChance = irregularity * 0.15
        if CGFloat.random(in: 0...1) < catchChance {
            lastBreathCatchTime = time
            return true
        }

        return false
    }

    // MARK: - Apply Breath

    /// Applies the breath value to the CoreNode
    private func applyBreathToCore(breathValue: CGFloat, core: CoreNode) {
        // Scale: 1.0 ± scaleRange
        let scale = 1.0 + (breathValue * scaleRange)
        core.setBreathScale(scale)

        // Brightness adjustment
        let brightness = breathValue * brightnessRange
        core.adjustBrightness(by: brightness)

        // Vertical drift
        let yOffset = breathValue * verticalDrift * screenHeight
        var newPosition = core.basePosition
        newPosition.y += yOffset
        core.position = newPosition
    }

    // MARK: - Parameter Updates

    /// Updates breathing parameters for a new state
    /// - Parameters:
    ///   - state: The target CoreState
    ///   - duration: Transition duration
    func updateParameters(for state: CoreState, duration: TimeInterval) {
        let adherence = state.adherencePercentage

        // Calculate target parameters based on adherence
        // Cycle duration: 4s (dim/cold) to 15s (radiant/blazing)
        targetCycleDuration = lerp(4.0, 15.0, Double(adherence))

        // Scale range: 2% (dim) to 10% (radiant)
        targetScaleRange = lerp(0.02, 0.10, adherence)

        // Brightness range: 5% (dim) to 20% (radiant)
        targetBrightnessRange = lerp(0.05, 0.20, adherence)

        // Irregularity: 70% (cold) to 0% (radiant)
        targetIrregularity = lerp(0.7, 0.0, adherence)

        // Capture current values as start values for proper interpolation
        startCycleDuration = cycleDuration
        startScaleRange = scaleRange
        startBrightnessRange = brightnessRange
        startIrregularity = irregularity

        // Set transition timing
        parameterTransitionDuration = duration
        parameterTransitionProgress = 0
    }

    /// Smoothly transitions current parameters toward targets
    private func updateParameterTransition(deltaTime: TimeInterval) {
        guard parameterTransitionProgress < parameterTransitionDuration else { return }

        parameterTransitionProgress += deltaTime
        let t = CGFloat((parameterTransitionProgress / parameterTransitionDuration).clamped(to: 0...1))
        let eased = easeInOutQuad(t)

        // Interpolate all parameters from start to target using proper easing
        // (Fixed: was using asymptotic approach that never reached target)
        cycleDuration = lerp(startCycleDuration, targetCycleDuration, Double(eased))
        scaleRange = lerp(startScaleRange, targetScaleRange, eased)
        brightnessRange = lerp(startBrightnessRange, targetBrightnessRange, eased)
        irregularity = lerp(startIrregularity, targetIrregularity, eased)
    }

    // MARK: - Breath Boundary Detection

    /// Checks if we're at a breath boundary (peak inhale or exhale)
    /// - Parameter phase: Current breath phase
    /// - Returns: True if at a boundary suitable for haptic sync
    func isBreathBoundary(phase: CGFloat) -> Bool {
        let peakInhale: CGFloat = 0.25  // Phase at peak inhale
        let peakExhale: CGFloat = 0.75  // Phase at peak exhale
        let threshold: CGFloat = 0.02

        let crossedInhale = lastPhase < peakInhale && phase >= peakInhale
        let crossedExhale = lastPhase < peakExhale && phase >= peakExhale

        return crossedInhale || crossedExhale
    }

    /// Returns the current breath intensity (0 to 1) for haptic sync
    var currentBreathIntensity: CGFloat {
        // Map breath phase to intensity
        let phase = CGFloat((CACurrentMediaTime().truncatingRemainder(dividingBy: cycleDuration)) / cycleDuration)
        let breathValue = sin(phase * 2 * .pi)
        return (breathValue + 1) / 2  // Normalize to 0-1
    }

    // MARK: - Noise Function

    /// Simple noise approximation for breathing irregularity
    private func simplexNoise(x: Float, y: Float) -> Float {
        // Simplified noise using multiple sine waves
        let noise1 = sin(x * 1.7 + y * 2.3)
        let noise2 = sin(x * 3.1 + y * 1.1) * 0.5
        let noise3 = sin(x * 5.3 + y * 4.7) * 0.25
        return (noise1 + noise2 + noise3) / 1.75
    }
}
