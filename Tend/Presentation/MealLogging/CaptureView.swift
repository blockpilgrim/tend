//
//  CaptureView.swift
//  Tend
//
//  Camera capture view with viewfinder, capture button, and text entry option.
//

import SwiftUI

/// Camera capture screen for the meal logging flow.
/// Displays camera preview with capture button and option to enter text instead.
struct CaptureView: View {

    @Bindable var viewModel: MealLoggingViewModel
    @StateObject private var cameraService = CameraService()
    let onDismiss: () -> Void

    @State private var showingAuthorizationAlert = false

    var body: some View {
        ZStack {
            // Background
            Color("BackgroundPrimary")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Camera viewfinder area
                ZStack {
                    if cameraService.isAuthorized && cameraService.isCameraAvailable {
                        CameraPreviewView(cameraService: cameraService)
                            .ignoresSafeArea(edges: .top)
                    } else {
                        // Placeholder when camera not authorized or unavailable
                        VStack(spacing: 16) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(Color("TextSecondary"))

                            if cameraService.isCameraAvailable {
                                Text("Camera access required")
                                    .font(.headline)
                                    .foregroundStyle(Color("TextPrimary"))

                                Text("Enable camera access in Settings to capture meal photos.")
                                    .font(.body)
                                    .foregroundStyle(Color("TextSecondary"))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)

                                Button("Open Settings") {
                                    openSettings()
                                }
                                .font(.headline)
                                .foregroundStyle(Color("AccentPrimary"))
                                .padding(.top, 8)
                            } else {
                                Text("Camera not available")
                                    .font(.headline)
                                    .foregroundStyle(Color("TextPrimary"))

                                Text("Use the text option below to describe your meal.")
                                    .font(.body)
                                    .foregroundStyle(Color("TextSecondary"))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                            }
                        }
                    }

                    // Capture progress overlay
                    if cameraService.isCapturing {
                        Color.black.opacity(0.5)
                            .ignoresSafeArea()

                        ProgressView()
                            .tint(.white)
                            .scaleEffect(1.5)
                    }
                }
                .frame(height: UIScreen.main.bounds.height * 0.55)

                // Controls area
                VStack(spacing: 24) {
                    Spacer()

                    // Capture button
                    Button(action: capturePhoto) {
                        ZStack {
                            Circle()
                                .stroke(Color("AccentPrimary"), lineWidth: 4)
                                .frame(width: 72, height: 72)

                            Circle()
                                .fill(Color("AccentPrimary"))
                                .frame(width: 60, height: 60)
                        }
                    }
                    .disabled(!cameraService.isAuthorized || !cameraService.isCameraAvailable || cameraService.isCapturing)
                    .opacity(cameraService.isAuthorized && cameraService.isCameraAvailable ? 1 : 0.5)

                    // Text entry option
                    Button(action: { viewModel.switchToTextEntry() }) {
                        Text("Or describe in text")
                            .font(.body)
                            .foregroundStyle(Color("TextSecondary"))
                    }

                    Spacer()
                }
                .padding(.bottom, 48)
            }

            // Close button overlay
            VStack {
                HStack {
                    Spacer()

                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(Color("TextPrimary"))
                            .padding(12)
                            .background(Color("BackgroundPrimary").opacity(0.8))
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 16)
                    .padding(.top, 8)
                }
                Spacer()
            }
        }
        .task {
            await cameraService.checkAuthorization()
            cameraService.startSession()
        }
        .onDisappear {
            cameraService.stopSession()
        }
        .alert("Camera Error", isPresented: .init(
            get: { cameraService.error != nil },
            set: { if !$0 { cameraService.clearError() } }
        )) {
            Button("OK") {
                cameraService.clearError()
            }
        } message: {
            Text(cameraService.error?.localizedDescription ?? "An error occurred")
        }
    }

    // MARK: - Actions

    private func capturePhoto() {
        Task {
            do {
                let image = try await cameraService.capturePhoto()
                viewModel.confirmPhoto(image)
            } catch {
                // Error is handled by the camera service
            }
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Text Entry View

/// Text entry alternative to photo capture
struct TextEntryView: View {

    @Bindable var viewModel: MealLoggingViewModel
    @FocusState private var isTextFieldFocused: Bool
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color("BackgroundPrimary")
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Header area with back and close buttons
                HStack {
                    Button(action: { viewModel.goBackToCapture() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(Color("TextSecondary"))
                    }

                    Spacer()

                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(Color("TextSecondary"))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)

                Spacer()

                // Icon
                Image(systemName: "text.bubble.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Color("AccentSecondary"))

                // Title
                Text("Describe your meal")
                    .font(.title2.bold())
                    .foregroundStyle(Color("TextPrimary"))

                // Text input
                TextField("e.g., Grilled chicken salad", text: $viewModel.textDescription, axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(.body)
                    .padding()
                    .background(Color("BackgroundSecondary"))
                    .cornerRadius(12)
                    .lineLimit(3...6)
                    .focused($isTextFieldFocused)
                    .padding(.horizontal, 24)

                Spacer()

                // Continue button
                Button(action: { viewModel.confirmTextEntry() }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            viewModel.textDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? Color("AccentSecondary")
                            : Color("AccentPrimary")
                        )
                        .cornerRadius(12)
                }
                .disabled(viewModel.textDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
        .onAppear {
            isTextFieldFocused = true
        }
    }
}

// MARK: - Preview

#Preview("Capture View") {
    CaptureView(
        viewModel: MealLoggingViewModel(appState: AppState()),
        onDismiss: {}
    )
}

#Preview("Text Entry") {
    TextEntryView(
        viewModel: MealLoggingViewModel(appState: AppState()),
        onDismiss: {}
    )
}
