import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

class FirebaseBootstrap {
  FirebaseBootstrap._();

  static Future<bool> initialize() async {
    try {
      final options = DefaultFirebaseOptions.currentPlatform;
      if (options.apiKey.startsWith('REPLACE_WITH_')) return false;
      await Firebase.initializeApp(options: options);
      return true;
    } catch (_) {
      return false;
    }
  }
}
