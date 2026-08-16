import SwiftUI

struct AuthStepHeader: View {
    let title: String
    let onBack: () -> Void

    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.colorTextPrimary)
                    .frame(width: 36, height: 36)
                    .background(Color.colorSurfaceHigh.opacity(0.76))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.colorBorder, lineWidth: 1))
            }
            .accessibilityLabel("Back")

            Spacer()

            Text(title)
                .font(.headline)
                .foregroundStyle(Color.colorTextPrimary)

            Spacer()

            Color.clear.frame(width: 36, height: 36)
        }
    }
}

/// A liquid-glass text field matching the Onboarding welcome step's style,
/// generalized to support both plain text and secure (password) entry, and
/// reusable across any `Hashable` focus-field enum.
struct AuthGlassField<Field: Hashable>: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let isSecure: Bool
    let field: Field
    var focusedField: FocusState<Field?>.Binding
    var keyboardType: UIKeyboardType = .default
    var submitLabel: SubmitLabel = .next
    var onSubmit: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.colorTextPrimary)

            fieldContent
                .font(.body)
                .foregroundStyle(Color.colorTextPrimary)
                .padding(.horizontal, 14)
                .frame(height: 50)
                .background(Color.appCard.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(
                            focusedField.wrappedValue == field ? Color.colorTeal.opacity(0.75) : Color.colorBorder,
                            lineWidth: 1
                        )
                )
                .keyboardType(keyboardType)
                .focused(focusedField, equals: field)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .submitLabel(submitLabel)
                .onSubmit(onSubmit)
                .onTapGesture { focusedField.wrappedValue = field }
        }
    }

    @ViewBuilder
    private var fieldContent: some View {
        if isSecure {
            SecureField(placeholder, text: $text)
        } else {
            TextField(placeholder, text: $text)
        }
    }
}
