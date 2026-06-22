import SwiftUI

struct RootView: View {
    @Environment(GameViewModel.self) private var vm
    @State private var tab: AppTab = .quarter

    var body: some View {
        @Bindable var vm = vm
        ZStack(alignment: .bottom) {
            WarmBackground()

            screen
                .transition(.opacity)

            VStack(spacing: 0) {
                Spacer()
                CustomTabBar(selection: $tab, badges: badges)
                    .padding(.bottom, Spacing.s)
            }
            .ignoresSafeArea(.keyboard)

            VStack {
                ToastStack(items: vm.toasts)
                Spacer()
            }
            .padding(.top, 44)

            if let summary = vm.offlineSummary, !vm.showOnboarding {
                WhileYouWereAwayView(summary: summary) { vm.dismissOffline() }
                    .transition(.opacity)
                    .zIndex(2)
            }

            if let celebration = vm.celebration {
                CelebrationOverlay(item: celebration) { vm.dismissCelebration() }
                    .transition(.opacity)
                    .zIndex(3)
            }
        }
        .animation(.gentle, value: tab)
        .animation(.softSpring, value: vm.offlineSummary == nil)
        .fullScreenCover(isPresented: $vm.showOnboarding) {
            OnboardingView { vm.finishOnboarding() }
        }
        .onAppear { vm.onAppear() }
        .environment(\.soundEnabled, vm.state.settings.soundOn)
    }

    @ViewBuilder private var screen: some View {
        switch tab {
        case .quarter: QuarterScreen(goToTab: { tab = $0 })
        case .workshops: WorkshopsScreen()
        case .zones: ZonesScreen()
        case .decorate: DecorateScreen()
        case .quests: QuestsScreen()
        case .more: MoreScreen(goToTab: { tab = $0 })
        }
    }

    private var badges: [AppTab: Int] {
        var result: [AppTab: Int] = [:]
        let ready = GameConfig.quests.indices.filter { ProgressionEngine.status(vm.state, index: $0) == .ready }.count
        if ready > 0 { result[.quests] = ready }
        let zonesReady = ZoneKind.allCases.filter { !vm.state.formedZones.contains($0) && EconomyService.zoneReady(vm.state, zone: $0) && vm.state.reputation >= GameConfig.zone($0).formCost }.count
        if zonesReady > 0 { result[.zones] = zonesReady }
        return result
    }
}
