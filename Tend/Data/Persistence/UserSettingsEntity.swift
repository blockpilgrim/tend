//
//  UserSettingsEntity.swift
//  Tend
//
//  SwiftData model for persisting user settings.
//

import Foundation
import SwiftData

@Model
final class UserSettingsEntity {
    var id: UUID
    var hasCompletedOnboarding: Bool
    var soundEnabled: Bool
    var hapticsEnabled: Bool
    var calorieTarget: Int?
    var proteinTarget: Int?
    var isPremium: Bool

    init(
        id: UUID = UUID(),
        hasCompletedOnboarding: Bool = false,
        soundEnabled: Bool = true,
        hapticsEnabled: Bool = true,
        calorieTarget: Int? = nil,
        proteinTarget: Int? = nil,
        isPremium: Bool = false
    ) {
        self.id = id
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.soundEnabled = soundEnabled
        self.hapticsEnabled = hapticsEnabled
        self.calorieTarget = calorieTarget
        self.proteinTarget = proteinTarget
        self.isPremium = isPremium
    }
}
