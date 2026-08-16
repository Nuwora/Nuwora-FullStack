import SwiftUI

struct OnboardingView: View {
    let repository: OnboardingRepository
    let onFinished: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var step: Step = .welcome
    @State private var name = ""
    @State private var age = ""
    @State private var selectedGoals: Set<PrimaryGoal> = [.focus]
    @State private var assessmentAnswers: [Int] = [3, 3, 3, 3, 3]
    @State private var connectedWearables: Set<WearableKind> = []
    @State private var isSubmitting = false
    @State private var submissionError: AppError?
    @FocusState private var focusedWelcomeField: WelcomeField?

    init(repository: OnboardingRepository = MockOnboardingRepository(), onFinished: @escaping () -> Void) {
        self.repository = repository
        self.onFinished = onFinished
    }

    enum Step: Int, CaseIterable {
        case welcome
        case goals
        case assessment
        case wearables
        case score

        var title: String {
            switch self {
            case .welcome: return "Welcome"
            case .goals: return "Goals"
            case .assessment: return "Assessment"
            case .wearables: return "Sync"
            case .score: return "Score"
            }
        }
    }

    enum WearableKind: String, CaseIterable, Identifiable {
        case appleWatch = "Apple Watch"
        case oura = "Oura"
        case fitbit = "Fitbit"
        case whoop = "WHOOP"

        var id: String { rawValue }

        var apiIdentifier: String {
            switch self {
            case .appleWatch: return "apple_watch"
            case .oura: return "oura"
            case .fitbit: return "fitbit"
            case .whoop: return "whoop"
            }
        }

        var icon: String {
            switch self {
            case .appleWatch: return "applewatch"
            case .oura: return "circle.hexagongrid"
            case .fitbit: return "waveform.path.ecg"
            case .whoop: return "bolt.heart"
            }
        }
    }

    enum WelcomeField: Hashable {
        case name
        case age
    }

    private let assessmentQuestions: [String] = [
        "How high does stress feel today?",
        "How was your sleep quality last night?",
        "How clear is your focus right now?",
        "How emotionally balanced do you feel?",
        "How steady is your energy today?"
    ]

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            OnboardingProgressHeader(
                stepIndex: step.rawValue,
                totalSteps: Step.allCases.count,
                stepTitle: step.title
            )

