import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<UserCredential> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await credential.user?.updateDisplayName(name.trim());
    return credential;
  }

  static Future<UserCredential> login({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  static Future<void> resetPassword(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  static Future<void> updateDisplayName(String name) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('No signed-in user.');
    await user.updateDisplayName(name.trim());
    await user.reload();
  }

  static Future<void> requestEmailChange(String newEmail) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('No signed-in user.');
    if ((user.email ?? '').toLowerCase() == newEmail.trim().toLowerCase()) return;
    await user.verifyBeforeUpdateEmail(newEmail.trim());
  }

  static Future<void> logout() => _auth.signOut();
}
