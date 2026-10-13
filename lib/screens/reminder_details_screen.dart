import 'package:flutter/material.dart';
import '../data/app_store.dart';
import '../models/document_item.dart';
import '../theme/app_theme.dart';
import '../widgets/app_motion.dart';
import 'document_details_screen.dart';
import 'reminder_settings_screen.dart';

class ReminderDetailsScreen extends StatelessWidget {
  final String documentId;
  const ReminderDetailsScreen({super.key, required this.documentId});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppStore.instance,
      builder: (context, _) {
        final document = AppStore.instance.byId(documentId);
        if (document == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Reminder')),
            body: const Center(child: Text('This document is no longer available.')),
          );
        }
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
            title: const Text('Reminder', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
          ),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
              children: [
                PageEntrance(child: _ReminderHero(document: document)),
                const SizedBox(height: 18),
                const Text('Reminder plan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                PageEntrance(
                  delay: 60,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Column(
                      children: [
                        _TimelineRow(
                          icon: Icons.notifications_active_outlined,
                          title: 'Reminder starts',
                          value: document.reminder,
                          active: true,
                        ),
                        const SizedBox(height: 14),
                        _TimelineRow(
                          icon: Icons.event_outlined,
                          title: 'Expiry date',
                          value: document.expiry,
                        ),
                        const SizedBox(height: 14),
                        _TimelineRow(
                          icon: document.status == 'Expired' ? Icons.error_outline_rounded : Icons.verified_outlined,
                          title: 'Current status',
                          value: document.status,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => openAppPage(context, ReminderSettingsScreen(documentId: document.id)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          minimumSize: const Size.fromHeight(54),
                          side: const BorderSide(color: AppColors.mint),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                        ),
                        icon: const Icon(Icons.tune_rounded, size: 18),
                        label: const Text('Change reminder', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => openAppPage(context, DocumentDetailsScreen(document: document)),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          minimumSize: const Size.fromHeight(54),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                        ),
                        icon: const Icon(Icons.description_outlined, size: 18),
                        label: const Text('Open document', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ReminderHero extends StatelessWidget {
  final DocumentItem document;
  const _ReminderHero({required this.document});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF07584B), Color(0xFF118268)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(color: Colors.white.withOpacity(.12), borderRadius: BorderRadius.circular(19)),
            child: const Icon(Icons.notifications_active_outlined, color: Colors.white, size: 29),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(document.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 5),
                Text(document.daysText, style: TextStyle(color: Colors.white.withOpacity(.74), fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(.10), borderRadius: BorderRadius.circular(999)),
                  child: Text(document.reminder, style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool active;
  const _TimelineRow({required this.icon, required this.title, required this.value, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: active ? AppColors.mintSoft : AppColors.background,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: active ? AppColors.primary : AppColors.muted, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w600)),
              const SizedBox(height: 3),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ],
    );
  }
}