            ZStack {
                Group {
                    switch step {
                    case .welcome:
                        welcomeStep
                    case .goals:
                        OnboardingGoalsStep(selectedGoals: $selectedGoals)
                    case .assessment:
                        OnboardingAssessmentStep(questions: assessmentQuestions, assessmentAnswers: $assessmentAnswers)
                    case .wearables:
                        OnboardingWearablesStep(connectedWearables: $connectedWearables)
                    case .score:
                        OnboardingScoreStep(
                            scoreResult: scoreResult,
                            scoreTier: scoreTier,
                            cognitiveResult: cognitiveResult,
                            biometricResult: biometricResult,
                            moodResult: moodResult
                        )
                    }
                }
                .id(step)
                .transition(
                    .asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .trailing)),
                        removal: .opacity.combined(with: .move(edge: .leading))
                    )
                )
            }
            .animation(reduceMotion ? .linear(duration: 0.01) : .nuworaPageSpring, value: step)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            OnboardingBottomActions(
                showBack: step != .welcome,
                canContinue: canContinueCurrentStep && isSubmitting == false,
                isLastStep: step == .score,
                isWorking: isSubmitting,
                onBack: goBack,
                onContinue: goForward,
                onFinish: submitOnboarding
            )

            if let submissionError {
                Text("\(submissionError.message) \(submissionError.retryHint)")
                    .font(.caption)
                    .foregroundStyle(Color.colorAmber)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityIdentifier("onboardingSubmissionError")
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .padding(.top, DesignTokens.Spacing.xl)
        .padding(.bottom, DesignTokens.Spacing.lg)
    }

    private var welcomeStep: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    focusedWelcomeField = nil
                }

            VStack(spacing: DesignTokens.Spacing.xl) {
                welcomeHero

                NCard {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Let's get to know you")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.colorTextPrimary)
                            Text("Both fields are required to continue.")
                                .font(.caption)
                                .foregroundStyle(Color.colorTextSecondary)
                        }

                        glassField(
                            title: "First name",
                            placeholder: "Type your name",
                            text: $name,
                            field: .name,
                            keyboardType: .default
                        )
                        glassField(
                            title: "Age (years)",
                            placeholder: "Type your age",
                            text: $age,
                            field: .age,
                            keyboardType: .numberPad
                        )

                        if let message = welcomeValidationMessage {
                            Text(message)
                                .font(.caption)
                                .foregroundStyle(Color.colorAmber)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    focusedWelcomeField = nil
                }
            }
        }
    }

    private var welcomeHero: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            ZStack {
                Circle()
                    .fill(Color.colorGreen.opacity(0.1))
                    .frame(width: 80, height: 80)
                Circle()
                    .fill(Color.colorTeal.opacity(0.08))
                    .frame(width: 56, height: 56)
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 28, weight: .regular))
                    .foregroundStyle(Color.colorGreen)
            }
            .padding(.top, DesignTokens.Spacing.sm)

            VStack(spacing: DesignTokens.Spacing.xs) {
                Text("Train your mind\nlike a muscle")
                    .font(.title2.weight(.bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.colorTextPrimary)

                Text("Build focus, reduce stress, and improve resilience — guided by AI.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.colorTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: DesignTokens.Spacing.xs) {
                welcomeValuePill(icon: "bolt.fill", text: "Personalized")
                welcomeValuePill(icon: "arrow.triangle.2.circlepath", text: "Adaptive")
                welcomeValuePill(icon: "lock.shield.fill", text: "Private")
            }
        }
    }

    private func welcomeValuePill(icon: String, text: String) -> some View {
        Label(text, systemImage: icon)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(Color.colorGreen)
            .padding(.horizontal, DesignTokens.Insets.pillHorizontal)
            .padding(.vertical, DesignTokens.Insets.pillVertical)
            .background(Color.colorGreen.opacity(0.1))
            .clipShape(Capsule())
    }

    private func glassField(
        title: String,
        placeholder: String,
        text: Binding<String>,
        field: WelcomeField,
        keyboardType: UIKeyboardType
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.colorTextPrimary)
                Text("*")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.colorAmber)
            }

            TextField(placeholder, text: text)
                .font(.body)
                .foregroundStyle(Color.colorTextPrimary)
                .padding(.horizontal, 14)
                .frame(height: 50)
                .background(Color.appCard.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(focusedWelcomeField == field ? Color.colorTeal.opacity(0.75) : Color.colorBorder, lineWidth: 1)
                )
                .keyboardType(keyboardType)
                .focused($focusedWelcomeField, equals: field)
                .textInputAutocapitalization(field == .name ? .words : .never)
                .autocorrectionDisabled(true)
                .submitLabel(field == .name ? .next : .done)
                .onSubmit {
                    if field == .name {
                        focusedWelcomeField = .age
                    } else {
                        focusedWelcomeField = nil
                    }
                }
                .onTapGesture {
                    focusedWelcomeField = field
                }
                .onChange(of: text.wrappedValue) { _, newValue in
                    guard field == .age else { return }
                    let digitsOnly = newValue.filter(\.isNumber)
                    if digitsOnly != newValue {
                        text.wrappedValue = digitsOnly
                    }
                }
        }
    }

    private var cognitiveResult: Int {
        let focus = normalizedAnswer(assessmentAnswers[2])
        let energy = normalizedAnswer(assessmentAnswers[4])
        return Int((focus + energy) / 2)
    }

    private var biometricResult: Int {
        let stressInverse = 100 - normalizedAnswer(assessmentAnswers[0])
        let sleep = normalizedAnswer(assessmentAnswers[1])
        return Int((stressInverse + sleep) / 2)
    }

    private var moodResult: Int {
        let mood = normalizedAnswer(assessmentAnswers[3])
        let energy = normalizedAnswer(assessmentAnswers[4])
        return Int((mood + energy) / 2)
    }

    private var scoreResult: Int {
        MindFitnessCalculator.calculateOverall(cognitive: cognitiveResult, biometric: biometricResult, mood: moodResult)
    }

    private var scoreTier: String {
        switch scoreResult {
        case 80...100: return "Peak Performer"
        case 65..<80: return "Building Momentum"
        case 50..<65: return "Foundation Phase"
        default: return "Reset and Recover"
        }
    }

    private func normalizedAnswer(_ value: Int) -> Double {
        Double((value - 1) * 25)
    }

    private var canContinueCurrentStep: Bool {
        switch step {
        case .welcome:
            return OnboardingValidator.isWelcomeStepValid(name: name, age: age)
        case .goals:
            return OnboardingValidator.hasAtLeastOneGoal(selectedGoals)
        case .assessment, .wearables, .score:
            return true
        }
    }

    private var welcomeValidationMessage: String? {
        OnboardingValidator.welcomeValidationMessage(name: name, age: age)
    }

    private func goBack() {
        withAnimation(.nuworaSpring) {
            step = Step(rawValue: max(0, step.rawValue - 1)) ?? .welcome
        }
    }

    private func goForward() {
        withAnimation(.nuworaSpring) {
            step = Step(rawValue: min(Step.allCases.count - 1, step.rawValue + 1)) ?? .score
        }
    }

    private func submitOnboarding() {
        guard isSubmitting == false,
              let parsedAge = Int(age.trimmingCharacters(in: .whitespacesAndNewlines))
        else { return }

        isSubmitting = true
        submissionError = nil
        let submission = OnboardingSubmission(
            name: name,
            age: parsedAge,
            primaryGoals: Array(selectedGoals),
            assessmentAnswers: assessmentAnswers,
            connectedWearables: connectedWearables.map(\.apiIdentifier),
            initialScore: scoreResult,
            cognitiveScore: cognitiveResult,
            biometricScore: biometricResult,
            moodScore: moodResult
        )

        Task {
            do {
                try await repository.submit(submission)
                isSubmitting = false
                onFinished()
            } catch {
                submissionError = AppError.fallback(
                    error,
                    or: AppError.saveFailed(
                        action: "save onboarding",
                        retryHint: "Start the backend or check the connection, then retry."
                    )
                )
                isSubmitting = false
            }
        }
    }
}

#Preview {
    ZStack {
        NSceneBackground(style: .onboarding)
        OnboardingView(onFinished: {})
    }
}
