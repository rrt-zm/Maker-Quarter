import SwiftUI

struct GalleryView: View {
    let onClose: () -> Void
    @Environment(GameViewModel.self) private var vm

    private let columns = [GridItem(.flexible(), spacing: Spacing.m), GridItem(.flexible(), spacing: Spacing.m)]

    var body: some View {
        SheetScreen(title: "Gallery", symbol: "photo.artframe", accent: Palette.plum, onClose: onClose) {
            Text("A showcase of every craft and masterpiece you have unlocked across the quarter.")
                .font(AppFont.body(13))
                .foregroundStyle(Palette.inkSoft)

            SectionHeader(title: "Ateliers", subtitle: "Workshops you have opened", symbol: "house.fill")

            LazyVGrid(columns: columns, spacing: Spacing.m) {
                ForEach(GameConfig.workshops) { def in
                    let workshop = vm.state.workshop(def.kind)
                    if workshop.isOpen {
                        atelierCard(def, level: workshop.level)
                    } else {
                        lockedAtelierCard
                    }
                }
            }

            SectionHeader(title: "Masterpieces", subtitle: "\(vm.state.unlockedMasterpieces.count)/\(GameConfig.masterpieces.count) masterpieces created", symbol: "crown.fill")

            LazyVGrid(columns: columns, spacing: Spacing.m) {
                ForEach(GameConfig.masterpieces) { def in
                    if ProgressionEngine.isMasterpieceUnlocked(vm.state, def: def) {
                        masterpieceCard(def)
                    } else {
                        lockedMasterpieceCard(def)
                    }
                }
            }
        }
    }

    private func atelierCard(_ def: WorkshopDef, level: Int) -> some View {
        let accent = Color(hex: def.accentHex)
        return cardSurface {
            VStack(alignment: .leading, spacing: Spacing.s) {
                iconBadge(def.symbol, tint: accent)
                Text(def.name)
                    .font(AppFont.heading(16))
                    .foregroundStyle(Palette.ink)
                    .lineLimit(1)
                Text(def.product)
                    .font(AppFont.body(12))
                    .foregroundStyle(Palette.inkSoft)
                    .lineLimit(1)
                Tag(text: "Lv \(level)", color: accent)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var lockedAtelierCard: some View {
        cardSurface {
            VStack(alignment: .leading, spacing: Spacing.s) {
                iconBadge("lock.fill", tint: Palette.inkFaint)
                Text("? ? ?")
                    .font(AppFont.heading(16))
                    .foregroundStyle(Palette.inkFaint)
                Text("Open this workshop to discover")
                    .font(AppFont.body(12))
                    .foregroundStyle(Palette.inkFaint)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func masterpieceCard(_ def: MasterpieceDef) -> some View {
        let accent = Color(hex: GameConfig.workshop(def.workshop).accentHex)
        return cardSurface {
            VStack(alignment: .leading, spacing: Spacing.s) {
                iconBadge(def.symbol, tint: accent)
                Text(def.name)
                    .font(AppFont.heading(17))
                    .foregroundStyle(Palette.ink)
                Text(def.flavor)
                    .font(AppFont.body(12))
                    .foregroundStyle(Palette.inkSoft)
                Tag(text: "Created", color: Palette.plum)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func lockedMasterpieceCard(_ def: MasterpieceDef) -> some View {
        cardSurface {
            VStack(alignment: .leading, spacing: Spacing.s) {
                iconBadge("lock.fill", tint: Palette.inkFaint)
                Text("???")
                    .font(AppFont.heading(17))
                    .foregroundStyle(Palette.inkFaint)
                Text("Reach level \(def.requiredLevel) in \(GameConfig.workshop(def.workshop).name)")
                    .font(AppFont.body(12))
                    .foregroundStyle(Palette.inkFaint)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func iconBadge(_ symbol: String, tint: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(tint.opacity(0.16))
                .frame(width: 44, height: 44)
            Image(systemName: symbol)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(tint)
        }
    }

    private func cardSurface<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(Spacing.m)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: Radius.l, style: .continuous)
                    .fill(Palette.panel)
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.l, style: .continuous)
                            .strokeBorder(Palette.panelEdge, lineWidth: 1.5)
                    )
            )
            .softShadow()
    }
}
