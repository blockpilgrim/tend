//
//  DietaryGoal.swift
//  Tend
//
//  Domain model representing a user's dietary goal.
//

import Foundation

/// A dietary goal that contextualizes what "on track" means for the user.
struct DietaryGoal: Identifiable, Equatable, Sendable {
    let id: UUID
    let name: String
    let isCustom: Bool
    let customDescription: String?

    init(
        id: UUID = UUID(),
        name: String,
        isCustom: Bool = false,
        customDescription: String? = nil
    ) {
        self.id = id
        self.name = name
        self.isCustom = isCustom
        self.customDescription = customDescription
    }

    /// Preset dietary goals available during onboarding
    static let presets: [DietaryGoal] = [
        DietaryGoal(name: "Keto / Low-carb"),
        DietaryGoal(name: "Vegetarian"),
        DietaryGoal(name: "Vegan"),
        DietaryGoal(name: "Mediterranean"),
        DietaryGoal(name: "Whole30 / Paleo"),
        DietaryGoal(name: "Low sugar"),
        DietaryGoal(name: "High protein"),
        DietaryGoal(name: "Whole foods"),
    ]

    /// Create a custom dietary goal with user-defined description
    static func custom(description: String) -> DietaryGoal {
        DietaryGoal(
            name: "Custom",
            isCustom: true,
            customDescription: description
        )
    }
}
