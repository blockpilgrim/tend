//
//  ProgressView.swift
//  Tend
//
//  View displaying adherence data, meal history, and diet settings.
//

import SwiftUI
import SwiftData
import UIKit

struct ProgressView: View {

    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MealEntity.timestamp, order: .reverse) private var meals: [MealEntity]

    @State private var isShowingDietSelection = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Weekly summary card
                    WeeklySummaryCard(stats: appState.adherenceStats)

                    // Time period stats
                    TimePeriodStats(stats: appState.adherenceStats)

                    // Meal history
                    MealHistorySection(meals: meals)

                    // Diet selection card
                    DietSelectionCard(goal: appState.currentGoal, onChange: { isShowingDietSelection = true })
                }
                .padding()
            }
            .background(Color("BackgroundSecondary"))
            .navigationTitle("Progress")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        SettingsView(appState: appState)
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingDietSelection) {
            DietGoalSelectionSheet(
                currentGoal: appState.currentGoal,
                onSelect: { goal in
                    appState.updateDietaryGoal(goal, context: modelContext)
                }
            )
        }
    }
}

struct WeeklySummaryCard: View {
    let stats: AdherenceStats

    var body: some View {
        let hasMeals = stats.weekCount.hasMeals
        let progress = hasMeals ? stats.weekPercentage : 0

        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("This Week")
                    .font(.headline)
                    .foregroundStyle(Color("TextPrimary"))
                Spacer()
                Text(hasMeals ? "\(Int(stats.weekPercentage * 100))%" : "—")
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
                        .frame(width: geometry.size.width * progress, height: 8)
                }
            }
            .frame(height: 8)

            if hasMeals {
                Text("\(stats.weekCount.formatted) meals on track")
                    .font(.caption)
                    .foregroundStyle(Color("TextSecondary"))
            } else {
                Text("Start logging to see your weekly progress.")
                    .font(.caption)
                    .foregroundStyle(Color("TextSecondary"))
            }
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
        let hasMeals = count.hasMeals

        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(Color("TextSecondary"))
            Text(hasMeals ? "\(Int(percentage * 100))%" : "—")
                .font(.title3.bold())
                .foregroundStyle(Color("TextPrimary"))
            Text(hasMeals ? count.formatted : "No meals")
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
    let meals: [MealEntity]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Meal History")
                .font(.headline)
                .foregroundStyle(Color("TextPrimary"))

            if meals.isEmpty {
                Text("Log your first meal to start tracking your progress.")
                    .font(.body)
                    .foregroundStyle(Color("TextSecondary"))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 32)
            } else {
                VStack(spacing: 12) {
                    ForEach(meals, id: \.id) { meal in
                        MealHistoryRow(meal: meal)
                    }
                }
            }
        }
        .padding()
        .background(Color("BackgroundPrimary"))
        .cornerRadius(16)
    }
}

struct MealHistoryRow: View {
    let meal: MealEntity

    var body: some View {
        HStack(spacing: 12) {
            MealThumbnail(photoFilename: meal.photoFilename, hasTextDescription: hasTextDescription)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("TextPrimary"))
                    .lineLimit(1)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Color("TextSecondary"))
                    .lineLimit(1)
            }

            Spacer(minLength: 12)

            AdherenceBadge(isOnTrack: meal.isOnTrack)
        }
        .padding(12)
        .background(Color("BackgroundSecondary"))
        .cornerRadius(12)
    }

    private var hasTextDescription: Bool {
        let trimmed = meal.textDescription?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return !trimmed.isEmpty
    }

    private var title: String {
        if hasTextDescription {
            return meal.textDescription!.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return meal.photoFilename != nil ? "Photo logged" : "Meal logged"
    }

    private var subtitle: String {
        let date = meal.timestamp
        let time = date.formatted(date: .omitted, time: .shortened)
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            return "Today, \(time)"
        }
        if calendar.isDateInYesterday(date) {
            return "Yesterday, \(time)"
        }
        return date.formatted(date: .abbreviated, time: .shortened)
    }
}

struct MealThumbnail: View {
    let photoFilename: String?
    let hasTextDescription: Bool

    @State private var image: UIImage?
    private let photoStorage = PhotoStorageService()

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color("BackgroundPrimary"))

            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
            } else {
                Image(systemName: placeholderSymbol)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color("TextSecondary"))
            }
        }
        .frame(width: 52, height: 52)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .task(id: photoFilename) {
            guard let photoFilename else {
                image = nil
                return
            }
            image = await photoStorage.load(filename: photoFilename)
        }
    }

    private var placeholderSymbol: String {
        if photoFilename != nil {
            return "photo"
        }
        return hasTextDescription ? "text.bubble" : "fork.knife"
    }
}

struct AdherenceBadge: View {
    let isOnTrack: Bool

    var body: some View {
        Text(isOnTrack ? "On track" : "Off track")
            .font(.caption.weight(.semibold))
            .foregroundStyle(isOnTrack ? .white : Color("TextPrimary"))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isOnTrack ? Color("Success") : Color("Neutral"))
            .clipShape(Capsule())
    }
}

struct DietSelectionCard: View {
    let goal: DietaryGoal?
    let onChange: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Diet")
                .font(.headline)
                .foregroundStyle(Color("TextPrimary"))

