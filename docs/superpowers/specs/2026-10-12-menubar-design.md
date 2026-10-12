# Walkingpad Companion menu bar

Implement the approved Pomodoro-inspired HTML mockup as a native SwiftUI popover on a dedicated branch from master. Keep the live workout, BLE commands, login/logout, statistics link, quit/save and manual/automatic modes.

## Interface

A compact 320-point panel: segmented Steps / Time / Distance selector; large daily metric within a daily step goal ring; remaining two daily metrics underneath; confirmed connection/activity status and current-session duration; circular slower / Start-or-Stop / faster controls; confirmed speed and manual/automatic selector; quiet Stats / Login-or-Logout / Quit footer. Use English like the existing app. Stopping sends the existing zero-speed command and is labeled Stop, with no promise of resumable pause. Disconnected controls are disabled and today's counters remain visible. Automatic mode disables manual speed changes. Speed buttons use 0.5 km/h increments inside the existing selectable 1.0–8.5 km/h range and never start a stopped treadmill.

The mockup's 12,000-step goal becomes a real local preference, configurable from an accessible goal button (1,000–50,000, increments 1,000). Clamp invalid persisted values when reading and never divide by zero. Ring progress represents daily steps on all three tabs and is explicitly labeled as such. Do not invent session totals, device status, or speed. Wait for BLE confirmations after commands.

## Design system

Store semantic colors, spacing, typography, panel sizing and motion tokens in `walkingpad-client/designSystem/WalkingpadTheme.swift`. Store generic segmented controls, circular command button style, quiet footer style, panel background and accessible progress ring beside it. Components do not know about BLE, workout persistence, or HCGateway. Document contracts, usage, light/dark behavior, accessibility and reference attribution in `docs/design-system.md`. Respect system appearance and Reduce Motion; provide VoiceOver labels and visible keyboard focus.

## Build and verification

Track the currently ignored reconstructed Xcode project, updated to include all new Swift sources. Target macOS 13; retain pinned Swift packages and ad-hoc local signing, without a personal developer team. This makes a clean checkout buildable. Keep the exploratory HTML mockup untracked.

Test formatting, goal clamping, ring ratios and speed policy with Swift regression checks; run existing workout tests. Build Debug app. Render the actual SwiftUI content using fake sample data in a standalone AppKit preview harness (no BLE/network services), in light/dark and disconnected/running/automatic states, if the environment supports capture. Hardware BLE behavior still requires the treadmill.
