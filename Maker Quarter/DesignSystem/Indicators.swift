import SwiftUI

struct RollingNumber: View {
    let value: Double
    var font: Font = AppFont.number(18)
    var color: Color = Palette.ink

    var body: some View {
        Text(EconomyService.format(value))
            .font(font)
            .foregroundStyle(color)
            .monospacedDigit()
            .contentTransition(.numericText(value: value))
            .animation(.spring(response: 0.4, dampingFraction: 0.9), value: value)
    }
}

struct CurrencyChip: View {
    enum Kind {
        case coins, reputation, inspiration
        var symbol: String {
            switch self {
            case .coins: return "circle.circle.fill"
            case .reputation: return "star.fill"
            case .inspiration: return "sparkles"
            }
        }
        var color: Color {
            switch self {
            case .coins: return Palette.coin
            case .reputation: return Palette.reputation
            case .inspiration: return Palette.inspiration
            }
        }
    }

    let kind: Kind
    let value: Double
    var compact: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: kind.symbol)
                .font(.system(size: compact ? 12 : 14, weight: .bold))
                .foregroundStyle(kind.color)
            RollingNumber(value: value, font: AppFont.number(compact ? 14 : 16), color: Palette.ink)
        }
        .padding(.horizontal, compact ? 10 : 12)
        .padding(.vertical, compact ? 6 : 8)
        .background(
            Capsule()
                .fill(Palette.panel)
                .overlay(Capsule().strokeBorder(kind.color.opacity(0.35), lineWidth: 1.5))
        )
        .softShadow(radius: 4, y: 2)
    }
}

struct StarRating: View {
    let rating: Double
    var size: CGFloat = 14

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5, id: \.self) { index in
                Image(systemName: symbol(for: index))
                    .font(.system(size: size, weight: .semibold))
                    .foregroundStyle(Palette.gold)
            }
        }
    }

    private func symbol(for index: Int) -> String {
        let filled = rating - Double(index)
        if filled >= 0.75 { return "star.fill" }
        if filled >= 0.25 { return "star.leadinghalf.filled" }
        return "star"
    }
}

struct CraftProgressBar: View {
    let progress: Double
    var tint: Color = Palette.clay
    var height: CGFloat = 10

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Palette.paperDeep)
                Capsule()
                    .fill(LinearGradient(colors: [tint.mix(with: .white, amount: 0.2), tint],
                                         startPoint: .leading, endPoint: .trailing))
                    .frame(width: max(height, geo.size.width * min(1, max(0, progress))))
                    .overlay(
                        Capsule().fill(Color.white.opacity(0.25))
                            .frame(height: height * 0.35)
                            .padding(.horizontal, 3)
                            .offset(y: -height * 0.22),
                        alignment: .top
                    )
            }
        }
        .frame(height: height)
    }
}

struct RingProgress: View {
    let progress: Double
    var tint: Color = Palette.clay
    var lineWidth: CGFloat = 6

    var body: some View {
        ZStack {
            Circle().stroke(Palette.paperDeep, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(1, max(0, progress)))
                .stroke(tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}
