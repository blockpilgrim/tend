//
//  BreathingController.swift
//  Tend
//
//  Procedural animation system for the Core's breathing effect.
//

import SpriteKit
import UIKit

enum BreathSegment: Sendable {
    case inhale
    case exhale
    case pause
}

/// Controls the procedural breathing animation of the Radiant Core.
/// Parameters interpolate based on adherence: slow/deep when radiant, fast/shallow when dim.
final class BreathingController {

    // MARK: - Breath Parameters

    private var cycleDuration: TimeInterval = 10.0
    private var scaleRange: CGFloat = 0.06
    private var brightnessRange: CGFloat = 0.12
    private var pauseDuration: TimeInterval = 0.8
    private var irregularity: CGFloat = 0.0

    // MARK: - Target Parameters (for smooth transitions)

    private var targetCycleDuration: TimeInterval = 10.0
    private var targetScaleRange: CGFloat = 0.06
    private var targetBrightnessRange: CGFloat = 0.12
    private var targetPauseDuration: TimeInterval = 0.8
    private var targetIrregularity: CGFloat = 0.0

    private var startCycleDuration: TimeInterval = 10.0
    private var startScaleRange: CGFloat = 0.06
    private var startBrightnessRange: CGFloat = 0.12
    private var startPauseDuration: TimeInterval = 0.8
    private var startIrregularity: CGFloat = 0.0

    private var parameterTransitionDuration: TimeInterval = 0
    private var parameterTransitionProgress: TimeInterval = 0

    // MARK: - State

    private weak var coreNode: CoreNode?
    private var screenHeight: CGFloat = UIScreen.main.bounds.height

    private var cycleProgress: CGFloat = 0
    private var lastCycleProgress: CGFloat = 0

    private(set) var currentBreathIntensity: CGFloat = 0
    private(set) var currentSegment: BreathSegment = .inhale

    private(set) var didPeakInhale: Bool = false
    private(set) var didPeakExhale: Bool = false

    private enum BreathVariant {
        case normal
        case catchBreath
        case shallow
        case skip
        case recovery
    }

    private var currentVariant: BreathVariant = .normal
    private var shallowBreathsRemaining: Int = 0
    private var pendingRecoveryBreath: Bool = false
    private var pauseExtension: TimeInterval = 0

    // MARK: - Setup

    func attach(to node: CoreNode) {
        coreNode = node
    }

    func setScreenHeight(_ height: CGFloat) {
        screenHeight = height
    }

    // MARK: - Update Loop

    func update(currentTime: TimeInterval, deltaTime: TimeInterval) {
        guard let core = coreNode else { return }

        didPeakInhale = false
        didPeakExhale = false

        updateParameterTransition(deltaTime: deltaTime)
        advanceCycle(deltaTime: deltaTime)

        let boundaries = segmentBoundaries()
        let (intensity, segment) = breathIntensity(
            for: cycleProgress,
            boundaries: boundaries,
            time: currentTime
        )

        currentBreathIntensity = intensity
        currentSegment = segment

        applyBreathToCore(core: core, intensity: intensity, time: currentTime)
    }

    // MARK: - Cycle

    private func advanceCycle(deltaTime: TimeInterval) {
        lastCycleProgress = cycleProgress

        let duration = max(0.25, cycleDuration)
        cycleProgress += CGFloat(deltaTime / duration)

        if cycleProgress >= 1 {
            cycleProgress = cycleProgress.truncatingRemainder(dividingBy: 1)
            startNewBreathCycle()
        }

        let boundaries = segmentBoundaries()
        if lastCycleProgress < boundaries.inhaleEnd && cycleProgress >= boundaries.inhaleEnd {
            didPeakInhale = true
        }
        if lastCycleProgress < boundaries.activeEnd && cycleProgress >= boundaries.activeEnd {
            didPeakExhale = true
        }
    }

    private func startNewBreathCycle() {
        pauseExtension = 0

        if pendingRecoveryBreath {
            currentVariant = .recovery
            pendingRecoveryBreath = false
            return
        }

        if shallowBreathsRemaining > 0 {
            currentVariant = .shallow
            shallowBreathsRemaining -= 1
            if shallowBreathsRemaining == 0 {
                pendingRecoveryBreath = true
            }
            return
        }

        let p = irregularity.clamped(to: 0...1)
        let r = CGFloat.random(in: 0...1)

        if r < p * 0.05 {
            currentVariant = .skip
            pauseExtension = min(1.0, cycleDuration * 0.35)
            return
        }

        if r < p * 0.13 {
            currentVariant = .shallow
            shallowBreathsRemaining = Int.random(in: 2...3) - 1
            if shallowBreathsRemaining == 0 {
                pendingRecoveryBreath = true
            }
            return
        }

        if r < p * 0.30 {
            currentVariant = .catchBreath
            return
        }

        currentVariant = .normal
    }

    // MARK: - Breath Shape

    private struct SegmentBoundaries {
        let inhaleEnd: CGFloat
        let activeEnd: CGFloat
    }

