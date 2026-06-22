import SwiftUI

struct SettingsView: View {
    let onClose: () -> Void
    @Environment(GameViewModel.self) private var vm
    @State private var confirmingReset = false

    var body: some View {
        SheetScreen(title: "Settings", symbol: "gearshape.fill", accent: Palette.inkSoft, onClose: onClose) {
            audioSection
            gameSection
            aboutSection
        }
        .alert("Reset all progress?", isPresented: $confirmingReset) {
            Button("Reset", role: .destructive) {
                vm.resetProgress()
                onClose()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This permanently deletes your quarter and starts over. Achievements, gallery and prestige are cleared too.")
        }
    }

    private var audioSection: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            SectionHeader(title: "Audio & Feel", symbol: "slider.horizontal.3")

            PaperPanel {
                VStack(spacing: Spacing.s) {
                    settingsRow(
                        icon: "speaker.wave.2.fill",
                        label: "Sound Effects",
                        isOn: Binding(get: { vm.state.settings.soundOn }, set: { vm.setSound($0) })
                    )
                    divider
                    settingsRow(
                        icon: "music.note",
                        label: "Music",
                        isOn: Binding(get: { vm.state.settings.musicOn }, set: { vm.setMusic($0) })
                    )
                    divider
                    settingsRow(
                        icon: "iphone.radiowaves.left.and.right",
                        label: "Haptics",
                        isOn: Binding(get: { vm.state.settings.hapticsOn }, set: { vm.setHaptics($0) })
                    )
                    divider
                    settingsRow(
                        icon: "sparkles",
                        label: "High Quality Animation",
                        isOn: Binding(get: { vm.state.settings.highQuality }, set: { vm.setQuality($0) })
                    )
                }
            }
        }
    }

    private func settingsRow(icon: String, label: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: Spacing.m) {
            ZStack {
                RoundedRectangle(cornerRadius: Radius.s, style: .continuous)
                    .fill(Palette.parchment)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Palette.clay)
            }
            .frame(width: 38, height: 38)

            Text(label)
                .font(AppFont.body(16))
                .foregroundStyle(Palette.ink)

            Spacer(minLength: Spacing.m)

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(Palette.clay)
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(Palette.panelEdge)
            .frame(height: 1)
            .opacity(0.6)
    }

    private var gameSection: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            SectionHeader(title: "Game", symbol: "gamecontroller.fill")

            VStack(spacing: Spacing.s) {
                GameButton(kind: .secondary) {
                    vm.replayTutorial()
                    onClose()
                } label: {
                    HStack(spacing: Spacing.s) {
                        Image(systemName: "book.fill")
                        Text("Replay Tutorial")
                    }
                }

                GameButton(kind: .danger) {
                    confirmingReset = true
                } label: {
                    HStack(spacing: Spacing.s) {
                        Image(systemName: "trash.fill")
                        Text("Reset Progress")
                    }
                }
            }
        }
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            SectionHeader(title: "About", symbol: "info.circle.fill")

            PaperPanel {
                VStack(alignment: .leading, spacing: Spacing.s) {
                    Text("Maker Quarter")
                        .font(AppFont.heading(22))
                        .foregroundStyle(Palette.ink)

                    Text("A cozy tycoon about a creative district of artisan workshops.")
                        .font(AppFont.body(15))
                        .foregroundStyle(Palette.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)

                    divider

                    Text("Made for makers. No ads. No tracking. Plays fully offline.")
                        .font(AppFont.label(13))
                        .foregroundStyle(Palette.inkFaint)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
