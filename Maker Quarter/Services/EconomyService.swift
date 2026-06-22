import Foundation

enum EconomyService {
    private static let suffixes = ["", "K", "M", "B", "T", "aa", "ab", "ac", "ad", "ae", "af", "ag", "ah", "ai", "aj", "ak", "al"]

    static func format(_ value: Double) -> String {
        if value.isNaN || value.isInfinite { return "0" }
        let v = max(0, value)
        if v < 1000 {
            return v == v.rounded() ? String(Int(v)) : String(format: "%.1f", v)
        }
        var tier = 0
        var scaled = v
        while scaled >= 1000 && tier < suffixes.count - 1 {
            scaled /= 1000
            tier += 1
        }
        let formatted = scaled >= 100 ? String(format: "%.0f", scaled)
            : scaled >= 10 ? String(format: "%.1f", scaled)
            : String(format: "%.2f", scaled)
        return formatted + suffixes[tier]
    }

    static func formatTime(_ seconds: Double) -> String {
        let s = Int(max(0, seconds))
        let h = s / 3600
        let m = (s % 3600) / 60
        let sec = s % 60
        if h > 0 { return "\(h)h \(m)m" }
        if m > 0 { return "\(m)m \(sec)s" }
        return "\(sec)s"
    }

    static func upgradeCost(_ kind: WorkshopKind, level: Int) -> Double {
        let def = GameConfig.workshop(kind)
        return (def.baseUpgradeCost * pow(def.costGrowth, Double(max(0, level)))).rounded()
    }

    static func outputPerCraft(_ kind: WorkshopKind, level: Int) -> Double {
        GameConfig.workshop(kind).baseOutput * Double(level)
    }

    static func boostProductionMultiplier(_ state: GameState) -> Double {
        state.activeBoosts.reduce(1.0) { $0 * GameConfig.boost($1.kind).productionMultiplier }
    }

    static func boostReputationMultiplier(_ state: GameState) -> Double {
        state.activeBoosts.reduce(1.0) { $0 * GameConfig.boost($1.kind).reputationMultiplier }
    }

    static func zoneFormed(_ state: GameState, for kind: WorkshopKind) -> Bool {
        state.formedZones.contains(GameConfig.workshop(kind).zone)
    }

    static func productionMultiplier(_ state: GameState, kind: WorkshopKind) -> Double {
        var m = 1.0
        let zone = GameConfig.workshop(kind).zone
        if state.formedZones.contains(zone) {
            m *= GameConfig.zone(zone).productionMultiplier
        }
        if state.formedZones.contains(.grandQuarter) {
            m *= GameConfig.zone(.grandQuarter).productionMultiplier
        }
        m *= 1 + Double(state.prestigeLevel(.mastersTouch)) * GameConfig.prestige(.mastersTouch).effectPerLevel
        m *= boostProductionMultiplier(state)
        return m
    }

    static func reputationMultiplier(_ state: GameState, kind: WorkshopKind) -> Double {
        var m = 1.0
        let zone = GameConfig.workshop(kind).zone
        if state.formedZones.contains(zone) {
            m *= GameConfig.zone(zone).reputationMultiplier
        }
        if state.formedZones.contains(.grandQuarter) {
            m *= GameConfig.zone(.grandQuarter).reputationMultiplier
        }
        m *= 1 + Double(state.prestigeLevel(.renownedQuarter)) * GameConfig.prestige(.renownedQuarter).effectPerLevel
        m *= boostReputationMultiplier(state)
        return m
    }

    static func craftTime(_ state: GameState, kind: WorkshopKind) -> Double {
        let base = GameConfig.workshop(kind).craftTime
        let speed = 1 + Double(state.prestigeLevel(.swiftHands)) * GameConfig.prestige(.swiftHands).effectPerLevel
        return base / speed
    }

    static func coinsPerCraft(_ state: GameState, kind: WorkshopKind) -> Double {
        let w = state.workshop(kind)
        return outputPerCraft(kind, level: w.level) * productionMultiplier(state, kind: kind)
    }

    static func reputationPerCraft(_ state: GameState, kind: WorkshopKind) -> Double {
        GameConfig.workshop(kind).reputationPerCraft * reputationMultiplier(state, kind: kind)
    }

    static func incomePerSecond(_ state: GameState, kind: WorkshopKind) -> Double {
        let w = state.workshop(kind)
        guard w.isOpen else { return 0 }
        return coinsPerCraft(state, kind: kind) / craftTime(state, kind: kind)
    }

    static func atmosphere(_ state: GameState) -> Double {
        state.placedDecorations.reduce(0) { $0 + GameConfig.decoration($1.kind).atmosphere }
    }

    static func atmosphereReputationPerSecond(_ state: GameState) -> Double {
        let renowned = 1 + Double(state.prestigeLevel(.renownedQuarter)) * GameConfig.prestige(.renownedQuarter).effectPerLevel
        return atmosphere(state) * 0.04 * renowned * boostReputationMultiplier(state)
    }

    static func visitorIncomePerSecond(_ state: GameState) -> Double {
        let welcoming = 1 + Double(state.prestigeLevel(.welcomingLanterns)) * GameConfig.prestige(.welcomingLanterns).effectPerLevel
        let atmosphereFactor = 1 + atmosphere(state) / 50
        return 0.6 * sqrt(max(0, state.reputation)) * atmosphereFactor * welcoming * boostProductionMultiplier(state)
    }

    static func visitorsPerSecond(_ state: GameState) -> Double {
        sqrt(max(0, state.reputation)) * 0.12 * (1 + atmosphere(state) / 80)
    }

    static func totalIncomePerSecond(_ state: GameState) -> Double {
        let auto = state.workshops.filter { $0.hasManager }.reduce(0.0) { $0 + incomePerSecond(state, kind: $1.kind) }
        return auto + visitorIncomePerSecond(state)
    }

    static func starRating(_ reputation: Double) -> Double {
        let r = log10(max(1, reputation) + 1) / log10(200_000)
        return min(5, max(0, r * 5))
    }

    static func offlineCapHours(_ state: GameState) -> Double {
        GameConfig.baseOfflineCapHours + Double(state.prestigeLevel(.patronNetwork)) * GameConfig.prestige(.patronNetwork).effectPerLevel
    }

    static func pendingInspiration(_ state: GameState) -> Double {
        guard state.earnedReputationThisRun >= GameConfig.prestigeReputationFloor else { return 0 }
        return floor(sqrt(state.earnedReputationThisRun / 25))
    }

    static func decorationSlots(_ state: GameState) -> Int {
        GameConfig.streets.prefix(state.unlockedStreets).reduce(0) { $0 + $1.decorationSlots }
    }

    static func prestigeUpgradeCost(_ kind: PrestigeUpgradeKind, level: Int) -> Double {
        let def = GameConfig.prestige(kind)
        return (def.baseCost * pow(def.costGrowth, Double(max(0, level)))).rounded()
    }

    static func zoneReady(_ state: GameState, zone: ZoneKind) -> Bool {
        let def = GameConfig.zone(zone)
        if zone == .grandQuarter {
            let others: [ZoneKind] = [.ceramicsCourt, .craftHall, .fineAtelier, .artLane]
            return others.allSatisfy { state.formedZones.contains($0) }
        }
        return def.members.allSatisfy { state.workshop($0).level >= def.requiredLevel }
    }
}
