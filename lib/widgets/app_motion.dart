import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_store.dart';

Route<T> appRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (_, animation, __) => page,
    transitionsBuilder: (_, animation, __, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: const Cubic(.2, .82, .2, 1),
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(.018, .014),
            end: Offset.zero,
          ).animate(curved),
          child: ScaleTransition(
            scale: Tween<double>(begin: .994, end: 1).animate(curved),
            child: child,
          ),
        ),
      );
    },
  );
}

Future<T?> openAppPage<T>(BuildContext context, Widget page) {
  if (AppStore.instance.haptics) HapticFeedback.selectionClick();
  return Navigator.of(context).push<T>(appRoute<T>(page));
}

class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  void _set(bool value) {
    if (widget.onTap == null || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? .982 : 1,
      duration: const Duration(milliseconds: 125),
      curve: Curves.easeOutCubic,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
          onHighlightChanged: _set,
          onTap: widget.onTap,
          child: widget.child,
        ),
      ),
    );
  }
}

/// A one-time entrance animation with a real start delay.
/// This avoids cards reanimating slowly on every store rebuild.
class PageEntrance extends StatefulWidget {
  final Widget child;
  final int delay;

  const PageEntrance({super.key, required this.child, this.delay = 0});

  @override
  State<PageEntrance> createState() => _PageEntranceState();
}

class _PageEntranceState extends State<PageEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    final curved = CurvedAnimation(
      parent: _controller,
      curve: const Cubic(.2, .82, .2, 1),
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(curved);
    _slide = Tween<Offset>(
      begin: const Offset(0, .028),
      end: Offset.zero,
    ).animate(curved);

    if (widget.delay <= 0) {
      _controller.forward();
    } else {
      Future<void>.delayed(Duration(milliseconds: widget.delay), () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}
