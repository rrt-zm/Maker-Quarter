import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case quarter
    case workshops
    case zones
    case decorate
    case quests
    case more

    var id: String { rawValue }

    var title: String {
        switch self {
        case .quarter: return "Quarter"
        case .workshops: return "Workshops"
        case .zones: return "Zones"
        case .decorate: return "Decorate"
        case .quests: return "Quests"
        case .more: return "More"
        }
    }

    var symbol: String {
        switch self {
        case .quarter: return "building.2.fill"
        case .workshops: return "hammer.fill"
        case .zones: return "building.columns.fill"
        case .decorate: return "leaf.fill"
        case .quests: return "scroll.fill"
        case .more: return "square.grid.2x2.fill"
        }
    }
}

struct CustomTabBar: View {
    @Binding var selection: AppTab
    var badges: [AppTab: Int] = [:]
    @State private var taps = 0

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                tabButton(tab)
            }
        }
        .padding(.horizontal, Spacing.xs)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
                .fill(Palette.panel)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
                        .strokeBorder(Palette.panelEdge, lineWidth: 1.5)
                )
        )
        .softShadow(radius: 14, y: 6)
        .padding(.horizontal, Spacing.l)
        .gameHaptic(.selection, trigger: taps)
    }

    private func tabButton(_ tab: AppTab) -> some View {
        let isSelected = selection == tab
        return Button {
            taps += 1
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) { selection = tab }
        } label: {
            VStack(spacing: 3) {
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Palette.clay.opacity(0.16))
                            .matchedGeometryEffect(id: "tabHighlight", in: namespace)
                            .frame(width: 46, height: 32)
                    }
                    Image(systemName: tab.symbol)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(isSelected ? Palette.clay : Palette.inkFaint)
                        .scaleEffect(isSelected ? 1.08 : 1)
                        .overlay(alignment: .topTrailing) {
                            if let count = badges[tab], count > 0 {
                                Text("\(count)")
                                    .font(.system(size: 9, weight: .heavy))
                                    .foregroundStyle(.white)
                                    .padding(4)
                                    .background(Circle().fill(Palette.rose))
                                    .offset(x: 12, y: -8)
                            }
                        }
                }
                Text(tab.title)
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                    .foregroundStyle(isSelected ? Palette.clay : Palette.inkFaint)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(JuicyButtonStyle(scale: 0.9))
    }

    @Namespace private var namespace
}
