import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            FitnessScoreCalculator()
                .tabItem {
                    Label("Calculator", systemImage: "figure.run")
                }

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
        }
        .tint(Color.usafaNavyAdaptive)
        .reviewPrompt()
    }
}

#Preview {
    MainTabView()
        .environmentObject(FitnessHistory())
        .environmentObject(ReviewPrompter())
}
