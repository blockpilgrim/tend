//
//  ConfirmationView.swift
//  Tend
//
//  Meal confirmation screen with on/off track tagging.
//

import SwiftUI

/// Confirmation screen for tagging a meal as on or off track.
/// Displays the captured photo or text description and prompts for adherence tagging.
struct ConfirmationView: View {

    @Bindable var viewModel: MealLoggingViewModel
    let onComplete: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color("BackgroundPrimary")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with back and close buttons
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

                // Content preview
                Group {
                    if viewModel.inputMode == .photo, let image = viewModel.capturedImage {
                        // Photo preview
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: UIScreen.main.bounds.height * 0.4)
                            .clipped()
                            .cornerRadius(16)
                            .padding(.horizontal, 16)
                            .padding(.top, 24)
                    } else {
                        // Text preview
                        VStack(spacing: 16) {
                            Image(systemName: "text.bubble.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(Color("AccentSecondary"))

                            Text(viewModel.textDescription)
                                .font(.title3)
                                .foregroundStyle(Color("TextPrimary"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }
                        .frame(height: UIScreen.main.bounds.height * 0.3)
                        .frame(maxWidth: .infinity)
                        .background(Color("BackgroundSecondary"))
                        .cornerRadius(16)
                        .padding(.horizontal, 16)
                        .padding(.top, 24)
                    }
                }

                Spacer()

                // Question
                Text("Was this meal on track with your \(viewModel.dietaryGoalName)?")
                    .font(.body)
                    .foregroundStyle(Color("TextSecondary"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 24)

                // Tagging buttons
                VStack(spacing: 12) {
                    // On Track button
                    Button(action: { logMeal(isOnTrack: true) }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("On track")
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("Success"))
                        .cornerRadius(12)
                    }
                    .disabled(viewModel.isProcessing)

                    // Off Track button
                    Button(action: { logMeal(isOnTrack: false) }) {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                            Text("Off track")
                        }
                        .font(.headline)
                        .foregroundStyle(Color("TextPrimary"))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("BackgroundSecondary"))
                        .cornerRadius(12)
                    }
                    .disabled(viewModel.isProcessing)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)

                // Processing overlay
                if viewModel.isProcessing {
                    HStack(spacing: 12) {
                        ProgressView()
                            .tint(Color("TextSecondary"))
                        Text("Saving meal...")
                            .font(.body)
                            .foregroundStyle(Color("TextSecondary"))
                    }
                    .padding(.bottom, 16)
                }
            }
        }
        .alert("Error", isPresented: .init(
            get: { viewModel.error != nil },
            set: { if !$0 { viewModel.clearError() } }
        )) {
            Button("OK") {
                viewModel.clearError()
            }
        } message: {
            Text(viewModel.error ?? "An error occurred")
        }
    }

    // MARK: - Actions

    private func logMeal(isOnTrack: Bool) {
        Task {
            let success = await viewModel.logMeal(isOnTrack: isOnTrack)
            if success {
                onComplete()
            }
        }
    }
}

// MARK: - Preview

#Preview("Photo Confirmation") {
    let viewModel = MealLoggingViewModel(appState: AppState())
    viewModel.capturedImage = UIImage(systemName: "photo")
    viewModel.inputMode = .photo
    viewModel.currentStep = .confirmation

    return ConfirmationView(
        viewModel: viewModel,
        onComplete: {},
        onDismiss: {}
    )
}

#Preview("Text Confirmation") {
    let viewModel = MealLoggingViewModel(appState: AppState())
    viewModel.textDescription = "Grilled chicken salad with olive oil dressing"
    viewModel.inputMode = .text
    viewModel.currentStep = .confirmation

    return ConfirmationView(
        viewModel: viewModel,
        onComplete: {},
        onDismiss: {}
    )
}
