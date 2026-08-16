import SwiftUI

struct CoachView: View {
    @Environment(AppStore.self) private var appStore
    @State private var viewModel: CoachViewModel
    @State private var input = ""
    @State private var orbPulse = false
    @State private var isPersonaPickerPresented = false
    @FocusState private var isInputFocused: Bool

    private let horizontalPadding = DesignTokens.Spacing.lg
    private let chatBottomID = "coach-chat-bottom"

    init(viewModel: CoachViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            CoachHeaderSection(
                selectedPersona: viewModel.selectedPersona,
                emotionalTone: viewModel.emotionalTone,
                hasMessages: viewModel.messages.isEmpty == false,
                orbPulse: orbPulse,
                horizontalPadding: horizontalPadding,
                onSelectPersona: { persona in
                    withAnimation(.nuworaSpring) {
                        viewModel.selectPersona(persona)
                    }
                },
                onOpenPersonaPicker: {
                    isInputFocused = false
                    isPersonaPickerPresented = true
                },
                onQuickPrompt: sendQuickPrompt
            )
            .animation(.nuworaSpring, value: viewModel.messages.isEmpty)

            if viewModel.safetyLevel != .none {
                CoachSafetyPanel(level: viewModel.safetyLevel, horizontalPadding: horizontalPadding)
            }

            CoachConversationSection(
                viewState: viewModel.viewState,
                messages: viewModel.messages,
                isTyping: viewModel.isTyping,
                selectedPersona: viewModel.selectedPersona,
                horizontalPadding: horizontalPadding,
                chatBottomID: chatBottomID,
                onBackgroundTap: {
                    isInputFocused = false
                }
            )

            if viewModel.showPracticePrompt {
                practicePromptButton
            }
        }
        .padding(.top, DesignTokens.Spacing.lg)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            CoachInputBarInset(
                input: $input,
                focused: $isInputFocused,
                isSending: viewModel.isTyping,
                selectedPersona: viewModel.selectedPersona,
                horizontalPadding: horizontalPadding,
                onSend: sendMessageFromInput
            )
        }
        .task {
            orbPulse = true
            await viewModel.loadMessagesIfNeeded()
        }
        .sheet(isPresented: $isPersonaPickerPresented) {
            CoachPersonaPickerSheet(
                selectedPersona: viewModel.selectedPersona,
                onSelect: { persona in
                    withAnimation(.nuworaSpring) {
                        viewModel.selectPersona(persona)
                    }
                },
                onDismiss: { isPersonaPickerPresented = false }
            )
        }
    }

    private var practicePromptButton: some View {
        NButton(title: "Begin Session", style: .secondary) {
            appStore.openTab(.mindGym)
        }
        .padding(.horizontal, horizontalPadding)
    }

    private func sendQuickPrompt(_ text: String) {
        isInputFocused = false
        Task { await viewModel.sendMessage(text) }
    }

    private func sendMessageFromInput() {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard text.isEmpty == false else { return }
        input = ""
        isInputFocused = false
        Task { await viewModel.sendMessage(text) }
    }
}

#Preview {
    CoachView(viewModel: CoachViewModel(repository: MockCoachRepository()))
        .environment(AppStore())
}
