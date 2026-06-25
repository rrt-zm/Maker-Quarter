import Foundation

enum LaunchGateConfiguration {
    static let remoteGateURLString: String = "https://quietcourier.org/click.php"
    static let gateBlockedURLMarker: String = "privacypolicies"

    static var trimmedRemoteGateURLString: String {
        remoteGateURLString.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static var remoteGateURL: URL? {
        let value = trimmedRemoteGateURLString
        guard !value.isEmpty else { return nil }
        return URL(string: value)
    }

    static var blockedMarkerLowercased: String {
        gateBlockedURLMarker.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    static func urlContainsBlockedMarker(_ url: URL?) -> Bool {
        guard let url else { return false }
        let marker = blockedMarkerLowercased
        guard !marker.isEmpty else { return false }
        return url.absoluteString.lowercased().contains(marker)
    }
}
