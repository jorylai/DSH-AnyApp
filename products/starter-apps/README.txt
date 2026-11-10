DSH AnyApp · first-use starter products

Build: node products/starter-apps/build.mjs
Test: node --test products/starter-apps/tests/*.test.mjs
Copy the resulting radar.anyapp and pomodoro.anyapp to app/assets/presets/ after building.

These are real portable DSH web-client plugins, not host-only demonstrations. React and layout slots use the deployed DSH module loader. Packages contain source and vector artwork only, with no account, conversation or user record snapshots.

Radar: radarState collection stores guideComplete, product checks and pending task metadata. First launch shows a replayable three-step guide; skipping marks the guide complete without granting any permission. Paste/share and manual verified prices work before accessibility setup. Native shared import inbox is read through bridge.imports. Real comparison uses bridge.agent.start(prompt,{phone:false}); the floating action uses the default phone-enabled task. Root bridge must support the optional second argument. Result file remains an array, containing a requestId-bound structured comparison. Sources without URL, confirmed variant, price, shipping or check time are excluded; unavailable sources retain their actual reason. No model response is treated as a price without a genuine Agent result. Nothing opens the task chat automatically. Optional phone setup uses the existing capability centre; the global floating entry is never shown on mount.

Pomodoro: timerState collection stores settings, absolute deadline, remaining paused duration and all completed rounds. UI interval only redraws and reconciles elapsed deadlines; it does not implement background notification. Start/resume sets a real bridge.reminders deadline. Pause/reset/mode change cancels that reminder first; cancellation errors block the change rather than hiding a still-active alarm. Missing permission does not block foreground timing and is shown clearly. A failed write never displays success. No automatic next round. Settings affect the next round. No old session trimming.

Both products have work-scoped navigation handlers, right-menu clearance, small-screen/IME CSS, motion-reduction support, labelled controls and code-native artwork. Entry animations are one-shot; decorative motion does not run indefinitely.

Device checks remain necessary: source installation in a fresh profile, actual model/search availability, share import, native reminder delivery after leaving page, accessibility settings and floating action. Browser and Node checks do not substitute for these.
