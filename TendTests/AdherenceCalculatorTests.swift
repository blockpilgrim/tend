//
//  AdherenceCalculatorTests.swift
//  TendTests
//
//  Unit tests for AdherenceCalculator - validates adherence percentage
//  calculations and CoreState derivation from meal data.
//

import XCTest
@testable import Tend

final class AdherenceCalculatorTests: XCTestCase {

    var sut: AdherenceCalculator!
    var calendar: Calendar!

    override func setUp() {
        super.setUp()
        sut = AdherenceCalculator()
        calendar = Calendar.current
    }

    override func tearDown() {
        sut = nil
        calendar = nil
        super.tearDown()
    }

    // MARK: - Empty Data Tests

    func testCalculateStatsWithNoMeals_ReturnsNeutralPercentages() {
        let stats = sut.calculateStats(from: [], referenceDate: Date())

        XCTAssertEqual(stats.todayPercentage, 0.5, "Empty today should return 0.5 (neutral)")
        XCTAssertEqual(stats.yesterdayPercentage, 0.5, "Empty yesterday should return 0.5 (neutral)")
        XCTAssertEqual(stats.weekPercentage, 0.5, "Empty week should return 0.5 (neutral)")
    }

    func testCalculateStatsWithNoMeals_ReturnsZeroCounts() {
        let stats = sut.calculateStats(from: [], referenceDate: Date())

        XCTAssertEqual(stats.todayCount.total, 0)
        XCTAssertEqual(stats.todayCount.onTrack, 0)
        XCTAssertEqual(stats.weekCount.total, 0)
        XCTAssertEqual(stats.weekCount.onTrack, 0)
    }

    func testCalculateCoreStateWithNoMeals_ReturnsNeutral() {
        let stats = sut.calculateStats(from: [], referenceDate: Date())
        let state = sut.calculateCoreState(from: stats)

        XCTAssertEqual(state.adherencePercentage, 0.5)
        XCTAssertEqual(state.tier, .smoldering)
    }

    // MARK: - Today Calculation Tests

    func testCalculateStatsToday_AllOnTrack() {
        let today = Date()
        let meals = [
            createMeal(timestamp: today, isOnTrack: true),
            createMeal(timestamp: today, isOnTrack: true),
            createMeal(timestamp: today, isOnTrack: true),
        ]

        let stats = sut.calculateStats(from: meals, referenceDate: today)

        XCTAssertEqual(stats.todayPercentage, 1.0, accuracy: 0.001)
        XCTAssertEqual(stats.todayCount.onTrack, 3)
        XCTAssertEqual(stats.todayCount.total, 3)
    }

    func testCalculateStatsToday_AllOffTrack() {
        let today = Date()
        let meals = [
            createMeal(timestamp: today, isOnTrack: false),
            createMeal(timestamp: today, isOnTrack: false),
        ]

        let stats = sut.calculateStats(from: meals, referenceDate: today)

        XCTAssertEqual(stats.todayPercentage, 0.0, accuracy: 0.001)
        XCTAssertEqual(stats.todayCount.onTrack, 0)
        XCTAssertEqual(stats.todayCount.total, 2)
    }

    func testCalculateStatsToday_Mixed() {
        let today = Date()
        let meals = [
            createMeal(timestamp: today, isOnTrack: true),
            createMeal(timestamp: today, isOnTrack: true),
            createMeal(timestamp: today, isOnTrack: false),
            createMeal(timestamp: today, isOnTrack: true),
        ]

        let stats = sut.calculateStats(from: meals, referenceDate: today)

        XCTAssertEqual(stats.todayPercentage, 0.75, accuracy: 0.001)
        XCTAssertEqual(stats.todayCount.onTrack, 3)
        XCTAssertEqual(stats.todayCount.total, 4)
    }

    // MARK: - Yesterday Calculation Tests

    func testCalculateStatsYesterday_Calculated() {
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        let meals = [
            createMeal(timestamp: yesterday, isOnTrack: true),
            createMeal(timestamp: yesterday, isOnTrack: false),
        ]

        let stats = sut.calculateStats(from: meals, referenceDate: today)

        XCTAssertEqual(stats.yesterdayPercentage, 0.5, accuracy: 0.001)
        XCTAssertEqual(stats.yesterdayCount.onTrack, 1)
        XCTAssertEqual(stats.yesterdayCount.total, 2)
        // Today should be neutral (no meals)
        XCTAssertEqual(stats.todayPercentage, 0.5)
    }

    // MARK: - Week Calculation Tests

