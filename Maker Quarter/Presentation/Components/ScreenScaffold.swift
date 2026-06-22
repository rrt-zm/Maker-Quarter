import SwiftUI

struct GameScreen<Content: View>: View {
    let title: String
    var subtitle: String?
    var symbol: String?
    var accent: Color = Palette.clay
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            WarmBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Spacing.l) {
                    header
                    content
                    Color.clear.frame(height: 96)
                }
                .padding(.horizontal, Spacing.l)
                .padding(.top, Spacing.s)
            }
        }
    }

    private var header: some View {
        HStack(spacing: Spacing.m) {
            if let symbol {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(accent.opacity(0.16))
                        .frame(width: 50, height: 50)
                    Image(systemName: symbol)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(accent)
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppFont.display(28))
                    .foregroundStyle(Palette.ink)
                if let subtitle {
                    Text(subtitle)
                        .font(AppFont.body(14))
                        .foregroundStyle(Palette.inkSoft)
                }
            }
            Spacer()
        }
        .padding(.top, Spacing.s)
    }
}

struct SheetScreen<Content: View>: View {
    let title: String
    var symbol: String?
    var accent: Color = Palette.clay
    let onClose: () -> Void
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            WarmBackground()
            VStack(spacing: 0) {
                HStack {
                    HStack(spacing: Spacing.s) {
                        if let symbol {
                            Image(systemName: symbol)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(accent)
                        }
                        Text(title)
                            .font(AppFont.display(24))
                            .foregroundStyle(Palette.ink)
                    }
                    Spacer()
                    IconButton(symbol: "xmark", tint: Palette.inkSoft, size: 38, action: onClose)
                }
                .padding(.horizontal, Spacing.l)
                .padding(.vertical, Spacing.m)
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: Spacing.l) {
                        content
                        Color.clear.frame(height: 40)
                    }
                    .padding(.horizontal, Spacing.l)
                }
            }
        }
    }
}

struct StatTile: View {
    let label: String
    let value: String
    var symbol: String
    var color: Color = Palette.clay

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack(spacing: 5) {
                Image(systemName: symbol)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(color)
                Text(label)
                    .font(AppFont.label(11))
                    .foregroundStyle(Palette.inkSoft)
            }
            Text(value)
                .font(AppFont.number(20))
                .foregroundStyle(Palette.ink)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.m)
        .background(
            RoundedRectangle(cornerRadius: Radius.m, style: .continuous)
                .fill(Palette.panel)
                .overlay(RoundedRectangle(cornerRadius: Radius.m, style: .continuous)
                    .strokeBorder(color.opacity(0.2), lineWidth: 1.5))
        )
    }
}

struct CostBadge: View {
    let amount: Double
    let currency: CurrencyChip.Kind
    var affordable: Bool

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: currency.symbol)
                .font(.system(size: 12, weight: .bold))
            Text(EconomyService.format(amount))
                .font(AppFont.number(14))
        }
        .foregroundStyle(affordable ? Palette.ink : Palette.danger.opacity(0.8))
    }
}

struct LockedRow: View {
    let title: String
    let requirement: String
    var symbol: String = "lock.fill"

    var body: some View {
        HStack(spacing: Spacing.m) {
            Image(systemName: symbol)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Palette.inkFaint)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppFont.heading(15))
                    .foregroundStyle(Palette.inkSoft)
                Text(requirement)
                    .font(AppFont.body(12))
                    .foregroundStyle(Palette.inkFaint)
            }
            Spacer()
        }
        .padding(Spacing.m)
        .background(
            RoundedRectangle(cornerRadius: Radius.m, style: .continuous)
                .fill(Palette.paperDeep.opacity(0.6))
        )
    }
}
