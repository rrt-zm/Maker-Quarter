import SwiftUI

private enum MoreDestination: String, Identifiable {
    case gallery, achievements, statistics, prestige, settings
    var id: String { rawValue }
}

struct MoreScreen: View {
    @Environment(GameViewModel.self) private var vm
    var goToTab: (AppTab) -> Void
    @State private var destination: MoreDestination?

    private let columns = [GridItem(.flexible(), spacing: Spacing.m), GridItem(.flexible(), spacing: Spacing.m)]

    var body: some View {
        GameScreen(title: "More", subtitle: "Everything in the quarter", symbol: "square.grid.2x2.fill") {
            summary

            LazyVGrid(columns: columns, spacing: Spacing.m) {
                tile("Gallery", "Masterpieces & crafts", "photo.artframe", Palette.plum) { destination = .gallery }
                tile("Achievements", "\(vm.state.unlockedAchievements.count)/\(GameConfig.achievements.count) earned", "rosette", Palette.gold) { destination = .achievements }
                tile("Statistics", "Your lifetime story", "chart.bar.fill", Palette.teal) { destination = .statistics }
                tile("Reinvent", "Prestige for Inspiration", "arrow.triangle.2.circlepath", Palette.inspiration) { destination = .prestige }
                tile("Upgrades", "Automate your ateliers", "hammer.fill", Palette.clay) { goToTab(.workshops) }
                tile("Settings", "Sound, haptics & more", "gearshape.fill", Palette.inkSoft) { destination = .settings }
            }
        }
        .sheet(item: $destination) { dest in
            switch dest {
            case .gallery: GalleryView { destination = nil }
            case .achievements: AchievementsView { destination = nil }
            case .statistics: StatisticsView { destination = nil }
            case .prestige: PrestigeView { destination = nil }
            case .settings: SettingsView { destination = nil }
            }
        }
    }

    private var summary: some View {
        PaperPanel {
            HStack(spacing: Spacing.l) {
                summaryItem("Prestiges", "\(vm.state.prestigeCount)", "arrow.triangle.2.circlepath", Palette.inspiration)
                Divider().frame(height: 36)
                summaryItem("Inspiration", EconomyService.format(vm.state.inspiration), "sparkles", Palette.inspiration)
                Divider().frame(height: 36)
                summaryItem("Zones", "\(vm.state.formedZones.count)", "building.columns.fill", Palette.brass)
            }
        }
    }

    private func summaryItem(_ label: String, _ value: String, _ symbol: String, _ color: Color) -> some View {
        VStack(spacing: 3) {
            Image(systemName: symbol).font(.system(size: 16, weight: .bold)).foregroundStyle(color)
            Text(value).font(AppFont.number(18)).foregroundStyle(Palette.ink)
            Text(label).font(AppFont.label(10)).foregroundStyle(Palette.inkSoft)
        }
        .frame(maxWidth: .infinity)
    }

    private func tile(_ title: String, _ subtitle: String, _ symbol: String, _ color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: Spacing.s) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous).fill(color.opacity(0.16)).frame(width: 44, height: 44)
                    Image(systemName: symbol).font(.system(size: 20, weight: .bold)).foregroundStyle(color)
                }
                Text(title).font(AppFont.heading(17)).foregroundStyle(Palette.ink)
                Text(subtitle).font(AppFont.body(12)).foregroundStyle(Palette.inkSoft).lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Spacing.m)
            .background(
                RoundedRectangle(cornerRadius: Radius.l, style: .continuous)
                    .fill(Palette.panel)
                    .overlay(RoundedRectangle(cornerRadius: Radius.l, style: .continuous).strokeBorder(Palette.panelEdge, lineWidth: 1.5))
            )
            .softShadow(radius: 6, y: 3)
        }
        .buttonStyle(JuicyButtonStyle())
    }
}
