//
//  MealRepositoryProtocol.swift
//  Tend
//
//  Protocol defining meal data access operations.
//

import Foundation

/// Protocol for meal persistence operations.
/// Implementations handle the storage mechanism (SwiftData, etc.)
protocol MealRepositoryProtocol: Sendable {
    /// Save a new meal to persistent storage
    func save(_ meal: Meal) async throws

    /// Fetch all meals for a specific date
    func fetchMeals(for date: Date) async -> [Meal]

    /// Fetch all meals for the week containing the given date (Monday-Sunday)
    func fetchMeals(forWeekContaining date: Date) async -> [Meal]

    /// Delete a meal from persistent storage
    func deleteMeal(_ meal: Meal) async throws
}

/// Errors that can occur during meal repository operations
enum MealRepositoryError: Error, LocalizedError {
    case saveFailed(underlying: Error)
    case deleteFailed(underlying: Error)
    case mealNotFound

    var errorDescription: String? {
        switch self {
        case .saveFailed(let error):
            return "Failed to save meal: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Failed to delete meal: \(error.localizedDescription)"
        case .mealNotFound:
            return "Meal not found"
        }
    }
}
