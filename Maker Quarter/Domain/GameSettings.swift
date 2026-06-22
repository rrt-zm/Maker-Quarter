import Foundation

struct GameSettings: Codable, Hashable {
    var soundOn: Bool = true
    var musicOn: Bool = true
    var hapticsOn: Bool = true
    var highQuality: Bool = true
    var tutorialCompleted: Bool = false
}
