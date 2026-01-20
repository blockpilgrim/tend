//
//  CoreVFXEvent.swift
//  Tend
//
//  One-shot visual effect events for the Radiant Core (separate from steady state interpolation).
//

import Foundation

struct CoreVFXEvent: Equatable, Sendable {
    enum Kind: Equatable, Sendable {
        case mealOnTrack
        case mealOffTrack
        case apexIgnition
    }

    let id: UUID
    let kind: Kind

    init(id: UUID = UUID(), kind: Kind) {
        self.id = id
        self.kind = kind
    }
}
