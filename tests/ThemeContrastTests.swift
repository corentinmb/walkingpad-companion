import SwiftUI
import AppKit

@main
struct ThemeContrastTests {
    static func main() {
        _ = NSApplication.shared
        for name in [NSAppearance.Name.aqua, .darkAqua] {
            let appearance = NSAppearance(named: name)!
            appearance.performAsCurrentDrawingAppearance {
                let foreground = NSColor(WalkingpadTheme.Colors.onAccent)
                for background in [WalkingpadTheme.Colors.accent, WalkingpadTheme.Colors.accentEnd] {
                    let first = luminance(foreground)
                    let second = luminance(NSColor(background))
                    let contrast = (max(first, second) + 0.05) / (min(first, second) + 0.05)
                    print("\(name.rawValue): selected text contrast \(contrast)")
                    precondition(contrast >= 4.5, "Selected tab text must meet 4.5:1 contrast")
                }
            }
        }
        print("Theme contrast regression checks passed")
    }

    static func luminance(_ color: NSColor) -> Double {
        let rgb = color.usingColorSpace(.sRGB)!
        func linear(_ value: CGFloat) -> Double {
            let value = Double(value)
            return value <= 0.04045 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * linear(rgb.redComponent) + 0.7152 * linear(rgb.greenComponent) + 0.0722 * linear(rgb.blueComponent)
    }
}