    private func segmentBoundaries() -> SegmentBoundaries {
        // Spec: inhale ~40%, exhale ~50%, pause ~10% (pause collapses toward 0 when dim).
        let pause = max(0, min(cycleDuration * 0.3, pauseDuration + pauseExtension))
        let pauseFraction = (pause / max(0.25, cycleDuration)).clamped(to: 0...0.6)
        let activeFraction = (1 - pauseFraction).clamped(to: 0.25...1)

        let inhaleFractionOfActive: CGFloat = 0.4 / 0.9  // keep 40:50 ratio when pause changes
        let inhaleEnd = activeFraction * inhaleFractionOfActive
        return SegmentBoundaries(inhaleEnd: inhaleEnd, activeEnd: activeFraction)
    }

    private func breathIntensity(
        for cycleProgress: CGFloat,
        boundaries: SegmentBoundaries,
        time: TimeInterval
    ) -> (CGFloat, BreathSegment) {
        let p = cycleProgress.clamped(to: 0...1)

        if p < boundaries.inhaleEnd {
            let t = (p / max(0.0001, boundaries.inhaleEnd)).clamped(to: 0...1)
            var intensity = easeInOutSine(t)

            // Dim-state catch: inhale stutters briefly.
            if currentVariant == .catchBreath {
                let stutter = (t > 0.18 && t < 0.36)
                if stutter {
                    intensity *= 0.55
                }
            }

            return (intensity, .inhale)
        }

        if p < boundaries.activeEnd {
            let denom = max(0.0001, boundaries.activeEnd - boundaries.inhaleEnd)
            let t = ((p - boundaries.inhaleEnd) / denom).clamped(to: 0...1)
            let intensity = 1 - easeInOutSine(t)
            return (intensity, .exhale)
        }

        return (0, .pause)
    }

    // MARK: - Apply Breath

    private func applyBreathToCore(core: CoreNode, intensity: CGFloat, time: TimeInterval) {
        let i = intensity.clamped(to: 0...1)

        let scaleMultiplier: CGFloat
        let brightnessMultiplier: CGFloat

        switch currentVariant {
        case .normal:
            scaleMultiplier = 1.0
            brightnessMultiplier = 1.0
        case .catchBreath:
            scaleMultiplier = 0.85
            brightnessMultiplier = 0.85
        case .shallow:
            scaleMultiplier = 0.55
            brightnessMultiplier = 0.60
        case .skip:
            scaleMultiplier = 0.40
            brightnessMultiplier = 0.50
        case .recovery:
            scaleMultiplier = 1.20
            brightnessMultiplier = 1.15
        }

        let scale = 1 + (i * scaleRange * scaleMultiplier)
        core.setBreathScale(scale)

        let boost = i * brightnessRange * brightnessMultiplier
        core.applyBreath(intensity: i, brightnessBoost: boost, time: time)
    }

    // MARK: - Parameter Updates

    func updateParameters(for state: CoreState, duration: TimeInterval) {
        let adherence = state.adherencePercentage.clamped(to: 0...1)

        // Cycle duration: ~4s (cold) to ~14s (radiant)
        targetCycleDuration = lerp(4.0, 14.0, Double(adherence))

        // Scale range: ~2.5% (dim) to ~9% (radiant)
        targetScaleRange = lerp(0.025, 0.090, adherence)

        // Brightness range: ~6% (dim) to ~20% (radiant)
        targetBrightnessRange = lerp(0.06, 0.20, adherence)

        // Pause: 0.1–0.3s (dim) to 1.0–1.3s (radiant)
        targetPauseDuration = lerp(0.15, 1.2, Double(easeInOutSine(adherence)))

        // Irregularity: high when cold, none when radiant
        targetIrregularity = lerp(0.7, 0.0, adherence)

        startCycleDuration = cycleDuration
        startScaleRange = scaleRange
        startBrightnessRange = brightnessRange
        startPauseDuration = pauseDuration
        startIrregularity = irregularity

        parameterTransitionDuration = duration
        parameterTransitionProgress = 0
    }

    private func updateParameterTransition(deltaTime: TimeInterval) {
        guard parameterTransitionDuration > 0 else {
            cycleDuration = targetCycleDuration
            scaleRange = targetScaleRange
            brightnessRange = targetBrightnessRange
            pauseDuration = targetPauseDuration
            irregularity = targetIrregularity
            return
        }

        guard parameterTransitionProgress < parameterTransitionDuration else { return }

        parameterTransitionProgress += deltaTime
        let t = CGFloat((parameterTransitionProgress / parameterTransitionDuration).clamped(to: 0...1))
        let eased = easeInOutQuad(t)

        cycleDuration = lerp(startCycleDuration, targetCycleDuration, Double(eased))
        scaleRange = lerp(startScaleRange, targetScaleRange, eased)
        brightnessRange = lerp(startBrightnessRange, targetBrightnessRange, eased)
        pauseDuration = lerp(startPauseDuration, targetPauseDuration, Double(eased))
        irregularity = lerp(startIrregularity, targetIrregularity, eased)
    }
}
