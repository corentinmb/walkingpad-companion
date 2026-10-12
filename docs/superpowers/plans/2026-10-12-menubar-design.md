# Menu bar redesign implementation plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement the approved menu mockup with a reusable native design system.
**Architecture:** Separate theme and reusable components from a pure presentation model and the service-connected ContentView. Keep existing services and footer actions.
**Tech Stack:** SwiftUI, AppKit, Swift 5 language mode, macOS 13.
**Spec:** `docs/superpowers/specs/2026-10-12-menubar-design.md`

## Global constraints
- Real daily counters, confirmed BLE state and existing commands.
- Goal default 12,000; effective range 1,000–50,000; increments 1,000 in UI.
- Manual speed range 10–85 device units; step 5; only connected/running/manual.
- Theme/components live under `walkingpad-client/designSystem/`.
- Start from origin/master; PR only to corentinmb/walkingpad-companion.

## Review focus
- Disconnected or missing BLE status must not enable treadmill controls.
- Automatic mode must not expose enabled manual speed controls.
- Invalid persisted goal, negative counters and goal completion must produce finite clamped progress.
- System dark/light appearance, Reduce Motion and keyboard/VoiceOver operation.
- Clean checkout must include sources and build configuration without local-only files.

## Task 1: Presentation model and regression checks
**Files:** `walkingpad-client/models/MenuBarPresentation.swift`, `tests/MenuBarPresentationTests.swift`, `tests/run-menubar-presentation.sh`.
**Produces:** WorkoutMetric display metadata; WorkoutSummary formatted values and progress; SpeedControlPolicy methods using DeviceState plus connection state.
- [x] Write checks for 10,085 steps, 3,050 m, 5,563 s, empty/negative counters, invalid/complete goals; speed boundaries and connection/manual/running eligibility.
- [x] Run failing checks before model implementation.
- [x] Implement pure formatting, goal normalization, progress and speed policy.
- [x] Run new checks and existing workout suite.

## Task 2: Design system and integrated panel
**Files:** `walkingpad-client/designSystem/*.swift`, `walkingpad-client/views/ContentView.swift`, `FooterView.swift`, `LoginLogoutButton.swift`, `walkingpad_clientApp.swift`, `.gitignore`, Xcode project, `docs/design-system.md`, README.
**Consumes:** Task 1 presentation API.
**Produces:** Theme tokens, generic UI components, state-aware menu panel and reproducible project.
- [x] Implement theme and reusable components, including keyboard-accessible segmented picker and ring.
- [x] Integrate live counters, local goal preference, status/session details, speed/mode commands and footer.
- [x] Update popover size, register source files and track project configuration.
- [x] Document component usage, attribution, build and hardware check procedure.
- [x] Run full regression suite, Debug build, render actual SwiftUI components, and inspect available previews.
- [x] Obtain fresh review, resolve important findings, resolve important findings; commit, push and create PR after the final checks.
