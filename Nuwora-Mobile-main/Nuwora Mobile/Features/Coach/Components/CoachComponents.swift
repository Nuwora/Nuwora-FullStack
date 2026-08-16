import SwiftUI

struct CoachSafetyPanel: View {
    let level: SafetyLevel
    let horizontalPadding: CGFloat

    var body: some View {
        Group {
            switch level {
            case .none:
                EmptyView()
            case .watch:
                NCard(glow: .colorAmber) {
                    Text("You are not alone. If this gets heavier, tap support for immediate help.")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.colorAmber)
                }
                .padding(.horizontal, horizontalPadding)
            case .urgent:
                NCard(glow: .colorRose) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Immediate support is available right now.")
                            .font(.headline)
                            .foregroundStyle(Color.colorRose)
                        Text("If you're in danger, call emergency services. For crisis support in the U.S., contact 988.")
                            .font(.subheadline)
                            .foregroundStyle(Color.colorTextSecondary)

                        HStack(spacing: 8) {
                            Link("Call 988", destination: URL(string: "tel://988")!)
                                .buttonStyle(.borderedProminent)
                                .tint(.colorRose)
                                .accessibilityLabel("Call crisis support at 988")
                                .accessibilityHint("Starts a phone call to the suicide and crisis lifeline.")

                            Link("Open Help", destination: URL(string: "https://988lifeline.org/chat")!)
                                .buttonStyle(.bordered)
                                .accessibilityLabel("Open crisis chat support")
                                .accessibilityHint("Opens the lifeline web support page.")
                        }
                    }
                }
                .padding(.horizontal, horizontalPadding)
            }
        }
    }
}

// MARK: - Header

struct CoachHeaderSection: View {
    let selectedPersona: CoachPersona
    let emotionalTone: CoachViewModel.EmotionalTone
    let hasMessages: Bool
    let orbPulse: Bool
    let horizontalPadding: CGFloat
    let onSelectPersona: (CoachPersona) -> Void
    let onOpenPersonaPicker: () -> Void
    let onQuickPrompt: (String) -> Void

