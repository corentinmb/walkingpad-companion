import SwiftUI
import AppKit

/// Shared visual tokens. Keep feature-specific state and commands out of this namespace.
enum WalkingpadTheme {
    enum Colors {
        static let text = Color.primary
        static let secondaryText = Color.secondary
        static let accent = adaptive(light: 0x267A48, dark: 0x83D996)
        static let accentEnd = adaptive(light: 0x2F8056, dark: 0xB2ED9B)
        static let onAccent = adaptive(light: 0xFFFFFF, dark: 0x1B3223)
        static let panel = adaptive(light: 0xF3F5F2, dark: 0x282C2A)
        static let glow = adaptive(light: 0xD9EBDC, dark: 0x304437)
        static let control = adaptive(light: 0xE2E9E2, dark: 0x3A423C)
        static let track = adaptive(light: 0xD9E2DA, dark: 0x404A43)
        static let divider = adaptive(light: 0xD3DDD4, dark: 0x414A43)
        static let accentGradient = LinearGradient(colors: [accent, accentEnd], startPoint: .topLeading, endPoint: .bottomTrailing)

        private static func adaptive(light: UInt32, dark: UInt32) -> Color {
            Color(nsColor: NSColor(name: nil) { appearance in
                let value = appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua ? dark : light
                return NSColor(srgbRed: Double((value >> 16) & 255) / 255,
                               green: Double((value >> 8) & 255) / 255,
                               blue: Double(value & 255) / 255, alpha: 1)
            })
        }
    }

    enum Spacing {
        static let tiny: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 20
        static let extraLarge: CGFloat = 24
    }

    enum Layout {
        static let panelWidth: CGFloat = 320
        static let panelRadius: CGFloat = 20
        static let ringSize: CGFloat = 224
        static let ringStroke: CGFloat = 12
        static let actionSize: CGFloat = 46
        static let primaryActionSize: CGFloat = 72
    }

    enum Typography {
        static let metric = Font.system(size: 43, weight: .medium, design: .rounded).monospacedDigit()
        static let duration = Font.system(size: 35, weight: .medium, design: .rounded).monospacedDigit()
        static let caption = Font.system(size: 11, weight: .semibold, design: .rounded)
        static let body = Font.system(size: 13, weight: .medium, design: .rounded)
        static let detail = Font.system(size: 11, weight: .regular, design: .rounded)
    }

    static let progressAnimation = Animation.easeInOut(duration: 0.3)
}
