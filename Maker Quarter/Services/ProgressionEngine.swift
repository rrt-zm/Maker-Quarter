import Foundation

enum QuestStatus {
    case locked
    case active
    case ready
    case claimed
}

struct QuestReward {
    let coins: Double
    let reputation: Double
    let boost: BoostKind?
}

enum ProgressionEngine {
    static func currentQuestIndex(_ state: GameState) -> Int? {
        for (index, def) in GameConfig.quests.enumerated() where !state.claimedQuests.contains(def.id) {
            return index
        }
        return nil
    }

    static func isUnlocked(_ state: GameState, index: Int) -> Bool {
        guard index > 0 else { return true }
        return state.claimedQuests.contains(GameConfig.quests[index - 1].id)
    }

    static func progress(_ state: GameState, def: QuestDef) -> Double {
        min(state.metricValue(def.metric), def.target)
    }

    static func isComplete(_ state: GameState, def: QuestDef) -> Bool {
        state.metricValue(def.metric) >= def.target
    }

    static func status(_ state: GameState, index: Int) -> QuestStatus {
        let def = GameConfig.quests[index]
        if state.claimedQuests.contains(def.id) { return .claimed }
        if !isUnlocked(state, index: index) { return .locked }
        return isComplete(state, def: def) ? .ready : .active
    }

    @discardableResult
    static func claimQuest(_ state: inout GameState, id: String) -> QuestReward? {
        guard let index = GameConfig.quests.firstIndex(where: { $0.id == id }) else { return nil }
        guard status(state, index: index) == .ready else { return nil }
        let def = GameConfig.quests[index]
        state.coins += def.rewardCoins
        state.statistics.coinsEarned += def.rewardCoins
        if def.rewardReputation > 0 {
            state.reputation += def.rewardReputation
            state.earnedReputationThisRun += def.rewardReputation
            state.statistics.reputationEarned += def.rewardReputation
        }
        if let boost = def.rewardBoost {
            GameActions.activateBoost(&state, kind: boost, fromCharge: false)
        }
        state.claimedQuests.insert(def.id)
        return QuestReward(coins: def.rewardCoins, reputation: def.rewardReputation, boost: def.rewardBoost)
    }

    static func achievementProgress(_ state: GameState, def: AchievementDef) -> Double {
        min(state.metricValue(def.metric) / def.target, 1)
    }

    static func isAchievementUnlocked(_ state: GameState, def: AchievementDef) -> Bool {
        state.unlockedAchievements.contains(def.id)
    }

    @discardableResult
    static func checkAchievements(_ state: inout GameState) -> [AchievementDef] {
        var unlocked: [AchievementDef] = []
        for def in GameConfig.achievements where !state.unlockedAchievements.contains(def.id) {
            if state.metricValue(def.metric) >= def.target {
                state.unlockedAchievements.insert(def.id)
                if def.rewardInspiration > 0 {
                    state.inspiration += def.rewardInspiration
                }
                unlocked.append(def)
            }
        }
        return unlocked
    }

    @discardableResult
    static func checkMasterpieces(_ state: inout GameState) -> [MasterpieceDef] {
        var unlocked: [MasterpieceDef] = []
        for def in GameConfig.masterpieces where !state.unlockedMasterpieces.contains(def.id) {
            if state.workshop(def.workshop).level >= def.requiredLevel {
                state.unlockedMasterpieces.insert(def.id)
                unlocked.append(def)
            }
        }
        return unlocked
    }

    static func isMasterpieceUnlocked(_ state: GameState, def: MasterpieceDef) -> Bool {
        state.unlockedMasterpieces.contains(def.id)
    }
}
