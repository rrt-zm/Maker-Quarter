import SwiftUI
import Observation

@Observable
final class GameViewModel {
    private(set) var state: GameState
    private(set) var offlineSummary: OfflineSummary?
    var showOnboarding: Bool = false
    var toasts: [ToastItem] = []
    var celebration: CelebrationItem?

    @ObservationIgnored private let save = SaveService()
    @ObservationIgnored private let audio = AudioService()
    @ObservationIgnored private let haptics = HapticsService()
    @ObservationIgnored private var timer: Timer?
    @ObservationIgnored private var lastTick = Date()
    @ObservationIgnored private var saveAccumulator: Double = 0
    @ObservationIgnored private var progressAccumulator: Double = 0
    @ObservationIgnored private var celebrationQueue: [CelebrationItem] = []
    @ObservationIgnored private var isLoaded = false

    init() {
        if let loaded = save.load() {
            state = loaded
            isLoaded = true
        } else {
            state = InitialState.newGame()
        }
        haptics.enabled = state.settings.hapticsOn
        haptics.prepare()
        audio.soundEnabled = state.settings.soundOn
        audio.musicEnabled = state.settings.musicOn
        audio.configure()
    }

    func onAppear() {
        if !state.settings.tutorialCompleted {
            showOnboarding = true
        } else if isLoaded {
            evaluateOffline()
        }
        startTimer()
    }

    private func evaluateOffline() {
        let summary = OfflineService.summary(for: state, now: Date())
        if summary.hasMeaningfulGains && summary.elapsed > 60 {
            OfflineService.apply(summary, to: &state)
            offlineSummary = summary
        }
    }

    func dismissOffline() {
        offlineSummary = nil
        persist()
    }

    func finishOnboarding() {
        state.settings.tutorialCompleted = true
        showOnboarding = false
        persist()
    }

