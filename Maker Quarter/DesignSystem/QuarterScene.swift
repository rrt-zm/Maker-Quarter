import SwiftUI

struct WorkshopVisual: Identifiable, Equatable {
    let kind: WorkshopKind
    let level: Int
    let hasManager: Bool
    let progress: Double
    let accentHex: String
    let symbol: String
    var id: WorkshopKind { kind }
}

struct QuarterScene: View {
    let workshops: [WorkshopVisual]
    let atmosphere: Double
    let lanternCount: Int
    let treeCount: Int
    let stars: Double
    let visitorDensity: Double
    let highQuality: Bool
    var onTap: (WorkshopKind) -> Void

    private let slot: CGFloat = 120

    var body: some View {
        GeometryReader { geo in
            let contentWidth = max(geo.size.width, CGFloat(max(1, workshops.count)) * slot + 48)
            ZStack {
                SkyBackdrop(stars: stars)
                ScrollView(.horizontal, showsIndicators: false) {
                    sceneCanvas(width: contentWidth, height: geo.size.height)
                        .frame(width: contentWidth, height: geo.size.height)
                        .contentShape(Rectangle())
                        .gesture(
                            SpatialTapGesture().onEnded { value in
                                handleTap(at: value.location, width: contentWidth, height: geo.size.height)
                            }
                        )
                }
            }
        }
    }

