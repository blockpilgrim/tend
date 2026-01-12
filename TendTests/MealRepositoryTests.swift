//
//  MealRepositoryTests.swift
//  TendTests
//
//  Unit tests for MealRepository - validates SwiftData CRUD operations
//  using an in-memory model container for isolation.
//

import XCTest
import SwiftData
@testable import Tend

final class MealRepositoryTests: XCTestCase {

    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var sut: MealRepository!
    var calendar: Calendar!

    @MainActor
    override func setUp() {
        super.setUp()
        calendar = Calendar.current

        // Create in-memory SwiftData container for testing
        let schema = Schema([MealEntity.self, DietaryGoalEntity.self, UserSettingsEntity.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)

        do {
            modelContainer = try ModelContainer(for: schema, configurations: [configuration])
            modelContext = modelContainer.mainContext
            sut = MealRepository(modelContext: modelContext)
        } catch {
            XCTFail("Failed to create in-memory model container: \(error)")
        }
    }

    override func tearDown() {
        sut = nil
        modelContext = nil
        modelContainer = nil
        calendar = nil
        super.tearDown()
    }

    // MARK: - Save Tests

    @MainActor
    func testSave_PersistsMealSuccessfully() async throws {
        let meal = createMeal(isOnTrack: true, description: "Test breakfast")

        try await sut.save(meal)

        let fetchedMeals = await sut.fetchMeals(for: Date())
        XCTAssertEqual(fetchedMeals.count, 1)
        XCTAssertEqual(fetchedMeals.first?.id, meal.id)
        XCTAssertEqual(fetchedMeals.first?.textDescription, "Test breakfast")
    }

    @MainActor
    func testSave_PreservesAllFields() async throws {
        let meal = Meal(
            id: UUID(),
            timestamp: Date(),
            isOnTrack: true,
            photoFilename: "test_photo.jpg",
            textDescription: "Grilled chicken salad",
            calorieEstimate: 450,
            proteinEstimate: 35
        )

        try await sut.save(meal)

        let fetchedMeals = await sut.fetchMeals(for: Date())
        let fetched = fetchedMeals.first!

        XCTAssertEqual(fetched.isOnTrack, true)
        XCTAssertEqual(fetched.photoFilename, "test_photo.jpg")
        XCTAssertEqual(fetched.textDescription, "Grilled chicken salad")
        XCTAssertEqual(fetched.calorieEstimate, 450)
        XCTAssertEqual(fetched.proteinEstimate, 35)
    }

    @MainActor
    func testSave_MultipleMeals() async throws {
        let meal1 = createMeal(isOnTrack: true, description: "Breakfast")
        let meal2 = createMeal(isOnTrack: false, description: "Lunch")
        let meal3 = createMeal(isOnTrack: true, description: "Dinner")

        try await sut.save(meal1)
        try await sut.save(meal2)
        try await sut.save(meal3)

        let fetchedMeals = await sut.fetchMeals(for: Date())
        XCTAssertEqual(fetchedMeals.count, 3)
    }

    // MARK: - Fetch By Date Tests

    @MainActor
    func testFetchMealsForDate_ReturnsOnlyMealsFromThatDay() async throws {
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        let todayMeal = createMeal(timestamp: today, isOnTrack: true, description: "Today")
        let yesterdayMeal = createMeal(timestamp: yesterday, isOnTrack: true, description: "Yesterday")

        try await sut.save(todayMeal)
        try await sut.save(yesterdayMeal)

        let todayMeals = await sut.fetchMeals(for: today)
        let yesterdayMeals = await sut.fetchMeals(for: yesterday)

        XCTAssertEqual(todayMeals.count, 1)
        XCTAssertEqual(todayMeals.first?.textDescription, "Today")
        XCTAssertEqual(yesterdayMeals.count, 1)
        XCTAssertEqual(yesterdayMeals.first?.textDescription, "Yesterday")
    }

    @MainActor
    func testFetchMealsForDate_ReturnsEmptyForDayWithNoMeals() async throws {
        let today = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!

        let todayMeal = createMeal(timestamp: today, isOnTrack: true)
        try await sut.save(todayMeal)

        let tomorrowMeals = await sut.fetchMeals(for: tomorrow)
        XCTAssertTrue(tomorrowMeals.isEmpty)
    }

    @MainActor
    func testFetchMealsForDate_ReturnsSortedByTimestampDescending() async throws {
        let today = Date()
        let morning = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: today)!
        let noon = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: today)!
        let evening = calendar.date(bySettingHour: 19, minute: 0, second: 0, of: today)!

        // Save in non-chronological order
        try await sut.save(createMeal(timestamp: noon, isOnTrack: true, description: "Lunch"))
        try await sut.save(createMeal(timestamp: evening, isOnTrack: true, description: "Dinner"))
        try await sut.save(createMeal(timestamp: morning, isOnTrack: true, description: "Breakfast"))

        let meals = await sut.fetchMeals(for: today)

