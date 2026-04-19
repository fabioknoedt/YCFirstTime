// Nuke all recorded executions — in memory and on disk.
//
// Typical use: a developer-menu "Reset app state" action. After this call,
// every key behaves as if the app were freshly installed.

import YCFirstTime

func resetAppState() {
    YCFirstTime.shared.reset()
}
