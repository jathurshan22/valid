import 'package:flutter/material.dart';
import '../data/app_store.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../widgets/app_motion.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You can sign in again anytime to restore your cloud documents.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sign out')),
        ],
      ),
    );
    if (confirmed != true) return;

    await NotificationService.cancelAll();
    await AuthService.logout();
    AppStore.instance.clearForLogout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
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
        title: const Text('Profile', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context).pushReplacement(appRoute(const SettingsScreen())),
            icon: const Icon(Icons.settings_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedBuilder(
        animation: AppStore.instance,
        builder: (context, _) {
          final store = AppStore.instance;
          return SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
              children: [
                PageEntrance(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF0A584B), Color(0xFF0F7964)],
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.12),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: Colors.white.withOpacity(.18)),
                          ),
                          child: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 34),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(store.profileName, style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 4),
                              Text(store.profileEmail, style: TextStyle(color: Colors.white.withOpacity(.72), fontSize: 11.5)),
                              const SizedBox(height: 10),
                              OutlinedButton.icon(
                                onPressed: () => openAppPage(context, const EditProfileScreen()),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: BorderSide(color: Colors.white.withOpacity(.28)),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  visualDensity: VisualDensity.compact,
                                ),
                                icon: const Icon(Icons.edit_outlined, size: 16),
                                label: const Text('Edit profile', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                PageEntrance(
                  delay: 60,
                  child: Row(
                    children: [
                      _Metric(value: '${store.documents.length}', label: 'Documents', icon: Icons.folder_outlined),
                      const SizedBox(width: 10),
                      _Metric(value: '${store.expiringCount}', label: 'Expiring', icon: Icons.schedule_outlined),
                      const SizedBox(width: 10),
                      _Metric(value: '${store.validCount}', label: 'Valid', icon: Icons.verified_outlined),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                const Text('Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                PageEntrance(
                  delay: 100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Column(
                      children: [
                        _ProfileRow(icon: Icons.person_outline_rounded, title: 'Name', value: store.profileName),
                        _ProfileRow(icon: Icons.email_outlined, title: 'Email', value: store.profileEmail),
                        _ProfileRow(icon: Icons.notifications_outlined, title: 'Notifications', value: store.expiryNotifications ? 'Enabled' : 'Disabled', last: true),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: () => openAppPage(context, const EditProfileScreen()),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                    ),
                    icon: const Icon(Icons.manage_accounts_outlined),
                    label: const Text('Manage profile', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 54,
                  child: OutlinedButton.icon(
                    onPressed: () => _logout(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: BorderSide(color: AppColors.danger.withOpacity(.25)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                    ),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Sign out', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  const _Metric({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(height: 7),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 3),
            Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 9.5, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool last;
  const _ProfileRow({required this.icon, required this.title, required this.value, this.last = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(border: last ? null : const Border(bottom: BorderSide(color: AppColors.line))),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: AppColors.mintSoft, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.primary, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
          Flexible(child: Text(value, textAlign: TextAlign.end, style: const TextStyle(color: AppColors.muted, fontSize: 11))),
        ],
      ),
    );
  }
}