    var body: some View {
        if hasMessages {
            compactHeader
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .opacity
                ))
        } else {
            fullHeader
                .transition(.asymmetric(
                    insertion: .opacity,
                    removal: .opacity.combined(with: .move(edge: .top))
                ))
        }
    }

    // Single-row header shown while a conversation is active
    private var compactHeader: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            Button(action: onOpenPersonaPicker) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(selectedPersona.accentColor)
                        .frame(width: 8, height: 8)
                    Text("\(selectedPersona.displayName) · \(selectedPersona.toneLabel)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(selectedPersona.accentColor)
                        .lineLimit(1)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(selectedPersona.accentColor.opacity(0.85))
                }
                .padding(.horizontal, DesignTokens.Insets.pillHorizontal + 2)
                .padding(.vertical, 7)
                .background(selectedPersona.surfaceColor.opacity(0.9))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(selectedPersona.ringColor, lineWidth: 1))
                .animation(.nuworaSpring, value: selectedPersona)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Active coach: \(selectedPersona.displayName)")
            .accessibilityHint("Open coach picker to switch persona.")

            Spacer()

            Button(action: onOpenPersonaPicker) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.caption2.weight(.bold))
                    Text("Switch")
                        .font(.caption.weight(.bold))
                }
                .foregroundStyle(Color.colorTextSecondary)
                .padding(.horizontal, DesignTokens.Insets.chipHorizontal + 4)
                .padding(.vertical, DesignTokens.Insets.chipVertical + 2)
                .background(Color.appCard.opacity(0.6))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.colorBorder.opacity(0.6), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Switch coach")
            .accessibilityHint("Opens the coach picker.")
        }
        .padding(.horizontal, horizontalPadding)
    }

    // Full header shown on the empty/welcome state
    private var fullHeader: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            titleRow
            chooseCoachCTA
            promptChips
        }
    }

    private var chooseCoachCTA: some View {
        Button(action: onOpenPersonaPicker) {
            HStack(spacing: DesignTokens.Spacing.md) {
                ZStack {
                    Circle()
                        .fill(selectedPersona.surfaceColor.opacity(0.9))
                        .frame(width: 38, height: 38)
                    Circle()
                        .stroke(selectedPersona.ringColor, lineWidth: 1)
                        .frame(width: 38, height: 38)
                    Circle()
                        .fill(selectedPersona.accentColor)
                        .frame(width: 12, height: 12)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(selectedPersona.displayName)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.colorTextPrimary)
                        .lineLimit(1)
                    Text(selectedPersona.tagline)
                        .font(.caption)
                        .foregroundStyle(Color.colorTextSecondary)
                        .lineLimit(1)
                }

                Spacer(minLength: 4)

                HStack(spacing: 6) {
                    Text("Change")
                        .font(.caption.weight(.bold))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundStyle(selectedPersona.accentColor)
                .padding(.horizontal, DesignTokens.Insets.pillHorizontal + 2)
                .padding(.vertical, 7)
                .background(selectedPersona.surfaceColor.opacity(0.85))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(selectedPersona.ringColor, lineWidth: 1))
            }
            .padding(.horizontal, DesignTokens.Insets.cardRegular)
            .padding(.vertical, DesignTokens.Insets.cardCompact)
            .background {
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.medium, style: .continuous)
                    .fill(Color.appCard.opacity(0.7))
            }
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.medium, style: .continuous)
                    .stroke(Color.colorBorder.opacity(0.7), lineWidth: 1)
            )
            .animation(.nuworaSpring, value: selectedPersona)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, horizontalPadding)
        .accessibilityLabel("Active coach: \(selectedPersona.displayName), \(selectedPersona.tagline)")
        .accessibilityHint("Opens the coach picker to switch persona.")
    }

    private var titleRow: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text("AI Cognitive Coach")
                        .font(.nTitle)
                        .foregroundStyle(Color.colorTextPrimary)
                    Text("Empathetic guidance with neuroscience context")
                        .font(.subheadline)
                        .foregroundStyle(Color.colorTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: DesignTokens.Spacing.sm)

                HStack(spacing: 6) {
                    Circle()
                        .fill(toneColor)
                        .frame(width: 8, height: 8)
                    Text(emotionalTone.label)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.colorTextSecondary)
                }
                .padding(.horizontal, DesignTokens.Insets.pillHorizontal)
                .padding(.vertical, DesignTokens.Insets.pillVertical)
                .background(Color.appCard.opacity(0.8))
                .clipShape(Capsule())
            }

            ZStack {
                Circle()
                    .fill(selectedPersona.ringColor)
                    .frame(width: 76, height: 76)
                    .blur(radius: 18)
                    .scaleEffect(orbPulse ? 1.1 : 0.94)
                    .animation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true), value: orbPulse)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                selectedPersona.accentColor.opacity(0.8),
                                selectedPersona.accentColor.opacity(0.24)
                            ],
                            center: .center,
                            startRadius: 4,
                            endRadius: 34
                        )
                    )
                    .frame(width: 58, height: 58)
                    .overlay {
                        Image(systemName: "sparkles")
                            .foregroundStyle(Color.textPrimary.opacity(0.9))
                    }
            }
        }
        .padding(.horizontal, horizontalPadding)
    }

    private var promptChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                quickPrompt("How am I doing today?")
                quickPrompt("I feel anxious")
                quickPrompt("Give me a focus challenge")
                quickPrompt("Reflect on my week")
            }
            .padding(.horizontal, horizontalPadding)
        }
    }

    private func quickPrompt(_ text: String) -> some View {
        Button(text) {
            onQuickPrompt(text)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(selectedPersona.accentColor)
        .padding(.horizontal, DesignTokens.Insets.pillHorizontal)
        .padding(.vertical, 7)
        .background(selectedPersona.surfaceColor.opacity(0.94))
        .overlay(Capsule().stroke(selectedPersona.ringColor, lineWidth: 1))
        .clipShape(Capsule())
        .buttonStyle(.plain)
    }

    private var toneColor: Color {
        switch emotionalTone {
        case .calm:       return .coachZenMonk
        case .analytical: return .coachNeuroscientist
        case .energized:  return .coachPeakPerformer
        }
    }
}

// MARK: - Persona switch banner