    private func sceneCanvas(width: CGFloat, height: CGFloat) -> some View {
        TimelineView(.animation(minimumInterval: highQuality ? 1.0 / 60.0 : 1.0 / 30.0)) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                let cycle = (t.truncatingRemainder(dividingBy: 90)) / 90
                let dayFactor = (sin(cycle * 2 * .pi - .pi / 2) + 1) / 2
                let night = 1 - dayFactor
                drawGround(context, size: size, night: night)
                drawStringLights(context, size: size, t: t, night: night)
                for (index, workshop) in workshops.enumerated() {
                    let frame = buildingFrame(index: index, size: size)
                    drawBuilding(context, frame: frame, workshop: workshop, t: t, night: night)
                }
                drawDecor(context, size: size, t: t, night: night)
                drawVisitors(context, size: size, t: t)
            }
        }
    }

    private func buildingFrame(index: Int, size: CGSize) -> CGRect {
        let groundY = size.height * 0.78
        let workshop = workshops[index]
        let height = min(size.height * 0.5, 86 + CGFloat(min(workshop.level, 40)) * 2.2)
        let width = slot * 0.74
        let x = 24 + CGFloat(index) * slot + (slot - width) / 2
        return CGRect(x: x, y: groundY - height, width: width, height: height)
    }

    private func handleTap(at point: CGPoint, width: CGFloat, height: CGFloat) {
        let size = CGSize(width: width, height: height)
        for (index, workshop) in workshops.enumerated() {
            var frame = buildingFrame(index: index, size: size)
            frame = frame.insetBy(dx: -10, dy: -16)
            if frame.contains(point) {
                onTap(workshop.kind)
                return
            }
        }
        if let nearest = workshops.indices.min(by: { lhs, rhs in
            abs(buildingFrame(index: lhs, size: size).midX - point.x) < abs(buildingFrame(index: rhs, size: size).midX - point.x)
        }) {
            onTap(workshops[nearest].kind)
        }
    }

    private func drawGround(_ context: GraphicsContext, size: CGSize, night: Double) {
        let groundY = size.height * 0.78
        let ground = Path(CGRect(x: 0, y: groundY, width: size.width, height: size.height - groundY))
        context.fill(ground, with: .linearGradient(
            Gradient(colors: [Palette.ground.mix(with: .black, amount: night * 0.3),
                              Palette.groundDeep.mix(with: .black, amount: night * 0.35)]),
            startPoint: CGPoint(x: 0, y: groundY),
            endPoint: CGPoint(x: 0, y: size.height)))

        var path = Path()
        path.move(to: CGPoint(x: 0, y: groundY + 14))
        path.addLine(to: CGPoint(x: size.width, y: groundY + 14))
        context.stroke(path, with: .color(Palette.groundDeep.opacity(0.6)), lineWidth: 2)
    }

    private func drawStringLights(_ context: GraphicsContext, size: CGSize, t: Double, night: Double) {
        let topY = size.height * 0.12
        var garland = Path()
        garland.move(to: CGPoint(x: -10, y: topY))
        let segments = max(2, Int(size.width / 60))
        for i in 0...segments {
            let x = size.width * CGFloat(i) / CGFloat(segments)
            let droop = sin(Double(i) + t * 1.2) * 6
            let y = topY + 26 + droop
            garland.addQuadCurve(
                to: CGPoint(x: x, y: y),
                control: CGPoint(x: x - size.width / CGFloat(segments) / 2, y: y + 16))
        }
        context.stroke(garland, with: .color(Palette.ink.opacity(0.35)), lineWidth: 1.5)
        for i in 0...segments {
            let x = size.width * CGFloat(i) / CGFloat(segments)
            let droop = sin(Double(i) + t * 1.2) * 6
            let y = topY + 26 + droop + 14
            let glow = 0.4 + night * 0.6
            let colors = [Palette.gold, Palette.rose, Palette.teal, Palette.sage]
            let color = colors[i % colors.count]
            context.fill(Path(ellipseIn: CGRect(x: x - 4, y: y - 4, width: 8, height: 8)),
                         with: .color(color.opacity(glow)))
            if night > 0.2 {
                context.fill(Path(ellipseIn: CGRect(x: x - 8, y: y - 8, width: 16, height: 16)),
                             with: .color(color.opacity(night * 0.25)))
            }
        }
    }

    private func drawBuilding(_ context: GraphicsContext, frame: CGRect, workshop: WorkshopVisual, t: Double, night: Double) {
        let accent = Color(hex: workshop.accentHex)
        let wall = accent.mix(with: Palette.paper, amount: 0.55).mix(with: .black, amount: night * 0.25)
        let body = Path(roundedRect: frame, cornerRadius: 8)
        context.fill(body, with: .linearGradient(
            Gradient(colors: [wall.mix(with: .white, amount: 0.1), wall.mix(with: .black, amount: 0.08)]),
            startPoint: frame.origin,
            endPoint: CGPoint(x: frame.origin.x, y: frame.maxY)))
        context.stroke(body, with: .color(accent.mix(with: .black, amount: 0.25).opacity(0.5)), lineWidth: 1.5)

        var roof = Path()
        roof.move(to: CGPoint(x: frame.minX - 8, y: frame.minY + 4))
        roof.addLine(to: CGPoint(x: frame.midX, y: frame.minY - 22))
        roof.addLine(to: CGPoint(x: frame.maxX + 8, y: frame.minY + 4))
        roof.closeSubpath()
        context.fill(roof, with: .color(accent.mix(with: .black, amount: 0.3)))

        let signRect = CGRect(x: frame.midX - 16, y: frame.minY - 14, width: 32, height: 22)
        context.fill(Path(roundedRect: signRect, cornerRadius: 6), with: .color(Palette.parchment.mix(with: .black, amount: night * 0.2)))
        context.draw(
            Text(Image(systemName: workshop.symbol)).font(.system(size: 14, weight: .bold)).foregroundColor(accent.mix(with: .black, amount: 0.2)),
            at: CGPoint(x: signRect.midX, y: signRect.midY))

        let windowRect = CGRect(x: frame.minX + frame.width * 0.18, y: frame.minY + frame.height * 0.28,
                                width: frame.width * 0.64, height: frame.height * 0.46)
        let lit = 0.35 + night * 0.55 + (workshop.hasManager ? 0.1 : 0)
        context.fill(Path(roundedRect: windowRect, cornerRadius: 5),
                     with: .color(Palette.gold.opacity(min(0.95, lit))))
        context.stroke(Path(roundedRect: windowRect, cornerRadius: 5),
                       with: .color(accent.mix(with: .black, amount: 0.3).opacity(0.5)), lineWidth: 1.5)

        drawArtisan(context, in: windowRect, accent: accent, workshop: workshop, t: t)

        if night > 0.15 {
            let lantern = CGPoint(x: frame.minX + 6, y: frame.minY + frame.height * 0.2)
            context.fill(Path(ellipseIn: CGRect(x: lantern.x - 9, y: lantern.y - 9, width: 18, height: 18)),
                         with: .color(Palette.gold.opacity(night * 0.3)))
            context.fill(Path(ellipseIn: CGRect(x: lantern.x - 3, y: lantern.y - 4, width: 6, height: 8)),
                         with: .color(Palette.gold))
        }
    }

    private func drawArtisan(_ context: GraphicsContext, in window: CGRect, accent: Color, workshop: WorkshopVisual, t: Double) {
        let baseX = window.midX
        let baseY = window.maxY - 4
        let speed = workshop.hasManager ? 6.0 : 4.0
        let motion = sin(t * speed + Double(workshop.kind.hashValue % 7)) * 0.5 + 0.5

        let benchRect = CGRect(x: window.minX + 4, y: baseY - 8, width: window.width - 8, height: 6)
        context.fill(Path(roundedRect: benchRect, cornerRadius: 2), with: .color(Palette.inkSoft.opacity(0.8)))

        let product = CGRect(x: baseX - 5 + window.width * 0.18, y: benchRect.minY - 6, width: 10, height: 8)
        let grow = 0.4 + workshop.progress * 0.6
        context.fill(Path(roundedRect: product.insetBy(dx: 5 * (1 - grow), dy: 4 * (1 - grow)), cornerRadius: 2),
                     with: .color(accent.mix(with: .white, amount: 0.2)))

        let bodyRect = CGRect(x: baseX - 9 - window.width * 0.12, y: baseY - 22, width: 14, height: 20)
        context.fill(Path(roundedRect: bodyRect, cornerRadius: 6),
                     with: .color(accent.mix(with: .black, amount: 0.05)))

        let head = CGRect(x: bodyRect.midX - 6, y: bodyRect.minY - 11, width: 12, height: 12)
        context.fill(Path(ellipseIn: head), with: .color(Color(hex: "E8C49A")))

        var arm = Path()
        let shoulder = CGPoint(x: bodyRect.maxX - 2, y: bodyRect.minY + 5)
        let handReach = 8 + motion * 6
        let hand = CGPoint(x: shoulder.x + handReach, y: bodyRect.minY + 8 + motion * 4)
        arm.move(to: shoulder)
        arm.addLine(to: hand)
        context.stroke(arm, with: .color(accent.mix(with: .black, amount: 0.05)), lineWidth: 4)
        context.fill(Path(ellipseIn: CGRect(x: hand.x - 3, y: hand.y - 3, width: 6, height: 6)),
                     with: .color(Color(hex: "E8C49A")))
    }

    private func drawDecor(_ context: GraphicsContext, size: CGSize, t: Double, night: Double) {
        let groundY = size.height * 0.78
        for i in 0..<min(treeCount, 6) {
            let x = 40 + CGFloat(i) * (size.width - 80) / 6 + 14
            drawTree(context, base: CGPoint(x: x, y: groundY + 4), sway: sin(t * 1.5 + Double(i)) * 2, night: night)
        }
        for i in 0..<min(lanternCount, 10) {
            let x = 30 + CGFloat(i) * (size.width - 60) / 10
            let y = groundY + 8
            context.fill(Path(roundedRect: CGRect(x: x - 1.5, y: y - 18, width: 3, height: 18), cornerRadius: 1),
                         with: .color(Palette.inkSoft))
            let glow = 0.4 + night * 0.6
            context.fill(Path(ellipseIn: CGRect(x: x - 6, y: y - 26, width: 12, height: 14)),
                         with: .color(Palette.gold.opacity(glow)))
            if night > 0.2 {
                context.fill(Path(ellipseIn: CGRect(x: x - 12, y: y - 30, width: 24, height: 24)),
                             with: .color(Palette.gold.opacity(night * 0.22)))
            }
        }
    }

    private func drawTree(_ context: GraphicsContext, base: CGPoint, sway: Double, night: Double) {
        context.fill(Path(roundedRect: CGRect(x: base.x - 2, y: base.y - 20, width: 4, height: 20), cornerRadius: 1),
                     with: .color(Color(hex: "7A5A3A")))
        let foliage = Palette.sage.mix(with: .black, amount: night * 0.3)
        for layer in 0..<3 {
            let r = 18.0 - Double(layer) * 4
            let cy = base.y - 18 - Double(layer) * 10
            context.fill(Path(ellipseIn: CGRect(x: base.x - r + sway, y: cy - r, width: r * 2, height: r * 2)),
                         with: .color(foliage.opacity(0.95)))
        }
    }

    private func drawVisitors(_ context: GraphicsContext, size: CGSize, t: Double) {
        let groundY = size.height * 0.78
        let count = min(14, Int(visitorDensity * 14) + 1)
        let colors = [Palette.rose, Palette.teal, Palette.plum, Palette.sage, Palette.clay, Palette.brass]
        for i in 0..<count {
            let speed = 18.0 + Double(i % 5) * 6
            let phase = Double(i) * 1.7
            let raw = (t * speed + phase * 40).truncatingRemainder(dividingBy: Double(size.width + 80))
            let x = CGFloat(raw) - 40
            let bob = abs(sin(t * 4 + phase)) * 3
            let y = groundY + 6 + CGFloat(i % 3) * 5 - bob
            let color = colors[i % colors.count]
            context.fill(Path(roundedRect: CGRect(x: x - 3, y: y - 12, width: 7, height: 12), cornerRadius: 3),
                         with: .color(color))
            context.fill(Path(ellipseIn: CGRect(x: x - 3, y: y - 18, width: 6, height: 6)),
                         with: .color(Color(hex: "E8C49A")))
        }
    }
}

