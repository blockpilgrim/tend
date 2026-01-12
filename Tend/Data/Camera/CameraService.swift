//
//  CameraService.swift
//  Tend
//
//  AVFoundation camera service for meal photo capture.
//

import AVFoundation
import UIKit
import SwiftUI

/// Service for camera capture using AVFoundation.
/// Handles authorization, session management, and photo capture.
@MainActor
final class CameraService: NSObject, ObservableObject {

    // MARK: - Published State

    @Published private(set) var isAuthorized: Bool = false
    @Published private(set) var isCameraAvailable: Bool = false
    @Published private(set) var capturedImage: UIImage?
    @Published private(set) var error: CameraError?
    @Published private(set) var isCapturing: Bool = false

    // MARK: - AVFoundation Components

    let captureSession = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()
    private var currentDevice: AVCaptureDevice?

    // MARK: - Capture Continuation

    private var photoContinuation: CheckedContinuation<UIImage, Error>?

    // MARK: - Initialization

    override init() {
        super.init()
        checkCameraAvailability()
    }

    // MARK: - Authorization

    /// Check and request camera authorization
    func checkAuthorization() async {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isAuthorized = true
            await setupCaptureSession()

        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            isAuthorized = granted
            if granted {
                await setupCaptureSession()
            }

        case .denied, .restricted:
            isAuthorized = false
            error = .authorizationDenied

        @unknown default:
            isAuthorized = false
        }
    }

    // MARK: - Camera Availability

    private func checkCameraAvailability() {
        isCameraAvailable = AVCaptureDevice.default(for: .video) != nil
    }

    // MARK: - Session Setup

    private func setupCaptureSession() async {
        guard !captureSession.isRunning else { return }

        captureSession.beginConfiguration()
        captureSession.sessionPreset = .photo

        // Add video input
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            error = .cameraUnavailable
            captureSession.commitConfiguration()
            return
        }

        currentDevice = videoDevice

        do {
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)

            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            } else {
                error = .configurationFailed
                captureSession.commitConfiguration()
                return
            }
        } catch {
            self.error = .configurationFailed
            captureSession.commitConfiguration()
            return
        }

        // Add photo output
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
            photoOutput.isHighResolutionCaptureEnabled = true
            photoOutput.maxPhotoQualityPrioritization = .balanced
        } else {
            error = .configurationFailed
            captureSession.commitConfiguration()
            return
        }

        captureSession.commitConfiguration()
    }

    // MARK: - Session Control

    func startSession() {
        guard isAuthorized, !captureSession.isRunning else { return }

        Task.detached(priority: .userInitiated) { [captureSession] in
            captureSession.startRunning()
        }
    }

    func stopSession() {
        guard captureSession.isRunning else { return }

        Task.detached(priority: .userInitiated) { [captureSession] in
            captureSession.stopRunning()
        }
    }

    // MARK: - Photo Capture

    /// Capture a photo asynchronously
    func capturePhoto() async throws -> UIImage {
        guard isAuthorized else {
            throw CameraError.authorizationDenied
        }

        guard captureSession.isRunning else {
            throw CameraError.sessionNotRunning
        }

        isCapturing = true

        return try await withCheckedThrowingContinuation { continuation in
            self.photoContinuation = continuation

            let settings = AVCapturePhotoSettings()
            settings.flashMode = .auto

            photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }

    /// Reset captured image state
    func resetCapture() {
        capturedImage = nil
        error = nil
    }

    /// Clear any error state
    func clearError() {
        error = nil
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension CameraService: AVCapturePhotoCaptureDelegate {

    nonisolated func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        Task { @MainActor in
            self.isCapturing = false

            if let error = error {
                self.error = .captureFailed(underlying: error)
                self.photoContinuation?.resume(throwing: CameraError.captureFailed(underlying: error))
                self.photoContinuation = nil
                return
            }

            guard let imageData = photo.fileDataRepresentation(),
                  let image = UIImage(data: imageData) else {
                self.error = .imageProcessingFailed
                self.photoContinuation?.resume(throwing: CameraError.imageProcessingFailed)
                self.photoContinuation = nil
                return
            }

            // Fix orientation
            let correctedImage = image.fixedOrientation()

            self.capturedImage = correctedImage
            self.photoContinuation?.resume(returning: correctedImage)
            self.photoContinuation = nil
        }
    }
}

// MARK: - Camera Errors

enum CameraError: Error, LocalizedError {
    case authorizationDenied
    case cameraUnavailable
    case configurationFailed
    case sessionNotRunning
    case captureFailed(underlying: Error)
    case imageProcessingFailed

    var errorDescription: String? {
        switch self {
        case .authorizationDenied:
            return "Camera access was denied. Please enable camera access in Settings."
        case .cameraUnavailable:
            return "No camera is available on this device."
        case .configurationFailed:
            return "Failed to configure the camera."
        case .sessionNotRunning:
            return "Camera session is not running."
        case .captureFailed(let error):
            return "Failed to capture photo: \(error.localizedDescription)"
        case .imageProcessingFailed:
            return "Failed to process the captured image."
        }
    }
}

// MARK: - UIImage Extension for Orientation Fix

extension UIImage {
    /// Fix image orientation to always be .up
    func fixedOrientation() -> UIImage {
        guard imageOrientation != .up else { return self }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return normalizedImage ?? self
    }
}

// MARK: - Camera Preview UIViewRepresentable

/// SwiftUI view that displays the camera preview
struct CameraPreviewView: UIViewRepresentable {
    let cameraService: CameraService

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black

        let previewLayer = AVCaptureVideoPreviewLayer(session: cameraService.captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds

        view.layer.addSublayer(previewLayer)
        context.coordinator.previewLayer = previewLayer

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.previewLayer?.frame = uiView.bounds
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
    }
}
