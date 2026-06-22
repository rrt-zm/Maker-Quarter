import Foundation

enum GameActions {
    @discardableResult
    static func openWorkshop(_ state: inout GameState, kind: WorkshopKind) -> Bool {
        guard let index = state.workshops.firstIndex(where: { $0.kind == kind }), !state.workshops[index].isOpen else { return false }
        let cost = GameConfig.workshop(kind).unlockCost
        guard state.coins >= cost else { return false }
        state.coins -= cost
        state.workshops[index].level = 1
        state.workshops[index].craftProgress = 0
        state.statistics.workshopsOpened += 1
        return true
    }

    @discardableResult
    static func upgradeWorkshop(_ state: inout GameState, kind: WorkshopKind) -> Bool {
        guard let index = state.workshops.firstIndex(where: { $0.kind == kind }), state.workshops[index].isOpen else { return false }
        let cost = EconomyService.upgradeCost(kind, level: state.workshops[index].level)
        guard state.coins >= cost else { return false }
        state.coins -= cost
        state.workshops[index].level += 1
        state.statistics.workshopUpgrades += 1
        return true
    }

    @discardableResult
    static func hireManager(_ state: inout GameState, kind: WorkshopKind) -> Bool {
        guard let index = state.workshops.firstIndex(where: { $0.kind == kind }), state.workshops[index].isOpen, !state.workshops[index].hasManager else { return false }
        let cost = GameConfig.workshop(kind).managerCost
        guard state.coins >= cost else { return false }
        state.coins -= cost
        state.workshops[index].hasManager = true
        state.statistics.managersHired += 1
        return true
    }

    @discardableResult
    static func formZone(_ state: inout GameState, zone: ZoneKind) -> Bool {
        guard !state.formedZones.contains(zone), EconomyService.zoneReady(state, zone: zone) else { return false }
        let cost = GameConfig.zone(zone).formCost
        guard state.reputation >= cost else { return false }
        state.reputation -= cost
        state.formedZones.insert(zone)
        state.statistics.zonesFormed += 1
        return true
    }

    @discardableResult
    static func placeDecoration(_ state: inout GameState, kind: DecorationKind) -> Bool {
        let used = state.placedDecorations.count
        guard used < EconomyService.decorationSlots(state) else { return false }
        let cost = GameConfig.decoration(kind).cost
        guard state.coins >= cost else { return false }
        state.coins -= cost
        state.placedDecorations.append(PlacedDecoration(id: UUID(), kind: kind, slot: used))
        state.statistics.decorationsPlaced += 1
        return true
    }

    @discardableResult
    static func removeDecoration(_ state: inout GameState, id: UUID) -> Bool {
        guard let index = state.placedDecorations.firstIndex(where: { $0.id == id }) else { return false }
        let kind = state.placedDecorations[index].kind
        state.coins += GameConfig.decoration(kind).cost * 0.5
        state.placedDecorations.remove(at: index)
        for i in state.placedDecorations.indices {
            state.placedDecorations[i] = PlacedDecoration(id: state.placedDecorations[i].id, kind: state.placedDecorations[i].kind, slot: i)
        }
        return true
    }

    @discardableResult
    static func unlockStreet(_ state: inout GameState) -> Bool {
        guard state.unlockedStreets < GameConfig.streets.count else { return false }
        let cost = GameConfig.streets[state.unlockedStreets].unlockCost
        guard state.coins >= cost else { return false }
        state.coins -= cost
        state.unlockedStreets += 1
        return true
    }

    @discardableResult
    static func buyPrestigeUpgrade(_ state: inout GameState, kind: PrestigeUpgradeKind) -> Bool {
        let def = GameConfig.prestige(kind)
        let level = state.prestigeLevel(kind)
        guard level < def.maxLevel else { return false }
        let cost = EconomyService.prestigeUpgradeCost(kind, level: level)
        guard state.inspiration >= cost else { return false }
        state.inspiration -= cost
        state.prestigeUpgrades[kind.rawValue] = level + 1
        return true
    }

    @discardableResult
    static func prestige(_ state: inout GameState) -> Double {
        let gained = EconomyService.pendingInspiration(state)
        guard gained > 0 else { return 0 }
        state = InitialState.freshRun(preserving: state, gainedInspiration: gained)
        return gained
    }

    @discardableResult
    static func activateBoost(_ state: inout GameState, kind: BoostKind, fromCharge: Bool) -> Bool {
        if fromCharge {
            guard state.boostCharge >= 1 else { return false }
            state.boostCharge = 0
        }
        let duration = GameConfig.boost(kind).duration
        if let index = state.activeBoosts.firstIndex(where: { $0.kind == kind }) {
            state.activeBoosts[index].remaining = max(state.activeBoosts[index].remaining, duration)
        } else {
            state.activeBoosts.append(ActiveBoost(kind: kind, remaining: duration))
        }
        state.statistics.boostsActivated += 1
        return true
    }
}
