import Foundation

enum BoostKind: String, Codable, CaseIterable, Identifiable, Hashable {
    case festivalDay
    case inspirationSurge
    case goldenHour

    var id: String { rawValue }
}

struct ActiveBoost: Codable, Identifiable, Hashable {
    let kind: BoostKind
    var remaining: Double

    var id: String { kind.rawValue }
}
