//
//  PhotoStorageServiceProtocol.swift
//  Tend
//
//  Protocol defining photo storage operations.
//

import UIKit

/// Protocol for meal photo storage operations.
/// Implementations handle file system storage.
protocol PhotoStorageServiceProtocol: Sendable {
    /// Save an image and return the filename for later retrieval
    func save(image: UIImage) async throws -> String

    /// Load an image by filename
    func load(filename: String) async -> UIImage?

    /// Delete an image by filename
    func delete(filename: String) async throws
}

/// Errors that can occur during photo storage operations
enum PhotoStorageError: Error, LocalizedError {
    case compressionFailed
    case saveFailed(underlying: Error)
    case deleteFailed(underlying: Error)
    case fileNotFound

    var errorDescription: String? {
        switch self {
        case .compressionFailed:
            return "Failed to compress image"
        case .saveFailed(let error):
            return "Failed to save photo: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Failed to delete photo: \(error.localizedDescription)"
        case .fileNotFound:
            return "Photo file not found"
        }
    }
}
