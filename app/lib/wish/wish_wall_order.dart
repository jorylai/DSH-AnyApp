import 'package:shared_preferences/shared_preferences.dart';

enum WishWallSort { added, recent }

/// Sort indices, so open/edit/remove keep their original work identity.
List<int> wishWallOrder(List<({String id, int added})> works, WishWallSort sort, Map<String, int> lastUsed) {
  final order = List.generate(works.length, (i) => i);
  order.sort((a, b) {
    if (sort == WishWallSort.recent) {
      final used = (lastUsed[works[b].id] ?? 0).compareTo(lastUsed[works[a].id] ?? 0);
      if (used != 0) return used;
    }
    final added = works[b].added.compareTo(works[a].added);
    return added != 0 ? added : b.compareTo(a);
  });
  return order;
}

Future<void> recordWishOpen(String id) async {
  final prefs = await SharedPreferences.getInstance();
  final now = DateTime.now().millisecondsSinceEpoch;
  await prefs.setInt('wish-wall-used:$id', now);
}
