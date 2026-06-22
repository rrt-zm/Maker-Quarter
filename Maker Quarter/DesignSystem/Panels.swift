import SwiftUI

struct PaperPanel<Content: View>: View {
    var cornerRadius: CGFloat = Radius.l
    var padding: CGFloat = Spacing.l
    var tint: Color = Palette.panel
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(tint)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(
                                LinearGradient(colors: [Color.white.opacity(0.45), .clear],
                                               startPoint: .top, endPoint: .center)
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(Palette.panelEdge, lineWidth: 1.5)
                    )
            )
            .softShadow()
    }
}

struct InsetWell<Content: View>: View {
    var cornerRadius: CGFloat = Radius.m
    @ViewBuilder var content: Content

    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Palette.paperDeep)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(Palette.panelShadow.opacity(0.35), lineWidth: 1)
                    )
            )
    }
}

struct SectionHeader: View {
    let title: String
    var subtitle: String?
    var symbol: String?

    var body: some View {
        HStack(spacing: Spacing.s) {
            if let symbol {
                Image(systemName: symbol)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Palette.clay)
            }
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(AppFont.heading(20))
                    .foregroundStyle(Palette.ink)
                if let subtitle {
                    Text(subtitle)
                        .font(AppFont.body(12))
                        .foregroundStyle(Palette.inkSoft)
                }
            }
            Spacer(minLength: 0)
        }
    }
}

struct Tag: View {
    let text: String
    var color: Color = Palette.clay
    var filled: Bool = true

    var body: some View {
        Text(text)
            .font(AppFont.label(11))
            .foregroundStyle(filled ? .white : color)
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(
                Capsule().fill(filled ? color : color.opacity(0.14))
            )
    }
}
