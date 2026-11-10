import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n.dart';
import '../state/phone_state.dart';
import 'wish_preferences.dart';
import 'wish_form.dart';
import 'wish_ui.dart';
import 'wish_home.dart';

class WishExecutionSettings extends ConsumerStatefulWidget {
  const WishExecutionSettings({super.key});
  @override
  ConsumerState<WishExecutionSettings> createState() => _ExecutionState();
}

class _ExecutionState extends ConsumerState<WishExecutionSettings> {
  bool? _full;
  bool _busy = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final full = await WishPreferences.fullCreator();
      await ref.read(phoneProvider.notifier).refresh();
      if (mounted) setState(() => _full = full);
    });
  }

  Future<void> _change(Future<void> Function() fn) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await fn();
      await ref.read(phoneProvider.notifier).refresh();
    } catch (e) {
      if (mounted) setState(() => _error = wishErrorText(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final policy = ref.watch(phoneProvider).policies;
    return WishPage(
      title: appL10n.wishAuthorization,
      children: [
        if (_busy) const LinearProgressIndicator(),
        if (_error != null) Text(_error!, style: const TextStyle(color: wishWarm)),
        WishCard(
          title: appL10n.wishCreatorHeader,
          help: appL10n.wishFullAccessHelp,
          children: [
            SwitchListTile(
              title: Text(appL10n.wishFullAccess),
              subtitle: Text(appL10n.wishFullCreatorDetail),
              value: _full ?? true,
              onChanged: _full == null || _busy
                  ? null
                  : (value) => _change(() async {
                      await WishPreferences.setFullCreator(value);
                      if (mounted) setState(() => _full = value);
                    }),
            ),
          ],
        ),
        WishCard(
          title: appL10n.wishPhone,
          help: appL10n.wishPreauthorizedApps,
          children: [
            for (final row in [
              (PhoneConfirmMode.always, appL10n.phoneConfirmAlways),
              (PhoneConfirmMode.task, appL10n.phoneConfirmTask),
              (PhoneConfirmMode.ask, appL10n.phoneConfirmAsk),
            ])
              ListTile(
                leading: Icon(
                  policy?.confirmMode == row.$1 ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: policy?.confirmMode == row.$1 ? wishBlue : wishText3,
                ),
                title: Text(row.$2),
                onTap: policy == null || _busy
                    ? null
                    : () => _change(() async {
                        await ref.read(phoneChannelProvider).setPolicies(policy.withConfirmMode(row.$1));
                      }),
              ),
          ],
        ),
      ],
    );
  }
}
