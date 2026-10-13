import 'package:flutter/material.dart';
import '../data/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/app_motion.dart';
import 'add_document_screen.dart';
import 'reminder_settings_screen.dart';
import 'renew_document_screen.dart';

class DocumentActionsScreen extends StatelessWidget {
  final String documentId;
  const DocumentActionsScreen({super.key, required this.documentId});

  @override
  Widget build(BuildContext context) {
    final document = AppStore.instance.byId(documentId);
    if (document == null) return const Scaffold(body: Center(child: Text('Document not found')));

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
        title: const Text('Document options', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.line)),
              child: Row(children: [
                Container(width: 50, height: 50, decoration: BoxDecoration(color: AppColors.mintSoft, borderRadius: BorderRadius.circular(16)), child: Icon(document.icon, color: AppColors.primary)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(document.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(document.number, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                ])),
              ]),
            ),
            const SizedBox(height: 18),
            _ActionRow(
              icon: Icons.edit_outlined,
              title: 'Edit document',
              subtitle: 'Update name, number, dates or type',
              onTap: () async {
                await openAppPage(context, AddDocumentScreen(existingDocument: document));
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
            _ActionRow(
              icon: Icons.notifications_outlined,
              title: 'Reminder settings',
              subtitle: 'Change when you are reminded',
              onTap: () => openAppPage(context, ReminderSettingsScreen(documentId: document.id)),
            ),
            _ActionRow(
              icon: Icons.autorenew_rounded,
              title: 'Renew document',
              subtitle: 'Set a new expiry date and reminder',
              onTap: () async {
                await openAppPage(context, RenewDocumentScreen(documentId: document.id));
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 14),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete document?'),
                      content: Text('${document.title} will be permanently removed from your cloud account.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                        FilledButton(
                          style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    try {
                      await AppStore.instance.deleteDocument(document.id);
                      if (context.mounted) Navigator.of(context).pop('deleted');
                    } catch (_) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not delete the document. Please try again.')),
                      );
                    }
                  }
                },
                borderRadius: BorderRadius.circular(22),
                child: Ink(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: AppColors.dangerSoft, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.danger.withOpacity(.14))),
                  child: const Row(children: [
                    Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                    SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Delete document', style: TextStyle(color: AppColors.danger, fontSize: 13, fontWeight: FontWeight.w900)),
                      SizedBox(height: 3),
                      Text('Remove this document and its reminders', style: TextStyle(color: AppColors.muted, fontSize: 10.5)),
                    ])),
                    Icon(Icons.chevron_right_rounded, color: AppColors.danger),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ActionRow({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Ink(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.line)),
            child: Row(children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.mintSoft, borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: AppColors.primary, size: 21)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 10.5)),
              ])),
              const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
            ]),
          ),
        ),
      ),
    );
  }
}