private struct PersonaSwitchBanner: View {
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.caption2.weight(.bold))
                .foregroundStyle(color)
            Text(text)
                .font(.caption.weight(.semibold))
                .foregroundStyle(color)
        }
        .padding(.horizontal, DesignTokens.Insets.pillHorizontal + 4)
        .padding(.vertical, DesignTokens.Insets.pillVertical)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(color.opacity(0.35), lineWidth: 1))
        .shadow(color: color.opacity(0.25), radius: 8, y: 3)
    }
}

// MARK: - Conversation

struct CoachConversationSection: View {
    let viewState: FeatureState<[ChatMessage]>
    let messages: [ChatMessage]
    let isTyping: Bool
    let selectedPersona: CoachPersona
    let horizontalPadding: CGFloat
    let chatBottomID: String
    let onBackgroundTap: () -> Void

    @State private var dotsAnimating = false
    @State private var personaSwitchNotice: String? = nil
    @State private var noticeDismissTask: Task<Void, Never>? = nil

    var body: some View {
        ZStack(alignment: .top) {
            Group {
                switch viewState {
                case .idle, .loading:
                    NSkeletonView()
                        .frame(maxWidth: .infinity, minHeight: 220, maxHeight: .infinity, alignment: .top)
                case .empty:
                    emptyState
                case let .error(error):
                    NFeatureStatusCard.error(error)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                case .loaded:
                    messagesList
                }
            }
            .padding(.horizontal, horizontalPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            if let notice = personaSwitchNotice {
                PersonaSwitchBanner(text: notice, color: selectedPersona.accentColor)
                    .padding(.top, DesignTokens.Spacing.xs)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task(id: isTyping) {
            dotsAnimating = isTyping
        }
        .onChange(of: selectedPersona) { _, new in
            guard messages.isEmpty == false else { return }
            noticeDismissTask?.cancel()
            withAnimation(.nuworaSpring) {
                personaSwitchNotice = "Switched to \(new.displayName)"
            }
            noticeDismissTask = Task {
                try? await Task.sleep(for: .seconds(2))
                guard Task.isCancelled == false else { return }
                withAnimation(.nuworaQuickEase) {
                    personaSwitchNotice = nil
                }
            }
        }
    }

    private var messagesList: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 12) {
                    ForEach(messages) { message in
                        HStack {
                            if message.sender == .coach {
                                bubble(message: message, user: false)
                                    .transition(.opacity.combined(with: .move(edge: .leading)))
                                Spacer(minLength: 40)
                            } else {
                                Spacer(minLength: 40)
                                bubble(message: message, user: true)
                                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                            }
                        }
                    }

                    if isTyping {
                        typingIndicator
                            .transition(.opacity.combined(with: .move(edge: .leading)))
                    }

                    Color.clear
                        .frame(height: 1)
                        .id(chatBottomID)
                }
                .animation(.easeOut(duration: 0.35), value: messages.count)
                .animation(.easeOut(duration: 0.2), value: isTyping)
                .padding(.vertical, 4)
            }
            .scrollDismissesKeyboard(.interactively)
            .contentShape(Rectangle())
            .onTapGesture { onBackgroundTap() }
            .onAppear {
                // Defer one run-loop tick so the ScrollView layout is complete
                DispatchQueue.main.async {
                    scrollToLatestMessage(using: proxy, animated: false)
                }
            }
            .onChange(of: messages.count) { _, _ in
                scrollToLatestMessage(using: proxy)
            }
            .onChange(of: isTyping) { _, _ in
                scrollToLatestMessage(using: proxy)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: DesignTokens.Spacing.sm) {
            Image(systemName: "message")
                .font(.title3.weight(.medium))
                .foregroundStyle(Color.colorTextTertiary)
            Text("No messages yet")
                .font(.headline)
                .foregroundStyle(Color.colorTextPrimary)
            Text("Start with a prompt or send a message below.")
                .font(.subheadline)
                .foregroundStyle(Color.colorTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding(.horizontal, DesignTokens.Spacing.xl)
    }

    private func bubble(message: ChatMessage, user: Bool) -> some View {
        VStack(alignment: user ? .trailing : .leading, spacing: 4) {
            Text(message.content)
                .font(.body)
                .foregroundStyle(user ? Color.appBackground : Color.colorTextPrimary)
                .padding(.horizontal, DesignTokens.Insets.cardRegular)
                .padding(.vertical, DesignTokens.Insets.cardCompact)
                .background(
                    user
                        ? selectedPersona.accentColor.opacity(0.95)
                        : selectedPersona.surfaceColor.opacity(0.96)
                )
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.medium, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.medium, style: .continuous)
                        .stroke(
                            user ? selectedPersona.ringColor : selectedPersona.ringColor.opacity(0.92),
                            lineWidth: 1
                        )
                )

            Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                .font(.caption2.weight(.medium))
                .foregroundStyle(Color.colorTextTertiary)
                .padding(.horizontal, 4)
        }
    }

