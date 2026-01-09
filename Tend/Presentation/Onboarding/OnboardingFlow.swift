//
//  OnboardingFlow.swift
//  Tend
//
//  Onboarding flow for new users.
//

import SwiftUI

struct OnboardingFlow: View {

    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @State private var currentStep: OnboardingStep = .welcome
    @State private var selectedGoal: DietaryGoal?

    enum OnboardingStep {
        case welcome
        case selectDiet
        case meetCore
        case firstLog
    }

    var body: some View {
        ZStack {
            Color("BackgroundPrimary")
                .ignoresSafeArea()

            switch currentStep {
            case .welcome:
                WelcomeStep(onContinue: { currentStep = .selectDiet })

            case .selectDiet:
                DietSelectionStep(
                    selectedGoal: $selectedGoal,
                    onContinue: { currentStep = .meetCore }
                )

            case .meetCore:
                MeetCoreStep(onContinue: { currentStep = .firstLog })

            case .firstLog:
                FirstLogStep(
                    onLogMeal: { completeOnboarding() },
                    onSkip: { completeOnboarding() }
                )
            }
        }
    }

    private func completeOnboarding() {
        guard let goal = selectedGoal else { return }
        appState.completeOnboarding(with: goal, context: modelContext)
    }
}

struct WelcomeStep: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "flame.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color("AccentPrimary"))

            Text("Tend")
                .font(.largeTitle.bold())
                .foregroundStyle(Color("TextPrimary"))

            Text("Tend to your fire.")
                .font(.title3)
                .foregroundStyle(Color("TextPrimary"))

            Text("A living ember that glows when you eat well and dims when you don't. No spreadsheets. No shame. Just something alive.")
                .font(.body)
                .foregroundStyle(Color("TextSecondary"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()

            Button("Get Started", action: onContinue)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("AccentPrimary"))
                .cornerRadius(12)
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
        }
    }
}

struct DietSelectionStep: View {
    @Binding var selectedGoal: DietaryGoal?
    let onContinue: () -> Void

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(spacing: 24) {
            Text("What's your dietary goal?")
                .font(.title2.bold())
                .foregroundStyle(Color("TextPrimary"))
                .padding(.top, 48)

            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(DietaryGoal.presets) { goal in
                        GoalButton(
                            goal: goal,
                            isSelected: selectedGoal?.id == goal.id,
                            action: { selectedGoal = goal }
                        )
                    }
                }
                .padding(.horizontal)
            }

            Spacer()

            Button("Continue", action: onContinue)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(selectedGoal != nil ? Color("AccentPrimary") : Color("AccentSecondary"))
                .cornerRadius(12)
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
                .disabled(selectedGoal == nil)
        }
    }
}

struct GoalButton: View {
    let goal: DietaryGoal
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(goal.name)
                .font(.subheadline)
                .foregroundStyle(isSelected ? .white : Color("TextPrimary"))
                .frame(maxWidth: .infinity)
                .padding()
                .background(isSelected ? Color("AccentPrimary") : Color("BackgroundSecondary"))
                .cornerRadius(12)
        }
    }
}

struct MeetCoreStep: View {
    let onContinue: () -> Void
    @State private var hasInteracted = false

    var body: some View {
        VStack(spacing: 24) {
            Text("This is your Core.")
                .font(.title2.bold())
                .foregroundStyle(Color("TextPrimary"))
                .padding(.top, 48)

            Spacer()

            // Core placeholder
            CorePlaceholderView(state: .neutral)
                .onTapGesture {
                    hasInteracted = true
                }

            Spacer()

            Text("It reflects your inner vitality. Eat well, and watch it glow. Drift, and it dims—waiting to be rekindled.")
                .font(.body)
                .foregroundStyle(Color("TextSecondary"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            if hasInteracted {
                Button("Continue", action: onContinue)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("AccentPrimary"))
                    .cornerRadius(12)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 48)
            } else {
                Text("Try tapping it")
                    .font(.caption)
                    .foregroundStyle(Color("AccentPrimary"))
                    .padding(.bottom, 48)
            }
        }
    }
}

struct FirstLogStep: View {
    let onLogMeal: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color("AccentPrimary"))

            Text("You're all set.")
                .font(.title2.bold())
                .foregroundStyle(Color("TextPrimary"))

            Text("Log your next meal to see your Core respond.")
                .font(.body)
                .foregroundStyle(Color("TextSecondary"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()

            VStack(spacing: 12) {
                Button("Log First Meal", action: onLogMeal)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("AccentPrimary"))
                    .cornerRadius(12)

                Button("I'll do it later", action: onSkip)
                    .font(.subheadline)
                    .foregroundStyle(Color("TextSecondary"))
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 48)
        }
    }
}

#Preview {
    OnboardingFlow()
        .environment(AppState())
}
