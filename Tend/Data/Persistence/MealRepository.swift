//
//  MealRepository.swift
//  Tend
//
//  SwiftData implementation of MealRepositoryProtocol.
//

import Foundation
import SwiftData

final class MealRepository: MealRepositoryProtocol {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func save(_ meal: Meal) async throws {
        let entity = MealEntity.fromDomain(meal)
        modelContext.insert(entity)

        do {
            try modelContext.save()
        } catch {
            throw MealRepositoryError.saveFailed(underlying: error)
        }
    }

    func fetchMeals(for date: Date) async -> [Meal] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let predicate = #Predicate<MealEntity> { meal in
            meal.timestamp >= startOfDay && meal.timestamp < endOfDay
        }

        let descriptor = FetchDescriptor<MealEntity>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )

        do {
            let entities = try modelContext.fetch(descriptor)
            return entities.map { $0.toDomain() }
        } catch {
            return []
        }
    }

    func fetchMeals(forWeekContaining date: Date) async -> [Meal] {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        // Convert to Monday = 0 (Sunday = 1 in Calendar)
        let daysFromMonday = (weekday + 5) % 7

        let startOfWeek = calendar.date(
            byAdding: .day,
            value: -daysFromMonday,
            to: calendar.startOfDay(for: date)
        )!
        let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek)!

        let predicate = #Predicate<MealEntity> { meal in
            meal.timestamp >= startOfWeek && meal.timestamp < endOfWeek
        }

        let descriptor = FetchDescriptor<MealEntity>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )

        do {
            let entities = try modelContext.fetch(descriptor)
            return entities.map { $0.toDomain() }
        } catch {
            return []
        }
    }

    func deleteMeal(_ meal: Meal) async throws {
        let mealId = meal.id
        let predicate = #Predicate<MealEntity> { entity in
            entity.id == mealId
        }

        let descriptor = FetchDescriptor<MealEntity>(predicate: predicate)

        do {
            let entities = try modelContext.fetch(descriptor)
            guard let entity = entities.first else {
                throw MealRepositoryError.mealNotFound
            }
            modelContext.delete(entity)
            try modelContext.save()
        } catch let error as MealRepositoryError {
            throw error
        } catch {
            throw MealRepositoryError.deleteFailed(underlying: error)
        }
    }
}
