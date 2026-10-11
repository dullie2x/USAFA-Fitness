import SwiftUI

// MARK: - Gender Selection Model
enum FitnessGender: String, CaseIterable, Identifiable {
    case male   = "Male"
    case female = "Female"
    var id: String { rawValue }
}

// MARK: - Main View
struct FitnessScoreCalculator: View {
    @AppStorage("selectedGender") private var selectedGender: FitnessGender = .male
    @Environment(\.colorScheme) private var colorScheme
    @Namespace private var togglePill

    var body: some View {
        VStack(spacing: 0) {
            // Header bar — background bleeds into status bar, content stays in safe area
            headerBar
                .background {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea(edges: .top)
                }
                .overlay(alignment: .bottom) {
                    Divider().opacity(colorScheme == .dark ? 0.3 : 0.5)
                }

            // Both screens stay loaded side by side and slide as one, so switching
            // never rebuilds a screen mid-animation (and each keeps its scroll position).
            GeometryReader { geo in
                let width = geo.size.width
                let isMale = selectedGender == .male
                ZStack {
                    MaleScores()
                        .offset(x: isMale ? 0 : -width)
                        .allowsHitTesting(isMale)
                        .accessibilityHidden(!isMale)
                    FemaleScores()
                        .offset(x: isMale ? width : 0)
                        .allowsHitTesting(!isMale)
                        .accessibilityHidden(isMale)
                }
            }
        }
        // NOTE: No .ignoresSafeArea on outer VStack — header background handles it
    }

    // MARK: - Header Bar
    private var headerBar: some View {
        VStack(spacing: 14) {
            Spacer().frame(height: 10) // breathing room below status bar

            // Brand row
            HStack(spacing: 12) {
                Image("applogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(5)
                    .frame(width: 38, height: 38)
                    .background(Color.usafaNavyAdaptive)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.usafaGold.opacity(0.55), lineWidth: 1.5))

                VStack(alignment: .leading, spacing: 1) {
                    Text("USAFA FITNESS")
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .tracking(1.5)
                        .foregroundColor(.primary)
                    Text("Score Calculator")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .tracking(0.5)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal, 20)

            // Gender toggle
            genderToggle
                .padding(.horizontal, 20)
                .padding(.bottom, 14)
        }
    }

    // MARK: - Gender Toggle (custom pill)
    private var genderToggle: some View {
        HStack(spacing: 0) {
            ForEach(FitnessGender.allCases) { gender in
                Button {
                    guard gender != selectedGender else { return }
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                        selectedGender = gender
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: gender == .male ? "figure.stand" : "figure.stand.dress")
                            .font(.system(size: 13, weight: .semibold))
                        Text(gender.rawValue)
                            .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background {
                        // One pill that slides between options instead of two that cross-fade
                        if selectedGender == gender {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.usafaNavyAdaptive)
                                .matchedGeometryEffect(id: "pill", in: togglePill)
                        }
                    }
                    .foregroundColor(selectedGender == gender ? .white : .secondary)
                }
                .modifier(SensoryFeedbackModifier(trigger: selectedGender))
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(UIColor.tertiarySystemBackground))
                .shadow(color: .black.opacity(colorScheme == .dark ? 0.0 : 0.08), radius: 4, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.primary.opacity(colorScheme == .dark ? 0.12 : 0.0), lineWidth: 0.5)
        )
    }
}

// MARK: - Sensory Feedback Helper
struct SensoryFeedbackModifier<T: Equatable>: ViewModifier {
    var trigger: T
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content.sensoryFeedback(.selection, trigger: trigger)
        } else {
            content
        }
    }
}

// MARK: - Previews
#Preview("Male") {
    FitnessScoreCalculator()
        .environmentObject(FitnessHistory())
        .environmentObject(ReviewPrompter())
}
#Preview("Female") {
    FitnessScoreCalculator()
        .environmentObject(FitnessHistory())
        .environmentObject(ReviewPrompter())
        .onAppear { UserDefaults.standard.set("Female", forKey: "selectedGender") }
}
#Preview("Dark Mode") {
    FitnessScoreCalculator()
        .environmentObject(FitnessHistory())
        .environmentObject(ReviewPrompter())
        .preferredColorScheme(.dark)
}
