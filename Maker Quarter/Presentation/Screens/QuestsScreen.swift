import SwiftUI

struct QuestsScreen: View {
    @Environment(GameViewModel.self) private var vm

    var body: some View {
        GameScreen(title: "Commissions", subtitle: "Requests from the quarter", symbol: "scroll.fill") {
            progressHeader

            VStack(spacing: Spacing.m) {
                ForEach(Array(GameConfig.quests.enumerated()), id: \.element.id) { index, def in
                    let status = ProgressionEngine.status(vm.state, index: index)
                    if status == .locked {
                        LockedRow(title: "Locked Commission", requirement: "Complete the previous commission first", symbol: "lock.fill")
                    } else {
                        questCard(def, status)
                    }
                }
            }
        }
    }

    private var progressHeader: some View {
        PaperPanel {
            HStack(spacing: Spacing.m) {
                ZStack {
                    Circle()
                        .fill(Palette.clay.mix(with: .white, amount: 0.78))
                        .frame(width: 48, height: 48)
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(Palette.clay)
                }

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("\(vm.state.claimedQuests.count)/\(GameConfig.quests.count) completed")
                        .font(AppFont.heading(18))
                        .foregroundStyle(Palette.ink)
                    Text("Fulfil requests to earn rewards")
                        .font(AppFont.body(12))
                        .foregroundStyle(Palette.inkFaint)
                }

                Spacer()
            }
        }
    }

    private func accentColor(_ status: QuestStatus) -> Color {
        switch status {
        case .ready: return Palette.success
        case .claimed: return Palette.inkFaint
        default: return Palette.clay
        }
    }

    private func questCard(_ def: QuestDef, _ status: QuestStatus) -> some View {
        let accent = accentColor(status)
        let current = min(vm.state.metricValue(def.metric), def.target)
        let progress = ProgressionEngine.progress(vm.state, def: def) / def.target

        return VStack(spacing: Spacing.m) {
            HStack(spacing: Spacing.m) {
                ZStack {
                    Circle()
                        .fill(accent.mix(with: .white, amount: 0.78))
                        .frame(width: 48, height: 48)
                    Image(systemName: def.symbol)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(accent)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(def.title)
                        .font(AppFont.heading(18))
                        .foregroundStyle(Palette.ink)
                    Text(def.detail)
                        .font(AppFont.body(13))
                        .foregroundStyle(Palette.inkSoft)
                }

                Spacer()

                statusTag(status)
            }

            VStack(alignment: .leading, spacing: Spacing.xs) {
                CraftProgressBar(progress: progress, tint: accent)
                Text("\(EconomyService.format(current))/\(EconomyService.format(def.target))")
                    .font(AppFont.number(13))
                    .foregroundStyle(Palette.inkSoft)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }

            rewards(def)

            if status == .ready {
                GameButton(kind: .primary, tint: Palette.success) {
                    vm.claimQuest(def.id)
                } label: {
                    HStack(spacing: Spacing.s) {
                        Image(systemName: "gift.fill")
                        Text("Claim Reward")
                    }
                }
                .softShadow(radius: 16, y: 8)
            }
        }
        .padding(Spacing.l)
        .background(
            RoundedRectangle(cornerRadius: Radius.l, style: .continuous)
                .fill(Palette.panel)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.l, style: .continuous)
                .stroke(Palette.panelEdge, lineWidth: 1)
        )
        .softShadow()
        .opacity(status == .claimed ? 0.6 : 1)
    }

    @ViewBuilder
    private func statusTag(_ status: QuestStatus) -> some View {
        switch status {
        case .ready:
            Tag(text: "Ready", color: Palette.success)
        case .active:
            Tag(text: "In Progress", color: Palette.brass)
        case .claimed:
            HStack(spacing: Spacing.xs) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(Palette.success)
                Tag(text: "Completed", color: Palette.inkFaint)
            }
        case .locked:
            EmptyView()
        }
    }

    private func rewards(_ def: QuestDef) -> some View {
        HStack(spacing: Spacing.s) {
            if def.rewardCoins > 0 {
                Tag(text: "+\(EconomyService.format(def.rewardCoins)) coins", color: Palette.coin, filled: false)
            }
            if def.rewardReputation > 0 {
                Tag(text: "+\(EconomyService.format(def.rewardReputation)) rep", color: Palette.reputation, filled: false)
            }
            if let boost = def.rewardBoost {
                Tag(text: GameConfig.boost(boost).name, color: Palette.plum, filled: false)
            }
            Spacer()
        }
    }
}
