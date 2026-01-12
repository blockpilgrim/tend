//
//  CoreView.swift
//  Tend
//
//  Primary view displaying the Radiant Core with fidget interactions.
//

import SwiftUI

struct CoreView: View {

    @Environment(AppState.self) private var appState
    @State private var isShowingMealLogger = false

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color("BackgroundPrimary"), Color("BackgroundPrimary").opacity(0.95)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Radiant Core SpriteKit scene
                SpriteKitContainer(coreState: appState.coreState)
                    .frame(maxWidth: .infinity)
                    .frame(height: UIScreen.main.bounds.height * 0.6)

                // Status text
                Text(statusText)
                    .font(.body)
                    .foregroundStyle(Color("TextSecondary"))
                    .padding(.top, 24)

                Spacer()

                // Log Meal button
                Button(action: { isShowingMealLogger = true }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Log Meal")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(Color("AccentPrimary"))
                    .clipShape(Capsule())
                }
                .padding(.bottom, 24)
            }
        }
        .fullScreenCover(isPresented: $isShowingMealLogger) {
            MealLoggingPlaceholder()
        }
    }

    private var statusText: String {
        let stats = appState.adherenceStats
        if stats.todayCount.total == 0 {
            return "No meals logged yet today."
        }
        return "\(stats.todayCount.onTrack) of \(stats.todayCount.total) meals on track today"
    }
}

/// Placeholder for the Core until SpriteKit implementation
struct CorePlaceholderView: View {
    let state: CoreState

    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [coreColor.opacity(0.3), .clear],
                        center: .center,
                        startRadius: 50,
                        endRadius: 150
                    )
                )
                .frame(width: 300, height: 300)

            // Core body
            Circle()
                .fill(
                    RadialGradient(
                        colors: [coreColor, coreColor.opacity(0.7)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 60
                    )
                )
                .frame(width: 120, height: 120)
                .shadow(color: coreColor.opacity(0.5), radius: 20)

            // State indicator
            Text(state.tier.description)
                .font(.caption)
                .foregroundStyle(Color("TextSecondary"))
                .offset(y: 100)
        }
    }

    private var coreColor: Color {
        switch state.tier {
        case .blazing: return Color("RadiantGlow")
        case .warm: return Color("RadiantGlow").opacity(0.85)
        case .smoldering: return Color("AccentSecondary")
        case .dim: return Color("DimGlow")
        case .cold: return Color("DimInnerCore")
        }
    }
}

#Preview {
    CoreView()
        .environment(AppState())
}
