import SwiftUI

struct RegisterView: View {
    let credentialAuth: CredentialAuthenticating
    let onBack: () -> Void
    let onSuccess: () -> Void

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isSubmitting = false
    @State private var submissionError: AppError?
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case email
        case password
        case confirmPassword
    }

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            AuthStepHeader(title: "Create Account", onBack: onBack)

            ZStack {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { focusedField = nil }

                VStack(spacing: DesignTokens.Spacing.lg) {
                    NCard {
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Create your account")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.colorTextPrimary)
                                Text("At least \(AuthValidator.minimumPasswordLength) characters. You'll set up your profile next.")
                                    .font(.caption)
                                    .foregroundStyle(Color.colorTextSecondary)
                            }

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
                                placeholder: "Create a password",
                                text: $password,
                                isSecure: true,
                                field: Field.password,
                                focusedField: $focusedField,
                                keyboardType: .default,
                                submitLabel: .next,
                                onSubmit: { focusedField = .confirmPassword }
                            )

                            AuthGlassField(
                                title: "Confirm password",
                                placeholder: "Re-enter your password",
                                text: $confirmPassword,
                                isSecure: true,
                                field: Field.confirmPassword,
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
                            .accessibilityIdentifier("registerSubmissionError")
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            NButton(
                title: isSubmitting ? "Creating Account..." : "Create Account",
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
        AuthValidator.isRegisterStepValid(email: email, password: password, confirmPassword: confirmPassword)
    }

    private var validationMessage: String? {
        AuthValidator.registerValidationMessage(email: email, password: password, confirmPassword: confirmPassword)
    }

    private func submit() {
        guard canSubmit, isSubmitting == false else { return }
        isSubmitting = true
        submissionError = nil

        Task {
            do {
                _ = try await credentialAuth.register(
                    email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                    password: password
                )
                isSubmitting = false
                onSuccess()
            } catch {
                submissionError = AppError.fallback(
                    error,
                    or: AppError.saveFailed(
                        action: "create your account",
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
        RegisterView(credentialAuth: MockCredentialAuthClient(), onBack: {}, onSuccess: {})
    }
}
