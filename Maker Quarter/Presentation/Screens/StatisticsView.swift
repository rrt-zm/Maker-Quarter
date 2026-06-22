import SwiftUI

struct StatisticsView: View {
    let onClose: () -> Void
    @Environment(GameViewModel.self) private var vm

    private let columns = [GridItem(.flexible(), spacing: Spacing.m), GridItem(.flexible(), spacing: Spacing.m)]

    var body: some View {
        SheetScreen(title: "Statistics", symbol: "chart.bar.fill", accent: Palette.teal, onClose: onClose) {
            let s = vm.state.statistics

            Text("A snapshot of everything your hands have shaped so far.")
                .font(AppFont.body(13))
                .foregroundStyle(Palette.inkSoft)

            LazyVGrid(columns: columns, spacing: Spacing.m) {
                StatTile(label: "Goods Crafted", value: EconomyService.format(Double(s.goodsCrafted)), symbol: "shippingbox.fill", color: Palette.clay)
                StatTile(label: "Coins Earned", value: EconomyService.format(s.coinsEarned), symbol: "circle.circle.fill", color: Palette.coin)
                StatTile(label: "Reputation Earned", value: EconomyService.format(s.reputationEarned), symbol: "star.fill", color: Palette.reputation)
                StatTile(label: "Workshops Opened", value: "\(s.workshopsOpened)", symbol: "hammer.fill", color: Palette.brass)
                StatTile(label: "Upgrades", value: "\(s.workshopUpgrades)", symbol: "arrow.up.circle.fill", color: Palette.sage)
                StatTile(label: "Zones Formed", value: "\(s.zonesFormed)", symbol: "building.columns.fill", color: Palette.plum)
                StatTile(label: "Visitors Welcomed", value: EconomyService.format(Double(s.visitorsWelcomed)), symbol: "figure.walk", color: Palette.teal)
                StatTile(label: "Decorations Placed", value: "\(s.decorationsPlaced)", symbol: "leaf.fill", color: Palette.sage)
                StatTile(label: "Managers Hired", value: "\(s.managersHired)", symbol: "person.fill", color: Palette.clay)
                StatTile(label: "Taps", value: EconomyService.format(Double(s.taps)), symbol: "hand.tap.fill", color: Palette.terracotta)
                StatTile(label: "Prestiges", value: "\(s.prestiges)", symbol: "arrow.triangle.2.circlepath", color: Palette.inspiration)
                StatTile(label: "Boosts Used", value: "\(s.boostsActivated)", symbol: "party.popper.fill", color: Palette.rose)
                StatTile(label: "Time Played", value: EconomyService.formatTime(s.secondsPlayed), symbol: "clock.fill", color: Palette.inkSoft)
            }

            SectionHeader(title: "Workshop Levels", subtitle: "How far each craft has grown", symbol: "chart.bar.xaxis")

            PaperPanel {
                VStack(alignment: .leading, spacing: Spacing.m) {
                    ForEach(barRows, id: \.kind) { row in
                        workshopBar(name: row.name, level: row.level, accent: row.accent, maxLevel: maxLevel)
                    }
                }
            }

            Text("Every number here is a piece of the quarter's story.")
                .font(AppFont.body(12))
                .foregroundStyle(Palette.inkFaint)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, Spacing.s)
        }
    }

    private struct BarRow {
        let kind: WorkshopKind
        let name: String
        let level: Int
        let accent: Color
    }

    private var barRows: [BarRow] {
        var rows: [BarRow] = []
        for def in GameConfig.workshops {
            let workshop = vm.state.workshop(def.kind)
            if workshop.isOpen {
                rows.append(BarRow(kind: def.kind, name: def.name, level: workshop.level, accent: Color(hex: def.accentHex)))
            }
        }
        if rows.isEmpty, let pottery = GameConfig.workshops.first {
            let workshop = vm.state.workshop(pottery.kind)
            rows.append(BarRow(kind: pottery.kind, name: pottery.name, level: workshop.level, accent: Color(hex: pottery.accentHex)))
        }
        return rows
    }

    private var maxLevel: Int {
        let top = barRows.map(\.level).max() ?? 0
        return top == 0 ? 1 : top
    }

    private func workshopBar(name: String, level: Int, accent: Color, maxLevel: Int) -> some View {
        let fraction = min(1.0, max(0.0, Double(level) / Double(maxLevel)))
        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(name)
                    .font(AppFont.label(13))
                    .foregroundStyle(Palette.ink)
                    .lineLimit(1)
                Spacer(minLength: Spacing.s)
                Text("Lv \(level)")
                    .font(AppFont.number(13))
                    .foregroundStyle(accent)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Palette.paperDeep)
                    Capsule()
                        .fill(accent.mix(with: .white, amount: 0.1))
                        .frame(width: max(8, geo.size.width * fraction))
                }
            }
            .frame(height: 14)
        }
    }
}
