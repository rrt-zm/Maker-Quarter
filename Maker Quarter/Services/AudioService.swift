import AVFoundation

enum SoundEffect {
    case tap
    case craft
    case coin
    case upgrade
    case success
    case unlock
    case error
    case prestige
}

final class AudioService {
    var soundEnabled = true
    var musicEnabled = true

    private let engine = AVAudioEngine()
    private let effectPlayer = AVAudioPlayerNode()
    private let musicPlayer = AVAudioPlayerNode()
    private let sampleRate: Double = 44_100
    private var format: AVAudioFormat?
    private var started = false
    private var musicBuffer: AVAudioPCMBuffer?
    private var effectCache: [String: AVAudioPCMBuffer] = [:]

    func configure() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
        try? session.setActive(true)

        let outputFormat = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)
        format = outputFormat
        guard let outputFormat else { return }

        engine.attach(effectPlayer)
        engine.attach(musicPlayer)
        engine.connect(effectPlayer, to: engine.mainMixerNode, format: outputFormat)
        engine.connect(musicPlayer, to: engine.mainMixerNode, format: outputFormat)
        engine.prepare()
        do {
            try engine.start()
            started = true
            effectPlayer.play()
            musicPlayer.play()
        } catch {
            started = false
        }
        if musicEnabled { startMusic() }
    }

    func play(_ effect: SoundEffect) {
        guard soundEnabled, started, let buffer = buffer(for: effect) else { return }
        effectPlayer.scheduleBuffer(buffer, at: nil, options: [.interrupts], completionHandler: nil)
    }

    func setMusic(_ on: Bool) {
        musicEnabled = on
        if on { startMusic() } else { stopMusic() }
    }

    private func startMusic() {
        guard started, musicEnabled else { return }
        if musicBuffer == nil { musicBuffer = makeMusicBuffer() }
        guard let musicBuffer else { return }
        musicPlayer.scheduleBuffer(musicBuffer, at: nil, options: [.loops], completionHandler: nil)
        musicPlayer.volume = 0.16
    }

    private func stopMusic() {
        guard started else { return }
        musicPlayer.stop()
        musicPlayer.play()
    }

    private func buffer(for effect: SoundEffect) -> AVAudioPCMBuffer? {
        let key = String(describing: effect)
        if let cached = effectCache[key] { return cached }
        let buffer: AVAudioPCMBuffer?
        switch effect {
        case .tap: buffer = makeTone(frequencies: [660], duration: 0.08, attack: 0.005, release: 0.07, volume: 0.22)
        case .craft: buffer = makeTone(frequencies: [523.25, 783.99], duration: 0.16, attack: 0.005, release: 0.14, volume: 0.22)
        case .coin: buffer = makeTone(frequencies: [987.77, 1318.51], duration: 0.12, attack: 0.004, release: 0.1, volume: 0.18)
        case .upgrade: buffer = makeTone(frequencies: [392, 587.33, 783.99], duration: 0.32, attack: 0.01, release: 0.28, volume: 0.24)
        case .success: buffer = makeTone(frequencies: [523.25, 659.25, 783.99], duration: 0.36, attack: 0.01, release: 0.3, volume: 0.24)
        case .unlock: buffer = makeTone(frequencies: [440, 554.37, 659.25, 880], duration: 0.5, attack: 0.01, release: 0.42, volume: 0.26)
        case .error: buffer = makeTone(frequencies: [196, 185], duration: 0.2, attack: 0.005, release: 0.18, volume: 0.2)
        case .prestige: buffer = makeTone(frequencies: [261.63, 392, 523.25, 659.25, 783.99], duration: 0.8, attack: 0.02, release: 0.7, volume: 0.26)
        }
        effectCache[key] = buffer
        return buffer
    }

    private func makeTone(frequencies: [Double], duration: Double, attack: Double, release: Double, volume: Double) -> AVAudioPCMBuffer? {
        guard let format else { return nil }
        let frameCount = AVAudioFrameCount(duration * sampleRate)
        guard frameCount > 0, let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        buffer.frameLength = frameCount
        guard let channel = buffer.floatChannelData?[0] else { return nil }
        let amplitude = Float(volume / Double(max(1, frequencies.count)))
        for frame in 0..<Int(frameCount) {
            let t = Double(frame) / sampleRate
            var sample: Double = 0
            for (offset, freq) in frequencies.enumerated() {
                let detune = 1 + Double(offset) * 0.0008
                sample += sin(2 * .pi * freq * detune * t)
            }
            let env = envelope(t: t, duration: duration, attack: attack, release: release)
            channel[frame] = Float(sample) * amplitude * Float(env)
        }
        return buffer
    }

    private func envelope(t: Double, duration: Double, attack: Double, release: Double) -> Double {
        if t < attack { return t / attack }
        let releaseStart = duration - release
        if t > releaseStart { return max(0, (duration - t) / release) }
        return 1
    }

    private func makeMusicBuffer() -> AVAudioPCMBuffer? {
        guard let format else { return nil }
        let duration: Double = 16
        let frameCount = AVAudioFrameCount(duration * sampleRate)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        buffer.frameLength = frameCount
        guard let channel = buffer.floatChannelData?[0] else { return nil }
        let progression: [[Double]] = [
            [130.81, 164.81, 196.00],
            [146.83, 174.61, 220.00],
            [110.00, 164.81, 196.00],
            [123.47, 155.56, 196.00]
        ]
        let chordDuration = duration / Double(progression.count)
        for frame in 0..<Int(frameCount) {
            let t = Double(frame) / sampleRate
            let chordIndex = min(progression.count - 1, Int(t / chordDuration))
            let chord = progression[chordIndex]
            let localT = t - Double(chordIndex) * chordDuration
            let fade = min(1, localT / 1.5) * min(1, (chordDuration - localT) / 1.5)
            var sample: Double = 0
            for freq in chord {
                sample += sin(2 * .pi * freq * t)
                sample += 0.3 * sin(2 * .pi * freq * 2 * t)
            }
            let shimmer = 0.04 * sin(2 * .pi * 0.1 * t)
            channel[frame] = Float((sample / Double(chord.count) * 0.5 + shimmer) * max(0, fade))
        }
        return buffer
    }
}