    func testCalculateStatsWeek_IncludesMultipleDays() {
        // Create a reference date and compute days within the same week
        let referenceDate = Date()

        // Get start of week for reference date (Monday)
        let weekday = calendar.component(.weekday, from: referenceDate)
        let daysFromMonday = (weekday + 5) % 7
        let weekStart = calendar.date(byAdding: .day, value: -daysFromMonday, to: calendar.startOfDay(for: referenceDate))!

        // Create meals within this week
        let mondayMeal = createMeal(timestamp: weekStart, isOnTrack: true)
        let dayAfterMonday = calendar.date(byAdding: .day, value: 1, to: weekStart)!
        let tuesdayMeal = createMeal(timestamp: dayAfterMonday, isOnTrack: false)

        let meals = [mondayMeal, tuesdayMeal]
        let stats = sut.calculateStats(from: meals, referenceDate: referenceDate)

        // Week should include both meals
        XCTAssertEqual(stats.weekCount.total, 2)
        XCTAssertEqual(stats.weekCount.onTrack, 1)
        XCTAssertEqual(stats.weekPercentage, 0.5, accuracy: 0.001)
    }

    func testCalculateStatsWeek_ExcludesMealsFromPreviousWeek() {
        // Use current date and compute week start dynamically
        let referenceDate = Date()
        let weekday = calendar.component(.weekday, from: referenceDate)
        let daysFromMonday = (weekday + 5) % 7
        let weekStart = calendar.date(byAdding: .day, value: -daysFromMonday, to: calendar.startOfDay(for: referenceDate))!

        // One day before week start (Sunday of previous week)
        let previousWeekDay = calendar.date(byAdding: .day, value: -1, to: weekStart)!

        let meals = [
            createMeal(timestamp: weekStart, isOnTrack: true), // Monday - in current week
            createMeal(timestamp: previousWeekDay, isOnTrack: false), // Sunday - previous week
        ]

        let stats = sut.calculateStats(from: meals, referenceDate: referenceDate)

        // Week should only include Monday meal
        XCTAssertEqual(stats.weekCount.total, 1, "Should only count meals from current week")
        XCTAssertEqual(stats.weekCount.onTrack, 1)
    }

    // MARK: - Week Boundary Tests (Monday Start)

    func testWeekBoundary_MondayIsFirstDay() {
        // Dynamically compute a Monday
        let referenceDate = Date()
        let weekday = calendar.component(.weekday, from: referenceDate)
        let daysFromMonday = (weekday + 5) % 7
        let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: calendar.startOfDay(for: referenceDate))!

        // Sunday before Monday (previous week)
        let previousSunday = calendar.date(byAdding: .day, value: -1, to: monday)!

        let meals = [
            createMeal(timestamp: monday, isOnTrack: true),
            createMeal(timestamp: previousSunday, isOnTrack: false),
        ]

        let stats = sut.calculateStats(from: meals, referenceDate: monday)