    private var typingIndicator: some View {
        HStack(spacing: 6) {
            ForEach([0, 1, 2], id: \.self) { idx in
                Circle()
                    .fill(selectedPersona.accentColor.opacity(0.9))
                    .frame(width: 6, height: 6)
                    .offset(y: dotsAnimating ? -2 : 2)
                    .animation(
                        .easeInOut(duration: 0.45).repeatForever(autoreverses: true).delay(Double(idx) * 0.12),
                        value: dotsAnimating
                    )
            }
            Spacer()
        }
        .padding(.horizontal, 2)
    }

    private func scrollToLatestMessage(using proxy: ScrollViewProxy, animated: Bool = true) {
        let action = { proxy.scrollTo(chatBottomID, anchor: .bottom) }
        if animated {
            withAnimation(.easeOut(duration: 0.25), action)
        } else {
            action()
        }
    }
}

// MARK: - Input bar

struct CoachInputBarInset: View {
    @Binding var input: String
    let focused: FocusState<Bool>.Binding
    let isSending: Bool
    let selectedPersona: CoachPersona
    let horizontalPadding: CGFloat
    let onSend: () -> Void

    private var canSendMessage: Bool {
        input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false && isSending == false
    }

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.sm) {
            Divider()
                .overlay(Color.colorBorder.opacity(0.75))

            inputBar
                .padding(.horizontal, horizontalPadding)
                .padding(.bottom, DesignTokens.Spacing.sm)
        }
        .padding(.top, DesignTokens.Spacing.xs)
        .background(.ultraThinMaterial)
    }

    private var inputBar: some View {
        HStack(alignment: .bottom, spacing: DesignTokens.Spacing.sm) {
            TextField("Message your coach...", text: $input, axis: .vertical)
                .lineLimit(1...5)
                .font(.body)
                .foregroundStyle(Color.colorTextPrimary)
                .focused(focused)
                .submitLabel(.send)
                .onSubmit(onSend)
                .padding(.vertical, DesignTokens.Insets.cardCompact)
                .accessibilityLabel("Coach message input")
                .accessibilityHint("Type your message for the selected coach persona.")

            if canSendMessage {
                Button(action: onSend) {
                    ZStack {
                        Circle()
                            .fill(selectedPersona.accentColor)
                            .frame(width: 34, height: 34)
                        Image(systemName: "arrow.up")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Color.appBackground)
                    }
                }
                .padding(.bottom, 2)
                .accessibilityLabel("Send message")
                .accessibilityHint("Sends your message to the coach.")
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.4).combined(with: .opacity),
                    removal: .scale(scale: 0.4).combined(with: .opacity)
                ))
            }
        }
        .padding(.leading, DesignTokens.Spacing.lg)
        .padding(.trailing, DesignTokens.Spacing.sm)
        .padding(.vertical, DesignTokens.Spacing.xs)
        .background(Color.colorSurface.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(
                    canSendMessage ? selectedPersona.accentColor.opacity(0.55) : Color.colorBorder,
                    lineWidth: 1
                )
        )
        .animation(.nuworaSpring, value: canSendMessage)
    }
}

// MARK: - Persona picker sheet

struct CoachPersonaPickerSheet: View {
    let selectedPersona: CoachPersona
    let onSelect: (CoachPersona) -> Void
    let onDismiss: () -> Void

    @State private var pendingPersona: CoachPersona

    init(
        selectedPersona: CoachPersona,
        onSelect: @escaping (CoachPersona) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.selectedPersona = selectedPersona
        self.onSelect = onSelect
        self.onDismiss = onDismiss
        _pendingPersona = State(initialValue: selectedPersona)
    }

