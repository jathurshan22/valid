import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_mark.dart';

class FirebaseSetupScreen extends StatelessWidget {
  const FirebaseSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                children: [
                  Container(
                    width: 92,
                    height: 92,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.mintSoft,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const BrandMark(size: 56, dark: true),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'One Firebase setup step remains',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'This project contains all app code, but Firebase requires the configuration generated for your own Firebase account. Run the command below once from the project folder, then restart the app.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 12.5,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: const SelectableText(
                      '"%LOCALAPPDATA%\\Pub\\Cache\\bin\\flutterfire.bat" configure --project=valid-document-reminder-2026',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Select Android (and any other platforms you want). FlutterFire will replace lib/firebase_options.dart with the real configuration.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
