# AnyApp frontend event contract v1


## Android Umeng integration (0.10.12)

Integration uses official umeng-cli 0.2.17 and umeng-skills-index 1.13.0 onboarding. Its macOS wrapper incorrectly requires CocoaPods for an Android-only project. The same unmodified official core installers were run within the recorded onboarding stage, analytics before APM/native crash setup. No iOS project is added.

Resolved Flutter dependencies: umeng_common_sdk 1.3.1 and umeng_apm_sdk 2.3.7. Android dependencies: Common 10.0.1, ASMS 1.8.7.2, APM 2.0.1, supplied once through the Flutter plugins. Channel is the user-specified `https://github.com/jorylai/DSH-AnyApp`. Push is not included and no Message Secret is needed. An override retains the app's http 1.6.x API; the APM plugin's MultipartRequest/MultipartFile usage is compatible.

Order: native UMCrash configuration/preInit, app UI, persisted current-disclosure consent, native consent check, initCommon, APM.init, route observation and fixed-enum events. The existing binding, animation clock and widget tree are retained. Automatic network tracing is disabled. Custom events do not include account identifiers, prompts or work content.

Collection starts off. Previous local-only consent does not authorize Umeng. A diagnosticsConsent revision and a native withdrawal record guard initialization. Disabling explicitly confirms closing the process to stop SDK timers. Accounts, works and business data are retained. The SDK processes device/app information, performance and error logs, as explained by the in-app privacy link.

For clean builds, install the official skill and run its `scripts/umeng-flutter-apm-integration/plugin_fixer.py <app-path>` after flutter pub get. It fixes vendor plugin stubs, compileSdk and jcenter compatibility; local pub-cache changes are not repository changes.

Validation separately records this run's getTodayData increments, device SDK evidence and APM exceptions. Successful compilation or initialization does not prove backend receipt. Sampling and API permission limits are reported explicitly.

[简体中文](README.md)

The legacy usage sender, consent, IDs and queue are retired. DSH_USAGE_ENDPOINT cannot restore them. AnyApp consent starts off and is independent of DeepSeek's model-request session logs and feedback diagnostics.

A build may explicitly set `ANYAPP_ANALYTICS_ENDPOINT` to an owned HTTPS collector. There is no default or legacy fallback. User information, query strings, fragments, dshtui.com and its subdomains are rejected. Requests do not follow redirects or carry cookies/authorization; the user agent is dsh-anyapp. This section describes the optional owned collector only. Without its endpoint, its queue remains local; the Android Umeng SDK described above uses its own channel. No owned receiving service or dashboard is deployed.

POST JSON: `{"schema":"dsh-anyapp.analytics/1","events":[...]}`. Each batch contains up to 20 events. Fields are limited to id, event, at, install_id, session_id, app_version, and optional page, outcome, preset, elapsed_ms. Event/page/preset/outcome are fixed enums. Outcomes: start/success/failure/cancelled/skipped. Presets: voyo/calorie/radar/pomodoro/imported. Duration is capped at 24 hours. IDs are random, not system device identifiers; installation IDs expire after 7 days and session IDs change on process restart.

There is no free-text properties API. Work identities/titles, prompts, conversations, accounts, authorization URLs, exception messages, screenshots, accessibility content, products, health and travel records are excluded.

The collector must validate and durably save the whole batch before acknowledging with 2xx and deduplicate event IDs. A timeout can occur after acceptance, so retries retain the same event IDs. Non2xx responses retain the batch and trigger backoff. The service must implement its own rate limits, retention and deletion policy.

The frontend keeps at most 200 pending events, sends 20 per batch, uses an 8-second timeout, and backs off from 30 seconds to 6 hours across process restarts. Events expire after 7 days. Disabling cancels current connections and clears the queue; already received server requests cannot be recalled. Failed consent persistence is shown explicitly with a retry action. Exports only contain pending local events, not a complete history of previously delivered events.

Measurement rules:

- appOpen occurs once per process after valid consent. No pre-consent history is reconstructed.
- Page and onboarding events occur on transitions, never on each build.
- Runtime installation results require native verification. Restarting an installed runtime is not a new installation.
- Login results follow the Host's actual result. Launching a browser is not login success.
- creatorResult describes creation of the Creator conversation, not completion of the product.
- workReady follows a real UI handshake or a previously verified cached UI becoming visible after a frame; a tap alone is insufficient.
- Published starter portions are verified on recovery without counting a second installation.
- Permission outcomes follow the native state, not the settings-page launch.

Fixed enums and implementation: `app/lib/analytics/anyapp_analytics.dart`. This frontend contract does not claim model inference or background-task completion has been validated.

The official Common Android Flutter plugin does not reply to initCommon. Follow the official example without awaiting its unresolved Future, so APM initialization can proceed. An unset owned collector URL does not disable Umeng after explicit opt-in.

Validation on 2026-11-11: 26 analytics/UI tests, static analysis and localization checks passed. An in-place upgrade to 0.10.12+2026110935 retained the 8 works visible on the device home. Official U-App verification confirmed launches 0→1 and new users 0→1. UMCrash captured one authorized native test crash and the app relaunched. The U-APM query returned threshold_free; cloud exception receipt is unconfirmed. No separate Dart exception was injected.
