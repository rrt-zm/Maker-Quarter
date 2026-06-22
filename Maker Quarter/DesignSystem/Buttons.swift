import SwiftUI

struct JuicyButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.93
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .brightness(configuration.isPressed ? -0.04 : 0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

enum GameButtonKind {
    case primary
    case secondary
    case ghost
    case danger
}

struct GameButton<Label: View>: View {
    var kind: GameButtonKind = .primary
    var tint: Color = Palette.clay
    var enabled: Bool = true
    var feedback: SensoryFeedback = .impact(weight: .medium)
    let action: () -> Void
    @ViewBuilder var label: Label

    @State private var taps = 0

    var body: some View {
        Button {
            guard enabled else { return }
            taps += 1
            action()
        } label: {
            label
                .font(AppFont.label(16))
                .foregroundStyle(foreground)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(background)
                .clipShape(RoundedRectangle(cornerRadius: Radius.m, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.m, style: .continuous)
                        .strokeBorder(borderColor, lineWidth: kind == .ghost ? 1.5 : 0)
                )
                .opacity(enabled ? 1 : 0.45)
                .softShadow(radius: enabled && kind == .primary ? 8 : 0, y: 4)
        }
        .buttonStyle(JuicyButtonStyle())
        .disabled(!enabled)
        .gameHaptic(feedback, trigger: taps)
    }

    private var foreground: Color {
        switch kind {
        case .primary, .danger: return .white
        case .secondary: return Palette.ink
        case .ghost: return tint
        }
    }

    @ViewBuilder private var background: some View {
        switch kind {
        case .primary:
            LinearGradient(colors: [tint.mix(with: .white, amount: 0.12), tint.mix(with: .black, amount: 0.08)],
                           startPoint: .top, endPoint: .bottom)
        case .danger:
            LinearGradient(colors: [Palette.danger.mix(with: .white, amount: 0.1), Palette.danger.mix(with: .black, amount: 0.08)],
                           startPoint: .top, endPoint: .bottom)
        case .secondary:
            Palette.panel
        case .ghost:
            Color.clear
        }
    }

    private var borderColor: Color {
        kind == .ghost ? tint.opacity(0.6) : .clear
    }
}

struct IconButton: View {
    let symbol: String
    var tint: Color = Palette.clay
    var size: CGFloat = 44
    var feedback: SensoryFeedback = .impact(weight: .light)
    let action: () -> Void
    @State private var taps = 0

    var body: some View {
        Button {
            taps += 1
            action()
        } label: {
            Image(systemName: symbol)
                .font(.system(size: size * 0.4, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(Palette.panel)
                        .overlay(Circle().strokeBorder(Palette.panelEdge, lineWidth: 1.5))
                )
                .softShadow(radius: 5, y: 3)
        }
        .buttonStyle(JuicyButtonStyle())
        .gameHaptic(feedback, trigger: taps)
    }
}
