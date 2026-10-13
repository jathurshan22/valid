import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../data/app_store.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: AppStore.instance.profileName);
    _email = TextEditingController(text: AppStore.instance.profileEmail);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    setState(() => _saving = true);
    try {
      final newName = _name.text.trim();
      final newEmail = _email.text.trim();
      final currentEmail = AuthService.currentUser?.email ?? AppStore.instance.profileEmail;

      await AuthService.updateDisplayName(newName);
      if (newEmail.toLowerCase() != currentEmail.toLowerCase()) {
        await AuthService.requestEmailChange(newEmail);
        await AppStore.instance.updateProfile(name: newName, email: currentEmail);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification sent to $newEmail. Your sign-in email changes after you confirm it.')),
        );
      } else {
        await AppStore.instance.updateProfile(name: newName, email: currentEmail);
      }

      if (mounted) Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final message = e.code == 'requires-recent-login'
          ? 'For security, sign out and sign in again before changing your email.'
          : (e.message ?? 'Could not update your account.');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save the profile. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: IconButton.filledTonal(
            style: IconButton.styleFrom(backgroundColor: AppColors.surface),
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        title: const Text('Edit profile', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
            children: [
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(color: AppColors.mintSoft, borderRadius: BorderRadius.circular(28)),
                  child: const Icon(Icons.person_outline_rounded, color: AppColors.primary, size: 40),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _name,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person_outline_rounded)),
                validator: (value) => value == null || value.trim().isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Sign-in email', prefixIcon: Icon(Icons.email_outlined)),
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return 'Enter your email';
                  if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              const Text(
                'Changing your sign-in email sends a verification link to the new address.',
                style: TextStyle(color: AppColors.muted, fontSize: 10.5, height: 1.4),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 54,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                  ),
                  icon: _saving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.check_rounded),
                  label: Text(_saving ? 'Saving...' : 'Save changes', style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
