import SwiftUI
import StoreKit

// MARK: - Review Prompter
/// Counts saved and shared sessions and, once the user has done
/// enough of them, asks "Enjoying USAFA Fitness?". A "Yes" hands off to Apple's
/// native review prompt; a "No" just backs off until later.
final class ReviewPrompter: ObservableObject {
    @Published var showEnjoymentPrompt = false

    /// Saves/shares required before the first ask.
    private let actionsBeforePrompt = 2
    /// Minimum days between asks.
    private let daysBetweenPrompts = 60

    private let defaults = UserDefaults.standard
    private let actionCountKey     = "review_actionCount"
    private let lastPromptDateKey  = "review_lastPromptDate"
    private let lastVersionKey     = "review_lastPromptedVersion"

    private var currentVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
    }

    /// Call after the user does something that shows they're getting value from the app.
    func recordSignificantAction() {
        let count = defaults.integer(forKey: actionCountKey) + 1
        defaults.set(count, forKey: actionCountKey)

        guard shouldPrompt(actionCount: count) else { return }

        // Small delay so the prompt doesn't collide with the action's own feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.showEnjoymentPrompt = true
        }
    }

    /// Call when the enjoyment prompt is answered (either way).
    func markPrompted() {
        defaults.set(Date(), forKey: lastPromptDateKey)
        defaults.set(currentVersion, forKey: lastVersionKey)
        defaults.set(0, forKey: actionCountKey)
    }

    private func shouldPrompt(actionCount: Int) -> Bool {
        guard actionCount >= actionsBeforePrompt else { return false }

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
