import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import 'wish_home.dart';
import 'wish_identity.dart';
import 'wish_dot_motion.dart';
import 'wish_motion.dart';

/// Real phase label, without a fabricated percentage or minimum waiting time.
class WishLaunch extends StatelessWidget {
  const WishLaunch({super.key, required this.title, required this.stage, this.icon = const {}, this.retry});
  final String title, stage;
  final Map<String, dynamic> icon;
  final VoidCallback? retry;
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: wishBg,
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: wishBlue.withValues(alpha: .16), blurRadius: 54, spreadRadius: 8)],
              ),
              child: WishIdentityIcon(icon: icon, size: 64),
            ),
            const SizedBox(height: 28),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(color: wishText, fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            WishDotLoader(size: 56, phase: stage),
            const SizedBox(height: 16),
            WishContentTransition(
              child: Text(
                stage,
                key: ValueKey(stage),
                style: const TextStyle(color: wishText2, fontSize: 13),
              ),
            ),
            if (retry != null)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: TextButton(onPressed: retry, child: Text(appL10n.wishRetry)),
              ),
          ],
        ),
      ),
    ),
  );
}
