import 'package:flutter/material.dart';

import '../l10n/l10n.dart';

/// A single host menu. Infrequent management tools stay available without
/// competing with opening the app or continuing its creation conversation.
class WishProjectMenu extends StatelessWidget {
  const WishProjectMenu({
    super.key,
    required this.title,
    required this.creator,
    required this.published,
    required this.onSelected,
  });
  final String title;
  final bool creator, published;
  final ValueChanged<String> onSelected;

  Widget _entry(String value, IconData icon, String label) => ListTile(
    key: ValueKey('work-menu-$value'),
    leading: Icon(icon),
    title: Text(label),
    onTap: () => onSelected(value),
  );

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(title, maxLines: 2),
            subtitle: Text(creator ? appL10n.wishCreatorConversation : appL10n.wishPreviewPlugin),
          ),
          _entry('preview', Icons.open_in_new_rounded, appL10n.wishPreviewPlugin),
          _entry('creator', Icons.edit_outlined, appL10n.wishEditConversation),
          const Divider(height: 16, indent: 20, endIndent: 20),
          _entry('settings', Icons.tune_outlined, appL10n.wishWorkSettings),
          _entry('identity', Icons.palette_outlined, appL10n.wishIdentity),
          _entry('permissions', Icons.shield_outlined, appL10n.anyPermissionsAndActions),
          ExpansionTile(
            key: const ValueKey('work-menu-more'),
            maintainState: false,
            leading: const Icon(Icons.more_horiz_rounded),
            title: Text(appL10n.anyWorkMoreManagement),
            subtitle: Text(appL10n.anyWorkMoreManagementHelp),
            children: [
              _entry('versions', Icons.history_outlined, appL10n.wishVersions),
              _entry('records', Icons.receipt_long_outlined, appL10n.wishRecords),
              _entry(
                'publish',
                published ? Icons.visibility_off_outlined : Icons.push_pin_outlined,
                published ? appL10n.wishUnpublish : appL10n.wishPublish,
              ),
              _entry('task', Icons.smart_toy_outlined, appL10n.wishTaskConversation),
              _entry('models', Icons.manage_accounts_outlined, appL10n.wishCreatorModelSettings),
            ],
          ),
          _entry('wall', Icons.arrow_back_rounded, appL10n.wishBackWall),
        ],
      ),
    ),
  );
}
