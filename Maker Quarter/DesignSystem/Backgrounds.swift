import SwiftUI

struct WarmBackground: View {
    var body: some View {
        LinearGradient(
            colors: [Palette.parchment, Palette.paper, Palette.paperDeep],
            startPoint: .top,
            endPoint: .bottom
        )
        .overlay(PaperGrain().opacity(0.5))
        .ignoresSafeArea()
    }
}

struct PaperGrain: View {
    var body: some View {
        Canvas { context, size in
            let count = Int(size.width * size.height / 1400)
            var seed: UInt64 = 8765
            func random() -> Double {
                seed = seed &* 6364136223846793005 &+ 1442695040888963407
                return Double((seed >> 33) & 0xFFFFFF) / Double(0xFFFFFF)
            }
            for _ in 0..<count {
                let x = random() * size.width
                let y = random() * size.height
                let r = 0.4 + random() * 0.9
                let opacity = 0.02 + random() * 0.05
                let rect = CGRect(x: x, y: y, width: r, height: r)
                context.fill(Path(ellipseIn: rect), with: .color(Palette.ink.opacity(opacity)))
            }
        }
        .allowsHitTesting(false)
    }
}

struct SoftShadow: ViewModifier {
    var radius: CGFloat = 12
    var y: CGFloat = 6
    func body(content: Content) -> some View {
        content.shadow(color: Palette.panelShadow.opacity(0.45), radius: radius, x: 0, y: y)
    }
}

extension View {
    func softShadow(radius: CGFloat = 12, y: CGFloat = 6) -> some View {
        modifier(SoftShadow(radius: radius, y: y))
    }
}
