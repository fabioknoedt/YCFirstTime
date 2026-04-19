// Rate-this-app prompt — runs at most every 7 days.
//
// The interval is `days × 86_400` seconds. Fractional days work:
// `withDaysInterval: 0.5` = 12 hours.

import YCFirstTime

func promptForRating() {
    YCFirstTime.shared.executeOncePerInterval({
        print("Show rate-the-app prompt.")
    }, forKey: "prompt.rating", withDaysInterval: 7)
}
