# AnyApp frontend event contract v1

[简体中文](README.md)

The legacy usage sender, consent, IDs and queue are retired. DSH_USAGE_ENDPOINT cannot restore them. AnyApp consent starts off and is independent of DeepSeek's model-request session logs and feedback diagnostics.

A build may explicitly set `ANYAPP_ANALYTICS_ENDPOINT` to an owned HTTPS collector. There is no default or legacy fallback. User information, query strings, fragments, dshtui.com and its subdomains are rejected. Requests do not follow redirects or carry cookies/authorization; the user agent is dsh-anyapp. Without an endpoint, opting in only records locally. No receiving service or dashboard is deployed by this change.

POST JSON: `{"schema":"dsh-anyapp.analytics/1","events":[...]}`. Each batch contains up to 20 events. Fields are limited to id, event, at, install_id, session_id, app_version, and optional page, outcome, preset, elapsed_ms. Event/page/preset/outcome are fixed enums. Outcomes: start/success/failure/cancelled/skipped. Presets: voyo/calorie/imported. Duration is capped at 24 hours. IDs are random, not system device identifiers; installation IDs expire after 7 days and session IDs change on process restart.

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
