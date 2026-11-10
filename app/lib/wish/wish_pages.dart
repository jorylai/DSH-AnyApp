import 'dart:async';
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

import 'wish_home.dart';
import 'wish_store.dart';

String _money(int cents) {
  final yuan = cents ~/ 100;
  final text = yuan.toString();
  final buf = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    if (i > 0 && (text.length - i) % 3 == 0) buf.write(',');
    buf.write(text[i]);
  }
  return '¥$buf';
}

String _clock(int seconds) {
  final m = (seconds ~/ 60).toString().padLeft(2, '0');
  final s = (seconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

class WishTodayFoodPage extends StatefulWidget {
  const WishTodayFoodPage({super.key});
  @override
  State<WishTodayFoodPage> createState() => _WishTodayFoodPageState();
}

class _WishTodayFoodPageState extends State<WishTodayFoodPage> {
  WishData? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final d = await WishStore.load();
    if (mounted) setState(() => _data = d);
  }

  Future<void> _add() async {
    final name = TextEditingController(text: '加餐');
    final kcal = TextEditingController(text: '200');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: wishSurface,
        title: const Text('记一餐', style: TextStyle(color: wishText)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              style: const TextStyle(color: wishText),
              decoration: const InputDecoration(labelText: '吃了什么'),
            ),
            TextField(
              controller: kcal,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: wishText),
              decoration: const InputDecoration(labelText: '热量 kcal'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('记下')),
        ],
      ),
    );
    if (ok == true) {
      await WishStore.addFood(int.tryParse(kcal.text) ?? 0, name: name.text.trim());
      await _load();
    }
    name.dispose();
    kcal.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = _data;
    return _WishPageScaffold(
      title: '今日饮食',
      child: d == null
          ? const Center(child: CircularProgressIndicator(color: wishBlue))
          : ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
              children: [
                Text('今天吃了什么', style: TextStyle(color: wishText2, fontSize: 13)),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: wishSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x1FFFFFFF)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${d.foodKcal}',
                        style: const TextStyle(color: wishText, fontSize: 36, fontWeight: FontWeight.w600, height: 1),
                      ),
                      const SizedBox(width: 6),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 3),
                        child: Text('kcal', style: TextStyle(color: wishText3, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                for (final e in d.food.reversed)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    decoration: BoxDecoration(
                      color: wishSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0x1FFFFFFF)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(color: wishGreen, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(e.name, style: const TextStyle(color: wishText, fontSize: 13)),
                        ),
                        Text('${e.kcal} kcal', style: const TextStyle(color: wishText3, fontSize: 12)),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _add,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('手动记一餐'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: wishText,
                    side: const BorderSide(color: Color(0x33FFFFFF)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
    );
  }
}

class WishWaterPage extends StatefulWidget {
  const WishWaterPage({super.key});
  @override
  State<WishWaterPage> createState() => _WishWaterPageState();
}

class _WishWaterPageState extends State<WishWaterPage> {
  WishData? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final d = await WishStore.load();
    if (mounted) setState(() => _data = d);
  }

  Future<void> _change(int delta) async {
    final d = await WishStore.addWater(delta);
    if (mounted) setState(() => _data = d);
  }

  @override
  Widget build(BuildContext context) {
    final d = _data;
    return _WishPageScaffold(
      title: '喝水提醒',
      child: d == null
          ? const Center(child: CircularProgressIndicator(color: wishBlue))
          : Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
              child: Column(
                children: [
                  const Text('今天喝到第几杯？', style: TextStyle(color: wishText2, fontSize: 13)),
                  const SizedBox(height: 26),
                  Text(
                    '${d.water}',
                    style: const TextStyle(color: wishText, fontSize: 86, fontWeight: FontWeight.w300, height: 1),
                  ),
                  const Text('/ 8 杯', style: TextStyle(color: wishText3, fontSize: 13)),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: d.water <= 0 ? null : () => _change(-1),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 50),
                            foregroundColor: wishText,
                            side: const BorderSide(color: Color(0x33FFFFFF)),
                          ),
                          child: const Text('少一杯'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          onPressed: d.water >= 20 ? null : () => _change(1),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 50),
                            backgroundColor: wishBlue,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('＋ 喝一杯'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('数据只在本机；提醒在 DSH 设置 › 通知。', style: TextStyle(color: wishText3, fontSize: 10.5)),
                ],
              ),
            ),
    );
  }
}

class WishRecordPage extends StatefulWidget {
  const WishRecordPage({super.key, required this.title, required this.kind, required this.hint, required this.icon});
  final String title;
  final String kind; // contacts / ledger / reading
  final String hint;
  final IconData icon;

  @override
  State<WishRecordPage> createState() => _WishRecordPageState();
}

