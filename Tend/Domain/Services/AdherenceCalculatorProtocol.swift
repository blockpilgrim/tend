//
//  AdherenceCalculatorProtocol.swift
//  Tend
//
//  Protocol defining adherence calculation operations.
//

import Foundation

/// Protocol for calculating adherence statistics and Core state.
protocol AdherenceCalculatorProtocol: Sendable {
    /// Calculate adherence stats from a collection of meals
    func calculateStats(from meals: [Meal], referenceDate: Date) -> AdherenceStats

    /// Calculate the Core's state from adherence stats
    func calculateCoreState(from stats: AdherenceStats) -> CoreState
}

/// Default implementation of the adherence calculator
final class AdherenceCalculator: AdherenceCalculatorProtocol, Sendable {

    private let calendar = Calendar.current

    func calculateStats(from meals: [Meal], referenceDate: Date) -> AdherenceStats {
        let today = calendar.startOfDay(for: referenceDate)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let weekStart = startOfWeek(containing: referenceDate)

        // Today's stats
        let todayMeals = meals.filter { calendar.isDate($0.timestamp, inSameDayAs: today) }
        let todayOnTrack = todayMeals.filter(\.isOnTrack).count
        let todayPercentage = todayMeals.isEmpty ? 0.5 : CGFloat(todayOnTrack) / CGFloat(todayMeals.count)

        // Yesterday's stats
        let yesterdayMeals = meals.filter { calendar.isDate($0.timestamp, inSameDayAs: yesterday) }
        let yesterdayOnTrack = yesterdayMeals.filter(\.isOnTrack).count
        let yesterdayPercentage = yesterdayMeals.isEmpty ? 0.5 : CGFloat(yesterdayOnTrack) / CGFloat(yesterdayMeals.count)

        // This week's stats
        let weekMeals = meals.filter { $0.timestamp >= weekStart }
        let weekOnTrack = weekMeals.filter(\.isOnTrack).count
        let weekPercentage = weekMeals.isEmpty ? 0.5 : CGFloat(weekOnTrack) / CGFloat(weekMeals.count)

        return AdherenceStats(
            todayPercentage: todayPercentage,
            todayCount: MealCount(onTrack: todayOnTrack, total: todayMeals.count),
            yesterdayPercentage: yesterdayPercentage,
            yesterdayCount: MealCount(onTrack: yesterdayOnTrack, total: yesterdayMeals.count),
            weekPercentage: weekPercentage,
            weekCount: MealCount(onTrack: weekOnTrack, total: weekMeals.count)
        )
    }

    func calculateCoreState(from stats: AdherenceStats) -> CoreState {
        // Week percentage is the primary driver
        // If no meals logged, return neutral state
        if stats.weekCount.total == 0 {
            return .neutral
        }

        return CoreState(adherencePercentage: stats.weekPercentage)
    }

    /// Calculate the start of the week (Monday) containing the given date
    private func startOfWeek(containing date: Date) -> Date {
        let weekday = calendar.component(.weekday, from: date)
        // Convert to Monday = 0 (Sunday = 1 in Calendar, so adjust)
        let daysFromMonday = (weekday + 5) % 7
        return calendar.date(byAdding: .day, value: -daysFromMonday, to: calendar.startOfDay(for: date))!
    }
}
