import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../state/app_info.dart';
import '../ui/update/update_sheet.dart';
import '../update/update_config.dart';
import 'wish_ui.dart';
import 'wish_material.dart';
import 'wish_palette.dart';

class WishUpdatesPage extends StatelessWidget {
  const WishUpdatesPage({super.key});
  @override
  Widget build(BuildContext context) => WishPage(
    title: appL10n.wishUpdateTitle,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WishBrandMark(size: 56),
            const SizedBox(height: 20),
            Text(
              appL10n.wishUpdatePoem,
              style: const TextStyle(fontSize: 28, height: 1.3, color: wishText, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text('DSH AnyApp · ${AppInfo.displayVersion}', style: const TextStyle(color: wishText2)),
          ],
        ),
      ),
      WishCard(
        title: appL10n.wishUpdateNew,
        children: [
          WishRow(
            icon: Icons.auto_awesome_outlined,
            title: appL10n.wishUpdateDesign,
            help: appL10n.wishUpdateDesignHelp,
          ),
          WishRow(icon: Icons.bubble_chart_outlined, title: appL10n.wishUpdateFloat, help: appL10n.wishUpdateFloatHelp),
          WishRow(icon: Icons.palette_outlined, title: appL10n.wishUpdateKit, help: appL10n.wishUpdateKitHelp),
        ],
      ),
      WishCard(
        title: appL10n.wishUpdateWay,
        children: [
          WishRow(icon: Icons.verified_user_outlined, title: appL10n.wishUpdateKeep, help: appL10n.wishUpdateKeepHelp),
          WishRow(icon: Icons.history_rounded, title: appL10n.wishUpdateWork, help: appL10n.wishUpdateWorkHelp),
          WishRow(
            icon: Icons.cloud_download_outlined,
            title: anyappUpdateFeedUri == null ? appL10n.wishUpdateChannelPending : appL10n.updateCheck,
            help: anyappUpdateFeedUri == null ? appL10n.wishUpdateChannelHelp : anyappUpdateFeedUri!.host,
            onTap: anyappUpdateFeedUri == null ? null : () => showUpdateSheet(context),
          ),
        ],
      ),
    ],
  );
}
