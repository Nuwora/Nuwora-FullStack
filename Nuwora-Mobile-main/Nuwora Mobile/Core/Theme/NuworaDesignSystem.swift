import SwiftUI

enum DesignTokens {
    enum Colors {
        static let background = Color.appBackground
        static let surface = Color.appSurface
        static let surfaceHigh = Color.appCard
        static let border = Color.borderSubtle
        static let borderStrong = Color.borderStrong

        static let green = Color.accent
        static let greenDeep = Color.accentDim
        static let teal = Color.accentDim
        static let purple = Color.accentTint
        static let amber = Color.warning
        static let rose = Color.destructive

        static let textPrimary = Color.textPrimary
        static let textSecondary = Color.textSecondary
        static let textTertiary = Color.textTertiary

        static let glowGreen = Color.accent.opacity(0.24)
        static let glowTeal = Color.accentDim.opacity(0.19)
        static let glowPurple = Color.accentTint.opacity(0.2)
    }

    enum Gradients {
        static let appBackground = LinearGradient(
            colors: [
                Color.appBackground,
                Color.appSurface,
                Color.appCard
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let glass = LinearGradient(
            colors: [
                Color.textPrimary.opacity(0.15),
                Color.textPrimary.opacity(0.04)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let cardSurface = LinearGradient(
            colors: [
                Color.appCard.opacity(0.88),
                Color.appSurface.opacity(0.96)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let cardSheen = LinearGradient(
            colors: [
                Color.textPrimary.opacity(0.14),
                Color.textPrimary.opacity(0.04),
                Color.clear
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let primaryButton = LinearGradient(
            colors: [Colors.green, Colors.teal],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let activeTab = LinearGradient(
            colors: [Colors.teal.opacity(0.44), Colors.green.opacity(0.24), Colors.purple.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let tabBarBase = LinearGradient(
            colors: [
                Color.appCard.opacity(0.84),
                Color.appSurface.opacity(0.72)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    enum CornerRadius {
        static let compact: CGFloat = 10
        static let standard: CGFloat = 12
        static let medium: CGFloat = 14
        static let large: CGFloat = 16
        static let xlarge: CGFloat = 18

        static let card: CGFloat = 24
        static let button: CGFloat = 17
        static let chip: CGFloat = 12
        static let tabBar: CGFloat = 30
    }

    enum Spacing {
        static let xxs: CGFloat = 2
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }

    enum Insets {
        static let cardCompact: CGFloat = 10
        static let cardRegular: CGFloat = 12
        static let cardComfortable: CGFloat = 14
        static let modal: CGFloat = 20

        static let pillHorizontal: CGFloat = 10
        static let pillVertical: CGFloat = 6

        static let chipHorizontal: CGFloat = 8
        static let chipVertical: CGFloat = 5
    }

    enum Layout {
        static let contentBottomInset: CGFloat = 110
        static let contentBottomInsetWithFloatingBar: CGFloat = 130
        static let floatingBarTopPadding: CGFloat = 8
        static let floatingBarBottomPadding: CGFloat = 18
    }

    enum Shadows {
        static let softRadius: CGFloat = 8
        static let softY: CGFloat = 4
        static let glowRadius: CGFloat = 14
    }

    enum Motion {
        static let standardSpring = Animation.spring(response: 0.42, dampingFraction: 0.82)
        static let tabSpring = Animation.spring(response: 0.40, dampingFraction: 0.84)
        static let gaugeSpring = Animation.spring(response: 1.05, dampingFraction: 0.84)
        static let pageSpring = Animation.spring(response: 0.54, dampingFraction: 0.86)
        static let softEase = Animation.easeInOut(duration: 0.32)
        static let quickEase = Animation.easeOut(duration: 0.22)
        static let backgroundBreathing = Animation.easeInOut(duration: 14).repeatForever(autoreverses: true)
    }
}
