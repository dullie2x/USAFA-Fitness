import SwiftUI

struct FitnessScoreCalculator: View {
    @State private var isMale = true
    @Environment(\.sizeCategory) var sizeCategory
    
    var body: some View {
        // Use VStack instead of ScrollView since child views have their own ScrollViews
        VStack {
            genderSwitchButton
            
            // Use if-else with content builders to prevent loading both views simultaneously
            if isMale {
                MaleScores()
                    .transition(.opacity) // Add smooth transition when switching
                    .id("male") // Add id for better view recycling
            } else {
                FemaleScores()
                    .transition(.opacity)
                    .id("female")
            }
        }
        .padding(.horizontal, sizeCategory.isAccessibilityCategory ? 10 : 20)
    }
    
    var genderSwitchButton: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                self.isMale.toggle()
            }
        }) {
            Text(isMale ? "Switch to Female Scores" : "Switch to Male Scores")
                .font(.title)
                .foregroundColor(.white)
                .padding()
                .background(isMale ? Color.pink : Color.blue)
                .cornerRadius(10)
        }
        .padding(.vertical, 10)
    }
}

// Preview for both male and female scores
struct FitnessScoreCalculator_Previews: PreviewProvider {
    static var previews: some View {
        FitnessScoreCalculator()
    }
}
