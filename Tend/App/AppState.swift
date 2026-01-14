//
//  AppState.swift
//  Tend
//
//  Global application state using @Observable macro.
//

import SwiftUI
import SwiftData

@MainActor
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
            apply(settings: settings)
        }

        // Load current goal
        let goalDescriptor = FetchDescriptor<DietaryGoalEntity>(
            predicate: #Predicate { $0.isActive },
            sortBy: [SortDescriptor(\DietaryGoalEntity.createdAt, order: .reverse)]
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
        guard let repository = mealRepository else {
            throw AppStateError.persistenceNotReady
        }

        try await repository.save(meal)
        await refreshCoreState()
    }

    func completeOnboarding(with goal: DietaryGoal, context: ModelContext) {
        hasCompletedOnboarding = true
        persistUserSettings(context: context)
        updateDietaryGoal(goal, context: context)
    }

    func updateDietaryGoal(_ goal: DietaryGoal, context: ModelContext) {
        // Deactivate existing active goals
        let activeGoalsDescriptor = FetchDescriptor<DietaryGoalEntity>(
            predicate: #Predicate { $0.isActive }
        )
        if let activeGoals = try? context.fetch(activeGoalsDescriptor) {
            for entity in activeGoals {
                entity.isActive = false
            }
        }

        let goalEntity = DietaryGoalEntity(
            name: goal.name,
            isCustom: goal.isCustom,
            customDescription: goal.customDescription,
            isActive: true
        )
        context.insert(goalEntity)

        do {
            try context.save()
            currentGoal = goalEntity.toDomain()
        } catch {
            // Non-fatal: UI state remains updated even if persistence fails
            currentGoal = goal
        }
    }

    func persistUserSettings(context: ModelContext) {
        let settings = fetchOrCreateUserSettings(context: context)
        settings.hasCompletedOnboarding = hasCompletedOnboarding
        settings.soundEnabled = soundEnabled
        settings.hapticsEnabled = hapticsEnabled
        settings.isPremium = isPremium
        try? context.save()
    }

    private func apply(settings: UserSettingsEntity) {
        hasCompletedOnboarding = settings.hasCompletedOnboarding
        soundEnabled = settings.soundEnabled
        hapticsEnabled = settings.hapticsEnabled
        isPremium = settings.isPremium
    }

    private func fetchOrCreateUserSettings(context: ModelContext) -> UserSettingsEntity {
        let descriptor = FetchDescriptor<UserSettingsEntity>()
        if let existing = try? context.fetch(descriptor).first {
            return existing
        }
        let settings = UserSettingsEntity()
        context.insert(settings)
        return settings
    }
}

enum AppStateError: Error, LocalizedError {
    case persistenceNotReady

    var errorDescription: String? {
        switch self {
        case .persistenceNotReady:
            return "Persistence not ready"
        }
    }
}
