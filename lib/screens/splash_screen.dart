import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_mark.dart';
import '../data/app_store.dart';
import '../services/auth_service.dart';
import 'dashboard_screen.dart';
import 'firebase_setup_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  final bool firebaseReady;
  const SplashScreen({super.key, required this.firebaseReady});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _float;
  late final Animation<double> _markScale;
  late final Animation<double> _markOpacity;
  late final Animation<Offset> _copySlide;
  late final Animation<double> _copyOpacity;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _float = AnimationController(vsync: this, duration: const Duration(milliseconds: 1900))..repeat(reverse: true);

    _markScale = Tween(begin: .78, end: 1.0).animate(
      CurvedAnimation(parent: _intro, curve: const Interval(0, .62, curve: Curves.easeOutBack)),
    );
    _markOpacity = CurvedAnimation(parent: _intro, curve: const Interval(0, .32, curve: Curves.easeIn));
    _copySlide = Tween(begin: const Offset(0, .32), end: Offset.zero).animate(
      CurvedAnimation(parent: _intro, curve: const Interval(.35, .95, curve: Curves.easeOutCubic)),
    );
    _copyOpacity = CurvedAnimation(parent: _intro, curve: const Interval(.35, .86, curve: Curves.easeIn));

    _intro.forward();
    _timer = Timer(const Duration(milliseconds: 2450), _openHome);
  }

  Future<void> _openHome() async {
    if (!mounted) return;

    Widget nextScreen;
    if (!widget.firebaseReady) {
      nextScreen = const FirebaseSetupScreen();
    } else if (AuthService.currentUser == null) {
      nextScreen = const LoginScreen();
    } else {
      await AppStore.instance.initializeForCurrentUser();
      nextScreen = const DashboardScreen();
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 520),
        pageBuilder: (_, animation, __) => nextScreen,
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween(begin: const Offset(0, .025), end: Offset.zero).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _intro.dispose();
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Stack(
        children: [
          const Positioned.fill(child: _SplashBackground()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  AnimatedBuilder(
                    animation: _float,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(0, -3 + (_float.value * 6)),
                      child: child,
                    ),
                    child: FadeTransition(
                      opacity: _markOpacity,
                      child: ScaleTransition(
                        scale: _markScale,
                        child: Container(
                          width: 132,
                          height: 132,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F7F2),
                            borderRadius: BorderRadius.circular(38),
                            border: Border.all(color: Colors.white.withOpacity(.14)),
                            boxShadow: const [
                              BoxShadow(color: Color(0x33000000), blurRadius: 28, offset: Offset(0, 16)),
                            ],
                          ),
                          child: const BrandMark(size: 84, dark: true),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  FadeTransition(
                    opacity: _copyOpacity,
                    child: SlideTransition(
                      position: _copySlide,
                      child: Column(
                        children: [
                          const Text(
                            'Valid',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 42,
                              letterSpacing: -1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Keep the dates that matter close.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(.74),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              letterSpacing: .1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(flex: 4),
                  FadeTransition(
                    opacity: _copyOpacity,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 28),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(width: 24, height: 2, color: Colors.white.withOpacity(.30)),
                          const SizedBox(width: 8),
                          Text(
                            'DOCUMENT EXPIRY REMINDER',
                            style: TextStyle(
                              color: Colors.white.withOpacity(.55),
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(width: 24, height: 2, color: Colors.white.withOpacity(.30)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashBackground extends StatelessWidget {
  const _SplashBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryDark, const Color(0xFF082F2A), const Color(0xFF041F1C)],
              ),
            ),
          ),
        ),
        Positioned(
          top: -90,
          right: -80,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(.05), width: 34),
            ),
          ),
        ),
        Positioned(
          bottom: -120,
          left: -95,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.mint.withOpacity(.05), width: 42),
            ),
          ),
        ),
      ],
    );
  }
}
