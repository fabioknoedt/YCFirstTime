// Display "last asked N days ago" for a rate-limited prompt.
//
// `lastExecutionDate(forKey:)` returns the stored timestamp of the most
// recent successful execution, or nil if the key has never run. It's a
// pure read — calling it does not mark anything as executed.

import Foundation
import YCFirstTime

func describeRatingPromptRecency() -> String {
    guard let lastAsked = YCFirstTime.shared.lastExecutionDate(forKey: "prompt.rating") else {
        return "Never asked."
    }
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .full
    return "Last asked \(formatter.localizedString(for: lastAsked, relativeTo: Date()))"
}
