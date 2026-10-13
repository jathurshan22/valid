import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valid_app/screens/firebase_setup_screen.dart';

void main() {
  testWidgets('Firebase setup fallback screen renders', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: FirebaseSetupScreen(),
      ),
    );

    expect(find.text('One Firebase setup step remains'), findsOneWidget);
    expect(find.textContaining('flutterfire.bat'), findsOneWidget);
  });
}
