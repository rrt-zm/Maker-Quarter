import Foundation

struct TickResult {
    var coinsGained: Double = 0
    var reputationGained: Double = 0
    var completions: [WorkshopKind: Int] = [:]
    var newVisitors: Int = 0
}

struct TapResult {
    let kind: WorkshopKind
    let completed: Bool
    let coinsGained: Double
}

enum GameEngine {
    private static let maxCompletionsPerTick = 40

    static func advance(_ state: inout GameState, dt: Double) -> TickResult {
        var result = TickResult()
        guard dt > 0 else { return result }

        state.statistics.secondsPlayed += dt

        if !state.activeBoosts.isEmpty {
            for index in state.activeBoosts.indices {
                state.activeBoosts[index].remaining -= dt
            }
            state.activeBoosts.removeAll { $0.remaining <= 0 }
        }

        for index in state.workshops.indices {
            let workshop = state.workshops[index]
            guard workshop.isOpen, workshop.hasManager else { continue }
            let craftTime = EconomyService.craftTime(state, kind: workshop.kind)
            guard craftTime > 0 else { continue }
            var progress = workshop.craftProgress + dt / craftTime
            var completions = 0
            while progress >= 1 && completions < maxCompletionsPerTick {
                progress -= 1
                completions += 1
            }
            if progress >= 1 { progress = 0.999 }
            state.workshops[index].craftProgress = progress
            if completions > 0 {
                creditCrafts(&state, kind: workshop.kind, count: completions, result: &result)
            }
        }

        let visitorIncome = EconomyService.visitorIncomePerSecond(state) * dt
        if visitorIncome > 0 {
            state.coins += visitorIncome
            state.statistics.coinsEarned += visitorIncome
            result.coinsGained += visitorIncome
        }

        let atmosphereRep = EconomyService.atmosphereReputationPerSecond(state) * dt
        if atmosphereRep > 0 {
            state.reputation += atmosphereRep
            state.earnedReputationThisRun += atmosphereRep
            state.statistics.reputationEarned += atmosphereRep
            result.reputationGained += atmosphereRep
        }

        state.visitorAccumulator += EconomyService.visitorsPerSecond(state) * dt
        if state.visitorAccumulator >= 1 {
            let whole = Int(state.visitorAccumulator)
            state.visitorAccumulator -= Double(whole)
            state.statistics.visitorsWelcomed += whole
            result.newVisitors += whole
        }

        return result
    }

    private static func creditCrafts(_ state: inout GameState, kind: WorkshopKind, count: Int, result: inout TickResult) {
        let coins = EconomyService.coinsPerCraft(state, kind: kind) * Double(count)
        let reputation = EconomyService.reputationPerCraft(state, kind: kind) * Double(count)
        state.coins += coins
        state.reputation += reputation
        state.earnedReputationThisRun += reputation
        state.statistics.coinsEarned += coins
        state.statistics.reputationEarned += reputation
        state.statistics.goodsCrafted += count
        state.boostCharge = min(1, state.boostCharge + GameConfig.boostChargePerCraft * Double(count))
        result.coinsGained += coins
        result.reputationGained += reputation
        result.completions[kind, default: 0] += count
    }

    static func tap(_ state: inout GameState, kind: WorkshopKind) -> TapResult {
        guard let index = state.workshops.firstIndex(where: { $0.kind == kind }), state.workshops[index].isOpen else {
            return TapResult(kind: kind, completed: false, coinsGained: 0)
        }
        state.statistics.taps += 1
        state.boostCharge = min(1, state.boostCharge + GameConfig.boostChargePerTap)
        var progress = state.workshops[index].craftProgress + GameConfig.tapCraftFraction
        if progress >= 1 {
            progress -= 1
            state.workshops[index].craftProgress = progress
            var result = TickResult()
            creditCrafts(&state, kind: kind, count: 1, result: &result)
            return TapResult(kind: kind, completed: true, coinsGained: result.coinsGained)
        } else {
            state.workshops[index].craftProgress = progress
            return TapResult(kind: kind, completed: false, coinsGained: 0)
        }
    }
}
