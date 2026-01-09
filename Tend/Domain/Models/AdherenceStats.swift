//
//  AdherenceStats.swift
//  Tend
//
//  Statistics for meal adherence across different time periods.
//

import Foundation

/// Aggregated adherence statistics for display in the Progress view.
struct AdherenceStats: Equatable, Sendable {
    let todayPercentage: CGFloat
    let todayCount: MealCount
    let yesterdayPercentage: CGFloat
    let yesterdayCount: MealCount
    let weekPercentage: CGFloat
    let weekCount: MealCount

    /// Empty/default stats when no data is available
    static let empty = AdherenceStats(
        todayPercentage: 0.5,
        todayCount: MealCount(onTrack: 0, total: 0),
        yesterdayPercentage: 0.5,
        yesterdayCount: MealCount(onTrack: 0, total: 0),
        weekPercentage: 0.5,
        weekCount: MealCount(onTrack: 0, total: 0)
    )
}

/// Simple count of on-track vs total meals
struct MealCount: Equatable, Sendable {
    let onTrack: Int
    let total: Int

    /// Formatted string like "3/4"
    var formatted: String {
        "\(onTrack)/\(total)"
    }

    /// Whether any meals have been logged
    var hasMeals: Bool {
        total > 0
    }
}