    var body: some View {
        VStack(spacing: 0) {
            handle
                .padding(.top, 8)
                .padding(.bottom, DesignTokens.Spacing.md)

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text("Choose your coach")
                    .font(.nTitle)
                    .foregroundStyle(Color.colorTextPrimary)
                Text("Each persona shapes tone, framing, and the questions you'll be asked.")
                    .font(.subheadline)
                    .foregroundStyle(Color.colorTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, DesignTokens.Spacing.lg)

            VStack(spacing: DesignTokens.Spacing.md) {
                ForEach(CoachPersona.allCases, id: \.self) { persona in
                    personaCard(persona: persona)
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.top, DesignTokens.Spacing.lg)

            Spacer(minLength: DesignTokens.Spacing.lg)

            confirmButton
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.bottom, DesignTokens.Spacing.lg)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.appBackground.ignoresSafeArea())
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(Color.appBackground)
    }

    private var handle: some View {
        Capsule()
            .fill(Color.colorBorder.opacity(0.7))
            .frame(width: 38, height: 5)
    }

    private func personaCard(persona: CoachPersona) -> some View {
        let isPending = pendingPersona == persona
        return Button {
            withAnimation(.nuworaSpring) {
                pendingPersona = persona
            }
        } label: {
            HStack(alignment: .top, spacing: DesignTokens.Spacing.md) {
                ZStack {
                    Circle()
                        .fill(persona.accentColor.opacity(0.18))
                        .frame(width: 46, height: 46)
                    Circle()
                        .stroke(persona.ringColor, lineWidth: 1)
                        .frame(width: 46, height: 46)
                    Image(systemName: personaIcon(persona))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(persona.accentColor)
                }

                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(persona.displayName)
                            .font(.headline)
                            .foregroundStyle(Color.colorTextPrimary)
                        Text(persona.rawValue)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(persona.accentColor)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(persona.surfaceColor.opacity(0.85))
                            .clipShape(Capsule())
                    }
                    Text(persona.tagline)
                        .font(.subheadline)
                        .foregroundStyle(Color.colorTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(persona.toneLabel)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(persona.accentColor)
                }

                Spacer(minLength: 4)

                ZStack {
                    Circle()
                        .stroke(
                            isPending ? persona.accentColor : Color.colorBorder.opacity(0.8),
                            lineWidth: isPending ? 2 : 1.2
                        )
                        .frame(width: 22, height: 22)
                    if isPending {
                        Circle()
                            .fill(persona.accentColor)
                            .frame(width: 12, height: 12)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.top, 2)
            }
            .padding(DesignTokens.Insets.cardComfortable)
            .background {
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.large, style: .continuous)
                    .fill(
                        isPending
                            ? AnyShapeStyle(persona.selectionGradient)
                            : AnyShapeStyle(Color.appCard.opacity(0.85))
                    )
            }
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.large, style: .continuous)
                    .stroke(
                        isPending ? persona.ringColor : Color.colorBorder.opacity(0.7),
                        lineWidth: isPending ? 1.5 : 1
                    )
            )
            .shadow(color: isPending ? persona.accentColor.opacity(0.22) : .clear, radius: 14, y: 6)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(persona.displayName)
        .accessibilityValue(isPending ? "Selected" : "Not selected")
        .accessibilityHint("Tap to choose this persona, then confirm below.")
    }

    private var confirmButton: some View {
        Button {
            onSelect(pendingPersona)
            onDismiss()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                Text("Coach with \(pendingPersona.displayName)")
                    .font(.headline)
            }
            .foregroundStyle(Color.appBackground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignTokens.Insets.cardComfortable)
            .background(pendingPersona.accentColor)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.button, style: .continuous))
            .shadow(color: pendingPersona.accentColor.opacity(0.35), radius: 16, y: 8)
            .animation(.nuworaSpring, value: pendingPersona)
        }
        .buttonStyle(.plain)
        .accessibilityHint("Applies the selected coach persona and closes the picker.")
    }

    private func personaIcon(_ persona: CoachPersona) -> String {
        switch persona {
        case .aria: return "leaf.fill"
        case .max:  return "bolt.fill"
        case .zen:  return "brain.head.profile"
        }
    }
}
