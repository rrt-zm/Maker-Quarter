import Foundation

final class SaveService {
    private let fileName = "maker_quarter_save.json"
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init() {
        encoder = JSONEncoder()
        encoder.outputFormatting = []
        decoder = JSONDecoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        decoder.dateDecodingStrategy = .secondsSince1970
    }

    private var fileURL: URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir.appendingPathComponent(fileName)
    }

    func save(_ state: GameState) {
        var snapshot = state
        snapshot.lastSaved = Date()
        guard let data = try? encoder.encode(snapshot) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    func load() -> GameState? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        guard var state = try? decoder.decode(GameState.self, from: data) else { return nil }
        state = Migration.migrate(state)
        return state
    }

    func deleteSave() {
        try? FileManager.default.removeItem(at: fileURL)
    }
}

enum Migration {
    static func migrate(_ state: GameState) -> GameState {
        var migrated = state
        if migrated.workshops.isEmpty {
            migrated.workshops = WorkshopKind.allCases.map { .locked($0) }
        }
        let present = Set(migrated.workshops.map { $0.kind })
        for kind in WorkshopKind.allCases where !present.contains(kind) {
            migrated.workshops.append(.locked(kind))
        }
        migrated.version = GameState.currentVersion
        return migrated
    }
}
