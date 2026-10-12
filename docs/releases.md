# Building and distributing Walkingpad Companion

## Local packages

Run from the repository root, with Xcode installed and selected as the developer directory:

```sh
./scripts/build-release.sh
```

This runs `build-app.sh` and `package-dmg.sh` in sequence. You can also run either script separately.

The default release build contains **arm64 and x86_64**. Output in `dist/` includes the app, a compressed DMG with an Applications shortcut, a ZIP and `SHA256SUMS`. Verify downloads with `shasum -a 256 -c SHA256SUMS` from that directory.

`WALKINGPAD_ARCHS=arm64` or `x86_64` selects one architecture. `WALKINGPAD_BUILD_DIR` overrides Xcode's derived data directory. `WALKINGPAD_VERSION` overrides the build version for local testing; otherwise the script reads `VERSION`. Debug builds use `./scripts/build-app.sh debug`.

The visible product name is Walkingpad Companion. The bundle identifier remains `klassm.walkingpad-client` so existing saved workouts, preferences and sandbox paths continue to work.

## Signed and notarized distribution (optional)

Default packages are **ad-hoc signed, without Apple notarization**. They are suitable for local testing; a downloaded app may require explicit approval through macOS Privacy & Security. A Developer ID certificate and Apple Developer account are required for normal notarized distribution.

Store notarization credentials interactively in the Keychain, never in the repository:

```sh
xcrun notarytool store-credentials walkingpad-companion
export WALKINGPAD_SIGN_IDENTITY='Developer ID Application: Your Name (TEAMID)'
export WALKINGPAD_NOTARY_PROFILE=walkingpad-companion
./scripts/build-app.sh
./scripts/notarize.sh
```

The helper submits the app ZIP, staples the app, packages it, submits and staples the DMG, then regenerates checksums. The ZIP contains the already stapled app. A submission failure stops the script; it does not publish anything. This path needs your certificate and account and is not exercised by CI. See [Apple's notarization documentation](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution).

## GitHub releases

The release workflow builds and tests a universal app on macOS when a `vMAJOR.MINOR.PATCH` tag is pushed. It creates a **draft release** containing DMG, ZIP and checksums. CI currently uses ad-hoc signing; no signing secrets are needed or configured.

Before tagging, merge the release changes into `master`, update `VERSION`, both Xcode `MARKETING_VERSION` values and the changelog. The tag must match `VERSION`, and its commit must be on `master`.

```sh
git switch master
git pull --ff-only
git tag v0.1.0
git push origin v0.1.0
```

Use the actual version being released. Review the generated draft and its assets before publishing. For a notarized release, build locally with Developer ID and replace all draft assets together, including checksums. The workflows do not publish releases automatically.

## GitHub Pages

The static landing page is in `site/`, uses local assets, and requires no build dependencies. Open `site/index.html` locally to preview it.

After merging, enable **Settings → Pages → Build and deployment → Source: GitHub Actions**. Run the **Pages** workflow manually for the first deployment. Subsequent changes to `site/` on `master` deploy automatically. The README's website link becomes available after this setup; this PR alone does not enable Pages.

Pages publishes only `site/`, not application sources or generated packages.

## App icon

The icon is drawn from source in `scripts/make-icon.swift`. Run `swift scripts/make-icon.swift` from the repository root to regenerate all Xcode icon sizes and the website image. No downloaded artwork or image generation service is required.
