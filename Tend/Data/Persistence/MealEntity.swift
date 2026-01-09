//
//  MealEntity.swift
//  Tend
//
//  SwiftData model for persisting meal records.
//

import Foundation
import SwiftData

@Model
final class MealEntity {
    var id: UUID
    var timestamp: Date
    var isOnTrack: Bool
    var photoFilename: String?
    var textDescription: String?
    var calorieEstimate: Int?
    var proteinEstimate: Int?

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        isOnTrack: Bool,
        photoFilename: String? = nil,
        textDescription: String? = nil,
        calorieEstimate: Int? = nil,
        proteinEstimate: Int? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.isOnTrack = isOnTrack
        self.photoFilename = photoFilename
        self.textDescription = textDescription
        self.calorieEstimate = calorieEstimate
        self.proteinEstimate = proteinEstimate
    }

    /// Convert to domain model
    func toDomain() -> Meal {
        Meal(
            id: id,
            timestamp: timestamp,
            isOnTrack: isOnTrack,
            photoFilename: photoFilename,
            textDescription: textDescription,
            calorieEstimate: calorieEstimate,
            proteinEstimate: proteinEstimate
        )
    }

    /// Create entity from domain model
    static func fromDomain(_ meal: Meal) -> MealEntity {
        MealEntity(
            id: meal.id,
            timestamp: meal.timestamp,
            isOnTrack: meal.isOnTrack,
            photoFilename: meal.photoFilename,
            textDescription: meal.textDescription,
            calorieEstimate: meal.calorieEstimate,
            proteinEstimate: meal.proteinEstimate
        )
    }
}
