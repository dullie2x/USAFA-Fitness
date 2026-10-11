import Foundation

// MARK: - Session Model

struct FitnessSession: Codable, Identifiable {
    let id: UUID
    let date: Date
    let gender: String
    let aftScore: Int
    let pullUpScore: Int
    let jumpScore: Int
    let sitUpScore: Int
    let pushUpScore: Int
    let runScore: Int

    var totalPFTScore: Int { pullUpScore + jumpScore + sitUpScore + pushUpScore + runScore }

    init(gender: String, aftScore: Int, pullUpScore: Int, jumpScore: Int,
         sitUpScore: Int, pushUpScore: Int, runScore: Int) {
        self.id           = UUID()
        self.date         = Date()
        self.gender       = gender
        self.aftScore     = aftScore
        self.pullUpScore  = pullUpScore
        self.jumpScore    = jumpScore
        self.sitUpScore   = sitUpScore
        self.pushUpScore  = pushUpScore
        self.runScore     = runScore
    }
}

// MARK: - History Manager

class FitnessHistory: ObservableObject {
    @Published var sessions: [FitnessSession] = []

    private let storageKey = "fitness_sessions_v1"

    init() { load() }

    func add(_ session: FitnessSession) {
        sessions.insert(session, at: 0)
        persist()
    }

    func delete(at offsets: IndexSet) {
        sessions.remove(atOffsets: offsets)
        persist()
    }

    func clearAll() {
        sessions.removeAll()
        persist()
    }

    var personalBestPFT: FitnessSession? {
        sessions.max(by: { $0.totalPFTScore < $1.totalPFTScore })
    }

    var personalBestAFT: FitnessSession? {
        sessions.max(by: { $0.aftScore < $1.aftScore })
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([FitnessSession].self, from: data)
        else { return }
        sessions = decoded
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(sessions) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
