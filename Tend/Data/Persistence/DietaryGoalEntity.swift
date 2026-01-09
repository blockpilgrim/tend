//
//  DietaryGoalEntity.swift
//  Tend
//
//  SwiftData model for persisting dietary goals.
//

import Foundation
import SwiftData

@Model
final class DietaryGoalEntity {
    var id: UUID
    var name: String
    var isCustom: Bool
    var customDescription: String?
    var createdAt: Date
    var isActive: Bool

    init(
        id: UUID = UUID(),
        name: String,
        isCustom: Bool = false,
        customDescription: String? = nil,
        createdAt: Date = Date(),
        isActive: Bool = true
    ) {
        self.id = id
        self.name = name
        self.isCustom = isCustom
        self.customDescription = customDescription
        self.createdAt = createdAt
        self.isActive = isActive
    }

    /// Convert to domain model
    func toDomain() -> DietaryGoal {
        DietaryGoal(
            id: id,
            name: name,
            isCustom: isCustom,
            customDescription: customDescription
        )
    }

    /// Create entity from domain model
    static func fromDomain(_ goal: DietaryGoal) -> DietaryGoalEntity {
        DietaryGoalEntity(
            id: goal.id,
            name: goal.name,
            isCustom: goal.isCustom,
            customDescription: goal.customDescription
        )
    }
}
