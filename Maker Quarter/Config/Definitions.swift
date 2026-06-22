import Foundation

struct WorkshopDef: Identifiable {
    let kind: WorkshopKind
    let name: String
    let product: String
    let symbol: String
    let accentHex: String
    let unlockCost: Double
    let baseUpgradeCost: Double
    let costGrowth: Double
    let craftTime: Double
    let baseOutput: Double
    let reputationPerCraft: Double
    let managerCost: Double
    let zone: ZoneKind

    var id: WorkshopKind { kind }
}

struct ZoneDef: Identifiable {
    let kind: ZoneKind
    let name: String
    let subtitle: String
    let symbol: String
    let accentHex: String
    let members: [WorkshopKind]
    let requiredLevel: Int
    let productionMultiplier: Double
    let reputationMultiplier: Double
    let formCost: Double

    var id: ZoneKind { kind }
}

struct DecorationDef: Identifiable {
    let kind: DecorationKind
    let name: String
    let symbol: String
    let accentHex: String
    let cost: Double
    let atmosphere: Double

    var id: DecorationKind { kind }
}

struct StreetDef: Identifiable {
    let index: Int
    let name: String
    let unlockCost: Double
    let decorationSlots: Int

    var id: Int { index }
}

struct QuestDef: Identifiable {
    let id: String
    let title: String
    let detail: String
    let symbol: String
    let metric: MetricKind
    let target: Double
    let rewardCoins: Double
    let rewardReputation: Double
    let rewardBoost: BoostKind?
}

struct AchievementDef: Identifiable {
    let id: String
    let title: String
    let detail: String
    let symbol: String
    let metric: MetricKind
    let target: Double
    let rewardInspiration: Double
}

struct PrestigeUpgradeDef: Identifiable {
    let kind: PrestigeUpgradeKind
    let name: String
    let detail: String
    let symbol: String
    let baseCost: Double
    let costGrowth: Double
    let effectPerLevel: Double
    let maxLevel: Int

    var id: PrestigeUpgradeKind { kind }
}

struct MasterpieceDef: Identifiable {
    let id: String
    let name: String
    let workshop: WorkshopKind
    let requiredLevel: Int
    let symbol: String
    let flavor: String
}

struct BoostDef: Identifiable {
    let kind: BoostKind
    let name: String
    let detail: String
    let symbol: String
    let duration: Double
    let productionMultiplier: Double
    let reputationMultiplier: Double

    var id: BoostKind { kind }
}