        // Only Monday meal should be in current week
        XCTAssertEqual(stats.weekCount.total, 1, "Sunday should be previous week")
        XCTAssertEqual(stats.weekPercentage, 1.0, accuracy: 0.001)
    }

    func testWeekBoundary_SundayIsLastDay() {
        // Dynamically compute a Sunday (end of week)
        let referenceDate = Date()
        let weekday = calendar.component(.weekday, from: referenceDate)
        let daysFromMonday = (weekday + 5) % 7
        let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: calendar.startOfDay(for: referenceDate))!
        let sunday = calendar.date(byAdding: .day, value: 6, to: monday)! // Sunday is 6 days after Monday

        let meals = [
            createMeal(timestamp: sunday, isOnTrack: true),
            createMeal(timestamp: monday, isOnTrack: true),
        ]

        let stats = sut.calculateStats(from: meals, referenceDate: sunday)

        // Both meals should be in current week
        XCTAssertEqual(stats.weekCount.total, 2, "Monday through Sunday should be same week")
    }

    // MARK: - CoreState Derivation Tests

    func testCalculateCoreState_BlazingTier() {
        let stats = AdherenceStats(
            todayPercentage: 1.0,
            todayCount: MealCount(onTrack: 3, total: 3),
            yesterdayPercentage: 0.5,
            yesterdayCount: MealCount(onTrack: 1, total: 2),
            weekPercentage: 0.95,
            weekCount: MealCount(onTrack: 19, total: 20)
        )

        let state = sut.calculateCoreState(from: stats)

        XCTAssertEqual(state.adherencePercentage, 0.95)
        XCTAssertEqual(state.tier, .blazing)
    }

    func testCalculateCoreState_WarmTier() {
        let stats = AdherenceStats(
            todayPercentage: 0.8,
            todayCount: MealCount(onTrack: 4, total: 5),
            yesterdayPercentage: 0.5,
            yesterdayCount: MealCount(onTrack: 1, total: 2),
            weekPercentage: 0.75,
            weekCount: MealCount(onTrack: 15, total: 20)
        )

        let state = sut.calculateCoreState(from: stats)

        XCTAssertEqual(state.tier, .warm)
    }

    func testCalculateCoreState_SmolderingTier() {
        let stats = AdherenceStats(
            todayPercentage: 0.5,
            todayCount: MealCount(onTrack: 1, total: 2),
            yesterdayPercentage: 0.5,
            yesterdayCount: MealCount(onTrack: 1, total: 2),
            weekPercentage: 0.55,
            weekCount: MealCount(onTrack: 11, total: 20)
        )

        let state = sut.calculateCoreState(from: stats)

        XCTAssertEqual(state.tier, .smoldering)
    }

    func testCalculateCoreState_DimTier() {
        let stats = AdherenceStats(
            todayPercentage: 0.3,
            todayCount: MealCount(onTrack: 1, total: 3),
            yesterdayPercentage: 0.5,
            yesterdayCount: MealCount(onTrack: 1, total: 2),
            weekPercentage: 0.4,
            weekCount: MealCount(onTrack: 8, total: 20)
        )

        let state = sut.calculateCoreState(from: stats)

        XCTAssertEqual(state.tier, .dim)
    }

    func testCalculateCoreState_ColdTier() {
        let stats = AdherenceStats(
            todayPercentage: 0.0,
            todayCount: MealCount(onTrack: 0, total: 3),
            yesterdayPercentage: 0.5,
            yesterdayCount: MealCount(onTrack: 1, total: 2),
            weekPercentage: 0.2,
            weekCount: MealCount(onTrack: 4, total: 20)
        )

        let state = sut.calculateCoreState(from: stats)

        XCTAssertEqual(state.tier, .cold)
    }

    func testCalculateCoreState_UsesWeekPercentage() {
        // Today is 100% but week is low - should use week
        let stats = AdherenceStats(
            todayPercentage: 1.0,
            todayCount: MealCount(onTrack: 3, total: 3),
            yesterdayPercentage: 0.5,
            yesterdayCount: MealCount(onTrack: 1, total: 2),
            weekPercentage: 0.25,
            weekCount: MealCount(onTrack: 5, total: 20)
        )

        let state = sut.calculateCoreState(from: stats)

        XCTAssertEqual(state.adherencePercentage, 0.25, "Should use week percentage, not today")
        XCTAssertEqual(state.tier, .cold)
    }

    // MARK: - Tier Boundary Tests

    func testTierBoundary_Exactly90Percent_IsBlazing() {
        let stats = createWeekStats(percentage: 0.90)
        let state = sut.calculateCoreState(from: stats)
        XCTAssertEqual(state.tier, .blazing)
    }

    func testTierBoundary_Exactly70Percent_IsWarm() {
        let stats = createWeekStats(percentage: 0.70)
        let state = sut.calculateCoreState(from: stats)
        XCTAssertEqual(state.tier, .warm)
    }

    func testTierBoundary_Just89Point9Percent_IsWarm() {
        let stats = createWeekStats(percentage: 0.899)
        let state = sut.calculateCoreState(from: stats)
        XCTAssertEqual(state.tier, .warm, "89.9% should be Warm, not Blazing")
    }

    func testTierBoundary_Exactly50Percent_IsSmoldering() {
        let stats = createWeekStats(percentage: 0.50)
        let state = sut.calculateCoreState(from: stats)
        XCTAssertEqual(state.tier, .smoldering)
    }

    func testTierBoundary_Exactly30Percent_IsDim() {
        let stats = createWeekStats(percentage: 0.30)
        let state = sut.calculateCoreState(from: stats)
        XCTAssertEqual(state.tier, .dim)
    }

    func testTierBoundary_Exactly0Percent_IsCold() {
        let stats = createWeekStats(percentage: 0.0)
        let state = sut.calculateCoreState(from: stats)
        XCTAssertEqual(state.tier, .cold)
    }

    // MARK: - Helpers

    private func createMeal(timestamp: Date, isOnTrack: Bool) -> Meal {
        Meal(
            id: UUID(),
            timestamp: timestamp,
            isOnTrack: isOnTrack,
            photoFilename: nil,
            textDescription: "Test meal"
        )
    }

    private func createWeekStats(percentage: CGFloat) -> AdherenceStats {
        let total = 20
        let onTrack = Int(CGFloat(total) * percentage)
        return AdherenceStats(
            todayPercentage: percentage,
            todayCount: MealCount(onTrack: onTrack, total: total),
            yesterdayPercentage: 0.5,
            yesterdayCount: MealCount(onTrack: 1, total: 2),
            weekPercentage: percentage,
            weekCount: MealCount(onTrack: onTrack, total: total)
        )
    }
}
