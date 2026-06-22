import SwiftUI

private struct HapticsEnabledKey: EnvironmentKey {
    static let defaultValue = true
}

private struct SoundEnabledKey: EnvironmentKey {
    static let defaultValue = true
}

extension EnvironmentValues {
    var hapticsEnabled: Bool {
        get { self[HapticsEnabledKey.self] }
        set { self[HapticsEnabledKey.self] = newValue }
    }
    var soundEnabled: Bool {
        get { self[SoundEnabledKey.self] }
        set { self[SoundEnabledKey.self] = newValue }
    }
}

struct GameHapticModifier: ViewModifier {
    @Environment(\.hapticsEnabled) private var enabled
    let feedback: SensoryFeedback
    let trigger: Int

    func body(content: Content) -> some View {
        content.sensoryFeedback(feedback, trigger: trigger) { _, _ in enabled }
    }
}

extension View {
    func gameHaptic(_ feedback: SensoryFeedback, trigger: Int) -> some View {
        modifier(GameHapticModifier(feedback: feedback, trigger: trigger))
    }
}
