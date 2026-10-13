import 'package:flutter/material.dart';
import '../data/app_store.dart';
import '../theme/app_theme.dart';
import '../services/notification_service.dart';
import '../widgets/app_motion.dart';
import '../widgets/brand_mark.dart';
import '../widgets/valid_nav_bar.dart';
import 'appearance_screen.dart';
import 'backup_restore_screen.dart';
import 'default_reminder_screen.dart';
import 'help_support_screen.dart';
import 'privacy_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: AppStore.instance,
          builder: (context, _) {
            final store = AppStore.instance;
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 112),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const PageEntrance(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Settings', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -.6)),
                    SizedBox(height: 4),
                    Text('Keep Valid comfortable and useful for you.', style: TextStyle(color: AppColors.muted, fontSize: 12.5, fontWeight: FontWeight.w500)),
                  ]),
                ),
                const SizedBox(height: 20),
                const PageEntrance(delay: 45, child: _AppCard()),
                const SizedBox(height: 18),
                PageEntrance(
                  delay: 90,
                  child: _SettingsCard(
                    title: 'Reminders',
                    children: [
                      _ToggleRow(
                        icon: Icons.notifications_outlined,
                        title: 'Expiry notifications',
                        subtitle: 'Get notified before a document expires',
                        value: store.expiryNotifications,
                        onChanged: store.setNotifications,
                      ),
                      _ChoiceRow(
                        icon: Icons.schedule_outlined,
                        title: 'Default reminder',
                        value: store.defaultReminder,
                        onTap: () => openAppPage(context, const DefaultReminderScreen()),
                      ),
                      _LinkRow(
                        icon: Icons.notifications_active_outlined,
                        title: 'Test notification',
                        subtitle: 'Send a notification now to verify permissions',
                        onTap: () async {
                          final granted = await NotificationService.requestPermission();
                          if (granted) await NotificationService.showTestNotification();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(granted ? 'Test notification sent.' : 'Notification permission is disabled.')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                PageEntrance(
                  delay: 130,
                  child: _SettingsCard(
                    title: 'Experience',
                    children: [
                      _ToggleRow(
                        icon: Icons.touch_app_outlined,
                        title: 'Haptic feedback',
                        subtitle: 'Gentle feedback on important actions',
                        value: store.haptics,
                        onChanged: store.setHaptics,
                      ),
                      _ChoiceRow(
                        icon: Icons.brightness_6_outlined,
                        title: 'Appearance',
                        value: store.appearance,
                        onTap: () => openAppPage(context, const AppearanceScreen()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                PageEntrance(
                  delay: 170,
                  child: _SettingsCard(
                    title: 'Data & support',
                    children: [
                      _LinkRow(
                        icon: Icons.cloud_outlined,
                        title: 'Cloud sync',
                        subtitle: 'Refresh your Firebase cloud data and reminders',
                        onTap: () => openAppPage(context, const BackupRestoreScreen()),
                      ),
                      _LinkRow(
                        icon: Icons.lock_outline_rounded,
                        title: 'Privacy',
                        subtitle: 'How your document data is handled',
                        onTap: () => openAppPage(context, const PrivacyScreen()),
                      ),
                      _LinkRow(
                        icon: Icons.help_outline_rounded,
                        title: 'Help & support',
                        subtitle: 'Common questions and contact',
                        onTap: () => openAppPage(context, const HelpSupportScreen()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Center(child: Text('Valid  •  Cloud build 2.0', style: TextStyle(color: AppColors.muted.withOpacity(.75), fontSize: 10.5, fontWeight: FontWeight.w600))),
              ]),
            );
          },
        ),
      ),
      bottomNavigationBar: const ValidNavBar(currentIndex: 2),
    );
  }
}

class _AppCard extends StatelessWidget {
  const _AppCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(color: AppColors.primaryDark, borderRadius: BorderRadius.circular(28)),
      child: Row(children: [
        Container(width: 62, height: 62, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF7F7F2), borderRadius: BorderRadius.circular(20)), child: const BrandMark(size: 38, dark: true)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Valid', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          Text('Document expiry reminder', style: TextStyle(color: Colors.white.withOpacity(.68), fontSize: 11.5, fontWeight: FontWeight.w500)),
          const SizedBox(height: 7),
          Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: Colors.white.withOpacity(.10), borderRadius: BorderRadius.circular(999)), child: Text('Version 2.0', style: TextStyle(color: Colors.white.withOpacity(.82), fontSize: 9.5, fontWeight: FontWeight.w700))),
        ])),
        Icon(Icons.shield_outlined, color: Colors.white.withOpacity(.70), size: 26),
      ]),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsCard({required this.title, required this.children});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.line)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 15, 16, 8), child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900))),
        ...children,
      ]),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleRow({required this.icon, required this.title, required this.subtitle, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => _BaseRow(
    icon: icon,
    title: title,
    subtitle: subtitle,
    trailing: Switch(value: value, activeColor: AppColors.primary, onChanged: onChanged),
  );
}

class _ChoiceRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;
  const _ChoiceRow({required this.icon, required this.title, required this.value, required this.onTap});
  @override
  Widget build(BuildContext context) => _BaseRow(icon: icon, title: title, subtitle: value, onTap: onTap, trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF9AA7A2), size: 20));
}

class _LinkRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _LinkRow({required this.icon, required this.title, required this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) => _BaseRow(icon: icon, title: title, subtitle: subtitle, onTap: onTap, trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF9AA7A2), size: 20));
}

class _BaseRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;
  const _BaseRow({required this.icon, required this.title, required this.subtitle, required this.trailing, this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(15, 13, 12, 13),
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.line))),
        child: Row(children: [
          Container(width: 38, height: 38, decoration: BoxDecoration(color: AppColors.mintSoft, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppColors.primary, size: 19)),
          const SizedBox(width: 11),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
            const SizedBox(height: 3),
            Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 10.5, height: 1.3, fontWeight: FontWeight.w500)),
          ])),
          const SizedBox(width: 8),
          trailing,
        ]),
      ),
    );
  }
}
