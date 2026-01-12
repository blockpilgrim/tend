//
//  PhotoStorageServiceTests.swift
//  TendTests
//
//  Unit tests for PhotoStorageService - validates file system operations
//  for meal photo storage.
//

import XCTest
import UIKit
@testable import Tend

final class PhotoStorageServiceTests: XCTestCase {

    var sut: PhotoStorageService!

    override func setUp() {
        super.setUp()
        sut = PhotoStorageService()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Save Tests

    func testSave_ReturnsValidFilename() async throws {
        let image = createTestImage()

        let filename = try await sut.save(image: image)

        XCTAssertFalse(filename.isEmpty)
        XCTAssertTrue(filename.hasSuffix(".jpg"), "Filename should have .jpg extension")

        // Cleanup
        try? await sut.delete(filename: filename)
    }

    func testSave_GeneratesUniqueFilenames() async throws {
        let image = createTestImage()

        let filename1 = try await sut.save(image: image)
        let filename2 = try await sut.save(image: image)

        XCTAssertNotEqual(filename1, filename2, "Each save should generate a unique filename")

        // Cleanup
        try? await sut.delete(filename: filename1)
        try? await sut.delete(filename: filename2)
    }

    func testSave_ImageCanBeLoadedAfterSave() async throws {
        let originalImage = createTestImage(color: .red, size: CGSize(width: 100, height: 100))

        let filename = try await sut.save(image: originalImage)
        let loadedImage = await sut.load(filename: filename)

        XCTAssertNotNil(loadedImage, "Should be able to load saved image")

        // Cleanup
        try? await sut.delete(filename: filename)
    }

    // MARK: - Load Tests

    func testLoad_ReturnsNilForNonExistentFile() async {
        let loadedImage = await sut.load(filename: "nonexistent_file_\(UUID().uuidString).jpg")

        XCTAssertNil(loadedImage)
    }

    func testLoad_ReturnsSavedImage() async throws {
        let originalImage = createTestImage(size: CGSize(width: 200, height: 150))

        let filename = try await sut.save(image: originalImage)
        let loadedImage = await sut.load(filename: filename)

        XCTAssertNotNil(loadedImage, "Should load the saved image")

        // Cleanup
        try? await sut.delete(filename: filename)
    }

    // MARK: - Delete Tests

    func testDelete_RemovesFileSuccessfully() async throws {
        let image = createTestImage()
        let filename = try await sut.save(image: image)

        // Verify file exists
        var loadedImage = await sut.load(filename: filename)
        XCTAssertNotNil(loadedImage, "File should exist before deletion")

        // Delete file
        try await sut.delete(filename: filename)

        // Verify file is gone
        loadedImage = await sut.load(filename: filename)
        XCTAssertNil(loadedImage, "File should not exist after deletion")
    }

    func testDelete_ThrowsForNonExistentFile() async {
        let filename = "nonexistent_file_\(UUID().uuidString).jpg"

        do {
            try await sut.delete(filename: filename)
            XCTFail("Expected fileNotFound error")
        } catch let error as PhotoStorageError {
            if case .fileNotFound = error {
                // Expected
            } else {
                XCTFail("Expected fileNotFound error, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // MARK: - Error Handling Tests

    func testPhotoStorageError_HasLocalizedDescriptions() {
        let compressionError = PhotoStorageError.compressionFailed
        let saveError = PhotoStorageError.saveFailed(underlying: NSError(domain: "test", code: 1))
        let deleteError = PhotoStorageError.deleteFailed(underlying: NSError(domain: "test", code: 2))
        let notFoundError = PhotoStorageError.fileNotFound

        XCTAssertNotNil(compressionError.errorDescription)
        XCTAssertNotNil(saveError.errorDescription)
        XCTAssertNotNil(deleteError.errorDescription)
        XCTAssertNotNil(notFoundError.errorDescription)

        XCTAssertTrue(compressionError.errorDescription!.contains("compress"))
        XCTAssertTrue(saveError.errorDescription!.contains("save"))
        XCTAssertTrue(deleteError.errorDescription!.contains("delete"))
        XCTAssertTrue(notFoundError.errorDescription!.contains("not found"))
    }

    // MARK: - JPEG Compression Tests

    func testSave_CompressesImage() async throws {
        // Create a large image
        let largeImage = createTestImage(size: CGSize(width: 500, height: 500))

        let filename = try await sut.save(image: largeImage)

        // The saved file should be JPEG compressed - verify it can be loaded
        let loadedImage = await sut.load(filename: filename)
        XCTAssertNotNil(loadedImage, "Compressed image should be loadable")

        // Cleanup
        try? await sut.delete(filename: filename)
    }

    // MARK: - Helpers

    private func createTestImage(color: UIColor = .blue, size: CGSize = CGSize(width: 50, height: 50)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}
