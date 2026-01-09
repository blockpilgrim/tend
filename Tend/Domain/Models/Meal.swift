//
//  Meal.swift
//  Tend
//
//  Domain model representing a logged meal.
//

import Foundation

/// A logged meal entry with adherence tagging.
struct Meal: Identifiable, Equatable, Sendable {
    let id: UUID
    let timestamp: Date
    let isOnTrack: Bool
    let photoFilename: String?
    let textDescription: String?
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

    /// User-friendly description for display
    var displayDescription: String {
        if let text = textDescription, !text.isEmpty {
            return text
        }
        return photoFilename != nil ? "Photo logged" : "Meal logged"
    }

    /// Formatted timestamp for display
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }

    /// Formatted date for display
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}
