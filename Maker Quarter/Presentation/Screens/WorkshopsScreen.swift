import SwiftUI

struct WorkshopsScreen: View {
    @Environment(GameViewModel.self) private var vm

    private var managerCount: Int {
        vm.state.workshops.filter { $0.hasManager }.count
    }

    var body: some View {
        GameScreen(title: "Workshops", subtitle: "Manage your ateliers", symbol: "hammer.fill") {
            summary

            VStack(spacing: Spacing.m) {
                ForEach(GameConfig.workshops) { def in
                    let w = vm.state.workshop(def.kind)
                    if w.isOpen || w.level > 0 {
                        openCard(def, w)
                    } else {
                        lockedCard(def, w)
                    }
                }
            }
        }
    }

    private var summary: some View {
        PaperPanel {
            HStack(spacing: Spacing.l) {
                summaryItem(label: "Income", value: EconomyService.format(vm.totalIncomePerSecond) + "/s", symbol: "chart.line.uptrend.xyaxis", color: Palette.coin)
                summaryItem(label: "Open", value: "\(vm.state.openWorkshops.count)/8", symbol: "door.left.hand.open", color: Palette.teal)
                summaryItem(label: "Managers", value: "\(managerCount)", symbol: "person.fill.checkmark", color: Palette.sage)
            }
        }
    }

    private func summaryItem(label: String, value: String, symbol: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: symbol)
                    .font(AppFont.label(12))
                    .foregroundStyle(color)
                Text(label)
                    .font(AppFont.label(12))
                    .foregroundStyle(Palette.inkFaint)
            }
            Text(value)
                .font(AppFont.number(18))
                .foregroundStyle(Palette.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func openCard(_ def: WorkshopDef, _ w: Workshop) -> some View {
        let accent = Color(hex: def.accentHex)
        let upgradeCost = EconomyService.upgradeCost(def.kind, level: w.level)
        let canUpgrade = vm.state.coins >= upgradeCost
        let canHire = vm.state.coins >= def.managerCost

        return cardContainer {
            VStack(alignment: .leading, spacing: Spacing.m) {
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
                        Text(def.name)
                            .font(AppFont.heading(18))
                            .foregroundStyle(Palette.ink)
                        Text("Crafts \(def.product)")
                            .font(AppFont.body(12))
                            .foregroundStyle(Palette.inkFaint)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: Spacing.xs) {
                        Tag(text: "Lv \(w.level)", color: accent)
                        if w.hasManager {
                            Tag(text: "Auto", color: Palette.sage)
                        }
                    }
                }

                CraftProgressBar(progress: w.craftProgress, tint: accent)

                HStack(spacing: Spacing.l) {
                    statLine(label: "Per craft", value: EconomyService.format(EconomyService.coinsPerCraft(vm.state, kind: def.kind)), symbol: "hammer.fill", color: accent)
                    statLine(label: "Income", value: EconomyService.format(EconomyService.incomePerSecond(vm.state, kind: def.kind)) + "/s", symbol: "clock.fill", color: Palette.coin)
                }

                HStack(spacing: Spacing.s) {
                    GameButton(kind: .primary, tint: accent, enabled: canUpgrade) {
                        vm.upgradeWorkshop(def.kind)
                    } label: {
                        HStack(spacing: Spacing.s) {
                            Text("Upgrade")
                            CostBadge(amount: upgradeCost, currency: .coins, affordable: canUpgrade)
                        }
                    }

                    if w.hasManager {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Palette.sage)
                            Text("Producing automatically")
                                .font(AppFont.body(12))
                                .foregroundStyle(Palette.inkSoft)
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        GameButton(kind: .secondary, enabled: canHire) {
                            vm.hireManager(def.kind)
                        } label: {
                            HStack(spacing: Spacing.s) {
                                Text("Hire Manager")
                                CostBadge(amount: def.managerCost, currency: .coins, affordable: canHire)
                            }
                        }
                    }

                    IconButton(symbol: "hand.tap.fill", tint: accent) {
                        vm.tap(def.kind)
                    }
                }
            }
        }
    }

    private func lockedCard(_ def: WorkshopDef, _ w: Workshop) -> some View {
        let accent = Color(hex: def.accentHex)
        let canOpen = vm.state.coins >= def.unlockCost

        return cardContainer {
            VStack(alignment: .leading, spacing: Spacing.m) {
                HStack(spacing: Spacing.m) {
                    ZStack {
                        Circle()
                            .fill(Palette.panelEdge.mix(with: .white, amount: 0.4))
                            .frame(width: 48, height: 48)
                        Image(systemName: "lock.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(Palette.inkFaint)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(def.name)
                            .font(AppFont.heading(18))
                            .foregroundStyle(Palette.ink)
                        Text("Crafts \(def.product)")
                            .font(AppFont.body(12))
                            .foregroundStyle(Palette.inkFaint)
                    }

                    Spacer()
                }

                GameButton(kind: .primary, tint: accent, enabled: canOpen) {
                    vm.openWorkshop(def.kind)
                } label: {
                    HStack(spacing: Spacing.s) {
                        Text("Open Workshop")
                        CostBadge(amount: def.unlockCost, currency: .coins, affordable: canOpen)
                    }
                }
            }
        }
    }

    private func statLine(label: String, value: String, symbol: String, color: Color) -> some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: symbol)
                .font(AppFont.label(11))
                .foregroundStyle(color)
            Text(label)
                .font(AppFont.label(11))
                .foregroundStyle(Palette.inkFaint)
            Text(value)
                .font(AppFont.number(13))
                .foregroundStyle(Palette.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func cardContainer<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
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
    }
}
