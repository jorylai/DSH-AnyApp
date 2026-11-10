import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n.dart';
import '../state/phone_state.dart';
import '../runtime/runtime_state.dart';
import 'wish_home.dart';
import 'wish_ui.dart';
import 'wish_setup_guide.dart';

class WishPhoneSetupPage extends ConsumerStatefulWidget {
  const WishPhoneSetupPage({super.key, this.embedded = false});
  final bool embedded;
  @override
  ConsumerState<WishPhoneSetupPage> createState() => _WishPhoneSetupPageState();
}

class _WishPhoneSetupPageState extends ConsumerState<WishPhoneSetupPage> {
  String? _error;
  late final _life = AppLifecycleListener(onResume: _refresh);
  @override
  void initState() {
    super.initState();
    _life;
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  @override
  void dispose() {
    _life.dispose();
    super.dispose();
  }

  Future<void> _refresh() => ref.read(phoneProvider.notifier).refresh();
  Future<void> _toggle(bool value) async {
    try {
      if (value && !ref.read(phoneProvider).disclosureAccepted) {
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(appL10n.anySetupDisclosureTitle),
            scrollable: true,
            content: Text(appL10n.anySetupEngineConsent),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(appL10n.anySetupDisclosureLater)),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(appL10n.anySetupDisclosureContinue)),
            ],
          ),
        );
        if (ok != true || !mounted) return;
        await ref.read(phoneProvider.notifier).acceptDisclosure();
      }
      final result = await ref.read(phoneProvider.notifier).setEnabled(value);
      if (!result.ok) throw StateError(appL10n.wishFailure);
      if (mounted) setState(() => _error = null);
    } catch (_) {
      if (mounted) setState(() => _error = appL10n.anySetupEngineFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final phone = ref.watch(phoneProvider);
    final s = phone.status;
    if (widget.embedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Text(_error!, style: const TextStyle(color: wishWarm)),
            ),
          SwitchListTile.adaptive(
            key: const ValueKey('phone-engine-switch'),
            title: Text(appL10n.anySetupEngineTitle),
            subtitle: Text(s.enabled && s.bridgeListening ? appL10n.wishDeviceReady : appL10n.anySetupEngineHelp),
            value: s.enabled,
            onChanged: phone.toggling || !phone.loaded ? null : _toggle,
          ),
          const WishSetupGuidePage(initialTopic: 'accessibility', embedded: true),
          ListTile(
            title: Text(appL10n.wishReadScreenTest),
            leading: const Icon(Icons.fact_check_outlined),
            onTap: !s.a11y.ok
                ? null
                : () async {
                    final result = await ref.read(phoneChannelProvider).testScreen();
                    if (mounted) {
                      ScaffoldMessenger.of(
                        this.context,
                      ).showSnackBar(SnackBar(content: Text(result.ok ? appL10n.wishA11yTestOk : appL10n.wishFailure)));
                    }
                  },
          ),
          if (phone.policies != null)
            SwitchListTile.adaptive(
              title: Text(appL10n.phoneConfirmAsk),
              subtitle: Text(appL10n.wishPhoneRulesHelp),
              value: phone.policies!.confirmMode == PhoneConfirmMode.ask,
              onChanged: (value) async {
                try {
                  final saved = await ref
                      .read(phoneChannelProvider)
                      .setPolicies(
                        phone.policies!.withConfirmMode(value ? PhoneConfirmMode.ask : PhoneConfirmMode.always),
                      );
                  if (!saved) throw StateError('phone-policy-save-failed');
                  await _refresh();
                } catch (_) {
                  if (mounted) setState(() => _error = appL10n.wishFailure);
                }
              },
            ),
        ],
      );
    }
    final runtime = ref.watch(localRuntimeProvider).status;
    return WishPage(
      title: appL10n.wishPhone,
      children: [
        Text(appL10n.anySetupPhonePageHelp, style: const TextStyle(color: wishText2, height: 1.5)),
        const SizedBox(height: 20),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(_error!, style: const TextStyle(color: wishWarm)),
          ),
        WishCard(
          children: [
            WishRow(
              title: appL10n.phoneSetupGuideTitle,
              help: appL10n.anySetupSettingsBody,
              icon: Icons.phonelink_setup_rounded,
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute<void>(builder: (_) => const WishSetupGuidePage(initialTopic: 'accessibility'))),
            ),
          ],
        ),
        WishCard(
          title: appL10n.wishSharedDevice,
          help: appL10n.anySetupEngineHelp,
          children: [
            SwitchListTile(
              title: Text(appL10n.anySetupEngineTitle),
              value: s.enabled,
              onChanged: phone.toggling || !phone.loaded ? null : _toggle,
            ),
            WishRow(
              title: appL10n.wishGuideA11y,
              help: s.a11y.ok ? appL10n.wishDeviceReady : appL10n.wishA11yInstruction,
              icon: Icons.accessibility_new,
              onTap: () async {
                await ref.read(phoneChannelProvider).openAccessibilitySettings();
              },
            ),
            WishRow(
              title: appL10n.wishNotificationSetup,
              help: s.notifications ? appL10n.wishDeviceReady : appL10n.wishDeviceOff,
              icon: Icons.notifications_outlined,
              onTap: () async {
                await ref.read(phoneChannelProvider).openAppDetails();
              },
            ),
            WishRow(
              title: appL10n.wishReadScreenTest,
              icon: Icons.fact_check_outlined,
              onTap: s.a11y.ok
                  ? () async {
                      final result = await ref.read(phoneChannelProvider).testScreen();
                      if (mounted) {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(content: Text(result.ok ? appL10n.wishA11yTestOk : appL10n.wishFailure)),
                        );
                      }
                    }
                  : null,
            ),
          ],
        ),
        WishCard(
          title: appL10n.wishPhoneRules,
          help: appL10n.wishPhoneRulesHelp,
          children: [
            WishRow(
              title: appL10n.wishRuntimeTitle,
              help: runtime.isRunning && s.bridgeListening ? appL10n.wishDeviceReady : appL10n.wishDeviceOff,
              icon: Icons.memory_outlined,
            ),
            if (phone.policies != null)
              SwitchListTile(
                title: Text(appL10n.phoneConfirmAsk),
                subtitle: Text(appL10n.wishPhoneRulesHelp),
                value: phone.policies!.confirmMode == PhoneConfirmMode.ask,
                onChanged: (v) async {
                  final p = phone.policies!;
                  await ref
                      .read(phoneChannelProvider)
                      .setPolicies(p.withConfirmMode(v ? PhoneConfirmMode.ask : PhoneConfirmMode.always));
                  await _refresh();
                },
              ),
          ],
        ),
      ],
    );
  }
}
