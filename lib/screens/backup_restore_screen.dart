import 'package:flutter/material.dart';
import '../data/app_store.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  bool _syncing = false;
  bool _rescheduling = false;

  String _lastSync() {
    final value = AppStore.instance.lastBackupAt;
    if (value == null) return 'Not synced in this session yet';
    final h = value.hour.toString().padLeft(2, '0');
    final m = value.minute.toString().padLeft(2, '0');
    return 'Last cloud sync at $h:$m';
  }

  Future<void> _refresh() async {
    if (_syncing) return;
    setState(() => _syncing = true);
    await AppStore.instance.refreshFromCloud();
    if (!mounted) return;
    setState(() => _syncing = false);
    final error = AppStore.instance.syncError;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error == null ? 'Cloud data refreshed.' : 'Sync failed. Check your internet connection.')),
    );
  }

  Future<void> _reschedule() async {
    if (_rescheduling) return;
    setState(() => _rescheduling = true);
    try {
      await NotificationService.requestPermission();
      await NotificationService.scheduleAll(AppStore.instance.documents);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expiry reminders rescheduled.')),
      );
    } finally {
      if (mounted) setState(() => _rescheduling = false);
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
        title: const Text('Cloud sync', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
      ),
      body: AnimatedBuilder(
        animation: AppStore.instance,
        builder: (context, _) => SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.mintSoft, borderRadius: BorderRadius.circular(28), border: Border.all(color: AppColors.mint)),
                child: Column(children: [
                  const Icon(Icons.cloud_done_outlined, color: AppColors.primary, size: 42),
                  const SizedBox(height: 12),
                  const Text('Firebase cloud sync is active', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 5),
                  Text(_lastSync(), textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted, fontSize: 11.5)),
                  const SizedBox(height: 5),
                  Text('${AppStore.instance.documents.length} document(s) in this account', style: const TextStyle(color: AppColors.muted, fontSize: 10.5)),
                ]),
              ),
              const SizedBox(height: 18),
              _ActionCard(
                icon: Icons.sync_rounded,
                title: 'Refresh from cloud',
                subtitle: 'Reload your profile, settings and documents from Firestore.',
                button: _syncing ? 'Refreshing...' : 'Refresh now',
                enabled: !_syncing,
                onTap: _refresh,
              ),
              const SizedBox(height: 12),
              _ActionCard(
                icon: Icons.notifications_active_outlined,
                title: 'Reschedule reminders',
                subtitle: 'Recreate local expiry notifications for all saved documents.',
                button: _rescheduling ? 'Scheduling...' : 'Reschedule',
                enabled: !_rescheduling,
                onTap: _reschedule,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String button;
  final bool enabled;
  final VoidCallback onTap;
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.button,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.line)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.mintSoft, borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: AppColors.primary)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
            const SizedBox(height: 3),
            Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 10.5, height: 1.35)),
          ])),
        ]),
        const SizedBox(height: 14),
        SizedBox(width: double.infinity, child: OutlinedButton(onPressed: enabled ? onTap : null, child: Text(button))),
      ]),
    );
  }
}
