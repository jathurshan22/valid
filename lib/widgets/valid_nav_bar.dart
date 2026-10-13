import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_store.dart';
import '../screens/add_document_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/documents_screen.dart';
import '../screens/settings_screen.dart';
import '../theme/app_theme.dart';

class ValidNavBar extends StatefulWidget {
  /// Existing project mapping:
  /// 0 = Home, 1 = Documents, 2 = Settings
  final int currentIndex;

  const ValidNavBar({super.key, required this.currentIndex});

  @override
  State<ValidNavBar> createState() => _ValidNavBarState();
}

class _ValidNavBarState extends State<ValidNavBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late double _fromSlot;
  late double _toSlot;
  late double _restingSlot;

  int _fromIconSlot = 0;
  int _toIconSlot = 0;
  bool _isNavigating = false;

  // Visual positions:
  // 0 = Home, 1 = Documents, 2 = Add, 3 = Settings
  int _visualSlotForCurrentIndex(int index) {
    switch (index) {
      case 0:
        return 0;
      case 1:
        return 1;
      case 2:
        return 3;
      default:
        return 0;
    }
  }

  @override
  void initState() {
    super.initState();
    final slot = _visualSlotForCurrentIndex(widget.currentIndex);
    _fromSlot = slot.toDouble();
    _toSlot = slot.toDouble();
    _restingSlot = slot.toDouble();
    _fromIconSlot = slot;
    _toIconSlot = slot;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 470),
    );
  }

  @override
  void didUpdateWidget(covariant ValidNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      final slot = _visualSlotForCurrentIndex(widget.currentIndex);
      _fromSlot = slot.toDouble();
      _toSlot = slot.toDouble();
      _restingSlot = slot.toDouble();
      _fromIconSlot = slot;
      _toIconSlot = slot;
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _moveT {
    // Smooth acceleration + soft landing. No harsh snap at either end.
    return const Cubic(0.22, 1.0, 0.36, 1.0).transform(_controller.value);
  }

  double get _animatedSlot {
    return _fromSlot + ((_toSlot - _fromSlot) * _moveT);
  }

  double get _motion => math.sin(math.pi * _controller.value);

  double get _direction {
    final delta = _toSlot - _fromSlot;
    if (delta == 0) return 0;
    return delta.isNegative ? -1 : 1;
  }

  IconData _iconForSlot(int slot) {
    switch (slot) {
      case 0:
        return Icons.home_rounded;
      case 1:
        return Icons.folder_rounded;
      case 2:
        return Icons.add_rounded;
      case 3:
        return Icons.settings_rounded;
      default:
        return Icons.home_rounded;
    }
  }

  String _labelForSlot(int slot) {
    switch (slot) {
      case 0:
        return 'Home';
      case 1:
        return 'Documents';
      case 2:
        return 'Add';
      case 3:
        return 'Settings';
      default:
        return '';
    }
  }

  Future<void> _onTap(int slot) async {
    if (_isNavigating) return;

    final activeSlot = _visualSlotForCurrentIndex(widget.currentIndex);
    if (slot == activeSlot && slot != 2) {
      if (AppStore.instance.haptics) HapticFeedback.selectionClick();
      return;
    }

    _isNavigating = true;
    if (AppStore.instance.haptics) HapticFeedback.lightImpact();

    setState(() {
      _fromSlot = _restingSlot;
      _toSlot = slot.toDouble();
      _fromIconSlot = _restingSlot.round();
      _toIconSlot = slot;
    });

    await _controller.forward(from: 0);
    if (!mounted) return;

    _restingSlot = slot.toDouble();
    if (AppStore.instance.haptics) HapticFeedback.selectionClick();

    if (slot == 2) {
      await Navigator.of(context).push(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 340),
          reverseTransitionDuration: const Duration(milliseconds: 280),
          pageBuilder: (_, animation, __) => const AddDocumentScreen(),
          transitionsBuilder: (_, animation, __, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: const Cubic(0.22, 1, 0.36, 1),
              reverseCurve: Curves.easeInCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: ScaleTransition(
                scale: Tween<double>(begin: .975, end: 1).animate(curved),
                child: child,
              ),
            );
          },
        ),
      );

      if (!mounted) return;

      final backSlot = _visualSlotForCurrentIndex(widget.currentIndex);
      setState(() {
        _fromSlot = 2;
        _toSlot = backSlot.toDouble();
        _fromIconSlot = 2;
        _toIconSlot = backSlot;
      });

      await _controller.forward(from: 0);
      _restingSlot = backSlot.toDouble();
      _isNavigating = false;
      return;
    }

    Widget page;
    switch (slot) {
      case 0:
        page = const DashboardScreen();
        break;
      case 1:
        page = const DocumentsScreen();
        break;
      case 3:
        page = const SettingsScreen();
        break;
      default:
        page = const DashboardScreen();
    }

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, animation, __) => page,
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(opacity: curved, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
        child: SizedBox(
          height: 82,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final slotWidth = width / 4;
                  final bubbleX = slotWidth * (_animatedSlot + .5);

                  final lift = _motion * 10;
                  final bubbleScale = 1 + (_motion * .055);
                  final bubbleTilt = _direction * _motion * .035;

                  // Cross-fade the icon during the middle of the travel instead
                  // of instantly changing it on tap.
                  final iconT = (((_controller.value - .30) / .34)
                          .clamp(0.0, 1.0))
                      .toDouble();
                  final iconSwap = Curves.easeInOutCubic.transform(iconT);

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Keep only the rounded white navbar pill.
                      // The area behind/outside this pill stays transparent
                      // because the parent screens use Scaffold(extendBody: true).
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 22,
                        height: 58,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.surface.withOpacity(.96),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Colors.white.withOpacity(.72),
                              width: 1,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x14152E27),
                                blurRadius: 18,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Positioned(
                        left: 0,
                        right: 0,
                        top: 24,
                        height: 52,
                        child: Row(
                          children: List.generate(4, (index) {
                            final distance = (_animatedSlot - index).abs();

                            // Icons softly fade/scale as the bubble reaches them.
                            final visibility = (((distance - .10) / .48)
                                    .clamp(0.0, 1.0))
                                .toDouble();
                            final scale = .82 + (.18 * visibility);

                            return Expanded(
                              child: Semantics(
                                button: true,
                                label: _labelForSlot(index),
                                child: Tooltip(
                                  message: _labelForSlot(index),
                                  child: InkResponse(
                                    radius: 26,
                                    highlightShape: BoxShape.circle,
                                    splashColor:
                                        AppColors.primary.withOpacity(.06),
                                    onTap: () => _onTap(index),
                                    child: Center(
                                      child: Opacity(
                                        opacity: visibility,
                                        child: Transform.scale(
                                          scale: scale,
                                          child: Icon(
                                            _iconForSlot(index),
                                            size: index == 2 ? 27 : 25,
                                            color: const Color(0xFF20352F),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      // Floating active bubble.
                      Positioned(
                        left: bubbleX - 30,
                        top: 2 - lift,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _onTap(_toIconSlot),
                          child: Transform.rotate(
                            angle: bubbleTilt,
                            child: Transform.scale(
                              scale: bubbleScale,
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF1BA786),
                                      AppColors.primary,
                                      AppColors.primaryDark,
                                    ],
                                  ),
                                  border: Border.all(
                                    color: const Color(0xFFC9F8E8),
                                    width: 2.1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(
                                        .24 + (.08 * _motion),
                                      ),
                                      blurRadius: 24 + (8 * _motion),
                                      spreadRadius: 1 + (1.5 * _motion),
                                      offset: Offset(0, 8 + (2 * _motion)),
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFF56E4B8)
                                          .withOpacity(.18 + (.14 * _motion)),
                                      blurRadius: 14 + (8 * _motion),
                                      spreadRadius: .5,
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Soft inner highlight gives the bubble more
                                    // depth without looking overly glossy.
                                    Positioned(
                                      left: 10,
                                      right: 10,
                                      top: 6,
                                      height: 15,
                                      child: IgnorePointer(
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.white.withOpacity(.20),
                                                Colors.white.withOpacity(0),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Opacity(
                                      opacity: 1 - iconSwap,
                                      child: Transform.scale(
                                        scale: 1 - (.16 * iconSwap),
                                        child: Icon(
                                          _iconForSlot(_fromIconSlot),
                                          color: Colors.white,
                                          size: _fromIconSlot == 2 ? 31 : 27,
                                        ),
                                      ),
                                    ),
                                    Opacity(
                                      opacity: iconSwap,
                                      child: Transform.scale(
                                        scale: .84 + (.16 * iconSwap),
                                        child: Icon(
                                          _iconForSlot(_toIconSlot),
                                          color: Colors.white,
                                          size: _toIconSlot == 2 ? 31 : 27,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
