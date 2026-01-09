//
//  PhotoStorageService.swift
//  Tend
//
//  File system implementation for meal photo storage.
//

import UIKit

final class PhotoStorageService: PhotoStorageServiceProtocol {

    private let fileManager = FileManager.default

    /// Directory where meal photos are stored
    private var photosDirectory: URL {
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let photosURL = documentsURL.appendingPathComponent("MealPhotos", isDirectory: true)

        // Create directory if it doesn't exist
        if !fileManager.fileExists(atPath: photosURL.path) {
            try? fileManager.createDirectory(at: photosURL, withIntermediateDirectories: true)
        }

        return photosURL
    }

    func save(image: UIImage) async throws -> String {
        let filename = UUID().uuidString + ".jpg"
        let fileURL = photosDirectory.appendingPathComponent(filename)

        // Compress image to JPEG with 0.8 quality (per TDD performance specs)
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw PhotoStorageError.compressionFailed
        }

        do {
            try data.write(to: fileURL)
            return filename
        } catch {
            throw PhotoStorageError.saveFailed(underlying: error)
        }
    }

    func load(filename: String) async -> UIImage? {
        let fileURL = photosDirectory.appendingPathComponent(filename)

        guard let data = try? Data(contentsOf: fileURL) else {
            return nil
        }

        return UIImage(data: data)
    }

    func delete(filename: String) async throws {
        let fileURL = photosDirectory.appendingPathComponent(filename)

        guard fileManager.fileExists(atPath: fileURL.path) else {
            throw PhotoStorageError.fileNotFound
        }

        do {
            try fileManager.removeItem(at: fileURL)
        } catch {
            throw PhotoStorageError.deleteFailed(underlying: error)
        }
    }
}
