import Foundation

struct GameState: Codable {
    static let currentVersion = 1

    var version: Int = GameState.currentVersion
    var coins: Double = 0
    var reputation: Double = 0
    var inspiration: Double = 0
    var earnedReputationThisRun: Double = 0

    var workshops: [Workshop] = []
    var formedZones: Set<ZoneKind> = []
    var placedDecorations: [PlacedDecoration] = []
    var unlockedStreets: Int = 1

    var claimedQuests: Set<String> = []
    var unlockedAchievements: Set<String> = []
    var unlockedMasterpieces: Set<String> = []

    var prestigeUpgrades: [String: Int] = [:]
    var prestigeCount: Int = 0

    var activeBoosts: [ActiveBoost] = []
    var boostCharge: Double = 0
    var visitorAccumulator: Double = 0

    var statistics = Statistics()
    var settings = GameSettings()
    var lastSaved: Date = .init(timeIntervalSince1970: 0)

    func workshop(_ kind: WorkshopKind) -> Workshop {
        workshops.first(where: { $0.kind == kind }) ?? .locked(kind)
    }

    var openWorkshops: [Workshop] { workshops.filter { $0.isOpen } }

    func prestigeLevel(_ kind: PrestigeUpgradeKind) -> Int {
        prestigeUpgrades[kind.rawValue] ?? 0
    }

    func decorationCount(_ kind: DecorationKind) -> Int {
        placedDecorations.filter { $0.kind == kind }.count
    }

    func metricValue(_ kind: MetricKind) -> Double {
        switch kind {
        case .goodsCrafted: return Double(statistics.goodsCrafted)
        case .coinsEarned: return statistics.coinsEarned
        case .reputationEarned: return statistics.reputationEarned
        case .workshopsOpened: return Double(statistics.workshopsOpened)
        case .workshopUpgrades: return Double(statistics.workshopUpgrades)
        case .zonesFormed: return Double(statistics.zonesFormed)
        case .visitorsWelcomed: return Double(statistics.visitorsWelcomed)
        case .decorationsPlaced: return Double(statistics.decorationsPlaced)
        case .managersHired: return Double(statistics.managersHired)
        case .taps: return Double(statistics.taps)
        case .prestiges: return Double(statistics.prestiges)
        case .boostsActivated: return Double(statistics.boostsActivated)
        case .coinsBalance: return coins
        case .reputationBalance: return reputation
        case .openWorkshopsNow: return Double(openWorkshops.count)
        case .totalWorkshopLevels: return Double(workshops.reduce(0) { $0 + $1.level })
        case .secondsPlayed: return statistics.secondsPlayed
        }
    }
}
