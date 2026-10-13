import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final email = _email.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid email address.')));
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthService.resetPassword(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset email sent. Check your inbox.')));
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Could not send the reset email.')));
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: AppColors.mintSoft, borderRadius: BorderRadius.circular(20)),
                    child: const Icon(Icons.lock_reset_rounded, color: AppColors.primary, size: 30),
                  ),
                  const SizedBox(height: 24),
                  const Text('Reset your password', style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900, letterSpacing: -.7)),
                  const SizedBox(height: 9),
                  const Text(
                    'Enter your account email. Firebase will send a secure password reset link.',
                    style: TextStyle(color: AppColors.muted, fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 26),
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email address', prefixIcon: Icon(Icons.mail_outline_rounded)),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _loading ? null : _send,
                    child: _loading
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                        : const Text('Send reset link'),
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
