// "What's new" sheet — runs once per distinct CFBundleShortVersionString.
//
// Version comparison is exact string equality: "1.0" and "1.0.0" are two
// different versions. If that matters, normalize your version string before
// shipping.

import YCFirstTime

func showWhatsNewIfNeeded() {
    YCFirstTime.shared.executeOncePerVersion({
        // Renders a sheet describing the changes in the current version.
        print("Showing 'What's new' for this app version.")
    }, forKey: "whats-new")
}
