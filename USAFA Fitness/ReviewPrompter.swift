import SwiftUI
import StoreKit

// MARK: - Review Prompter
/// Asks "Enjoying USAFA Fitness?" once the user has shown they're getting value from
/// the app — either by saving/sharing sessions, or by coming back on several different
/// days, whichever happens first. A "Yes" hands off to Apple's native review prompt;
/// a "No" just backs off until later.
final class ReviewPrompter: ObservableObject {
    @Published var showEnjoymentPrompt = false

    /// Saves/shares required before asking.
    private let actionsBeforePrompt = 2
    /// Distinct days the app has been opened before asking.
    private let daysOpenedBeforePrompt = 5
    /// Minimum days between asks.
    private let daysBetweenPrompts = 60

    private let defaults = UserDefaults.standard
    private let actionCountKey     = "review_actionCount"
    private let daysOpenedKey      = "review_daysOpened"
    private let lastOpenDayKey     = "review_lastOpenDay"
    private let lastPromptDateKey  = "review_lastPromptDate"
    private let lastVersionKey     = "review_lastPromptedVersion"

    private var currentVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
    }

    /// Call after the user does something that shows they're getting value from the app.
    func recordSignificantAction() {
        defaults.set(defaults.integer(forKey: actionCountKey) + 1, forKey: actionCountKey)
        // Small delay so the prompt doesn't collide with the action's own feedback
        promptIfEligible(after: 1.2)
    }

    /// Call whenever the app comes to the foreground. Only the first open of each
    /// calendar day counts. Pass `allowPrompt: false` when something else (like an ad)
    /// is about to take over the screen.
    func recordAppOpen(allowPrompt: Bool = true) {
        let today = Calendar.current.startOfDay(for: Date())
        if let lastDay = defaults.object(forKey: lastOpenDayKey) as? Date, lastDay >= today {
            return  // already counted today
        }
        defaults.set(today, forKey: lastOpenDayKey)
        defaults.set(defaults.integer(forKey: daysOpenedKey) + 1, forKey: daysOpenedKey)

        if allowPrompt { promptIfEligible(after: 1.5) }
    }

    /// Call when the enjoyment prompt is answered (either way).
    func markPrompted() {
        defaults.set(Date(), forKey: lastPromptDateKey)
        defaults.set(currentVersion, forKey: lastVersionKey)
        defaults.set(0, forKey: actionCountKey)
        defaults.set(0, forKey: daysOpenedKey)
    }

    private func promptIfEligible(after delay: TimeInterval) {
        guard shouldPrompt() else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.showEnjoymentPrompt = true
        }
    }

    private func shouldPrompt() -> Bool {
        let enoughActions = defaults.integer(forKey: actionCountKey) >= actionsBeforePrompt
        let enoughDays    = defaults.integer(forKey: daysOpenedKey) >= daysOpenedBeforePrompt
        guard enoughActions || enoughDays else { return false }

        // Only ask once per app version
        if defaults.string(forKey: lastVersionKey) == currentVersion { return false }

        // And not too often
        if let last = defaults.object(forKey: lastPromptDateKey) as? Date,
           let days = Calendar.current.dateComponents([.day], from: last, to: Date()).day,
           days < daysBetweenPrompts {
            return false
        }
        return true
    }
}

// MARK: - Enjoyment Alert Modifier
struct ReviewPromptModifier: ViewModifier {
    @EnvironmentObject var reviewPrompter: ReviewPrompter
    @Environment(\.requestReview) private var requestReview

    func body(content: Content) -> some View {
        content
            .alert("Enjoying USAFA Fitness?", isPresented: $reviewPrompter.showEnjoymentPrompt) {
                Button("Not Really", role: .cancel) {
                    reviewPrompter.markPrompted()
                }
                Button("Yes!") {
                    reviewPrompter.markPrompted()
                    requestReview()
                }
            } message: {
                Text("Your feedback helps other cadets find the app.")
            }
    }
}

extension View {
    func reviewPrompt() -> some View {
        modifier(ReviewPromptModifier())
    }
}
