import Foundation

enum PrestigeUpgradeKind: String, Codable, CaseIterable, Identifiable, Hashable {
    case mastersTouch
    case renownedQuarter
    case patronNetwork
    case swiftHands
    case welcomingLanterns

    var id: String { rawValue }
}
