import Foundation

protocol CoachServicing {
    func sendMessage(_ text: String, persona: CoachPersona) async throws -> [String]
}

struct CoachService: CoachServicing {
    func sendMessage(_ text: String, persona: CoachPersona) async throws -> [String] {
        [
            "\(persona.displayName): I hear you.",
            "Let's do one 60-second grounding breath now.",
            "Prompt echo: \(text)"
        ]
    }
}
