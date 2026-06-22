import SwiftUI

private struct OnboardingPage: Identifiable {
    let id = Int.random(in: 0...999999)
    let symbol: String
    let accent: Color
    let title: String
    let body: String
}

struct OnboardingView: View {
    let onFinish: () -> Void
    @State private var index = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(symbol: "building.2.fill", accent: Palette.clay,
                       title: "Welcome to the Quarter",
                       body: "You've inherited a quiet block. Open artisan workshops and grow it into a famous creative district."),
        OnboardingPage(symbol: "hand.tap.fill", accent: Palette.terracotta,
                       title: "Craft by Hand",
                       body: "Tap a workshop in the scene to help an artisan craft. Each finished piece earns coins and reputation."),
        OnboardingPage(symbol: "person.fill.badge.plus", accent: Palette.sage,
                       title: "Hire Managers",
                       body: "Hire a manager and a workshop crafts on its own — even while you're away. Idle income keeps the quarter alive."),
        OnboardingPage(symbol: "building.columns.fill", accent: Palette.plum,
                       title: "Combine into Zones",
                       body: "Level up related crafts and combine them into cultural zones for powerful production and reputation bonuses."),
        OnboardingPage(symbol: "leaf.fill", accent: Palette.gold,
                       title: "Shape the Atmosphere",
                       body: "Place lanterns, trees and fountains to draw visitors, raise your star rating, and bring the streets to life.")
    ]

    var body: some View {
        ZStack {
            WarmBackground()
            VStack(spacing: Spacing.xl) {
                Spacer()
                TabView(selection: $index) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { offset, page in
                        pageView(page).tag(offset)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 420)

                HStack(spacing: 8) {
                    ForEach(pages.indices, id: \.self) { dot in
                        Capsule()
                            .fill(dot == index ? Palette.clay : Palette.panelEdge)
                            .frame(width: dot == index ? 22 : 8, height: 8)
                            .animation(.softSpring, value: index)
                    }
                }

                GameButton(kind: .primary, tint: Palette.clay) {
                    if index < pages.count - 1 {
                        withAnimation(.softSpring) { index += 1 }
                    } else {
                        onFinish()
                    }
                } label: {
                    Text(index < pages.count - 1 ? "Next" : "Start Crafting")
                }
                .frame(maxWidth: 260)

                Button("Skip", action: onFinish)
                    .font(AppFont.label(14))
                    .foregroundStyle(Palette.inkFaint)
                    .opacity(index < pages.count - 1 ? 1 : 0)
                Spacer()
            }
            .padding(.horizontal, Spacing.l)
        }
    }

    private func pageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: Spacing.xl) {
            ZStack {
                Circle().fill(page.accent.opacity(0.14)).frame(width: 180, height: 180)
                Circle().fill(page.accent.opacity(0.1)).frame(width: 230, height: 230)
                OnboardingIllustration(symbol: page.symbol, accent: page.accent)
            }
            VStack(spacing: Spacing.m) {
                Text(page.title)
                    .font(AppFont.display(26))
                    .foregroundStyle(Palette.ink)
                    .multilineTextAlignment(.center)
                Text(page.body)
                    .font(AppFont.body(16))
                    .foregroundStyle(Palette.inkSoft)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.m)
            }
        }
        .padding(.horizontal, Spacing.l)
    }
}

private struct OnboardingIllustration: View {
    let symbol: String
    let accent: Color
    @State private var animate = false

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: 72, weight: .bold))
            .foregroundStyle(LinearGradient(colors: [accent.mix(with: .white, amount: 0.2), accent],
                                            startPoint: .top, endPoint: .bottom))
            .scaleEffect(animate ? 1.06 : 0.96)
            .rotationEffect(.degrees(animate ? 3 : -3))
            .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: animate)
            .onAppear { animate = true }
    }
}
