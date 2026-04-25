// RootView demonstrates the four most common YCFirstTime patterns in a
// single screen so a new reader can see all of them at once.
//
// In a real app these calls would be scattered across more meaningful
// trigger points (app launch, view appear, button tap, etc.).

import SwiftUI
import YCFirstTime

struct RootView: View {
    @State private var showOnboarding = false
    @State private var showWhatsNew = false
    @State private var lastRatingPromptDescription = "never"

    var body: some View {
        NavigationStack {
            List {
                Section("Once per install") {
                    Text("Onboarding runs the first time the app launches and never again until the install is wiped.")
                        .font(.callout).foregroundStyle(.secondary)
                }

                Section("Once per app version") {
                    Button("Show \"What's new\" maybe") {
                        YCFirstTime.shared.executeOncePerVersion({
                            showWhatsNew = true
                        }, forKey: "demo.whats-new")
                    }
                    Text("Fires once per CFBundleShortVersionString. Bump the build's version to see it fire again.")
                        .font(.callout).foregroundStyle(.secondary)
                }

                Section("Once per N days") {
                    Button("Ask for rating") {
                        YCFirstTime.shared.executeOncePerInterval({
                            // Real apps would call SKStoreReviewController.requestReview here.
                            print("[demo] Rating prompt fired.")
                        }, forKey: "demo.prompt.rating", withDaysInterval: 7)
                        refreshLastRatingDescription()
                    }
                    HStack {
                        Text("Last asked")
                        Spacer()
                        Text(lastRatingPromptDescription).foregroundStyle(.secondary)
                    }
                }

                Section("Debug") {
                    Button(role: .destructive) {
                        YCFirstTime.shared.reset()
                        refreshLastRatingDescription()
                    } label: {
                        Text("Reset all YCFirstTime state")
                    }
                }
            }
            .navigationTitle("YCFirstTime demo")
        }
        .sheet(isPresented: $showOnboarding) {
            OnboardingSheet { showOnboarding = false }
        }
        .sheet(isPresented: $showWhatsNew) {
            VStack(spacing: 16) {
                Text("What's new in this version").font(.title2)
                Text("Anything you want to highlight goes here.")
                Button("Got it") { showWhatsNew = false }
            }.padding()
        }
        .task {
            // Run-once-per-install onboarding, kicked off as soon as the
            // root view appears.
            YCFirstTime.shared.executeOnce({
                showOnboarding = true
            }, forKey: "demo.onboarding.v1")
            refreshLastRatingDescription()
        }
    }

    private func refreshLastRatingDescription() {
        guard let last = YCFirstTime.shared.lastExecutionDate(forKey: "demo.prompt.rating") else {
            lastRatingPromptDescription = "never"
            return
        }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        lastRatingPromptDescription = formatter.localizedString(for: last, relativeTo: Date())
    }
}

private struct OnboardingSheet: View {
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("Welcome").font(.largeTitle.bold())
            Text("This sheet is shown exactly once per install.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Continue", action: onDismiss).buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
