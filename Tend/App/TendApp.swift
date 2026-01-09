//
//  TendApp.swift
//  Tend
//
//  Main entry point for the Tend iOS application.
//

import SwiftUI
import SwiftData

@main
struct TendApp: App {

    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(
                for: MealEntity.self,
                DietaryGoalEntity.self,
                UserSettingsEntity.self
            )
        } catch {
            fatalError("Failed to initialize model container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .modelContainer(modelContainer)
        }
    }
}

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var appState = AppState()

    var body: some View {
        Group {
            if appState.hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingFlow()
            }
        }
        .environment(appState)
        .task {
            await appState.loadSettings(context: modelContext)
        }
    }
}
