// Inspect whether a key has ever fired, without side effects.
//
// `blockWasExecuted` ignores version and interval — it only answers
// "has this key ever been marked executed?".

import YCFirstTime

func describeOnboardingState() {
    if YCFirstTime.shared.blockWasExecuted("onboarding.v1") {
        print("User has seen onboarding at least once.")
    } else {
        print("Fresh install; onboarding not yet shown.")
    }
}
