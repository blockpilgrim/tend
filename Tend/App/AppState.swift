//
//  AppState.swift
//  Tend
//
//  Global application state using @Observable macro.
//

import SwiftUI
import SwiftData

@Observable
final class AppState {

    // MARK: - User State
    var hasCompletedOnboarding: Bool = false
    var currentGoal: DietaryGoal?
    var isPremium: Bool = false
    var soundEnabled: Bool = true
    var hapticsEnabled: Bool = true

    // MARK: - Core State (derived from adherence)
    private(set) var coreState: CoreState = .neutral
    private(set) var adherenceStats: AdherenceStats = .empty

    // MARK: - Services
    private var mealRepository: MealRepositoryProtocol?
    private let adherenceCalculator: AdherenceCalculatorProtocol = AdherenceCalculator()

    // MARK: - Initialization
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

    // MARK: - State Management
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

    func completeOnboarding(with goal: DietaryGoal, context: ModelContext) {
        hasCompletedOnboarding = true
        currentGoal = goal

        // Persist settings
        let settings = UserSettingsEntity()
        settings.hasCompletedOnboarding = true
        context.insert(settings)

        // Persist goal
        let goalEntity = DietaryGoalEntity(
            name: goal.name,
            isCustom: goal.isCustom,
            customDescription: goal.customDescription
        )
        context.insert(goalEntity)

        try? context.save()
    }
}
