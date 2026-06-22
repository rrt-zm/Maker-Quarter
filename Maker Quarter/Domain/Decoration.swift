import Foundation

enum DecorationKind: String, Codable, CaseIterable, Identifiable, Hashable {
    case lantern
    case tree
    case fountain
    case mural
    case bench
    case stringLights
    case flowerBed
    case statue

    var id: String { rawValue }
}

struct PlacedDecoration: Codable, Identifiable, Hashable {
    let id: UUID
    let kind: DecorationKind
    let slot: Int
}
