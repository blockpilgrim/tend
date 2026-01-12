//
//  DomainModelTests.swift
//  TendTests
//
//  Unit tests for domain models: Meal, DietaryGoal, AdherenceStats, MealCount.
//

import XCTest
@testable import Tend

final class DomainModelTests: XCTestCase {

    // MARK: - Meal Tests

    func testMeal_DisplayDescription_PrefersTextOverPhoto() {
        let meal = Meal(
            timestamp: Date(),
            isOnTrack: true,
            photoFilename: "photo.jpg",
            textDescription: "Grilled salmon"
        )

        XCTAssertEqual(meal.displayDescription, "Grilled salmon")
    }

    func testMeal_DisplayDescription_UsesPhotoLoggedWhenNoText() {
        let meal = Meal(
            timestamp: Date(),
            isOnTrack: true,
            photoFilename: "photo.jpg",
            textDescription: nil
        )

        XCTAssertEqual(meal.displayDescription, "Photo logged")
    }

    func testMeal_DisplayDescription_UsesPhotoLoggedForEmptyText() {
        let meal = Meal(
            timestamp: Date(),
            isOnTrack: true,
            photoFilename: "photo.jpg",
            textDescription: ""
        )

        XCTAssertEqual(meal.displayDescription, "Photo logged")
    }

    func testMeal_DisplayDescription_UsesMealLoggedWhenNoPhotoOrText() {
        let meal = Meal(
            timestamp: Date(),
            isOnTrack: true,
            photoFilename: nil,
            textDescription: nil
        )

        XCTAssertEqual(meal.displayDescription, "Meal logged")
    }

    func testMeal_FormattedTime_ReturnsNonEmptyString() {
        let meal = Meal(timestamp: Date(), isOnTrack: true)

        XCTAssertFalse(meal.formattedTime.isEmpty)
    }

    func testMeal_FormattedDate_ReturnsNonEmptyString() {
        let meal = Meal(timestamp: Date(), isOnTrack: true)

        XCTAssertFalse(meal.formattedDate.isEmpty)
    }

    func testMeal_Equatable() {
        let id = UUID()
        let timestamp = Date()

        let meal1 = Meal(id: id, timestamp: timestamp, isOnTrack: true)
        let meal2 = Meal(id: id, timestamp: timestamp, isOnTrack: true)
        let meal3 = Meal(id: UUID(), timestamp: timestamp, isOnTrack: true)

        XCTAssertEqual(meal1, meal2)
        XCTAssertNotEqual(meal1, meal3)
    }

    func testMeal_DefaultInitialization() {
        let meal = Meal(isOnTrack: true)

        XCTAssertNotNil(meal.id)
        XCTAssertNotNil(meal.timestamp)
        XCTAssertTrue(meal.isOnTrack)
        XCTAssertNil(meal.photoFilename)
        XCTAssertNil(meal.textDescription)
        XCTAssertNil(meal.calorieEstimate)
        XCTAssertNil(meal.proteinEstimate)
    }

    // MARK: - DietaryGoal Tests

    func testDietaryGoal_PresetsCount() {
        XCTAssertEqual(DietaryGoal.presets.count, 8, "Should have 8 preset goals per Concept Brief")
    }

    func testDietaryGoal_PresetsContainExpectedNames() {
        let presetNames = DietaryGoal.presets.map { $0.name }

        XCTAssertTrue(presetNames.contains("Keto / Low-carb"))
        XCTAssertTrue(presetNames.contains("Vegetarian"))
        XCTAssertTrue(presetNames.contains("Vegan"))
        XCTAssertTrue(presetNames.contains("Mediterranean"))
        XCTAssertTrue(presetNames.contains("Whole30 / Paleo"))
        XCTAssertTrue(presetNames.contains("Low sugar"))
        XCTAssertTrue(presetNames.contains("High protein"))
        XCTAssertTrue(presetNames.contains("Whole foods"))
    }

