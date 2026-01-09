//
//  CoreState.swift
//  Tend
//
//  Represents the current state of the Radiant Core based on adherence percentage.
//

import Foundation

/// Represents the Radiant Core's current state derived from weekly adherence.
struct CoreState: Equatable, Sendable {
    /// Adherence percentage from 0.0 to 1.0
    let adherencePercentage: CGFloat

    /// The discrete tier based on adherence percentage
    var tier: CoreTier {
        switch adherencePercentage {
        case 0.9...1.0: return .blazing
        case 0.7..<0.9: return .warm
        case 0.5..<0.7: return .smoldering
        case 0.3..<0.5: return .dim
        default: return .cold
        }
    }

    // MARK: - Preset States

    /// Neutral state (50% adherence) - used for new weeks or no data
    static let neutral = CoreState(adherencePercentage: 0.5)

    /// Fully radiant state (100% adherence)
    static let radiant = CoreState(adherencePercentage: 1.0)

    /// Fully dim state (0% adherence)
    static let dim = CoreState(adherencePercentage: 0.0)
}

/// The five discrete tiers of the Core's state spectrum.
/// While the Core transitions smoothly, these tiers provide a useful framework.
enum CoreTier: String, CaseIterable, Sendable {
    /// 90-100% adherence - Roaring campfire
    case blazing

    /// 70-89% adherence - Steady hearth fire
    case warm

    /// 50-69% adherence - Banked coals
    case smoldering

    /// 30-49% adherence - Dying ember
    case dim

    /// 0-29% adherence - Ash with faint heat
    case cold

    /// Human-readable description of the tier
    var description: String {
        switch self {
        case .blazing: return "Blazing"
        case .warm: return "Warm"
        case .smoldering: return "Smoldering"
        case .dim: return "Dim"
        case .cold: return "Cold"
        }
    }
}