    private func startTimer() {
        timer?.invalidate()
        lastTick = Date()
        let t = Timer(timeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    private func tick() {
        let now = Date()
        let dt = min(2.0, now.timeIntervalSince(lastTick))
        lastTick = now
        _ = GameEngine.advance(&state, dt: dt)

        progressAccumulator += dt
        if progressAccumulator >= 0.75 {
            progressAccumulator = 0
            checkProgress()
        }

        saveAccumulator += dt
        if saveAccumulator >= 6 {
            saveAccumulator = 0
            persist()
        }
    }

    private func checkProgress() {
        let achievements = ProgressionEngine.checkAchievements(&state)
        for def in achievements {
            enqueueCelebration(CelebrationItem(
                title: "Achievement!",
                subtitle: def.title,
                symbol: def.symbol,
                color: Palette.gold,
                rewards: def.rewardInspiration > 0 ? ["+\(EconomyService.format(def.rewardInspiration)) Inspiration"] : [],
                confetti: true))
        }
        let masterpieces = ProgressionEngine.checkMasterpieces(&state)
        for def in masterpieces {
            enqueueCelebration(CelebrationItem(
                title: "Masterpiece Created",
                subtitle: def.name,
                symbol: def.symbol,
                color: Palette.plum,
                confetti: true))
        }
    }

    func enterBackground() {
        persist()
        timer?.invalidate()
        timer = nil
    }

    func enterForeground() {
        let summary = OfflineService.summary(for: state, now: Date())
        if summary.hasMeaningfulGains && summary.elapsed > 120 {
            OfflineService.apply(summary, to: &state)
            offlineSummary = summary
        }
        startTimer()
    }

    private func persist() {
        save.save(state)
    }

    var stars: Double { EconomyService.starRating(state.reputation) }
    var totalIncomePerSecond: Double { EconomyService.totalIncomePerSecond(state) }
    var atmosphere: Double { EconomyService.atmosphere(state) }
    var pendingInspiration: Double { EconomyService.pendingInspiration(state) }

    var sceneWorkshops: [WorkshopVisual] {
        state.openWorkshops.map { workshop in
            let def = GameConfig.workshop(workshop.kind)
            return WorkshopVisual(kind: workshop.kind, level: workshop.level, hasManager: workshop.hasManager,
                                  progress: workshop.craftProgress, accentHex: def.accentHex, symbol: def.symbol)
        }
    }

    @discardableResult
    func tap(_ kind: WorkshopKind) -> TapResult {
        let result = GameEngine.tap(&state, kind: kind)
        if result.completed {
            audio.play(.craft)
            haptics.play(.light)
        } else {
            haptics.play(.soft)
        }
        return result
    }

    func tapFocused() {
        guard let kind = state.openWorkshops.max(by: { $0.level < $1.level })?.kind else { return }
        _ = tap(kind)
    }

    func openWorkshop(_ kind: WorkshopKind) {
        if GameActions.openWorkshop(&state, kind: kind) {
            audio.play(.unlock)
            haptics.play(.success)
            let def = GameConfig.workshop(kind)
            enqueueCelebration(CelebrationItem(title: "New Workshop!", subtitle: def.name, symbol: def.symbol,
                                               color: Color(hex: def.accentHex), confetti: true))
            checkProgress()
            persist()
        } else {
            haptics.play(.error)
        }
    }

    func upgradeWorkshop(_ kind: WorkshopKind) {
        if GameActions.upgradeWorkshop(&state, kind: kind) {
            audio.play(.upgrade)
            haptics.play(.medium)
            checkProgress()
        } else {
            haptics.play(.error)
        }
    }

    func hireManager(_ kind: WorkshopKind) {
        if GameActions.hireManager(&state, kind: kind) {
            audio.play(.success)
            haptics.play(.success)
            let def = GameConfig.workshop(kind)
            pushToast(ToastItem(text: "Manager hired for \(def.name)", symbol: "person.fill.badge.plus", color: Palette.sage))
            checkProgress()
            persist()
        } else {
            haptics.play(.error)
        }
    }

    func formZone(_ zone: ZoneKind) {
        if GameActions.formZone(&state, zone: zone) {
            audio.play(.unlock)
            haptics.play(.success)
            let def = GameConfig.zone(zone)
            enqueueCelebration(CelebrationItem(title: "Zone Formed!", subtitle: def.name, symbol: def.symbol,
                                               color: Color(hex: def.accentHex),
                                               rewards: ["Production x\(String(format: "%.2g", def.productionMultiplier))"],
                                               confetti: true))
            checkProgress()
            persist()
        } else {
            haptics.play(.error)
        }
    }

    func placeDecoration(_ kind: DecorationKind) {
        if GameActions.placeDecoration(&state, kind: kind) {
            audio.play(.coin)
            haptics.play(.light)
            checkProgress()
        } else {
            haptics.play(.error)
        }
    }

    func removeDecoration(_ id: UUID) {
        if GameActions.removeDecoration(&state, id: id) {
            haptics.play(.soft)
            persist()
        }
    }

    func unlockStreet() {
        if GameActions.unlockStreet(&state) {
            audio.play(.unlock)
            haptics.play(.success)
            let index = state.unlockedStreets - 1
            let name = GameConfig.streets[index].name
            enqueueCelebration(CelebrationItem(title: "New Street!", subtitle: name, symbol: "signpost.right.fill",
                                               color: Palette.brass, confetti: true))
            persist()
        } else {
            haptics.play(.error)
        }
    }

    func buyPrestigeUpgrade(_ kind: PrestigeUpgradeKind) {
        if GameActions.buyPrestigeUpgrade(&state, kind: kind) {
            audio.play(.upgrade)
            haptics.play(.medium)
            persist()
        } else {
            haptics.play(.error)
        }
    }

    func prestige() {
        let gained = GameActions.prestige(&state)
        if gained > 0 {
            audio.play(.prestige)
            haptics.play(.success)
            enqueueCelebration(CelebrationItem(title: "Quarter Reinvented", subtitle: "A fresh start, richer than before.",
                                               symbol: "arrow.triangle.2.circlepath", color: Palette.inspiration,
                                               rewards: ["+\(EconomyService.format(gained)) Inspiration"], confetti: true))
            checkProgress()
            persist()
        } else {
            haptics.play(.error)
        }
    }

    func activateFestival() {
        if GameActions.activateBoost(&state, kind: .festivalDay, fromCharge: true) {
            audio.play(.success)
            haptics.play(.success)
            pushToast(ToastItem(text: "Festival Day! x2 production", symbol: "party.popper.fill", color: Palette.rose))
            persist()
        } else {
            haptics.play(.error)
        }
    }

    func claimQuest(_ id: String) {
        if let reward = ProgressionEngine.claimQuest(&state, id: id) {
            audio.play(.success)
            haptics.play(.success)
            var lines: [String] = []
            if reward.coins > 0 { lines.append("+\(EconomyService.format(reward.coins)) Coins") }
            if reward.reputation > 0 { lines.append("+\(EconomyService.format(reward.reputation)) Reputation") }
            if let boost = reward.boost { lines.append("\(GameConfig.boost(boost).name) boost") }
            enqueueCelebration(CelebrationItem(title: "Commission Complete", subtitle: GameConfig.quest(id)?.title ?? "",
                                               symbol: "checkmark.seal.fill", color: Palette.success, rewards: lines, confetti: true))
            checkProgress()
            persist()
        } else {
            haptics.play(.error)
        }
    }

    func setSound(_ on: Bool) {
        state.settings.soundOn = on
        audio.soundEnabled = on
        persist()
    }

    func setMusic(_ on: Bool) {
        state.settings.musicOn = on
        audio.setMusic(on)
        persist()
    }

    func setHaptics(_ on: Bool) {
        state.settings.hapticsOn = on
        haptics.enabled = on
        if on { haptics.play(.light) }
        persist()
    }

    func setQuality(_ high: Bool) {
        state.settings.highQuality = high
        persist()
    }

    func replayTutorial() {
        showOnboarding = true
    }

    func resetProgress() {
        save.deleteSave()
        state = InitialState.newGame()
        state.settings.tutorialCompleted = true
        offlineSummary = nil
        celebrationQueue.removeAll()
        celebration = nil
        toasts.removeAll()
        haptics.play(.warning)
        persist()
    }

    private func enqueueCelebration(_ item: CelebrationItem) {
        if celebration == nil {
            celebration = item
        } else {
            celebrationQueue.append(item)
        }
    }

    func dismissCelebration() {
        if celebrationQueue.isEmpty {
            celebration = nil
        } else {
            celebration = celebrationQueue.removeFirst()
        }
    }

    private func pushToast(_ item: ToastItem) {
        toasts.append(item)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) { [weak self] in
            self?.toasts.removeAll { $0.id == item.id }
        }
    }
}
