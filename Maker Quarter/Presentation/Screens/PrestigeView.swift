import SwiftUI

struct PrestigeView: View {
    let onClose: () -> Void
    @Environment(GameViewModel.self) private var vm
    @State private var confirming = false

    var body: some View {
        SheetScreen(title: "Reinvent the Quarter", symbol: "arrow.triangle.2.circlepath", accent: Palette.inspiration, onClose: onClose) {
            hero

            SectionHeader(title: "Permanent Upgrades", subtitle: "Spend Inspiration on lasting boosts", symbol: "wand.and.stars")

            VStack(spacing: Spacing.s) {
                ForEach(GameConfig.prestigeUpgrades) { def in
                    upgradeCard(def)
                }
            }
        }
        .alert("Reinvent the Quarter?", isPresented: $confirming) {
            Button("Reinvent", role: .destructive) {
                vm.prestige()
                onClose()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your workshops, coins and zones will reset. Achievements, gallery, Inspiration and prestige upgrades stay.")
        }
    }

    private var hero: some View {
        PaperPanel {
            VStack(alignment: .leading, spacing: Spacing.m) {
                Text("Reinvent the Quarter to convert your renown into Inspiration — a permanent currency that powers lasting upgrades. Your workshops, coins and zones reset, but achievements, gallery, Inspiration and prestige upgrades stay.")
                    .font(AppFont.body(14))
                    .foregroundStyle(Palette.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: Spacing.s) {
                    CurrencyChip(kind: .inspiration, value: vm.state.inspiration)
                    Spacer(minLength: 0)
                }

                InsetWell {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        HStack(spacing: 5) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Palette.inspiration)
                            Text("You will gain")
                                .font(AppFont.label(11))
                                .foregroundStyle(Palette.inkSoft)
                        }
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(Palette.inspiration)
                            Text(EconomyService.format(vm.pendingInspiration))
                                .font(AppFont.number(34))
                                .foregroundStyle(Palette.inspiration)
                                .minimumScaleFactor(0.6)
                                .lineLimit(1)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(Spacing.m)
                }

                if vm.pendingInspiration <= 0 {
                    Text("Earn more reputation this run to gain Inspiration (you need a higher renown before reinventing).")
                        .font(AppFont.body(12))
                        .foregroundStyle(Palette.inkFaint)
                        .fixedSize(horizontal: false, vertical: true)
                }

                GameButton(kind: .primary, tint: Palette.inspiration, enabled: vm.pendingInspiration > 0) {
                    confirming = true
                } label: {
                    Text("Reinvent (+\(EconomyService.format(vm.pendingInspiration)))")
                }
            }
        }
    }

    private func upgradeCard(_ def: PrestigeUpgradeDef) -> some View {
        let level = vm.state.prestigeLevel(def.kind)
        let cost = EconomyService.prestigeUpgradeCost(def.kind, level: level)
        let maxed = level >= def.maxLevel
        let affordable = vm.state.inspiration >= cost

        return VStack(alignment: .leading, spacing: Spacing.m) {
            HStack(spacing: Spacing.m) {
                ZStack {
                    Circle()
                        .fill(Palette.inspiration.opacity(0.16))
                        .frame(width: 48, height: 48)
                    Image(systemName: def.symbol)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(Palette.inspiration)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(def.name)
                        .font(AppFont.heading(18))
                        .foregroundStyle(Palette.ink)
                    Text(def.detail)
                        .font(AppFont.body(13))
                        .foregroundStyle(Palette.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }

            HStack(spacing: Spacing.s) {
                Text("Level \(level)/\(def.maxLevel)")
                    .font(AppFont.number(13))
                    .foregroundStyle(Palette.inkSoft)
                Spacer(minLength: 0)
                if maxed {
                    Tag(text: "Maxed", color: Palette.success)
                }
            }

            if !maxed {
                GameButton(kind: .secondary, tint: Palette.inspiration, enabled: affordable && !maxed) {
                    vm.buyPrestigeUpgrade(def.kind)
                } label: {
                    HStack(spacing: Spacing.s) {
                        Text("Upgrade")
                        CostBadge(amount: cost, currency: .inspiration, affordable: affordable)
                    }
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
                .stroke(Palette.panelEdge, lineWidth: 1)
        )
        .softShadow()
    }
}
