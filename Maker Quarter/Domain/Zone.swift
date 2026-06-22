import Foundation

enum ZoneKind: String, Codable, CaseIterable, Identifiable, Hashable {
    case ceramicsCourt
    case artLane
    case craftHall
    case fineAtelier
    case grandQuarter

    var id: String { rawValue }
}
