import SwiftUI

struct ZonesScreen: View {
    @Environment(GameViewModel.self) private var vm

    var body: some View {
        GameScreen(title: "Cultural Zones", subtitle: "Combine crafts into something greater", symbol: "building.columns.fill") {
            intro

            ForEach(GameConfig.zones) { def in
                zoneCard(def)
            }
        }
    }

    private var intro: some View {
        PaperPanel {
            VStack(alignment: .leading, spacing: Spacing.m) {
                Text("Combine related workshops, each raised to the required level, and spend Reputation to form a cultural zone. Formed zones grant permanent production and reputation bonuses.")
                    .font(AppFont.body(14))
                    .foregroundStyle(Palette.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: Spacing.m) {
                    Tag(text: "\(vm.state.formedZones.count)/5 formed", color: Palette.plum)
                    Spacer()
                    CurrencyChip(kind: .reputation, value: vm.state.reputation)
                }
            }
        }
    }

    private func zoneCard(_ def: ZoneDef) -> some View {
        let accent = Color(hex: def.accentHex)
        let formed = vm.state.formedZones.contains(def.kind)

        return VStack(alignment: .leading, spacing: Spacing.m) {
            header(def, accent: accent)

            if formed {
                formedBody(def, accent: accent)
            } else {
                unformedBody(def, accent: accent)
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

    private func header(_ def: ZoneDef, accent: Color) -> some View {
        HStack(spacing: Spacing.m) {
            ZStack {
                Circle()
                    .fill(accent.mix(with: Palette.paper, amount: 0.78))
                    .frame(width: 52, height: 52)
                Image(systemName: def.symbol)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(accent)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(def.name)
                    .font(AppFont.heading(20))
                    .foregroundStyle(Palette.ink)
                Text(def.subtitle)
                    .font(AppFont.body(13))
                    .foregroundStyle(Palette.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
    }

    private func formedBody(_ def: ZoneDef, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Tag(text: "Formed", color: Palette.success)

            VStack(alignment: .leading, spacing: Spacing.s) {
                bonusRow("Production ×\(formatMult(def.productionMultiplier))", accent: accent)
                bonusRow("Reputation ×\(formatMult(def.reputationMultiplier))", accent: accent)
            }
        }
    }

    private func bonusRow(_ text: String, accent: Color) -> some View {
        HStack(spacing: Spacing.s) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(accent)
            Text(text)
                .font(AppFont.body(14))
                .foregroundStyle(Palette.ink)
        }
    }

    private func unformedBody(_ def: ZoneDef, accent: Color) -> some View {
        let levelsMet = EconomyService.zoneReady(vm.state, zone: def.kind)
        let affordable = vm.state.reputation >= def.formCost
        let ready = levelsMet && affordable

        return VStack(alignment: .leading, spacing: Spacing.m) {
            if def.kind == .grandQuarter {
                grandRequirement
            } else {
                memberRequirements(def, accent: accent)
            }

            VStack(alignment: .leading, spacing: Spacing.s) {
                SectionHeader(title: "Will grant", symbol: "sparkles")
                bonusRow("Production ×\(formatMult(def.productionMultiplier))", accent: accent)
                bonusRow("Reputation ×\(formatMult(def.reputationMultiplier))", accent: accent)
            }

            CostBadge(amount: def.formCost, currency: .reputation, affordable: affordable)

            GameButton(kind: .primary, tint: accent, enabled: ready) {
                vm.formZone(def.kind)
            } label: {
                Text("Form Zone")
            }

            if !levelsMet {
                Text("Level up the members to unlock")
                    .font(AppFont.body(12))
                    .foregroundStyle(Palette.inkFaint)
            }
        }
    }

    private func memberRequirements(_ def: ZoneDef, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            ForEach(def.members, id: \.self) { member in
                let level = vm.state.workshop(member).level
                let progress = min(1, Double(level) / Double(def.requiredLevel))
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    HStack {
                        Text(GameConfig.workshop(member).name)
                            .font(AppFont.body(14))
                            .foregroundStyle(Palette.ink)
                        Spacer()
                        Text("Lv \(level)/\(def.requiredLevel)")
                            .font(AppFont.label(13))
                            .foregroundStyle(level >= def.requiredLevel ? Palette.success : Palette.inkSoft)
                    }
                    CraftProgressBar(progress: progress, tint: accent, height: 8)
                }
            }
        }
    }

    private var grandRequirement: some View {
        let required: [ZoneKind] = [.ceramicsCourt, .craftHall, .fineAtelier, .artLane]
        let count = required.filter { vm.state.formedZones.contains($0) }.count
        return VStack(alignment: .leading, spacing: Spacing.s) {
            Text("Form all four cultural zones first")
                .font(AppFont.body(14))
                .foregroundStyle(Palette.inkSoft)
            Tag(text: "\(count)/4 zones formed", color: count >= 4 ? Palette.success : Palette.brass)
        }
    }

    private func formatMult(_ v: Double) -> String {
        v == v.rounded() ? String(Int(v)) : String(format: "%.2g", v)
    }
}
