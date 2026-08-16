import Foundation
import Observation

@Observable
final class CoachViewModel {
    var messages: [ChatMessage] = []
    var selectedPersona: CoachPersona = .aria
    var isTyping = false
    var safetyLevel: SafetyLevel = .none
    var viewState: FeatureState<[ChatMessage]> = .idle
    var showPracticePrompt = false
    var emotionalTone: EmotionalTone = .calm
    var sendCommandState: CommandState = .idle
    private(set) var hasLoadedOnce = false

    private let repository: CoachRepository

    enum EmotionalTone {
        case calm
        case analytical
        case energized

        var label: String {
            switch self {
            case .calm: return "Calm"
            case .analytical: return "Analytical"
            case .energized: return "Energized"
            }
        }
    }

    init(repository: CoachRepository) {
        self.repository = repository
    }

    func loadMessages() async {
        viewState = .loading
        do {
            messages = try await repository.fetchMessages(limit: 100, cursor: nil)
            viewState = messages.isEmpty ? .empty : .loaded(messages)
            hasLoadedOnce = true
        } catch {
            viewState = .error(AppError.loadFailed(feature: "messages", retryHint: "Try opening Coach again in a few moments."))
        }
    }

    func loadMessagesIfNeeded() async {
        guard hasLoadedOnce == false else { return }
        await loadMessages()
    }

    func sendMessage(_ text: String) async {
        guard text.isEmpty == false else { return }
        let userMessage = ChatMessage(id: UUID(), content: text, sender: .user, timestamp: .now)
        messages.append(userMessage)
        isTyping = true
        sendCommandState = .pending(message: "Sending message...")
        safetyLevel = SafetyKeywordDetector.detectLevel(for: text)
        emotionalTone = detectTone(from: text)

        do {
            let response = try await repository.sendMessage(text, persona: selectedPersona)
            let cleanedContent = response.content.trimmingCharacters(in: .whitespacesAndNewlines)

            if cleanedContent.isEmpty {
                messages.append(ChatMessage(
                    id: UUID(),
                    content: "I'm here with you. Let's take one slow breath together while I reset.",
                    sender: .coach,
                    timestamp: .now
                ))
                showPracticePrompt = true
                emotionalTone = .calm
            } else {
                messages.append(response)
                showPracticePrompt = shouldSuggestPractice(from: response.content)
                emotionalTone = detectTone(from: response.content)
            }
            sendCommandState = .succeeded(message: "Message sent.")
            scheduleCommandStateReset()
        } catch {
            let appError = AppError.fallback(
                error,
                or: AppError.saveFailed(action: "send your message", retryHint: "Check the backend connection and retry.")
            )
            sendCommandState = .failed(appError)
            messages.append(ChatMessage(
                id: UUID(),
                content: "I could not process that safely right now. Please retry, and if this feels urgent, use support options below.",
                sender: .coach,
                timestamp: .now
            ))
        }
        isTyping = false
    }

    func selectPersona(_ persona: CoachPersona) {
        selectedPersona = persona
        switch persona {
        case .aria: emotionalTone = .calm
        case .max:  emotionalTone = .energized
        case .zen:  emotionalTone = .analytical
        }
    }

    private func shouldSuggestPractice(from content: String) -> Bool {
        let lowered = content.lowercased()
        return lowered.contains("breath")
            || lowered.contains("grounding")
            || lowered.contains("reset")
            || lowered.contains("session")
            || lowered.contains("practice")
    }

    private func detectTone(from text: String) -> EmotionalTone {
        let lowered = text.lowercased()
        if lowered.contains("data") || lowered.contains("trend") || lowered.contains("pattern") {
            return .analytical
        }
        if lowered.contains("challenge") || lowered.contains("boost") || lowered.contains("push") {
            return .energized
        }
        return .calm
    }

    private func scheduleCommandStateReset() {
        Task {
            do {
                try await Task.sleep(for: .seconds(2))
            } catch {
                return
            }
            if case .succeeded = sendCommandState {
                sendCommandState = .idle
            }
        }
    }
}
