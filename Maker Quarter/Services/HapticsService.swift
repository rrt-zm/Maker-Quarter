import UIKit

enum HapticStyle {
    case light
    case medium
    case heavy
    case soft
    case rigid
    case success
    case warning
    case error
    case selection
}

final class HapticsService {
    var enabled = true

    private let light = UIImpactFeedbackGenerator(style: .light)
    private let medium = UIImpactFeedbackGenerator(style: .medium)
    private let heavy = UIImpactFeedbackGenerator(style: .heavy)
    private let soft = UIImpactFeedbackGenerator(style: .soft)
    private let rigid = UIImpactFeedbackGenerator(style: .rigid)
    private let notification = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()

    func prepare() {
        light.prepare()
        medium.prepare()
        heavy.prepare()
    }

    func play(_ style: HapticStyle) {
        guard enabled else { return }
        switch style {
        case .light: light.impactOccurred()
        case .medium: medium.impactOccurred()
        case .heavy: heavy.impactOccurred()
        case .soft: soft.impactOccurred()
        case .rigid: rigid.impactOccurred()
        case .success: notification.notificationOccurred(.success)
        case .warning: notification.notificationOccurred(.warning)
        case .error: notification.notificationOccurred(.error)
        case .selection: selectionGenerator.selectionChanged()
        }
    }
}
