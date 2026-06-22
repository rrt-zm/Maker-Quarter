import SwiftUI

enum Palette {
    static let clay = Color(hex: "C36A3E")
    static let terracotta = Color(hex: "B25B36")
    static let brass = Color(hex: "C99A4B")
    static let gold = Color(hex: "E0A65A")
    static let rose = Color(hex: "C0556B")
    static let sage = Color(hex: "7C9A57")
    static let teal = Color(hex: "4E9AA6")
    static let plum = Color(hex: "8E6FB0")

    static let paper = Color(hex: "F6EBD9")
    static let paperDeep = Color(hex: "EFE0C8")
    static let parchment = Color(hex: "FBF4E6")
    static let ink = Color(hex: "3B2A20")
    static let inkSoft = Color(hex: "6B5544")
    static let inkFaint = Color(hex: "9A8470")

    static let panel = Color(hex: "FCF6EA")
    static let panelEdge = Color(hex: "E3D2B6")
    static let panelShadow = Color(hex: "C9B392")

    static let coin = Color(hex: "E2A93F")
    static let reputation = Color(hex: "D86A82")
    static let inspiration = Color(hex: "7FA9D6")

    static let skyDay = Color(hex: "F3D9A8")
    static let skyDayTop = Color(hex: "BFE0E6")
    static let skyEvening = Color(hex: "E5A06A")
    static let skyEveningTop = Color(hex: "6A5A8C")
    static let ground = Color(hex: "C7A877")
    static let groundDeep = Color(hex: "A8895F")

    static let success = Color(hex: "6FA85B")
    static let warning = Color(hex: "D8923F")
    static let danger = Color(hex: "C0573F")
}

enum AppFont {
    static func display(_ size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .serif)
    }
    static func heading(_ size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .serif)
    }
    static func body(_ size: CGFloat) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }
    static func number(_ size: CGFloat) -> Font {
        .system(size: size, weight: .heavy, design: .rounded)
    }
    static func label(_ size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }
}

enum Spacing {
    static let xs: CGFloat = 4
    static let s: CGFloat = 8
    static let m: CGFloat = 12
    static let l: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
}

enum Radius {
    static let s: CGFloat = 10
    static let m: CGFloat = 16
    static let l: CGFloat = 22
    static let xl: CGFloat = 30
    static let pill: CGFloat = 999
}

enum Durations {
    static let quick: Double = 0.18
    static let base: Double = 0.32
    static let slow: Double = 0.6
    static let reveal: Double = 0.9
}

extension Animation {
    static var craftPop: Animation { .spring(response: 0.3, dampingFraction: 0.55) }
    static var softSpring: Animation { .spring(response: 0.45, dampingFraction: 0.8) }
    static var gentle: Animation { .easeInOut(duration: Durations.base) }
}
