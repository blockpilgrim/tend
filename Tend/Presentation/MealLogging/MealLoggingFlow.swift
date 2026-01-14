//
//  MealLoggingFlow.swift
//  Tend
//
//  Coordinator view for the complete meal logging flow.
//

import SwiftUI

/// Main coordinator for the meal logging flow.
/// Manages navigation between capture and confirmation screens.
struct MealLoggingFlow: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @State private var viewModel: MealLoggingViewModel?

    var body: some View {
        Group {
            if let viewModel = viewModel {
                MealLoggingFlowContent(viewModel: viewModel, dismiss: dismiss)
            } else {
                // Loading state
                ZStack {
                    Color("BackgroundPrimary")
                        .ignoresSafeArea()
                    ProgressView()
                        .tint(Color("TextSecondary"))
                }
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = MealLoggingViewModel(appState: appState)
            }
        }
    }
}

/// Internal view that properly tracks @Observable dependencies via @Bindable.
/// This separation is necessary because observation tracking doesn't work correctly
/// when an @Observable is passed through a method parameter to a @ViewBuilder.
private struct MealLoggingFlowContent: View {
    @Bindable var viewModel: MealLoggingViewModel
    let dismiss: DismissAction

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.currentStep {
                case .capture:
                    CaptureView(
                        viewModel: viewModel,
                        onDismiss: { dismiss() }
                    )
                    .transition(.opacity)

                case .textEntry:
                    TextEntryView(
                        viewModel: viewModel,
                        onDismiss: { dismiss() }
                    )
                    .transition(.move(edge: .trailing))

                case .confirmation:
                    ConfirmationView(
                        viewModel: viewModel,
                        onComplete: { dismiss() },
                        onDismiss: { dismiss() }
                    )
                    .transition(.move(edge: .trailing))
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Preview

#Preview {
    MealLoggingFlow()
        .environment(AppState())
}
