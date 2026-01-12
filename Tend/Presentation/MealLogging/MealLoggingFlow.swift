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
                NavigationStack {
                    flowContent(viewModel: viewModel)
                        .navigationBarHidden(true)
                }
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

    @ViewBuilder
    private func flowContent(viewModel: MealLoggingViewModel) -> some View {
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
}

// MARK: - Preview

#Preview {
    MealLoggingFlow()
        .environment(AppState())
}
