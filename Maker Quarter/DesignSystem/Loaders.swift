import SwiftUI

struct PottersWheelLoader: View {
    var size: CGFloat = 64
    @State private var spin = false

    var body: some View {
        ZStack {
            Circle()
                .fill(Palette.paperDeep)
                .frame(width: size, height: size)
            Circle()
                .fill(Palette.clay.opacity(0.18))
                .frame(width: size * 0.66, height: size * 0.66)
            ForEach(0..<8, id: \.self) { index in
                Capsule()
                    .fill(Palette.clay)
                    .frame(width: 3, height: size * 0.16)
                    .offset(y: -size * 0.28)
                    .rotationEffect(.degrees(Double(index) / 8 * 360))
            }
            Circle()
                .fill(Palette.terracotta)
                .frame(width: size * 0.24, height: size * 0.24)
        }
        .rotationEffect(.degrees(spin ? 360 : 0))
        .animation(.linear(duration: 1.4).repeatForever(autoreverses: false), value: spin)
        .onAppear { spin = true }
    }
}

struct LoadingView: View {
    var message: String = "Opening the quarter…"

    var body: some View {
        VStack(spacing: Spacing.l) {
            PottersWheelLoader(size: 72)
            Text(message)
                .font(AppFont.heading(16))
                .foregroundStyle(Palette.inkSoft)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(WarmBackground())
    }
}

struct EmptyStateView: View {
    let symbol: String
    let title: String
    let message: String
    var tint: Color = Palette.clay
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: Spacing.m) {
            ZStack {
                Circle()
                    .fill(tint.opacity(0.12))
                    .frame(width: 92, height: 92)
                Image(systemName: symbol)
                    .font(.system(size: 38, weight: .semibold))
                    .foregroundStyle(tint.opacity(0.8))
            }
            Text(title)
                .font(AppFont.heading(19))
                .foregroundStyle(Palette.ink)
            Text(message)
                .font(AppFont.body(14))
                .foregroundStyle(Palette.inkSoft)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)
            if let actionTitle, let action {
                GameButton(kind: .ghost, tint: tint, action: action) {
                    Text(actionTitle)
                }
                .frame(maxWidth: 220)
                .padding(.top, Spacing.xs)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xxl)
    }
}

struct ErrorStateView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(spacing: Spacing.m) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(Palette.warning)
            Text("Something needs a second look")
                .font(AppFont.heading(18))
                .foregroundStyle(Palette.ink)
            Text(message)
                .font(AppFont.body(14))
                .foregroundStyle(Palette.inkSoft)
                .multilineTextAlignment(.center)
            GameButton(kind: .primary, tint: Palette.clay, action: retry) {
                Text("Try Again")
            }
            .frame(maxWidth: 200)
        }
        .padding(Spacing.xl)
    }
}