    func testDietaryGoal_PresetsAreNotCustom() {
        for preset in DietaryGoal.presets {
            XCTAssertFalse(preset.isCustom, "\(preset.name) should not be custom")
            XCTAssertNil(preset.customDescription)
        }
    }

    func testDietaryGoal_CustomFactory() {
        let custom = DietaryGoal.custom(description: "No red meat")

        XCTAssertEqual(custom.name, "Custom")
        XCTAssertTrue(custom.isCustom)
        XCTAssertEqual(custom.customDescription, "No red meat")
    }

    func testDietaryGoal_Equatable() {
        let id = UUID()

        let goal1 = DietaryGoal(id: id, name: "Keto")
        let goal2 = DietaryGoal(id: id, name: "Keto")
        let goal3 = DietaryGoal(id: UUID(), name: "Keto")

        XCTAssertEqual(goal1, goal2)
        XCTAssertNotEqual(goal1, goal3)
    }

    // MARK: - AdherenceStats Tests

    func testAdherenceStats_Empty() {
        let empty = AdherenceStats.empty

        XCTAssertEqual(empty.todayPercentage, 0.5)
        XCTAssertEqual(empty.yesterdayPercentage, 0.5)
        XCTAssertEqual(empty.weekPercentage, 0.5)
        XCTAssertEqual(empty.todayCount.total, 0)
        XCTAssertEqual(empty.weekCount.total, 0)
    }

    func testAdherenceStats_Equatable() {
        let stats1 = AdherenceStats(
            todayPercentage: 0.8,
            todayCount: MealCount(onTrack: 4, total: 5),
            yesterdayPercentage: 0.6,
            yesterdayCount: MealCount(onTrack: 3, total: 5),
            weekPercentage: 0.7,
            weekCount: MealCount(onTrack: 14, total: 20)
        )

        let stats2 = AdherenceStats(
            todayPercentage: 0.8,
            todayCount: MealCount(onTrack: 4, total: 5),
            yesterdayPercentage: 0.6,
            yesterdayCount: MealCount(onTrack: 3, total: 5),
            weekPercentage: 0.7,
            weekCount: MealCount(onTrack: 14, total: 20)
        )

        XCTAssertEqual(stats1, stats2)
    }

    // MARK: - MealCount Tests

    func testMealCount_Formatted() {
        let count = MealCount(onTrack: 3, total: 5)
        XCTAssertEqual(count.formatted, "3/5")
    }

    func testMealCount_FormattedZero() {
        let count = MealCount(onTrack: 0, total: 0)
        XCTAssertEqual(count.formatted, "0/0")
    }

    func testMealCount_HasMeals_True() {
        let count = MealCount(onTrack: 2, total: 3)
        XCTAssertTrue(count.hasMeals)
    }

    func testMealCount_HasMeals_False() {
        let count = MealCount(onTrack: 0, total: 0)
        XCTAssertFalse(count.hasMeals)
    }

    func testMealCount_Equatable() {
        let count1 = MealCount(onTrack: 3, total: 5)
        let count2 = MealCount(onTrack: 3, total: 5)
        let count3 = MealCount(onTrack: 2, total: 5)

        XCTAssertEqual(count1, count2)
        XCTAssertNotEqual(count1, count3)
    }

    // MARK: - MealRepositoryError Tests

    func testMealRepositoryError_HasLocalizedDescriptions() {
        let saveError = MealRepositoryError.saveFailed(underlying: NSError(domain: "test", code: 1))
        let deleteError = MealRepositoryError.deleteFailed(underlying: NSError(domain: "test", code: 2))
        let notFoundError = MealRepositoryError.mealNotFound

        XCTAssertNotNil(saveError.errorDescription)
        XCTAssertNotNil(deleteError.errorDescription)
        XCTAssertNotNil(notFoundError.errorDescription)

        XCTAssertTrue(saveError.errorDescription!.contains("save"))
        XCTAssertTrue(deleteError.errorDescription!.contains("delete"))
        XCTAssertTrue(notFoundError.errorDescription!.contains("not found"))
    }
}
