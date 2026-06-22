import SwiftUI

struct DecorateScreen: View {
    @Environment(GameViewModel.self) private var vm

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.m),
        GridItem(.flexible(), spacing: Spacing.m)
    ]

    var body: some View {
        GameScreen(title: "Decorate", subtitle: "Bring the streets to life", symbol: "leaf.fill") {
            summary

            SectionHeader(title: "Streets")
            ForEach(GameConfig.streets) { street in
                streetRow(street)
            }

            SectionHeader(title: "Decorations")
            LazyVGrid(columns: columns, spacing: Spacing.m) {
                ForEach(GameConfig.decorations) { def in
                    decorationTile(def)
                }
            }

            SectionHeader(title: "Placed")
            placedSection
        }
    }

    private var summary: some View {
        PaperPanel {
            VStack(alignment: .leading, spacing: Spacing.m) {
                HStack(spacing: Spacing.m) {
                    ZStack {
                        Circle()
                            .fill(Palette.sage.mix(with: Palette.paper, amount: 0.78))
                            .frame(width: 52, height: 52)
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(Palette.sage)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Atmosphere")
                            .font(AppFont.label(13))
                            .foregroundStyle(Palette.inkSoft)
                        Text(EconomyService.format(EconomyService.atmosphere(vm.state)))
                            .font(AppFont.number(24))
                            .foregroundStyle(Palette.ink)
                    }
                    Spacer()
                    Tag(text: "\(vm.state.placedDecorations.count)/\(EconomyService.decorationSlots(vm.state)) slots", color: Palette.sage)
                }

                Text("A lively atmosphere raises reputation passively and draws more visitors to the quarter.")
                    .font(AppFont.body(13))
                    .foregroundStyle(Palette.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func streetRow(_ street: StreetDef) -> some View {
        Group {
            if street.index < vm.state.unlockedStreets {
                panel {
                    HStack(spacing: Spacing.m) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(street.name)
                                .font(AppFont.heading(17))
                                .foregroundStyle(Palette.ink)
                            Text("\(street.decorationSlots) slots")
                                .font(AppFont.body(13))
                                .foregroundStyle(Palette.inkSoft)
                        }
                        Spacer()
                        Tag(text: "Open", color: Palette.sage)
                    }
                }
            } else if street.index == vm.state.unlockedStreets {
                lockedStreet(street)
            } else {
                LockedRow(title: street.name, requirement: "Unlock previous streets first")
            }
        }
    }

    private func lockedStreet(_ street: StreetDef) -> some View {
        let affordable = vm.state.coins >= street.unlockCost
        return panel {
            VStack(alignment: .leading, spacing: Spacing.m) {
                HStack(spacing: Spacing.m) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(street.name)
                            .font(AppFont.heading(17))
                            .foregroundStyle(Palette.ink)
                        Text("\(street.decorationSlots) slots")
                            .font(AppFont.body(13))
                            .foregroundStyle(Palette.inkSoft)
                    }
                    Spacer()
                }
                GameButton(kind: .primary, tint: Palette.brass, enabled: affordable) {
                    vm.unlockStreet()
                } label: {
                    HStack(spacing: Spacing.s) {
                        Text("Unlock \(street.name)")
                        CostBadge(amount: street.unlockCost, currency: .coins, affordable: affordable)
                    }
                }
            }
        }
    }

    private func decorationTile(_ def: DecorationDef) -> some View {
        let accent = Color(hex: def.accentHex)
        let placedCount = vm.state.decorationCount(def.kind)
        let canPlace = vm.state.coins >= def.cost && vm.state.placedDecorations.count < EconomyService.decorationSlots(vm.state)

        return VStack(alignment: .leading, spacing: Spacing.s) {
            HStack {
                ZStack {
                    Circle()
                        .fill(accent.mix(with: Palette.paper, amount: 0.78))
                        .frame(width: 44, height: 44)
                    Image(systemName: def.symbol)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(accent)
                }
                Spacer()
                if placedCount > 0 {
                    Tag(text: "×\(placedCount)", color: accent)
                }
            }

            Text(def.name)
                .font(AppFont.heading(16))
                .foregroundStyle(Palette.ink)
            Text("+\(EconomyService.format(def.atmosphere)) atmosphere")
                .font(AppFont.body(12))
                .foregroundStyle(Palette.inkSoft)

            Spacer(minLength: 0)

            GameButton(kind: .primary, tint: accent, enabled: canPlace) {
                vm.placeDecoration(def.kind)
            } label: {
                HStack(spacing: Spacing.xs) {
                    Text("Place")
                    CostBadge(amount: def.cost, currency: .coins, affordable: canPlace)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.m)
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

    private var placedSection: some View {
        Group {
            if vm.state.placedDecorations.isEmpty {
                EmptyStateView(
                    symbol: "leaf",
                    title: "No decorations yet",
                    message: "Place lanterns, trees and fountains to make the quarter glow.",
                    tint: Palette.sage,
                    actionTitle: nil,
                    action: nil
                )
            } else {
                panel {
                    VStack(alignment: .leading, spacing: Spacing.m) {
                        Text("Tap × to remove (50% refund)")
                            .font(AppFont.body(12))
                            .foregroundStyle(Palette.inkSoft)

                        LazyVGrid(columns: columns, spacing: Spacing.m) {
                            ForEach(vm.state.placedDecorations) { item in
                                placedTile(item)
                            }
                        }
                    }
                }
            }
        }
    }

    private func placedTile(_ item: PlacedDecoration) -> some View {
        let def = GameConfig.decoration(item.kind)
        let accent = Color(hex: def.accentHex)

        return HStack(spacing: Spacing.s) {
            ZStack {
                Circle()
                    .fill(accent.mix(with: Palette.paper, amount: 0.78))
                    .frame(width: 38, height: 38)
                Image(systemName: def.symbol)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(accent)
            }
            Text(def.name)
                .font(AppFont.body(13))
                .foregroundStyle(Palette.ink)
                .lineLimit(1)
            Spacer(minLength: 0)
            IconButton(symbol: "xmark", tint: Palette.danger, size: 30) {
                vm.removeDecoration(item.id)
            }
        }
        .padding(Spacing.s)
        .background(
            RoundedRectangle(cornerRadius: Radius.m, style: .continuous)
                .fill(Palette.paper)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.m, style: .continuous)
                .stroke(Palette.panelEdge, lineWidth: 1)
        )
    }

    private func panel<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(Spacing.l)
            .frame(maxWidth: .infinity, alignment: .leading)
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