class _WishRecordPageState extends State<WishRecordPage> {
  WishData? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final d = await WishStore.load();
    if (mounted) setState(() => _data = d);
  }

  Future<void> _add() async {
    final c = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: wishSurface,
        title: Text(
          widget.kind == 'ledger'
              ? '记一笔'
              : widget.kind == 'contacts'
              ? '加一个客户'
              : '记一次阅读',
          style: const TextStyle(color: wishText),
        ),
        content: TextField(
          controller: c,
          autofocus: true,
          keyboardType: widget.kind == 'ledger' ? TextInputType.number : TextInputType.text,
          style: const TextStyle(color: wishText),
          decoration: InputDecoration(hintText: widget.hint),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('保存')),
        ],
      ),
    );
    if (ok == true) {
      if (widget.kind == 'contacts') await WishStore.addContact(c.text);
      if (widget.kind == 'ledger') await WishStore.addLedger(c.text);
      if (widget.kind == 'reading') await WishStore.addReading();
      await _load();
    }
    c.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = _data;
    return _WishPageScaffold(
      title: widget.title,
      child: d == null
          ? const Center(child: CircularProgressIndicator(color: wishBlue))
          : ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
              children: [
                Text(widget.hint, style: const TextStyle(color: wishText2, fontSize: 13)),
                const SizedBox(height: 16),
                if (widget.kind == 'contacts') ...[
                  for (final name in d.contacts)
                    _row(
                      name,
                      '待联系',
                      trailing: TextButton(
                        onPressed: () async {
                          await WishStore.markContactDone();
                          await _load();
                        },
                        child: const Text('完成', style: TextStyle(color: wishGreen, fontSize: 12)),
                      ),
                    ),
                ] else if (widget.kind == 'ledger') ...[
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: wishSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0x1FFFFFFF)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _money(d.ledgerCents),
                          style: const TextStyle(color: wishText, fontSize: 30, fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        const Text('本月', style: TextStyle(color: wishText3, fontSize: 11)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final e in d.ledger.reversed) _row('支出', _money((int.tryParse(e) ?? 0) * 100)),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: wishSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0x1FFFFFFF)),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${d.reading}',
                          style: const TextStyle(color: wishText, fontSize: 34, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                        const Text('篇', style: TextStyle(color: wishText3, fontSize: 13)),
                        const Spacer(),
                        const Icon(Icons.menu_book_outlined, color: wishBlue),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (var i = 0; i < d.reading; i++) _row('阅读 ${i + 1}', '已记录'),
                ],
                const SizedBox(height: 8),
                if (widget.kind != 'reading' || true)
                  OutlinedButton.icon(
                    onPressed: _add,
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(
                      widget.kind == 'ledger'
                          ? '记一笔'
                          : widget.kind == 'contacts'
                          ? '加客户'
                          : '记一篇',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: wishText,
                      side: const BorderSide(color: Color(0x33FFFFFF)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _row(String title, String sub, {Widget? trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: wishSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x1FFFFFFF)),
      ),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(color: wishGreen, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: wishText, fontSize: 13)),
                Text(sub, style: const TextStyle(color: wishText3, fontSize: 10.5)),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}

class WishMedicinePage extends StatefulWidget {
  const WishMedicinePage({super.key});
  @override
  State<WishMedicinePage> createState() => _WishMedicinePageState();
}

class _WishMedicinePageState extends State<WishMedicinePage> {
  WishData? _data;
  final _time = TextEditingController(text: '20:00');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final d = await WishStore.load();
    if (!mounted) return;
    setState(() {
      _data = d;
      _time.text = d.medicine;
    });
  }

  @override
  void dispose() {
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = _data;
    return _WishPageScaffold(
      title: '药箱',
      child: d == null
          ? const Center(child: CircularProgressIndicator(color: wishBlue))
          : ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
              children: [
                const Text('下一次吃药', style: TextStyle(color: wishText2, fontSize: 13)),
                const SizedBox(height: 12),
                Text(
                  d.medicine,
                  style: const TextStyle(color: wishText, fontSize: 54, fontWeight: FontWeight.w300),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _time,
                  style: const TextStyle(color: wishText, fontSize: 18),
                  decoration: const InputDecoration(
                    labelText: '时间 HH:mm',
                    filled: true,
                    fillColor: wishSurface,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: () async {
                    await WishStore.setMedicine(_time.text.trim());
                    await _load();
                    if (context.mounted)
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('下一次吃药时间已保存。')));
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 50),
                    backgroundColor: wishBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('保存时间'),
                ),
                const SizedBox(height: 12),
                Text('提醒需要通知权限；拒绝后仍会显示在这里。', style: TextStyle(color: wishText3, fontSize: 10.5)),
              ],
            ),
    );
  }
}

class WishTimerPage extends StatefulWidget {
  const WishTimerPage({super.key});
  @override
  State<WishTimerPage> createState() => _WishTimerPageState();
}

class _WishTimerPageState extends State<WishTimerPage> {
  Timer? _ticker;
  int _left = 1500;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    WishStore.load().then((d) {
      if (mounted) setState(() => _left = d.timerSeconds > 0 ? d.timerSeconds : 1500);
    });
  }

  void _toggle() {
    if (_running) {
      _ticker?.cancel();
      setState(() => _running = false);
      WishStore.setTimer(_left);
      return;
    }
    if (_left <= 0) setState(() => _left = 1500);
    setState(() => _running = true);
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_left <= 1) {
        t.cancel();
        setState(() {
          _left = 0;
          _running = false;
        });
        WishStore.setTimer(0);
      } else {
        setState(() => _left--);
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _WishPageScaffold(
      title: '计时器',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
        child: Column(
          children: [
            const Text('专注 25 分钟', style: TextStyle(color: wishText2, fontSize: 13)),
            const Spacer(),
            Text(
              _clock(_left),
              style: const TextStyle(
                color: wishText,
                fontSize: 78,
                fontWeight: FontWeight.w300,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _toggle,
                style: FilledButton.styleFrom(
                  backgroundColor: _running ? wishSurfaceAlt : wishBlue,
                  foregroundColor: Colors.white,
                ),
                child: Text(_running ? '暂停' : (_left == 0 ? '再来一次' : '开始')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WishPageScaffold extends StatelessWidget {
  const _WishPageScaffold({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: wishBg,
      appBar: AppBar(
        backgroundColor: wishBg,
        surfaceTintColor: Colors.transparent,
        foregroundColor: wishText,
        title: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
      ),
      body: child,
    );
  }
}
