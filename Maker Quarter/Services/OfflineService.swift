import Foundation

struct OfflineSummary {
    let elapsed: Double
    let cappedElapsed: Double
    let coins: Double
    let reputation: Double
    let wasCapped: Bool

    var hasMeaningfulGains: Bool { coins >= 1 || reputation >= 1 }
}

enum OfflineService {
    static func summary(for state: GameState, now: Date) -> OfflineSummary {
        let elapsed = max(0, now.timeIntervalSince(state.lastSaved))
        let cap = EconomyService.offlineCapHours(state) * 3600
        let capped = min(elapsed, cap)
        let efficiency = GameConfig.offlineEfficiency

        let autoIncome = state.workshops
            .filter { $0.hasManager }
            .reduce(0.0) { $0 + EconomyService.incomePerSecond(state, kind: $1.kind) }
        let visitorIncome = EconomyService.visitorIncomePerSecond(state)
        let coins = (autoIncome + visitorIncome) * capped * efficiency

        let repRate = EconomyService.atmosphereReputationPerSecond(state)
        let reputation = repRate * capped * efficiency

        return OfflineSummary(
            elapsed: elapsed,
            cappedElapsed: capped,
            coins: coins,
            reputation: reputation,
            wasCapped: elapsed > cap
        )
    }

    static func apply(_ summary: OfflineSummary, to state: inout GameState) {
        state.coins += summary.coins
        state.reputation += summary.reputation
        state.earnedReputationThisRun += summary.reputation
        state.statistics.coinsEarned += summary.coins
        state.statistics.reputationEarned += summary.reputation
    }
}
