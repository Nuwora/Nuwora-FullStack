import SwiftUI

struct NFeatureStatusCard: View {
    let icon: String
    let title: String
    let message: String
    let tint: Color

    var body: some View {
        NCard {
            VStack(alignment: .leading, spacing: 8) {
                Label(title, systemImage: icon)
                    .font(.headline)
                    .foregroundStyle(tint)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(Color.colorTextSecondary)
            }
        }
    }

    static func empty(title: String, message: String) -> NFeatureStatusCard {
        NFeatureStatusCard(icon: "tray", title: title, message: message, tint: .colorTextPrimary)
    }

    static func error(_ error: AppError) -> NFeatureStatusCard {
        NFeatureStatusCard(
            icon: "exclamationmark.triangle.fill",
            title: error.message,
            message: error.retryHint,
            tint: .colorRose
        )
    }
}

struct NCommandFeedbackCard: View {
    let state: CommandState

    var body: some View {
        switch state {
        case .idle:
            EmptyView()
        case let .pending(message):
            NCard {
                HStack(spacing: 10) {
                    ProgressView()
                        .tint(Color.colorTeal)
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(Color.colorTextSecondary)
                }
            }
        case let .succeeded(message):
            NCard {
                Label(message, systemImage: "checkmark.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.colorGreen)
            }
        case let .failed(error):
            NFeatureStatusCard.error(error)
        }
    }
}
