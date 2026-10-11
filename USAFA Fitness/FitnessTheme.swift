import SwiftUI

// MARK: - USAFA Color Extensions
extension Color {
    static let usafaNavy = Color("Blue")
    static let usafaGold = Color("Gold")

    /// Navy in light mode, bright sky-blue in dark mode — always readable on any background
    static let usafaNavyAdaptive = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor.systemBlue
            : (UIColor(named: "Blue") ?? UIColor(red: 0.04, green: 0.18, blue: 0.40, alpha: 1.0))
    })
}

// MARK: - Shared Grade Scale
struct FitnessGradeScale {
    let pointScale: Double
    let grade: String
    let scoreRange: ClosedRange<Int>
}

let sharedGradeScales: [FitnessGradeScale] = [
    FitnessGradeScale(pointScale: 4.0, grade: "A",   scoreRange: 476...500),
    FitnessGradeScale(pointScale: 3.7, grade: "A-",  scoreRange: 451...475),
    FitnessGradeScale(pointScale: 3.3, grade: "B+",  scoreRange: 426...450),
    FitnessGradeScale(pointScale: 3.0, grade: "B",   scoreRange: 400...425),
    FitnessGradeScale(pointScale: 2.7, grade: "B-",  scoreRange: 371...399),
    FitnessGradeScale(pointScale: 2.5, grade: "C+",  scoreRange: 331...370),
    FitnessGradeScale(pointScale: 2.3, grade: "C",   scoreRange: 291...330),
    FitnessGradeScale(pointScale: 2.0, grade: "C-",  scoreRange: 250...290),
    FitnessGradeScale(pointScale: 1.7, grade: "D+",  scoreRange: 226...249),
    FitnessGradeScale(pointScale: 1.0, grade: "D",   scoreRange: 200...225),
    FitnessGradeScale(pointScale: 0.0, grade: "F",   scoreRange: 0...199),
]

func gradeInfo(for score: Int) -> (grade: String, pointScale: Double) {
    for scale in sharedGradeScales {
        if scale.scoreRange.contains(score) {
            return (scale.grade, scale.pointScale)
        }
    }
    return ("F", 0.0)
}

func gradeToColor(_ grade: String) -> Color {
    switch grade {
    case "A", "A-":       return Color(red: 0.13, green: 0.80, blue: 0.43)  // Vivid green — best
    case "B+", "B", "B-": return Color.usafaGold                             // USAFA Gold
    case "C+", "C":       return Color(red: 0.96, green: 0.58, blue: 0.12)  // Orange
    case "C-", "D+":      return Color(red: 0.90, green: 0.38, blue: 0.10)  // Dark orange
    case "D":             return Color(red: 0.85, green: 0.20, blue: 0.20)  // Red
    case "F":             return Color(red: 0.65, green: 0.12, blue: 0.12)  // Dark red
    default:              return .secondary
    }
}

func performanceColor(for progress: Double) -> Color {
    switch progress {
    case 0.85...:     return Color(red: 0.13, green: 0.80, blue: 0.43)  // Green
    case 0.65..<0.85: return Color.usafaGold                             // Gold
    case 0.45..<0.65: return Color(red: 0.96, green: 0.58, blue: 0.12)  // Orange
    case 0.25..<0.45: return Color(red: 0.90, green: 0.38, blue: 0.10)  // Dark orange
    default:          return Color(red: 0.85, green: 0.20, blue: 0.20)  // Red
    }
}

// MARK: - Score Ring View
struct ScoreRingView: View {
    let score: Int
    let maxScore: Int
    let label: String
    let grade: String
    let pointScale: Double

    private var progress: Double {
        guard maxScore > 0 else { return 0 }
        return min(Double(score) / Double(maxScore), 1.0)
    }

    private var ringColor: Color { gradeToColor(grade) }

    var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(Color.primary.opacity(0.08), lineWidth: 16)

            // Progress arc
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: [ringColor.opacity(0.55), ringColor],
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(-90 + 360 * progress)
                    ),
                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.9, dampingFraction: 0.75), value: progress)

            // Center text
            VStack(spacing: 2) {
                Text(label.uppercased())
                    .font(.system(.caption2, design: .rounded).weight(.bold))
                    .tracking(1.5)
                    .foregroundColor(.secondary)

                Text("\(score)")
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .foregroundColor(.primary)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.4), value: score)

                if grade != "F" {
                    Text(grade)
                        .font(.system(.subheadline, design: .rounded).weight(.bold))
                        .foregroundColor(ringColor)
                        .animation(.easeInOut, value: grade)

                    Text(String(format: "%.1f pts", pointScale))
                        .font(.system(.caption2, design: .rounded))
                        .foregroundColor(.secondary)
                } else {
                    Text("/ \(maxScore)")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(6)
    }
}

// MARK: - Grade Badge
struct GradeBadge: View {
    let grade: String
    let pointScale: Double

    private var color: Color { gradeToColor(grade) }

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "star.fill")
                .font(.caption2)
            Text(grade)
                .font(.subheadline.bold())
                .lineLimit(1)
            Text("·")
                .font(.caption)
                .opacity(0.6)
            Text(String(format: "%.1f", pointScale))
                .font(.subheadline.bold())
                .lineLimit(1)
        }
        .fixedSize(horizontal: true, vertical: false)
        .foregroundColor(color)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(color.opacity(0.12))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(color.opacity(0.25), lineWidth: 1))
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.usafaNavyAdaptive)
            Text(title.uppercased())
                .font(.system(.caption, design: .rounded).weight(.bold))
                .tracking(1.2)
                .foregroundColor(.usafaNavyAdaptive)
            Spacer()
            Rectangle()
                .fill(Color.usafaNavyAdaptive.opacity(0.2))
                .frame(height: 1)
                .padding(.leading, 4)
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - Card Modifier
struct CardModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.primary.opacity(colorScheme == .dark ? 0.10 : 0.0), lineWidth: 0.5)
            )
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.0 : 0.06), radius: 8, x: 0, y: 2)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardModifier())
    }
}

// MARK: - Points Badge
struct PointsBadge: View {
    let points: Int
    let maxPoints: Int

    private var progress: Double {
        guard maxPoints > 0 else { return 0 }
        return min(Double(points) / Double(maxPoints), 1.0)
    }

    private var color: Color { performanceColor(for: progress) }

    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            Text("\(points)")
                .font(.system(.title2, design: .rounded).weight(.heavy))
                .foregroundColor(color)
                .contentTransition(.numericText())
                .animation(.spring(response: 0.3), value: points)
            Text("/ \(maxPoints)")
                .font(.system(.caption2, design: .rounded))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Mini Progress Bar
struct MiniProgressBar: View {
    let points: Int
    let maxPoints: Int

    private var progress: Double {
        guard maxPoints > 0 else { return 0 }
        return min(Double(points) / Double(maxPoints), 1.0)
    }

    private var color: Color { performanceColor(for: progress) }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.primary.opacity(0.08))
                    .frame(height: 5)
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.5), color],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(6, geo.size.width * progress), height: 5)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
            }
        }
        .frame(height: 5)
    }
}
