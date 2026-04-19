// Onboarding / DB seed — runs exactly once per install, ever.
//
// The key is global across the app; pick something descriptive. If you need
// to re-run this block on every install (e.g. you re-released the app), add
// a version suffix to the key: "onboarding.v2".

import YCFirstTime

func runOnboardingIfNeeded() {
    YCFirstTime.shared.executeOnce({
        // Put the work here — show a modal, seed a DB, log a one-time event.
        print("Running onboarding for the first time.")
    }, forKey: "onboarding.v1")
}
