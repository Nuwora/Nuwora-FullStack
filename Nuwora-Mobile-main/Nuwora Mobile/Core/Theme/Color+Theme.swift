import SwiftUI
import UIKit

private extension UIColor {
    convenience init?(nuworaHex hex: String) {
        let sanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        guard sanitized.count == 6 || sanitized.count == 8 else { return nil }

        var value: UInt64 = 0
        guard Scanner(string: sanitized).scanHexInt64(&value) else { return nil }

        let r: CGFloat
        let g: CGFloat
        let b: CGFloat
        let a: CGFloat

        if sanitized.count == 6 {
            r = CGFloat((value & 0xFF0000) >> 16) / 255
            g = CGFloat((value & 0x00FF00) >> 8) / 255
            b = CGFloat(value & 0x0000FF) / 255
            a = 1
        } else {
            r = CGFloat((value & 0xFF000000) >> 24) / 255
            g = CGFloat((value & 0x00FF0000) >> 16) / 255
            b = CGFloat((value & 0x0000FF00) >> 8) / 255
            a = CGFloat(value & 0x000000FF) / 255
        }

        self.init(red: r, green: g, blue: b, alpha: a)
    }
}

extension Color {
    private static func dynamic(light lightHex: String, dark darkHex: String) -> Color {
        Color(
            uiColor: UIColor { traits in
                let hex = traits.userInterfaceStyle == .dark ? darkHex : lightHex
                let fallbackHex = traits.userInterfaceStyle == .dark ? "0D0D0D" : "F4F4F2"
                return UIColor(nuworaHex: hex) ?? UIColor(nuworaHex: fallbackHex) ?? .clear
            }
        )
    }

    // Backgrounds
    static let appBackground = dynamic(light: "#F4F4F2", dark: "#0D0D0D")
    static let appSurface = dynamic(light: "#FFFFFF", dark: "#161616")
    static let appCard = dynamic(light: "#EAEAE6", dark: "#1E1E1E")

    // Accent
    static let accent = dynamic(light: "#4D8A00", dark: "#A3E635")
    static let accentDim = dynamic(light: "#3A6B00", dark: "#6B9E1F")
    static let accentTint = dynamic(light: "#D4EDAA", dark: "#1A2E0A")
    static let coachZenMonk = dynamic(light: "#2F8F4E", dark: "#7EE787")
    static let coachPeakPerformer = dynamic(light: "#7C4DFF", dark: "#C4B5FD")
    static let coachNeuroscientist = dynamic(light: "#EA7A18", dark: "#FDBA74")

    static let coachZenMonkSurface = dynamic(light: "#EAF7EE", dark: "#15261B")
    static let coachPeakPerformerSurface = dynamic(light: "#F2ECFF", dark: "#241B36")
    static let coachNeuroscientistSurface = dynamic(light: "#FFF2E6", dark: "#332314")

    // Text
    static let textPrimary = dynamic(light: "#111111", dark: "#F0F0F0")
    static let textSecondary = dynamic(light: "#6A6A6A", dark: "#8A8A8A")

    // Borders
    static let borderSubtle = dynamic(light: "#E0E0DB", dark: "#2A2A2A")

    // Semantic
    static let destructive = Color(hex: "#FF453A")
    static let warning = Color(hex: "#FF9F0A")
    static let success = Color(hex: "#30D158")
    static let info = Color(hex: "#0A84FF")

    // Optional supporting tokens
    static let textTertiary = dynamic(light: "#8A8A88", dark: "#8A8A8A")
    static let borderStrong = dynamic(light: "#CFCFCB", dark: "#3A3A3A")
}
