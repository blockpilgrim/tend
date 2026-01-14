//
//  MealLoggingViewModel.swift
//  Tend
//
//  ViewModel managing the meal logging flow state and meal creation.
//

import SwiftUI
import UIKit

/// ViewModel for the meal logging flow.
/// Manages state transitions between capture and confirmation,
/// coordinates photo storage, and handles meal creation.
@MainActor
@Observable
final class MealLoggingViewModel {

    // MARK: - Flow Steps

    enum Step: Equatable {
        case capture
        case textEntry
        case confirmation
    }

    // MARK: - Input Mode

    enum InputMode: Equatable {
        case photo
        case text
    }

    // MARK: - State

    var currentStep: Step = .capture
    var inputMode: InputMode = .photo
    var capturedImage: UIImage?
    var textDescription: String = ""
    var isProcessing: Bool = false
    var error: String?

    // MARK: - Services

    private let photoStorage: PhotoStorageServiceProtocol
    private let appState: AppState

    // MARK: - Initialization

    init(photoStorage: PhotoStorageServiceProtocol = PhotoStorageService(), appState: AppState) {
        self.photoStorage = photoStorage
        self.appState = appState
    }

    // MARK: - Flow Navigation

    /// Move to confirmation step after capturing a photo
    func confirmPhoto(_ image: UIImage) {
        capturedImage = image
        inputMode = .photo
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = .confirmation
        }
    }

    /// Move to text entry mode
    func switchToTextEntry() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = .textEntry
        }
    }

    /// Confirm text entry and move to confirmation
    func confirmTextEntry() {
        guard !textDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            error = "Please enter a meal description"
            return
        }
        inputMode = .text
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = .confirmation
        }
    }

    /// Go back to capture step
    func goBackToCapture() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = .capture
        }
        // Don't clear the captured image or text, so user can switch between modes
    }

    /// Reset the entire flow
    func reset() {
        currentStep = .capture
        inputMode = .photo
        capturedImage = nil
        textDescription = ""
        isProcessing = false
        error = nil
    }

    // MARK: - Meal Logging

    /// Log the meal with the given adherence tagging
    /// - Parameter isOnTrack: Whether the meal is on track with the user's dietary goal
    /// - Returns: True if the meal was logged successfully
    func logMeal(isOnTrack: Bool) async -> Bool {
        isProcessing = true
        error = nil

        defer { isProcessing = false }

        do {
            var photoFilename: String?

            // Save photo if we have one
            if let image = capturedImage {
                photoFilename = try await photoStorage.save(image: image)
            }

            // Create meal
            let meal = Meal(
                isOnTrack: isOnTrack,
                photoFilename: photoFilename,
                textDescription: inputMode == .text ? textDescription.trimmingCharacters(in: .whitespacesAndNewlines) : nil
            )

            // Save meal through app state
            try await appState.logMeal(meal)

            return true

        } catch {
            self.error = "Failed to log meal: \(error.localizedDescription)"
            return false
        }
    }

    // MARK: - Helpers

    /// Whether we have valid content to confirm (either photo or text)
    var hasValidContent: Bool {
        switch inputMode {
        case .photo:
            return capturedImage != nil
        case .text:
            return !textDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    /// The user's current dietary goal name for display
    var dietaryGoalName: String {
        guard let goal = appState.currentGoal else { return "your diet" }
        if goal.isCustom, let description = goal.customDescription?.trimmingCharacters(in: .whitespacesAndNewlines), !description.isEmpty {
            return description
        }
        return goal.name
    }

    /// Clear any error message
    func clearError() {
        error = nil
    }
}
