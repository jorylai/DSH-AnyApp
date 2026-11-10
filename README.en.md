# DSH AnyApp 0.10.11

Create personal Android apps with natural language and real DeepSeek Harness Creator. New installs include Price Radar 1.25.0 and Pomodoro. Existing works and records are not replaced by starter updates.

## Thanks

Special thanks to [DSH Go](https://github.com/ccch1mneyyy/dsh-go), its author and contributors. Their product showed us a practical path for running DeepSeek Harness on Android and connecting accessibility, overlays and other Android capabilities. Their exploration and open-source work were an important starting point for DSH AnyApp. This is an independently maintained community derivative, not an official DeepSeek or DSH Go distribution or endorsement.

## Install and build

Use DSH-AnyApp-0.10.11-arm64.apk on ARM64 Android 8+. Upgrade in place with the same package and signing key; do not uninstall or clear data. app.dshwish.fresh is a separate testing identity.

Flutter 3.47.9 / Dart 3.13.7, JDK 17, Android SDK 36. Build the ARM64 Linux runtime using runtime/build-runtime.sh and place its output in runtime/out/arm64-v8a. Run flutter pub get in app, then bash tooling/build-apk.sh --build-name 0.10.11 from the root. node products/radar-release/build.mjs regenerates the radar starter.

Signing keys, local configuration and accounts are excluded. Use your own signing key for your builds. AGPL-3.0 and third-party licenses apply; see LICENSE, THIRD_PARTY_NOTICES.md and ASSETS.md.

## Current limits

This APK targets API 28 for its local Linux execution architecture and is not a Google Play submission package. Final full device regression is pending. The independent in-app update feed has not been enabled. Automated tests and package verification do not establish successful live cross-app price comparison.
