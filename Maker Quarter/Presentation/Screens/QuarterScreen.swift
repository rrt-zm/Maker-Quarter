import SwiftUI

struct QuarterScreen: View {
    @Environment(GameViewModel.self) private var vm
    var goToTab: (AppTab) -> Void
    @State private var floats: [FloatingValue] = []
    @State private var tapTrigger = 0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                QuarterScene(
                    workshops: vm.sceneWorkshops,
                    atmosphere: vm.atmosphere,
                    lanternCount: vm.state.decorationCount(.lantern) + vm.state.decorationCount(.stringLights),
                    treeCount: vm.state.decorationCount(.tree) + vm.state.decorationCount(.flowerBed),
                    stars: vm.stars,
                    visitorDensity: min(1, vm.stars / 5 + vm.atmosphere / 400),
                    highQuality: vm.state.settings.highQuality,
                    onTap: { kind in craft(kind, in: geo.size) }
                )
                .ignoresSafeArea(edges: .bottom)

                VStack(spacing: 0) {
                    ResourceHUD(
                        coins: vm.state.coins,
                        reputation: vm.state.reputation,
                        inspiration: vm.state.inspiration,
                        stars: vm.stars,
                        incomePerSecond: vm.totalIncomePerSecond,
                        boostCharge: vm.state.boostCharge,
                        activeBoosts: vm.state.activeBoosts,
                        showInspiration: vm.state.inspiration > 0 || vm.state.prestigeCount > 0,
                        onFestival: { vm.activateFestival() },
                        onMenu: { goToTab(.more) }
                    )
                    Spacer()
                    bottomBar
                }

                ForEach(floats) { value in
                    FloatingValueView(value: value) {
                        floats.removeAll { $0.id == value.id }
                    }
                }

                SparkleBurst(trigger: tapTrigger, color: Palette.gold, count: 8)
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.52)
            }
        }
    }

    private var bottomBar: some View {
        HStack(spacing: Spacing.m) {
            PaperPanel(cornerRadius: Radius.l, padding: Spacing.m) {
                HStack(spacing: Spacing.m) {
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Tap a workshop to craft")
                            .font(AppFont.label(13))
                            .foregroundStyle(Palette.inkSoft)
                        Text("\(vm.state.openWorkshops.count) of \(WorkshopKind.allCases.count) ateliers open")
                            .font(AppFont.body(11))
                            .foregroundStyle(Palette.inkFaint)
                    }
                    Spacer()
                    Button {
                        vm.tapFocused()
                        tapTrigger += 1
                    } label: {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [Palette.clay.mix(with: .white, amount: 0.15), Palette.terracotta],
                                                     startPoint: .top, endPoint: .bottom))
                                .frame(width: 58, height: 58)
                                .softShadow(radius: 8, y: 4)
                            Image(systemName: "hand.tap.fill")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                    .buttonStyle(JuicyButtonStyle(scale: 0.86))
                }
            }
        }
        .padding(.horizontal, Spacing.l)
        .padding(.bottom, 92)
    }

    private func craft(_ kind: WorkshopKind, in size: CGSize) {
        let result = vm.tap(kind)
        tapTrigger += 1
        if result.completed {
            let x = size.width / 2 + CGFloat.random(in: -70...70)
            let y = size.height * 0.5 + CGFloat.random(in: -30...30)
            floats.append(FloatingValue(text: "+\(EconomyService.format(result.coinsGained))",
                                        color: Palette.coin, position: CGPoint(x: x, y: y)))
        }
    }
}
