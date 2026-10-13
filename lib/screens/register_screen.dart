import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../data/app_store.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String _message(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Use a stronger password with at least 6 characters.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'network-request-failed':
        return 'No internet connection. Check your network.';
      default:
        return e.message ?? 'Could not create your account.';
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate() || _loading) return;
    setState(() => _loading = true);
    try {
      await AuthService.register(
        name: _name.text,
        email: _email.text,
        password: _password.text,
      );
      await AppStore.instance.initializeForCurrentUser(registrationName: _name.text.trim());
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
        const SnackBar(content: Text('Account created, but profile setup failed. Try signing in again.')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        top: false,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 30),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Create your account', style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900, letterSpacing: -.7)),
                    const SizedBox(height: 8),
                    const Text(
                      'Your documents will sync securely to your own account.',
                      style: TextStyle(color: AppColors.muted, fontSize: 13, height: 1.5),
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _name,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person_outline_rounded)),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: 'Email address', prefixIcon: Icon(Icons.mail_outline_rounded)),
                      validator: (v) {
                        final value = v?.trim() ?? '';
                        if (value.isEmpty) return 'Enter your email address';
                        if (!value.contains('@') || !value.contains('.')) return 'Enter a valid email address';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _password,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter a password';
                        if (v.length < 6) return 'Use at least 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _confirm,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _register(),
                      decoration: const InputDecoration(labelText: 'Confirm password', prefixIcon: Icon(Icons.lock_reset_outlined)),
                      validator: (v) => v != _password.text ? 'Passwords do not match' : null,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _loading ? null : _register,
                      child: _loading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                          : const Text('Create account'),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: _loading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Already have an account? Sign in'),
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
