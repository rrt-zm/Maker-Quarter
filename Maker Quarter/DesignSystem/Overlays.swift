import SwiftUI

struct ToastItem: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let symbol: String
    var color: Color = Palette.clay
}

struct ToastView: View {
    let item: ToastItem

    var body: some View {
        HStack(spacing: Spacing.s) {
            Image(systemName: item.symbol)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)
            Text(item.text)
                .font(AppFont.label(14))
                .foregroundStyle(.white)
                .lineLimit(2)
        }
        .padding(.horizontal, Spacing.l)
        .padding(.vertical, Spacing.m)
        .background(
            Capsule().fill(item.color.mix(with: .black, amount: 0.05))
        )
        .softShadow(radius: 10, y: 5)
    }
}

struct ToastStack: View {
    let items: [ToastItem]

    var body: some View {
        VStack(spacing: Spacing.s) {
            ForEach(items) { item in
                ToastView(item: item)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.softSpring, value: items)
        .padding(.top, Spacing.s)
    }
}

struct RewardLine: Identifiable {
    let id = UUID()
    let symbol: String
    let text: String
    let color: Color
}

struct CelebrationItem: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let subtitle: String
    let symbol: String
    var color: Color = Palette.gold
    var rewards: [String] = []
    var confetti: Bool = true

    static func == (lhs: CelebrationItem, rhs: CelebrationItem) -> Bool { lhs.id == rhs.id }
}

struct CelebrationOverlay: View {
    let item: CelebrationItem
    let onDismiss: () -> Void
    @State private var appear = false

    var body: some View {
        ZStack {
            Color.black.opacity(appear ? 0.45 : 0)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }
            if item.confetti {
                ConfettiView(isActive: appear)
            }
            VStack(spacing: Spacing.l) {
                ZStack {
                    Circle()
                        .fill(item.color.opacity(0.2))
                        .frame(width: 120, height: 120)
                    Circle()
                        .fill(LinearGradient(colors: [item.color.mix(with: .white, amount: 0.2), item.color],
                                             startPoint: .top, endPoint: .bottom))
                        .frame(width: 92, height: 92)
                        .softShadow(radius: 10, y: 6)
                    Image(systemName: item.symbol)
                        .font(.system(size: 42, weight: .bold))
                        .foregroundStyle(.white)
                }
                .scaleEffect(appear ? 1 : 0.4)
                .rotationEffect(.degrees(appear ? 0 : -20))

                VStack(spacing: Spacing.xs) {
                    Text(item.title)
                        .font(AppFont.display(26))
                        .foregroundStyle(Palette.ink)
                        .multilineTextAlignment(.center)
                    Text(item.subtitle)
                        .font(AppFont.body(15))
                        .foregroundStyle(Palette.inkSoft)
                        .multilineTextAlignment(.center)
                }

                if !item.rewards.isEmpty {
                    VStack(spacing: Spacing.xs) {
                        ForEach(item.rewards, id: \.self) { reward in
                            Text(reward)
                                .font(AppFont.label(14))
                                .foregroundStyle(Palette.clay)
                        }
                    }
                }

                GameButton(kind: .primary, tint: item.color, action: dismiss) {
                    Text("Wonderful")
                }
                .frame(maxWidth: 200)
            }
            .padding(Spacing.xl)
            .background(
                RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
                    .fill(Palette.parchment)
                    .overlay(RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
                        .strokeBorder(item.color.opacity(0.3), lineWidth: 2))
            )
            .softShadow(radius: 24, y: 12)
            .padding(Spacing.xl)
            .scaleEffect(appear ? 1 : 0.7)
            .opacity(appear ? 1 : 0)
        }
        .onAppear { withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { appear = true } }
    }

    private func dismiss() {
        withAnimation(.easeIn(duration: 0.2)) { appear = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: onDismiss)
    }
}
