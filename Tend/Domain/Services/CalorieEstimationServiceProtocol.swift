//
//  CalorieEstimationServiceProtocol.swift
//  Tend
//
//  Protocol defining AI-powered calorie estimation (Premium feature).
//

import UIKit

/// Protocol for AI-powered calorie estimation from meal photos.
/// This is a Premium feature with provider implementation deferred.
protocol CalorieEstimationServiceProtocol: Sendable {
    /// Estimate calories and macros from a meal photo
    func estimateCalories(from image: UIImage) async throws -> CalorieEstimate
}

/// Result of AI calorie estimation
struct CalorieEstimate: Equatable, Sendable {
    /// Estimated calories
    let calories: Int

    /// Estimated protein in grams (optional)
    let protein: Int?

    /// Confidence score from 0.0 to 1.0
    let confidence: Float

    /// AI-generated description of the meal (optional)
    let description: String?
}

/// Errors that can occur during calorie estimation
enum CalorieEstimationError: Error, LocalizedError {
    case imageProcessingFailed
    case networkError(underlying: Error)
    case apiError(message: String)
    case notAvailable
    case rateLimited

    var errorDescription: String? {
        switch self {
        case .imageProcessingFailed:
            return "Failed to process the image"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .apiError(let message):
            return "API error: \(message)"
        case .notAvailable:
            return "Calorie estimation is not available"
        case .rateLimited:
            return "Too many requests. Please try again later."
        }
    }
}

// MARK: - Mock Implementation for Development

/// Mock implementation for development and testing
final class MockCalorieEstimator: CalorieEstimationServiceProtocol {
    func estimateCalories(from image: UIImage) async throws -> CalorieEstimate {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_500_000_000)

        // Return random estimate for testing
        return CalorieEstimate(
            calories: Int.random(in: 200...800),
            protein: Int.random(in: 10...40),
            confidence: Float.random(in: 0.7...0.95),
            description: "Estimated meal"
        )
    }
}
