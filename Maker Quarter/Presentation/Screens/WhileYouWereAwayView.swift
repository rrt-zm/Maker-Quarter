import SwiftUI

struct WhileYouWereAwayView: View {
    let summary: OfflineSummary
    let onDismiss: () -> Void
    @State private var appear = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()
            VStack(spacing: Spacing.l) {
                ZStack {
                    Circle().fill(Palette.gold.opacity(0.2)).frame(width: 110, height: 110)
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 46, weight: .bold))
                        .foregroundStyle(Palette.gold)
                        .rotationEffect(.degrees(appear ? 0 : -15))
                }

                VStack(spacing: 4) {
                    Text("While You Were Away")
                        .font(AppFont.display(24))
                        .foregroundStyle(Palette.ink)
                    Text("The quarter kept working for \(EconomyService.formatTime(summary.cappedElapsed)).")
                        .font(AppFont.body(14))
                        .foregroundStyle(Palette.inkSoft)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: Spacing.s) {
                    earningRow(symbol: "circle.circle.fill", color: Palette.coin, label: "Coins earned", value: summary.coins)
                    if summary.reputation >= 1 {
                        earningRow(symbol: "star.fill", color: Palette.reputation, label: "Reputation earned", value: summary.reputation)
                    }
                }

                if summary.wasCapped {
                    Text("Offline earnings are capped. Hire managers and upgrade Patron Network to earn more while away.")
                        .font(AppFont.body(11))
                        .foregroundStyle(Palette.inkFaint)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.m)
                }

                GameButton(kind: .primary, tint: Palette.clay, action: onDismiss) {
                    Text("Welcome Back")
                }
                .frame(maxWidth: 220)
            }
            .padding(Spacing.xl)
            .background(
                RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
                    .fill(Palette.parchment)
                    .overlay(RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
                        .strokeBorder(Palette.gold.opacity(0.3), lineWidth: 2))
            )
            .softShadow(radius: 24, y: 12)
            .padding(Spacing.xl)
            .scaleEffect(appear ? 1 : 0.8)
            .opacity(appear ? 1 : 0)
        }
        .onAppear { withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) { appear = true } }
    }

    private func earningRow(symbol: String, color: Color, label: String, value: Double) -> some View {
        HStack(spacing: Spacing.m) {
            Image(systemName: symbol)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(color)
            Text(label)
                .font(AppFont.body(14))
                .foregroundStyle(Palette.inkSoft)
            Spacer()
            Text("+\(EconomyService.format(value))")
                .font(AppFont.number(18))
                .foregroundStyle(Palette.ink)
        }
        .padding(.horizontal, Spacing.m)
        .padding(.vertical, Spacing.s)
        .background(
            RoundedRectangle(cornerRadius: Radius.m, style: .continuous).fill(Palette.panel)
        )
    }
}
