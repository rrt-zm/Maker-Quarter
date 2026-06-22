import SwiftUI

struct SparkleBurst: View {
    let trigger: Int
    var color: Color = Palette.gold
    var count: Int = 10
    var radius: CGFloat = 38
    @State private var animate = false
    @State private var angles: [Double] = []

    var body: some View {
        ZStack {
            ForEach(angles.indices, id: \.self) { index in
                Image(systemName: "sparkle")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(color)
                    .offset(x: cos(angles[index]) * (animate ? radius : 4),
                            y: sin(angles[index]) * (animate ? radius : 4))
                    .opacity(animate ? 0 : 1)
                    .scaleEffect(animate ? 0.3 : 1)
            }
        }
        .allowsHitTesting(false)
        .onChange(of: trigger) { _, _ in fire() }
    }

    private func fire() {
        angles = (0..<count).map { _ in Double.random(in: 0..<(2 * .pi)) }
        animate = false
        withAnimation(.easeOut(duration: 0.6)) { animate = true }
    }
}

struct FloatingValue: Identifiable {
    let id = UUID()
    let text: String
    let color: Color
    let position: CGPoint
}

struct FloatingValueView: View {
    let value: FloatingValue
    var onComplete: () -> Void
    @State private var rise = false

    var body: some View {
        Text(value.text)
            .font(AppFont.number(18))
            .foregroundStyle(value.color)
            .shadow(color: .white.opacity(0.7), radius: 1)
            .position(x: value.position.x, y: value.position.y - (rise ? 60 : 0))
            .opacity(rise ? 0 : 1)
            .scaleEffect(rise ? 1.1 : 0.7)
            .onAppear {
                withAnimation(.easeOut(duration: 0.9)) { rise = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { onComplete() }
            }
            .allowsHitTesting(false)
    }
}

struct ConfettiView: View {
    let isActive: Bool
    private let colors: [Color] = [Palette.clay, Palette.gold, Palette.rose, Palette.sage, Palette.teal, Palette.plum]

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                guard isActive else { return }
                let t = timeline.date.timeIntervalSinceReferenceDate
                var seed: UInt64 = 99
                func random() -> Double {
                    seed = seed &* 2862933555777941757 &+ 3037000493
                    return Double((seed >> 33) & 0xFFFFFF) / Double(0xFFFFFF)
                }
                for index in 0..<70 {
                    let speed = 60 + random() * 120
                    let startX = random() * size.width
                    let phase = random() * 10
                    let cycle = (t * speed / 200 + phase)
                    let progress = cycle.truncatingRemainder(dividingBy: 1)
                    let y = progress * (size.height + 60) - 40
                    let sway = sin((t + phase) * 2 + Double(index)) * 18
                    let x = startX + sway
                    let rotation = (t * 3 + phase) .truncatingRemainder(dividingBy: .pi * 2)
                    let w = 6.0 + random() * 4
                    let h = 9.0 + random() * 4
                    var rect = context
                    rect.translateBy(x: x, y: y)
                    rect.rotate(by: .radians(rotation))
                    rect.fill(Path(CGRect(x: -w / 2, y: -h / 2, width: w, height: h)),
                              with: .color(colors[index % colors.count].opacity(0.9)))
                }
            }
        }
        .allowsHitTesting(false)
    }
}