        XCTAssertEqual(meals.count, 3)
        // Should be sorted descending (most recent first)
        XCTAssertEqual(meals[0].textDescription, "Dinner")
        XCTAssertEqual(meals[1].textDescription, "Lunch")
        XCTAssertEqual(meals[2].textDescription, "Breakfast")
    }

    // MARK: - Fetch By Week Tests

    @MainActor
    func testFetchMealsForWeek_IncludesAllDaysInWeek() async throws {
        // Dynamically compute week bounds
        let referenceDate = Date()
        let weekday = calendar.component(.weekday, from: referenceDate)
        let daysFromMonday = (weekday + 5) % 7
        let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: calendar.startOfDay(for: referenceDate))!
        let wednesday = calendar.date(byAdding: .day, value: 2, to: monday)!
        let sunday = calendar.date(byAdding: .day, value: 6, to: monday)!

        try await sut.save(createMeal(timestamp: monday, isOnTrack: true, description: "Monday"))
        try await sut.save(createMeal(timestamp: wednesday, isOnTrack: true, description: "Wednesday"))
        try await sut.save(createMeal(timestamp: sunday, isOnTrack: true, description: "Sunday"))

        let weekMeals = await sut.fetchMeals(forWeekContaining: wednesday)

        XCTAssertEqual(weekMeals.count, 3)
    }

    @MainActor
    func testFetchMealsForWeek_ExcludesPreviousWeek() async throws {
        // Dynamically compute Monday
        let referenceDate = Date()
        let weekday = calendar.component(.weekday, from: referenceDate)
        let daysFromMonday = (weekday + 5) % 7
        let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: calendar.startOfDay(for: referenceDate))!

        // Previous Sunday
        let previousSunday = calendar.date(byAdding: .day, value: -1, to: monday)!

        try await sut.save(createMeal(timestamp: monday, isOnTrack: true, description: "This week"))
        try await sut.save(createMeal(timestamp: previousSunday, isOnTrack: true, description: "Last week"))

        let weekMeals = await sut.fetchMeals(forWeekContaining: monday)

        XCTAssertEqual(weekMeals.count, 1)
        XCTAssertEqual(weekMeals.first?.textDescription, "This week")
    }

    @MainActor
    func testFetchMealsForWeek_ExcludesNextWeek() async throws {
        // Dynamically compute Sunday (end of week)
        let referenceDate = Date()
        let weekday = calendar.component(.weekday, from: referenceDate)
        let daysFromMonday = (weekday + 5) % 7
        let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: calendar.startOfDay(for: referenceDate))!
        let sunday = calendar.date(byAdding: .day, value: 6, to: monday)!

        // Next Monday
        let nextMonday = calendar.date(byAdding: .day, value: 1, to: sunday)!

        try await sut.save(createMeal(timestamp: sunday, isOnTrack: true, description: "This week"))
        try await sut.save(createMeal(timestamp: nextMonday, isOnTrack: true, description: "Next week"))

        let weekMeals = await sut.fetchMeals(forWeekContaining: sunday)

        XCTAssertEqual(weekMeals.count, 1)
        XCTAssertEqual(weekMeals.first?.textDescription, "This week")
    }

    // MARK: - Delete Tests

    @MainActor
    func testDelete_RemovesMealSuccessfully() async throws {
        let meal = createMeal(isOnTrack: true, description: "To delete")
        try await sut.save(meal)

        // Verify it exists
        var meals = await sut.fetchMeals(for: Date())
        XCTAssertEqual(meals.count, 1)

        // Delete it
        try await sut.deleteMeal(meal)

        // Verify it's gone
        meals = await sut.fetchMeals(for: Date())
        XCTAssertTrue(meals.isEmpty)
    }

    @MainActor
    func testDelete_OnlyDeletesSpecifiedMeal() async throws {
        let meal1 = createMeal(isOnTrack: true, description: "Keep this")
        let meal2 = createMeal(isOnTrack: false, description: "Delete this")

        try await sut.save(meal1)
        try await sut.save(meal2)

        try await sut.deleteMeal(meal2)

        let meals = await sut.fetchMeals(for: Date())
        XCTAssertEqual(meals.count, 1)
        XCTAssertEqual(meals.first?.textDescription, "Keep this")
    }

    @MainActor
    func testDelete_ThrowsForNonExistentMeal() async throws {
        let nonExistentMeal = createMeal(isOnTrack: true, description: "Never saved")

        do {
            try await sut.deleteMeal(nonExistentMeal)
            XCTFail("Expected mealNotFound error")
        } catch let error as MealRepositoryError {
            if case .mealNotFound = error {
                // Expected
            } else {
                XCTFail("Expected mealNotFound error, got \(error)")
            }
        }
    }

    // MARK: - Helpers

    private func createMeal(
        timestamp: Date = Date(),
        isOnTrack: Bool,
        description: String = "Test meal"
    ) -> Meal {
        Meal(
            id: UUID(),
            timestamp: timestamp,
            isOnTrack: isOnTrack,
            photoFilename: nil,
            textDescription: description
        )
    }
}
