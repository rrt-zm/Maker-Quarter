import SwiftUI

struct AchievementsView: View {
    let onClose: () -> Void
    @Environment(GameViewModel.self) private var vm

    var body: some View {
        SheetScreen(title: "Achievements", symbol: "rosette", accent: Palette.gold, onClose: onClose) {
            header

            VStack(spacing: Spacing.s) {
                ForEach(GameConfig.achievements) { def in
                    row(def)
                }
            }
        }
    }

    private var unlockedCount: Int {
        vm.state.unlockedAchievements.count
    }

    private var totalCount: Int {
        GameConfig.achievements.count
    }

    private var earnedInspiration: Double {
        GameConfig.achievements
            .filter { ProgressionEngine.isAchievementUnlocked(vm.state, def: $0) }
            .reduce(0) { $0 + $1.rewardInspiration }
    }

    private var header: some View {
        PaperPanel {
            HStack(spacing: Spacing.m) {
                ZStack {
                    RingProgress(progress: ratio, tint: Palette.gold, lineWidth: 6)
                    Image(systemName: "rosette")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Palette.gold)
                }
                .frame(width: 56, height: 56)

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("\(unlockedCount)/\(totalCount) earned")
                        .font(AppFont.heading(18))
                        .foregroundStyle(Palette.ink)
                    if earnedInspiration > 0 {
                        HStack(spacing: 5) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Palette.inspiration)
                            Text("+\(EconomyService.format(earnedInspiration)) inspiration earned")
                                .font(AppFont.body(12))
                                .foregroundStyle(Palette.inkSoft)
                        }
                    }
                }

                Spacer(minLength: 0)
            }
        }
    }

    private var ratio: Double {
        totalCount == 0 ? 0 : Double(unlockedCount) / Double(totalCount)
    }

    private func row(_ def: AchievementDef) -> some View {
        let unlocked = ProgressionEngine.isAchievementUnlocked(vm.state, def: def)
        let progress = ProgressionEngine.achievementProgress(vm.state, def: def)

        return VStack(spacing: Spacing.m) {
            HStack(spacing: Spacing.m) {
                ZStack {
                    Circle()
                        .fill(unlocked ? Palette.gold : Palette.inkFaint.opacity(0.16))
                        .frame(width: 48, height: 48)
                    Image(systemName: def.symbol)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(unlocked ? .white : Palette.inkFaint)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(def.title)
                        .font(AppFont.heading(18))
                        .foregroundStyle(Palette.ink)
                    Text(def.detail)
                        .font(AppFont.body(13))
                        .foregroundStyle(Palette.inkSoft)
                }

                Spacer(minLength: 0)

                if unlocked {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Palette.success)
                        Tag(text: "Earned", color: Palette.success)
                    }
                }
            }

            if unlocked {
                if def.rewardInspiration > 0 {
                    HStack(spacing: Spacing.s) {
                        Tag(text: "+\(EconomyService.format(def.rewardInspiration)) inspiration", color: Palette.inspiration, filled: false)
                        Spacer(minLength: 0)
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    CraftProgressBar(progress: progress, tint: Palette.gold)
                    Text("\(Int(progress * 100))%")
                        .font(AppFont.number(13))
                        .foregroundStyle(Palette.inkSoft)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
        .padding(Spacing.l)
        .background(
            RoundedRectangle(cornerRadius: Radius.l, style: .continuous)
                .fill(Palette.panel)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.l, style: .continuous)
                .stroke(unlocked ? Palette.gold.opacity(0.55) : Palette.panelEdge, lineWidth: unlocked ? 1.5 : 1)
        )
        .softShadow()
        .opacity(unlocked ? 1 : 0.78)
    }
}
