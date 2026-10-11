import SwiftUI
import Charts

struct HistoryView: View {
    @EnvironmentObject var history: FitnessHistory
    @State private var showingClearAlert = false

    var body: some View {
        NavigationStack {
            Group {
                if history.sessions.isEmpty {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 14) {
                            statsRow
                            chartCard
                            sessionsList
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 40)
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if !history.sessions.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Clear All") { showingClearAlert = true }
                            .foregroundColor(.red)
                            .font(.system(.subheadline, design: .rounded).weight(.medium))
                    }
                }
            }
            .alert("Clear All History?", isPresented: $showingClearAlert) {
                Button("Clear", role: .destructive) { history.clearAll() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete all saved sessions.")
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.badge.xmark")
                .font(.system(size: 52, weight: .light))
                .foregroundColor(Color.usafaNavyAdaptive.opacity(0.25))
            Text("No Sessions Saved")
                .font(.system(.title3, design: .rounded).weight(.bold))
                .foregroundColor(.primary)
            Text("After calculating your scores, tap\n\"Save Session\" to track your progress.")
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: 10) {
            statCard(
                label: "Sessions",
                value: "\(history.sessions.count)",
                icon: "list.bullet.clipboard",
                color: Color.usafaNavyAdaptive
            )
            statCard(
                label: "Best PFT",
                value: history.personalBestPFT.map { "\($0.totalPFTScore)" } ?? "—",
                icon: "trophy.fill",
                color: Color(red: 0.13, green: 0.80, blue: 0.43)
            )
            statCard(
                label: "Best AFT",
                value: history.personalBestAFT.map { "\($0.aftScore)" } ?? "—",
                icon: "flame.fill",
                color: Color.usafaGold
            )
        }
    }

    private func statCard(label: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)
            Text(value)
                .font(.system(.title2, design: .rounded).weight(.heavy))
                .foregroundColor(.primary)
            Text(label)
                .font(.system(.caption2, design: .rounded).weight(.semibold))
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    // MARK: - Chart Card

    private var chartCard: some View {
        let chartSessions = Array(history.sessions.prefix(8).reversed())

        return VStack(alignment: .leading, spacing: 6) {
            Text("PFT Score Trend")
                .font(.system(.subheadline, design: .rounded).weight(.bold))
                .foregroundColor(.primary)
            Text("Last \(chartSessions.count) sessions")
                .font(.system(.caption2, design: .rounded))
                .foregroundColor(.secondary)

            Chart(chartSessions) { session in
                AreaMark(
                    x: .value("Date", session.date),
                    y: .value("Score", session.totalPFTScore)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.usafaNavyAdaptive.opacity(0.15), Color.usafaNavyAdaptive.opacity(0.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)

                LineMark(
                    x: .value("Date", session.date),
                    y: .value("Score", session.totalPFTScore)
                )
                .foregroundStyle(Color.usafaNavyAdaptive)
                .lineStyle(StrokeStyle(lineWidth: 2))
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("Date", session.date),
                    y: .value("Score", session.totalPFTScore)
                )
                .foregroundStyle(gradeToColor(gradeInfo(for: session.totalPFTScore).grade))
                .symbolSize(40)
            }
            .chartYScale(domain: 0...500)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel {
                            Text(date, format: .dateTime.month(.abbreviated).day())
                                .font(.system(size: 8, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: [0, 200, 350, 425, 500]) { value in
                    AxisValueLabel {
                        if let v = value.as(Int.self) {
                            Text("\(v)")
                                .font(.system(size: 8, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [3]))
                        .foregroundStyle(Color.primary.opacity(0.07))
                }
            }
            .frame(height: 130)
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Sessions List

    private var sessionsList: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Section label
            HStack(spacing: 8) {
                Text("Sessions")
                    .font(.system(.caption, design: .rounded).weight(.bold))
                    .tracking(1)
                    .textCase(.uppercase)
                    .foregroundColor(.usafaNavyAdaptive)
                Rectangle()
                    .fill(Color.usafaNavyAdaptive.opacity(0.15))
                    .frame(height: 1)
            }

            ForEach(history.sessions) { session in
                sessionRow(session)
            }
        }
    }

    private func sessionRow(_ session: FitnessSession) -> some View {
        let pftInfo = gradeInfo(for: session.totalPFTScore)
        let aftInfo = gradeInfo(for: session.aftScore)
        let isPBPFT = history.personalBestPFT?.id == session.id
        let isPBAFT = history.personalBestAFT?.id == session.id

        return HStack(spacing: 12) {
            // Color dot
            Circle()
                .fill(gradeToColor(pftInfo.grade))
                .frame(width: 10, height: 10)

            // Info
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(session.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(.caption, design: .rounded).weight(.semibold))
                        .foregroundColor(.secondary)
                    Text(session.gender)
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.usafaNavyAdaptive.opacity(0.7))
                        .clipShape(Capsule())
                    if isPBPFT || isPBAFT {
                        Text("PB")
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.usafaGold)
                            .clipShape(Capsule())
                    }
                }
                Text("AFT \(session.aftScore)  ·  PFT \(session.totalPFTScore)")
                    .font(.system(.subheadline, design: .rounded).weight(.bold))
                    .foregroundColor(.primary)
            }

            Spacer()

            // Grade + GPA
            VStack(alignment: .trailing, spacing: 2) {
                Text(pftInfo.grade)
                    .font(.system(.title3, design: .rounded).weight(.heavy))
                    .foregroundColor(gradeToColor(pftInfo.grade))
                Text(String(format: "%.1f pts", pftInfo.pointScale))
                    .font(.system(.caption2, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                if let idx = history.sessions.firstIndex(where: { $0.id == session.id }) {
                    history.delete(at: IndexSet(integer: idx))
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#Preview {
    HistoryView()
        .environmentObject(FitnessHistory())
}
