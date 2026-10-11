import SwiftUI
import LinkPresentation

// MARK: - Share Card (rendered to image for sharing)

struct ShareCardView: View {
    let gender: String
    let aftScore: Int
    let pullUpScore: Int
    let jumpScore: Int
    let sitUpScore: Int
    let pushUpScore: Int
    let runScore: Int
    let date: Date

    var totalPFTScore: Int { pullUpScore + jumpScore + sitUpScore + pushUpScore + runScore }

    var body: some View {
        VStack(spacing: 0) {
            cardHeader
            cardBody
            cardFooter
        }
        .frame(width: 340)
        .background(Color(red: 0.04, green: 0.13, blue: 0.25))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    // MARK: - Header
    private var cardHeader: some View {
        HStack(spacing: 12) {
            Image("applogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(4)
                .frame(width: 36, height: 36)
                .background(Color.usafaNavy)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.usafaGold.opacity(0.5), lineWidth: 1.2))

            VStack(alignment: .leading, spacing: 1) {
                Text("USAFA FITNESS")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .tracking(1.5)
                    .foregroundColor(.white)
                Text("Score Summary  ·  \(gender)")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.4))
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.05))
    }

    // MARK: - Body
    private var cardBody: some View {
        VStack(spacing: 14) {
            // Score rings row
            HStack(spacing: 12) {
                ringView(label: "AFT", score: aftScore, maxScore: 500)
                ringView(label: "PFT", score: totalPFTScore, maxScore: 500)
            }

            // Divider
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1)

            // Events grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                eventCell(label: "1.5mi Run",    pts: aftScore,      maxPts: 500)
                eventCell(label: "Pull-Ups",     pts: pullUpScore,   maxPts: 100)
                eventCell(label: "Sit-Ups",      pts: sitUpScore,    maxPts: 100)
                eventCell(label: "Push-Ups",     pts: pushUpScore,   maxPts: 100)
                eventCell(label: "Broad Jump",   pts: jumpScore,     maxPts: 100)
                eventCell(label: "600m Run",     pts: runScore,      maxPts: 100)
            }
        }
        .padding(16)
    }

    // MARK: - Footer
    private var cardFooter: some View {
        HStack {
            Text(date.formatted(date: .abbreviated, time: .omitted))
                .font(.system(size: 9, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.3))
            Spacer()
            Text("USAFA FITNESS APP")
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .tracking(1)
                .foregroundColor(Color.usafaGold.opacity(0.55))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.04))
    }

    // MARK: - Ring component
    private func ringView(label: String, score: Int, maxScore: Int) -> some View {
        let info = gradeInfo(for: score)
        let progress = min(Double(score) / Double(maxScore), 1.0)
        let color = gradeToColor(info.grade)

        return VStack(spacing: 6) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.08), lineWidth: 12)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 0) {
                    Text(label)
                        .font(.system(size: 8, weight: .bold, design: .rounded))
                        .tracking(1)
                        .foregroundColor(.white.opacity(0.4))
                    Text("\(score)")
                        .font(.system(size: 22, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    Text(info.grade)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(color)
                    Text(String(format: "%.1f pts", info.pointScale))
                        .font(.system(size: 8, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.3))
                }
            }
            .frame(width: 90, height: 90)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    // MARK: - Event cell
    private func eventCell(label: String, pts: Int, maxPts: Int) -> some View {
        let color = performanceColor(for: Double(pts) / Double(maxPts))
        return VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.35))
                .lineLimit(1)
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text("\(pts)")
                    .font(.system(size: 17, weight: .heavy, design: .rounded))
                    .foregroundColor(color)
                Text("/ \(maxPts)")
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.3))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

// MARK: - Identifiable wrapper so .sheet(item:) works with UIImage

struct ShareableImage: Identifiable {
    let id = UUID()
    let image: UIImage
    let gender: String
}

// MARK: - Activity item that provides the share sheet preview

final class ShareActivityItem: NSObject, UIActivityItemSource {
    private let image: UIImage
    private let gender: String

    init(image: UIImage, gender: String) {
        self.image  = image
        self.gender = gender
    }

    // The placeholder tells the sheet what type of data to expect
    func activityViewControllerPlaceholderItem(
        _ activityViewController: UIActivityViewController
    ) -> Any { image }

    // The actual item sent to the chosen activity
    func activityViewController(
        _ activityViewController: UIActivityViewController,
        itemForActivityType activityType: UIActivity.ActivityType?
    ) -> Any? { image }

    // The preview card shown at the top of the share sheet
    func activityViewControllerLinkMetadata(
        _ activityViewController: UIActivityViewController
    ) -> LPLinkMetadata? {
        let meta = LPLinkMetadata()
        meta.title = "USAFA Fitness Score"
        meta.imageProvider = NSItemProvider(object: image)
        return meta
    }
}

// MARK: - UIActivityViewController wrapper

struct ShareSheet: UIViewControllerRepresentable {
    let activityItem: ShareActivityItem

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [activityItem], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Helper to render ShareCardView → UIImage

@MainActor
func renderShareCard(
    gender: String,
    aftScore: Int,
    pullUpScore: Int,
    jumpScore: Int,
    sitUpScore: Int,
    pushUpScore: Int,
    runScore: Int
) -> UIImage? {
    let card = ShareCardView(
        gender: gender,
        aftScore: aftScore,
        pullUpScore: pullUpScore,
        jumpScore: jumpScore,
        sitUpScore: sitUpScore,
        pushUpScore: pushUpScore,
        runScore: runScore,
        date: Date()
    )
    let renderer = ImageRenderer(content: card)
    renderer.scale = 3.0
    return renderer.uiImage
}
