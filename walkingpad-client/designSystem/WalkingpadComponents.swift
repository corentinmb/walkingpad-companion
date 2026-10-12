import SwiftUI

struct WalkingpadPanelBackground: View {
    var body: some View {
        WalkingpadTheme.Colors.panel
            .overlay {
                RadialGradient(colors: [WalkingpadTheme.Colors.glow, .clear],
                               center: .init(x: 0.5, y: 0.35), startRadius: 10, endRadius: 230)
            }
    }
}

struct WalkingpadSegmentedControl<Selection: Hashable>: View {
    let options: [Selection]
    @Binding var selection: Selection
    let label: (Selection) -> String

    var body: some View {
        HStack(spacing: WalkingpadTheme.Spacing.tiny) {
            ForEach(options, id: \.self) { option in
                Button { selection = option } label: {
                    Text(label(option))
                        .font(WalkingpadTheme.Typography.body)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, WalkingpadTheme.Spacing.small)
                        .foregroundStyle(selection == option ? WalkingpadTheme.Colors.onAccent : WalkingpadTheme.Colors.secondaryText)
                        .background {
                            if selection == option {
                                Capsule().fill(WalkingpadTheme.Colors.accentGradient)
                            }
                        }
                }
                .buttonStyle(.plain)
                .contentShape(Capsule())
                .accessibilityAddTraits(selection == option ? .isSelected : [])
            }
        }
        .padding(WalkingpadTheme.Spacing.tiny)
        .background(WalkingpadTheme.Colors.control, in: Capsule())
        .onMoveCommand { direction in
            guard let index = options.firstIndex(of: selection) else { return }
            switch direction {
            case .left: selection = options[max(index - 1, 0)]
            case .right: selection = options[min(index + 1, options.count - 1)]
            default: break
            }
        }
    }
}

struct WalkingpadCircularButtonStyle: ButtonStyle {
    var primary = false
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: primary ? 25 : 22, weight: .medium))
            .frame(width: primary ? WalkingpadTheme.Layout.primaryActionSize : WalkingpadTheme.Layout.actionSize,
                   height: primary ? WalkingpadTheme.Layout.primaryActionSize : WalkingpadTheme.Layout.actionSize)
            .foregroundStyle(primary ? WalkingpadTheme.Colors.onAccent : WalkingpadTheme.Colors.text)
            .background {
                if primary { Circle().fill(WalkingpadTheme.Colors.accentGradient) }
                else { Circle().fill(WalkingpadTheme.Colors.control) }
            }
            .contentShape(Circle())
            .opacity(isEnabled ? (configuration.isPressed ? 0.75 : 1) : 0.35)
    }
}

struct WalkingpadQuietButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(WalkingpadTheme.Typography.detail)
            .foregroundStyle(configuration.isPressed ? WalkingpadTheme.Colors.text : WalkingpadTheme.Colors.secondaryText)
            .padding(.vertical, WalkingpadTheme.Spacing.tiny)
            .contentShape(Rectangle())
            .opacity(isEnabled ? 1 : 0.35)
    }
}
