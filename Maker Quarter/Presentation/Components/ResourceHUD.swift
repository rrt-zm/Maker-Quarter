import SwiftUI

struct ResourceHUD: View {
    let coins: Double
    let reputation: Double
    let inspiration: Double
    let stars: Double
    let incomePerSecond: Double
    let boostCharge: Double
    let activeBoosts: [ActiveBoost]
    let showInspiration: Bool
    var onFestival: () -> Void
    var onMenu: () -> Void

    var body: some View {
        VStack(spacing: Spacing.s) {
            HStack(spacing: Spacing.s) {
                CurrencyChip(kind: .coins, value: coins)
                CurrencyChip(kind: .reputation, value: reputation, compact: true)
                if showInspiration {
                    CurrencyChip(kind: .inspiration, value: inspiration, compact: true)
                }
                Spacer(minLength: 0)
                IconButton(symbol: "line.3.horizontal", tint: Palette.inkSoft, size: 38, action: onMenu)
            }
            HStack(spacing: Spacing.s) {
                HStack(spacing: 6) {
                    StarRating(rating: stars, size: 13)
                    Text(String(format: "%.1f", stars))
                        .font(AppFont.number(12))
                        .foregroundStyle(Palette.inkSoft)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Capsule().fill(Palette.panel.opacity(0.9)))

                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(Palette.sage)
                    Text("\(EconomyService.format(incomePerSecond))/s")
                        .font(AppFont.number(12))
                        .foregroundStyle(Palette.inkSoft)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Capsule().fill(Palette.panel.opacity(0.9)))

                Spacer(minLength: 0)

                festivalButton
            }
            if !activeBoosts.isEmpty {
                HStack(spacing: Spacing.s) {
                    ForEach(activeBoosts) { boost in
                        BoostPill(boost: boost)
                    }
                    Spacer(minLength: 0)
                }
            }
        }
        .padding(.horizontal, Spacing.l)
        .padding(.top, Spacing.s)
    }

    private var festivalButton: some View {
        Button(action: onFestival) {
            HStack(spacing: 5) {
                Image(systemName: "party.popper.fill")
                    .font(.system(size: 12, weight: .bold))
                if boostCharge >= 1 {
                    Text("Festival!")
                        .font(AppFont.label(12))
                } else {
                    Text("\(Int(boostCharge * 100))%")
                        .font(AppFont.number(12))
                }
            }
            .foregroundStyle(boostCharge >= 1 ? .white : Palette.inkSoft)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                Capsule().fill(boostCharge >= 1 ? Palette.rose : Palette.panel.opacity(0.9))
                    .overlay(
                        Capsule().strokeBorder(Palette.rose.opacity(boostCharge >= 1 ? 0 : 0.3), lineWidth: 1.5)
                    )
            )
            .scaleEffect(boostCharge >= 1 ? 1.04 : 1)
            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: boostCharge >= 1)
        }
        .buttonStyle(JuicyButtonStyle())
        .disabled(boostCharge < 1)
    }
}

struct BoostPill: View {
    let boost: ActiveBoost

    var body: some View {
        let def = GameConfig.boost(boost.kind)
        HStack(spacing: 4) {
            Image(systemName: def.symbol)
                .font(.system(size: 10, weight: .bold))
            Text(def.detail)
                .font(AppFont.label(10))
            Text(EconomyService.formatTime(boost.remaining))
                .font(AppFont.number(10))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(Capsule().fill(Palette.gold.mix(with: .black, amount: 0.05)))
    }
}