struct SkyBackdrop: View {
    let stars: Double

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                let cycle = (t.truncatingRemainder(dividingBy: 90)) / 90
                let dayFactor = (sin(cycle * 2 * .pi - .pi / 2) + 1) / 2
                let topColor = Palette.skyDayTop.mix(with: Palette.skyEveningTop, amount: 1 - dayFactor)
                let bottomColor = Palette.skyDay.mix(with: Palette.skyEvening, amount: 1 - dayFactor)
                context.fill(Path(CGRect(origin: .zero, size: size)),
                             with: .linearGradient(Gradient(colors: [topColor, bottomColor]),
                                                   startPoint: .zero,
                                                   endPoint: CGPoint(x: 0, y: size.height)))

                let sunX = size.width * CGFloat(cycle)
                let sunY = size.height * 0.55 - sin(cycle * .pi) * size.height * 0.4
                let isMoon = dayFactor < 0.4
                let bodyColor = isMoon ? Color(hex: "F3EAD0") : Palette.gold
                context.fill(Path(ellipseIn: CGRect(x: sunX - 18, y: sunY - 18, width: 36, height: 36)),
                             with: .color(bodyColor.opacity(0.9)))
                context.fill(Path(ellipseIn: CGRect(x: sunX - 30, y: sunY - 30, width: 60, height: 60)),
                             with: .color(bodyColor.opacity(0.2)))

