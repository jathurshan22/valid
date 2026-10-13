import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../data/app_store.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_mark.dart';
import 'dashboard_screen.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String _message(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Incorrect email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'No internet connection. Check your network.';
      default:
        return e.message ?? 'Could not sign in. Please try again.';
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate() || _loading) return;
    setState(() => _loading = true);
    try {
      await AuthService.login(email: _email.text, password: _password.text);
      await AppStore.instance.initializeForCurrentUser();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_message(e))));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load your account. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 86,
                        height: 86,
                        padding: const EdgeInsets.all(17),
                        decoration: BoxDecoration(
                          color: AppColors.mintSoft,
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: const BrandMark(size: 52, dark: true),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Welcome back',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -.7),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sign in to manage your documents and expiry reminders.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.muted, fontSize: 13, height: 1.5),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                        prefixIcon: Icon(Icons.mail_outline_rounded),
                      ),
                      validator: (value) {
                        final v = value?.trim() ?? '';
                        if (v.isEmpty) return 'Enter your email address';
                        if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email address';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _password,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _login(),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        ),
                      ),
                      validator: (value) => (value == null || value.isEmpty) ? 'Enter your password' : null,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                        ),
                        child: const Text('Forgot password?'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: _loading ? null : _login,
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                            )
                          : const Text('Sign in'),
                    ),
                    const SizedBox(height: 18),
                    OutlinedButton(
                      onPressed: _loading
                          ? null
                          : () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const RegisterScreen()),
                              ),
                      child: const Text('Create an account'),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Your document records are separated by your Firebase account.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.muted, fontSize: 10.5, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
