import SwiftUI

extension Color {
    init(hex: String) {
        let sanitized = hex.replacingOccurrences(of: "#", with: "")
        var value: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&value)

        switch sanitized.count {
        case 6:
            let r = Double((value & 0xFF0000) >> 16) / 255
            let g = Double((value & 0x00FF00) >> 8) / 255
            let b = Double(value & 0x0000FF) / 255
            self = Color(.sRGB, red: r, green: g, blue: b, opacity: 1)
        case 8:
            let r = Double((value & 0xFF000000) >> 24) / 255
            let g = Double((value & 0x00FF0000) >> 16) / 255
            let b = Double((value & 0x0000FF00) >> 8) / 255
            let a = Double(value & 0x000000FF) / 255
            self = Color(.sRGB, red: r, green: g, blue: b, opacity: a)
        default:
            self = .clear
        }
    }

    static let colorBackground = appBackground
    static let colorSurface = appSurface
    static let colorSurfaceHigh = appCard
    static let colorBorder = borderSubtle
    static let colorBorderStrong = borderStrong

    static let colorGreen = accent
    static let colorGreenDeep = accentDim
    static let colorTeal = accentDim
    static let colorPurple = accentTint
    static let colorAmber = warning
    static let colorRose = destructive

    static let colorTextPrimary = textPrimary
    static let colorTextSecondary = textSecondary
    static let colorTextTertiary = textTertiary
}
