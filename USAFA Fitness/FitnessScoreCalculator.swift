import SwiftUI

// MARK: - Gender Selection Model
enum FitnessGender: String, CaseIterable, Identifiable {
    case male = "Male"
    case female = "Female"
    
    var id: String { rawValue }
}

// MARK: - Main View
struct FitnessScoreCalculator: View {
    @AppStorage("selectedGender") private var selectedGender: FitnessGender = .male
    @Environment(\.sizeCategory) private var sizeCategory
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            genderPicker
                .padding(.vertical, 16)
                .background(.ultraThinMaterial)
            
            // Content area with smooth transitions
            ZStack {
                if selectedGender == .male {
                    MaleScores()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                        .id("male")
                } else {
                    FemaleScores()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                        .id("female")
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedGender)
        }
        .ignoresSafeArea(edges: .top)
    }
    
    // MARK: - Gender Picker
    private var genderPicker: some View {
        VStack(spacing: 12) {
            Text("Fitness Test")
                .font(.title2.bold())
                .foregroundStyle(.primary)
            
            Picker("Gender Selection", selection: $selectedGender) {
                ForEach(FitnessGender.allCases) { gender in
                    Text(gender.rawValue)
                        .tag(gender)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, sizeCategory.isAccessibilityCategory ? 12 : 20)
            .accessibilityLabel("Select gender for fitness standards")
            .modifier(SensoryFeedbackModifier(trigger: selectedGender))
        }
    }
}

// MARK: - Helper ViewModifiers
struct SensoryFeedbackModifier<T: Equatable>: ViewModifier {
    var trigger: T
    
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .sensoryFeedback(.selection, trigger: trigger)
        } else {
            content
        }
    }
}

// MARK: - Previews
#Preview("Male Scores") {
    FitnessScoreCalculator()
}
#Preview("Female Scores") {
    var calculator = FitnessScoreCalculator()
    let _ = UserDefaults.standard.set("Female", forKey: "selectedGender")
    return calculator
}

#Preview("Accessibility - Large Text") {
    FitnessScoreCalculator()
        .environment(\.sizeCategory, .accessibilityExtraExtraLarge)
}

#Preview("Dark Mode") {
    FitnessScoreCalculator()
        .preferredColorScheme(.dark)
}

