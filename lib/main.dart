import 'package:flutter/material.dart';
import 'data/app_store.dart';
import 'screens/splash_screen.dart';
import 'services/firebase_bootstrap.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final firebaseReady = await FirebaseBootstrap.initialize();
  await NotificationService.initialize();

  runApp(ValidApp(firebaseReady: firebaseReady));
}

class ValidApp extends StatelessWidget {
  final bool firebaseReady;
  const ValidApp({super.key, required this.firebaseReady});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppStore.instance,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Valid',
          theme: AppTheme.light(),
          home: SplashScreen(firebaseReady: firebaseReady),
        );
      },
    );
  }
}
