import Foundation

enum WorkshopKind: String, Codable, CaseIterable, Identifiable, Hashable {
    case pottery
    case painting
    case furniture
    case watchmaking
    case glassblowing
    case textiles
    case jewelry
    case design

    var id: String { rawValue }
}

struct Workshop: Codable, Identifiable, Hashable {
    let kind: WorkshopKind
    var level: Int
    var craftProgress: Double
    var hasManager: Bool

    var id: WorkshopKind { kind }
    var isOpen: Bool { level > 0 }

    static func locked(_ kind: WorkshopKind) -> Workshop {
        Workshop(kind: kind, level: 0, craftProgress: 0, hasManager: false)
    }
}
