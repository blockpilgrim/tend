//
//  ProgressView.swift
//  Tend
//
//  View displaying adherence data, meal history, and diet settings.
//

import SwiftUI

struct ProgressView: View {

    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Weekly summary card
                    WeeklySummaryCard(stats: appState.adherenceStats)

                    // Time period stats
                    TimePeriodStats(stats: appState.adherenceStats)

                    // Meal history placeholder
                    MealHistorySection()

                    // Diet selection card
                    DietSelectionCard(goal: appState.currentGoal)
                }
                .padding()
            }
            .background(Color("BackgroundSecondary"))
            .navigationTitle("Progress")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
    }
}

struct WeeklySummaryCard: View {
    let stats: AdherenceStats

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("This Week")
                    .font(.headline)
                    .foregroundStyle(Color("TextPrimary"))
                Spacer()
                Text("\(Int(stats.weekPercentage * 100))%")
                    .font(.title2.bold())
                    .foregroundStyle(Color("AccentPrimary"))
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color("BackgroundPrimary"))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color("AccentPrimary"))
                        .frame(width: geometry.size.width * stats.weekPercentage, height: 8)
                }
            }
            .frame(height: 8)

            Text(stats.weekCount.formatted + " meals on track")
                .font(.caption)
                .foregroundStyle(Color("TextSecondary"))
        }
        .padding()
        .background(Color("BackgroundPrimary"))
        .cornerRadius(16)
    }
}

struct TimePeriodStats: View {
    let stats: AdherenceStats

    var body: some View {
        HStack(spacing: 12) {
            StatColumn(
                title: "Today",
                percentage: stats.todayPercentage,
                count: stats.todayCount
            )
            StatColumn(
                title: "Yesterday",
                percentage: stats.yesterdayPercentage,
                count: stats.yesterdayCount
            )
            StatColumn(
                title: "This Week",
                percentage: stats.weekPercentage,
                count: stats.weekCount
            )
        }
    }
}

struct StatColumn: View {
    let title: String
    let percentage: CGFloat
    let count: MealCount

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(Color("TextSecondary"))
            Text("\(Int(percentage * 100))%")
                .font(.title3.bold())
                .foregroundStyle(Color("TextPrimary"))
            Text(count.formatted)
                .font(.caption2)
                .foregroundStyle(Color("TextSecondary"))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color("BackgroundPrimary"))
        .cornerRadius(12)
    }
}

struct MealHistorySection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Meal History")
                .font(.headline)
                .foregroundStyle(Color("TextPrimary"))

            // Placeholder for meal history
            Text("Log your first meal to start tracking.")
                .font(.body)
                .foregroundStyle(Color("TextSecondary"))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 32)
        }
        .padding()
        .background(Color("BackgroundPrimary"))
        .cornerRadius(16)
    }
}

struct DietSelectionCard: View {
    let goal: DietaryGoal?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Diet")
                .font(.headline)
                .foregroundStyle(Color("TextPrimary"))

            HStack {
                Text(goal?.name ?? "Not set")
                    .font(.body)
                    .foregroundStyle(Color("TextPrimary"))
                Spacer()
                Button("Change") {}
                    .font(.caption)
                    .foregroundStyle(Color("AccentPrimary"))
            }
        }
        .padding()
        .background(Color("BackgroundPrimary"))
        .cornerRadius(16)
    }
}

#Preview {
    ProgressView()
        .environment(AppState())
}
