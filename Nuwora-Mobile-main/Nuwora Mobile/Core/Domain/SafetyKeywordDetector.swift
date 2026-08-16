import Foundation

enum SafetyLevel: String, Codable {
    case none
    case watch
    case urgent
}

enum SafetyKeywordDetector {
    private static let urgentSignals: [String: Int] = [
        "kill myself": 6,
        "end my life": 6,
        "want to die": 6,
        "hurt myself": 5,
        "self harm": 5,
        "cant go on": 4,
        "can't go on": 4,
        "suicidal": 5
    ]

    private static let watchSignals: [String: Int] = [
        "hopeless": 2,
        "worthless": 2,
        "panic attack": 2,
        "nobody cares": 2,
        "i am done": 2,
        "dont want to wake up": 3,
        "don't want to wake up": 3,
        "overwhelmed": 1
    ]

    static func detectLevel(for text: String) -> SafetyLevel {
        let normalized = normalize(text)
        guard normalized.isEmpty == false else { return .none }

        var score = 0
        for (phrase, weight) in urgentSignals where normalized.contains(phrase) {
            score += weight
        }
        for (phrase, weight) in watchSignals where normalized.contains(phrase) {
            score += weight
        }

        if score >= 5 {
            return .urgent
        }
        if score >= 2 {
            return .watch
        }
        return .none
    }

    private static func normalize(_ text: String) -> String {
        let folded = text.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
        let components = folded
            .unicodeScalars
            .map { CharacterSet.alphanumerics.contains($0) || $0 == " " ? Character($0) : " " }
        return String(components).replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
