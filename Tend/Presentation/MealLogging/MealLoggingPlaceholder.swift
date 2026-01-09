//
//  MealLoggingPlaceholder.swift
//  Tend
//
//  Placeholder for the meal logging flow (to be fully implemented).
//

import SwiftUI

struct MealLoggingPlaceholder: View {

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundPrimary")
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    Spacer()

                    Image(systemName: "camera.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(Color("AccentSecondary"))

                    Text("Meal Logging")
                        .font(.title2.bold())
                        .foregroundStyle(Color("TextPrimary"))

                    Text("Camera and meal confirmation flow will be implemented in the Meal Logging epic.")
                        .font(.body)
                        .foregroundStyle(Color("TextSecondary"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    Spacer()

                    Button("Close", action: { dismiss() })
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundStyle(Color("TextSecondary"))
                    }
                }
            }
        }
    }
}

#Preview {
    MealLoggingPlaceholder()
}
