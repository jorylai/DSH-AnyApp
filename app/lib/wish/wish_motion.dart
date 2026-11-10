import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ui/theme/page_transitions.dart';

/// AnyApp's shared motion: touch responds first; content follows; the surface settles.
/// Movement never delays an action or represents progress that has not happened.
abstract final class WishMotion {
  static const press = Duration(milliseconds: 90);
  static const release = Duration(milliseconds: 220);
  static const quick = Duration(milliseconds: 160);
  static const content = Duration(milliseconds: 260);
  static const route = Duration(milliseconds: 340);
  static const enter = Cubic(.16, 1, .3, 1);
  static const settle = Cubic(.22, .8, .25, 1);
  static const exit = Cubic(.4, 0, 1, 1);

  static bool reduced(BuildContext context) => MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  static Duration duration(BuildContext context, Duration value) => reduced(context) ? Duration.zero : value;
}

/// Adds tactile feedback around an existing button, InkWell or action.
/// It owns no tap handler, semantics or haptics, so nested controls stay independent.
class WishPressable extends StatefulWidget {
  const WishPressable({super.key, required this.child, this.enabled = true, this.scale = .985});
  final Widget child;
  final bool enabled;
  final double scale;
  @override
  State<WishPressable> createState() => _WishPressableState();
}

class _WishPressableState extends State<WishPressable> with WidgetsBindingObserver {
  final _pointers = <int, Offset>{};
  bool _keyboardDown = false;
  bool _resumed = true;

  @override
  void initState() {
    super.initState();
    final binding = WidgetsBinding.instance;
    _resumed = binding.lifecycleState == null || binding.lifecycleState == AppLifecycleState.resumed;
    binding.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final resumed = state == AppLifecycleState.resumed;
    if (!mounted || _resumed == resumed) return;
    setState(() {
      _resumed = resumed;
      if (!_resumed) {
        _pointers.clear();
        _keyboardDown = false;
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _release(int pointer) {
    if (_pointers.remove(pointer) != null && mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.enabled && _resumed && !WishMotion.reduced(context) && TickerMode.valuesOf(context).enabled;
    final pressed = active && (_pointers.isNotEmpty || _keyboardDown);
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: (_, event) {
        if (event.logicalKey == LogicalKeyboardKey.space || event.logicalKey == LogicalKeyboardKey.enter) {
          final down = event is! KeyUpEvent;
          if (_keyboardDown != down) setState(() => _keyboardDown = down);
        }
        return KeyEventResult.ignored;
      },
      onFocusChange: (focused) {
        if (!focused && _keyboardDown) setState(() => _keyboardDown = false);
      },
      child: Listener(
        behavior: HitTestBehavior.deferToChild,
        onPointerDown: widget.enabled
            ? (event) {
                if (event.buttons == 1) setState(() => _pointers[event.pointer] = event.position);
              }
            : null,
        onPointerMove: (event) {
          final start = _pointers[event.pointer];
          if (start != null && (event.position - start).distance > 18) _release(event.pointer);
        },
        onPointerUp: (event) => _release(event.pointer),
        onPointerCancel: (event) => _release(event.pointer),
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: pressed ? 1 : 0),
          duration: active ? (pressed ? WishMotion.press : WishMotion.release) : Duration.zero,
          curve: pressed ? Curves.easeOutCubic : WishMotion.settle,
          child: widget.child,
          builder: (_, amount, child) => Transform.scale(scale: 1 - (1 - widget.scale) * amount, child: child),
        ),
      ),
    );
  }
}

/// A single, small arrival. At rest there is no ticker, and hidden pages do not run it.
/// Use [order] only for the first few visible items, never for a whole long list.
class WishEntrance extends StatefulWidget {
  const WishEntrance({super.key, required this.child, this.order = 0, this.enabled = true});
  final Widget child;
  final int order;
  final bool enabled;
  @override
  State<WishEntrance> createState() => _WishEntranceState();
}

class _WishEntranceState extends State<WishEntrance> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _controller;
  bool _resumed = true;
  bool _reduced = true;
  bool _visible = true;
  bool _inputActive = false;

  @override
  void initState() {
    super.initState();
    final binding = WidgetsBinding.instance;
    _resumed = binding.lifecycleState == null || binding.lifecycleState == AppLifecycleState.resumed;
    binding.addObserver(this);
    _controller = AnimationController(vsync: this, duration: WishMotion.route);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = WishMotion.reduced(context);
    _visible = TickerMode.valuesOf(context).enabled;
    _inputActive = _keyboardVisible;
    _sync();
  }

  // Scaffold removes the keyboard inset from its resized body's MediaQuery.
  // Read the window too so content inside that body settles before typing.
  bool get _keyboardVisible =>
      (MediaQuery.maybeViewInsetsOf(context)?.bottom ?? 0) > 0 || (View.maybeOf(context)?.viewInsets.bottom ?? 0) > 0;

  @override
  void didChangeMetrics() {
    _inputActive = _keyboardVisible;
    _sync();
  }

  @override
  void didUpdateWidget(WishEntrance oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _resumed = state == AppLifecycleState.resumed;
    _sync();
  }

  void _sync() {
    if (_reduced || _inputActive || !widget.enabled) {
      _controller.value = 1;
    } else if (!_visible || !_resumed) {
      _controller.stop();
    } else if (!_controller.isCompleted && !_controller.isAnimating) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final delay = widget.order.clamp(0, 5) * .055;
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (_, child) {
        final progress = ((_controller.value - delay) / (1 - delay)).clamp(0.0, 1.0);
        final value = WishMotion.enter.transform(progress);
        return Opacity(
          opacity: value,
          child: Transform.translate(offset: Offset(0, 10 * (1 - value)), child: child),
        );
      },
    );
  }
}

/// Key the child by its actual state. The outgoing state cannot accept taps or
/// duplicate screen-reader announcements. Input fields should keep their identity.
class WishContentTransition extends StatelessWidget {
  const WishContentTransition({super.key, required this.child, this.alignment = Alignment.center});
  final Widget child;
  final AlignmentGeometry alignment;
  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: WishMotion.duration(context, WishMotion.content),
    reverseDuration: WishMotion.duration(context, WishMotion.quick),
    switchInCurve: WishMotion.enter,
    switchOutCurve: WishMotion.exit,
    layoutBuilder: (current, previous) => Stack(
      alignment: alignment,
      children: [
        for (final old in previous) ExcludeSemantics(child: IgnorePointer(child: old)),
        ?current,
      ],
    ),
    transitionBuilder: (child, animation) => FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, .06), end: Offset.zero).animate(animation),
        child: child,
      ),
    ),
    child: child,
  );
}

/// Keeps the existing predictive-back and edge gesture implementation while using
/// AnyApp's restrained duration. System removal of animations remains immediate.
class WishPageTransitionsBuilder extends AppPageTransitionsBuilder {
  const WishPageTransitionsBuilder({this.instant = false});
  final bool instant;
  @override
  Duration get transitionDuration => instant ? Duration.zero : WishMotion.route;
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => instant || WishMotion.reduced(context)
      ? child
      : super.buildTransitions(route, context, animation, secondaryAnimation, child);
}
