import SwiftUI

struct LoginView: View {
    let credentialAuth: CredentialAuthenticating
    let onBack: () -> Void
    let onSuccess: () -> Void

    @State private var email = ""
    @State private var password = ""
    @State private var isSubmitting = false
    @State private var submissionError: AppError?
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case email
        case password
    }

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            AuthStepHeader(title: "Log In", onBack: onBack)

            ZStack {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { focusedField = nil }

                VStack(spacing: DesignTokens.Spacing.lg) {
                    NCard {
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                            Text("Welcome back")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.colorTextPrimary)

                            AuthGlassField(
                                title: "Email",
                                placeholder: "you@example.com",
                                text: $email,
                                isSecure: false,
                                field: Field.email,
                                focusedField: $focusedField,
                                keyboardType: .emailAddress,
                                submitLabel: .next,
                                onSubmit: { focusedField = .password }
                            )

                            AuthGlassField(
                                title: "Password",
                                placeholder: "Your password",
                                text: $password,
                                isSecure: true,
                                field: Field.password,
                                focusedField: $focusedField,
                                keyboardType: .default,
                                submitLabel: .go,
                                onSubmit: submit
                            )

                            if let message = validationMessage {
                                Text(message)
                                    .font(.caption)
                                    .foregroundStyle(Color.colorAmber)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }

                    if let submissionError {
                        Text("\(submissionError.message) \(submissionError.retryHint)")
                            .font(.caption)
                            .foregroundStyle(Color.colorAmber)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accessibilityIdentifier("loginSubmissionError")
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            NButton(
                title: isSubmitting ? "Logging In..." : "Log In",
                style: canSubmit ? .primary : .secondary,
                action: submit
            )
            .disabled(canSubmit == false || isSubmitting)
            .saturation(canSubmit ? 1 : 0)
        }
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .padding(.top, DesignTokens.Spacing.xl)
        .padding(.bottom, DesignTokens.Spacing.lg)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { focusedField = nil }
            }
        }
    }

    private var canSubmit: Bool {
        AuthValidator.isLoginStepValid(email: email, password: password)
    }

    private var validationMessage: String? {
        AuthValidator.loginValidationMessage(email: email, password: password)
    }

    private func submit() {
        guard canSubmit, isSubmitting == false else { return }
        isSubmitting = true
        submissionError = nil

        Task {
            do {
                _ = try await credentialAuth.login(
                    email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                    password: password
                )
                isSubmitting = false
                onSuccess()
            } catch {
                submissionError = AppError.fallback(
                    error,
                    or: AppError.saveFailed(
                        action: "log in",
                        retryHint: "Check your connection and try again."
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
        LoginView(credentialAuth: MockCredentialAuthClient(), onBack: {}, onSuccess: {})
    }
}
