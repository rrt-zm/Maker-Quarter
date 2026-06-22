import SwiftUI

@main
struct Maker_QuarterApp: App {
    @State private var viewModel = GameViewModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(viewModel)
                .environment(\.hapticsEnabled, viewModel.state.settings.hapticsOn)
                .onChange(of: scenePhase) { _, phase in
                    switch phase {
                    case .background: viewModel.enterBackground()
                    case .active: viewModel.enterForeground()
                    default: break
                    }
                }
        }
    }
}