                if dayFactor < 0.5 {
                    var seed: UInt64 = 4242
                    func random() -> Double {
                        seed = seed &* 6364136223846793005 &+ 1
                        return Double((seed >> 33) & 0xFFFFFF) / Double(0xFFFFFF)
                    }
                    let twinkle = 1 - dayFactor
                    for _ in 0..<40 {
                        let x = random() * size.width
                        let y = random() * size.height * 0.5
                        let s = 1 + random() * 1.5
                        let flick = 0.4 + 0.6 * abs(sin(t * 2 + x))
                        context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: s, height: s)),
                                     with: .color(.white.opacity(twinkle * flick * 0.9)))
                    }
                }

                for i in 0..<4 {
                    let cloudX = (CGFloat(t * 6).truncatingRemainder(dividingBy: size.width + 120)) + CGFloat(i) * 120 - 120
                    let cloudY = size.height * (0.16 + Double(i % 2) * 0.1)
                    let cloud = Palette.parchment.opacity(0.6 * dayFactor + 0.1)
                    context.fill(Path(ellipseIn: CGRect(x: cloudX, y: cloudY, width: 60, height: 22)), with: .color(cloud))
                    context.fill(Path(ellipseIn: CGRect(x: cloudX + 26, y: cloudY - 8, width: 44, height: 24)), with: .color(cloud))
                }
            }
        }
        .ignoresSafeArea(edges: .top)
    }
}