            HStack {
                Text(goalTitle)
                    .font(.body)
                    .foregroundStyle(Color("TextPrimary"))
                Spacer()
                Button("Change", action: onChange)
                    .font(.caption)
                    .foregroundStyle(Color("AccentPrimary"))
            }
        }
        .padding()
        .background(Color("BackgroundPrimary"))
        .cornerRadius(16)
    }

    private var goalTitle: String {
        guard let goal else { return "Not set" }
        if goal.isCustom, let description = goal.customDescription?.trimmingCharacters(in: .whitespacesAndNewlines), !description.isEmpty {
            return description
        }
        return goal.name
    }
}

struct DietGoalSelectionSheet: View {

    let currentGoal: DietaryGoal?
    let onSelect: (DietaryGoal) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var isShowingCustomGoalSheet = false
    @State private var customGoalDescription: String = ""

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(DietaryGoal.presets) { goal in
                        DietGoalButton(
                            title: goal.name,
                            isSelected: isSelected(goal),
                            action: {
                                onSelect(goal)
                                dismiss()
                            }
                        )
                    }

                    Button {
                        customGoalDescription = (currentGoal?.isCustom == true) ? (currentGoal?.customDescription ?? "") : ""
                        isShowingCustomGoalSheet = true
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Custom goal...")
                                .font(.subheadline)
                                .foregroundStyle(isCustomSelected ? .white : Color("TextPrimary"))

                            if isCustomSelected, let description = currentGoal?.customDescription, !description.isEmpty {
                                Text(description)
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.9))
                                    .lineLimit(2)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(isCustomSelected ? Color("AccentPrimary") : Color("BackgroundSecondary"))
                        .cornerRadius(12)
                    }
                    .gridCellColumns(2)
                }
                .padding()
            }
            .background(Color("BackgroundPrimary"))
            .navigationTitle("Your Diet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .sheet(isPresented: $isShowingCustomGoalSheet) {
            CustomDietGoalEntrySheet(
                initialDescription: customGoalDescription,
                onSave: { description in
                    onSelect(.custom(description: description))
                    dismiss()
                }
            )
        }
    }

    private var isCustomSelected: Bool {
        currentGoal?.isCustom == true
    }

    private func isSelected(_ goal: DietaryGoal) -> Bool {
        guard let currentGoal else { return false }
        return currentGoal.isCustom == goal.isCustom && currentGoal.name == goal.name
    }
}

private struct DietGoalButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(isSelected ? .white : Color("TextPrimary"))
                .frame(maxWidth: .infinity)
                .padding()
                .background(isSelected ? Color("AccentPrimary") : Color("BackgroundSecondary"))
                .cornerRadius(12)
        }
    }
}

private struct CustomDietGoalEntrySheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var description: String
    let onSave: (String) -> Void

    init(initialDescription: String, onSave: @escaping (String) -> Void) {
        _description = State(initialValue: initialDescription)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Describe your goal", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                } footer: {
                    Text("Examples: 'Whole foods, no late-night snacks' or 'Keto except weekends'.")
                }
            }
            .navigationTitle("Custom Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trimmed = description.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        onSave(trimmed)
                        dismiss()
                    }
                    .disabled(description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

struct SettingsView: View {

    @Bindable var appState: AppState
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        List {
            Section("Account") {
                LabeledContent("Status") {
                    Text("Not signed in")
                        .foregroundStyle(Color("TextSecondary"))
                }
            }

            Section("Preferences") {
                Toggle(isOn: $appState.soundEnabled) {
                    Text("Sound")
                        .foregroundStyle(Color("TextPrimary"))
                }
                .tint(Color("AccentPrimary"))
                .onChange(of: appState.soundEnabled) { _ in
                    appState.persistUserSettings(context: modelContext)
                }

                Toggle(isOn: $appState.hapticsEnabled) {
                    Text("Haptics")
                        .foregroundStyle(Color("TextPrimary"))
                }
                .tint(Color("AccentPrimary"))
                .onChange(of: appState.hapticsEnabled) { _ in
                    appState.persistUserSettings(context: modelContext)
                }
            }

            Section("Subscription") {
                LabeledContent("Plan") {
                    Text(appState.isPremium ? "Premium" : "Free")
                        .foregroundStyle(Color("TextSecondary"))
                }
                Button("Manage Subscription") {}
                    .foregroundStyle(Color("AccentPrimary"))
            }

            Section("Support") {
                Button("Help") {}
                    .foregroundStyle(Color("AccentPrimary"))
                Button("Contact Support") {}
                    .foregroundStyle(Color("AccentPrimary"))
                Button("Privacy Policy") {}
                    .foregroundStyle(Color("AccentPrimary"))
                Button("Terms") {}
                    .foregroundStyle(Color("AccentPrimary"))
            }

            Section("About") {
                LabeledContent("Version") {
                    Text(versionString)
                        .foregroundStyle(Color("TextSecondary"))
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color("BackgroundSecondary"))
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var versionString: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String

        switch (version, build) {
        case let (.some(version), .some(build)):
            return "\(version) (\(build))"
        case let (.some(version), .none):
            return version
        default:
            return "—"
        }
    }
}

#Preview {
    ProgressView()
        .environment(AppState())
}
