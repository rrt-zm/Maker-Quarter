import Foundation

enum InitialState {
    static func newGame() -> GameState {
        var state = GameState()
        state.coins = 15
        state.workshops = WorkshopKind.allCases.map { kind in
            kind == .pottery ? Workshop(kind: .pottery, level: 1, craftProgress: 0, hasManager: false) : .locked(kind)
        }
        state.statistics.workshopsOpened = 1
        state.lastSaved = Date()
        return state
    }

    static func freshRun(preserving previous: GameState, gainedInspiration: Double) -> GameState {
        var state = GameState()
        state.coins = 15
        state.workshops = WorkshopKind.allCases.map { kind in
            kind == .pottery ? Workshop(kind: .pottery, level: 1, craftProgress: 0, hasManager: false) : .locked(kind)
        }
        state.inspiration = previous.inspiration + gainedInspiration
        state.prestigeUpgrades = previous.prestigeUpgrades
        state.prestigeCount = previous.prestigeCount + 1
        state.claimedQuests = previous.claimedQuests
        state.unlockedAchievements = previous.unlockedAchievements
        state.unlockedMasterpieces = previous.unlockedMasterpieces
        state.settings = previous.settings
        state.statistics = previous.statistics
        state.statistics.workshopsOpened = max(previous.statistics.workshopsOpened, 1)
        state.statistics.prestiges = previous.statistics.prestiges + 1
        state.lastSaved = Date()
        return state
    }
}
