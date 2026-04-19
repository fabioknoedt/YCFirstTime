// Two-arg form — runs block A the first time, block B on every call after.
//
// Useful for "highlight this button on first launch, show a quick tip
// thereafter" patterns where both branches live at the same call site.

import YCFirstTime

func handleFeatureTap() {
    YCFirstTime.shared.executeOnce({
        print("First tap — show the tutorial bubble.")
    }, executeAfterFirstTime: {
        print("Every subsequent tap — show a quick tip.")
    }, forKey: "feature.tutorial")
}
