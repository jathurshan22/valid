import 'package:flutter/material.dart';
import '../data/app_store.dart';
import '../models/document_item.dart';
import '../theme/app_theme.dart';
import '../widgets/app_motion.dart';
import 'add_document_screen.dart';
import 'document_actions_screen.dart';
import 'renew_document_screen.dart';

class DocumentDetailsScreen extends StatefulWidget {
  final DocumentItem document;
  const DocumentDetailsScreen({super.key, required this.document});

  @override
  State<DocumentDetailsScreen> createState() => _DocumentDetailsScreenState();
}

class _DocumentDetailsScreenState extends State<DocumentDetailsScreen> {
  DocumentItem get document => AppStore.instance.byId(widget.document.id) ?? widget.document;

  Color _softColor(DocumentItem item) {
    if (item.status == 'Expired') return AppColors.dangerSoft;
    if (item.status == 'Expiring soon') return AppColors.amberSoft;
    if (item.accent == AppColors.blue) return AppColors.blueSoft;
    return AppColors.mintSoft;
  }

  Future<void> _edit() async {
    await openAppPage(context, AddDocumentScreen(existingDocument: document));
    if (mounted) setState(() {});
  }

  Future<void> _renew() async {
    await openAppPage(context, RenewDocumentScreen(documentId: document.id));
    if (mounted) setState(() {});
  }

  Future<void> _more() async {
    final result = await openAppPage<String>(context, DocumentActionsScreen(documentId: document.id));
    if (!mounted) return;
    if (result == 'deleted' || AppStore.instance.byId(document.id) == null) {
      Navigator.of(context).pop();
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppStore.instance,
      builder: (context, _) {
        final item = document;
        final soft = _softColor(item);
        final progress = item.daysRemaining <= 0 ? .04 : (item.daysRemaining / 365).clamp(.08, 1.0).toDouble();
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
            title: const Text('Document details', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, letterSpacing: -.3)),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: IconButton(onPressed: _more, icon: const Icon(Icons.more_vert_rounded)),
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                PageEntrance(child: _DocumentCover(document: item, softColor: soft)),
                const SizedBox(height: 18),
                PageEntrance(delay: 50, child: _ExpiryPanel(document: item, softColor: soft, progress: progress)),
                const SizedBox(height: 22),
                const Text('Document information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                const SizedBox(height: 11),
                PageEntrance(
                  delay: 90,
                  child: Container(
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.line)),
                    child: Column(children: [
                      _InfoRow(icon: Icons.tag_outlined, label: 'Document number', value: item.number),
                      _InfoRow(icon: Icons.calendar_today_outlined, label: 'Issue date', value: item.issueDate),
                      _InfoRow(icon: Icons.event_available_outlined, label: 'Expiry date', value: item.expiry),
                      _InfoRow(icon: Icons.notifications_outlined, label: 'Reminder', value: item.reminder, last: true),
                    ]),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.line)),
                  child: const Row(children: [
                    _PrivacyIcon(),
                    SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Private by design', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                      SizedBox(height: 3),
                      Text('Document data is saved to your Firebase account and protected by per-user Firestore rules.', style: TextStyle(color: AppColors.muted, fontSize: 10.8, height: 1.35)),
                    ])),
                  ]),
                ),
                const SizedBox(height: 22),
                Row(children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.mint), minimumSize: const Size.fromHeight(52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17))),
                      onPressed: _edit,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17))),
                      onPressed: _renew,
                      icon: const Icon(Icons.autorenew_rounded, size: 18),
                      label: const Text('Renew', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ]),
              ]),
            ),
          ),
        );
      },
    );
  }
}

class _PrivacyIcon extends StatelessWidget {
  const _PrivacyIcon();
  @override
  Widget build(BuildContext context) => Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.mintSoft, borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 20));
}

class _DocumentCover extends StatelessWidget {
  final DocumentItem document;
  final Color softColor;
  const _DocumentCover({required this.document, required this.softColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(28), border: Border.all(color: AppColors.line), boxShadow: AppShadows.soft),
      child: Row(children: [
        Hero(
          tag: 'doc-${document.id}',
          child: Container(
            width: 72,
            height: 88,
            decoration: BoxDecoration(color: softColor, borderRadius: BorderRadius.circular(20)),
            child: Stack(children: [
              Center(child: Icon(document.icon, color: document.accent, size: 34)),
              Positioned(top: 10, right: 10, child: Container(width: 7, height: 7, decoration: BoxDecoration(color: document.accent, shape: BoxShape.circle))),
            ]),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(document.type.toUpperCase(), style: TextStyle(color: document.accent, fontSize: 9.5, fontWeight: FontWeight.w900, letterSpacing: 1.1)),
          const SizedBox(height: 5),
          Text(document.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -.35)),
          const SizedBox(height: 5),
          Text(document.number, style: const TextStyle(color: AppColors.muted, fontSize: 12.5, fontWeight: FontWeight.w600)),
          const SizedBox(height: 9),
          Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: softColor, borderRadius: BorderRadius.circular(999)), child: Text(document.status, style: TextStyle(color: document.accent, fontSize: 10.5, fontWeight: FontWeight.w800))),
        ])),
      ]),
    );
  }
}

class _ExpiryPanel extends StatelessWidget {
  final DocumentItem document;
  final Color softColor;
  final double progress;
  const _ExpiryPanel({required this.document, required this.softColor, required this.progress});

  @override
  Widget build(BuildContext context) {
    final overdue = document.daysRemaining < 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: softColor, borderRadius: BorderRadius.circular(25)),
      child: Column(children: [
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(overdue ? 'Expired on' : 'Expires on', style: const TextStyle(color: AppColors.muted, fontSize: 11.5, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(document.expiry, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${document.daysRemaining.abs()}', style: TextStyle(color: document.accent, fontSize: 30, height: .95, fontWeight: FontWeight.w900)),
            const SizedBox(height: 3),
            Text(overdue ? 'days overdue' : 'days left', style: TextStyle(color: document.accent, fontSize: 10, fontWeight: FontWeight.w800)),
          ]),
        ]),
        const SizedBox(height: 15),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(value: progress, minHeight: 7, backgroundColor: Colors.white.withOpacity(.72), valueColor: AlwaysStoppedAnimation(document.accent)),
        ),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool last;
  const _InfoRow({required this.icon, required this.label, required this.value, this.last = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(border: last ? null : const Border(bottom: BorderSide(color: AppColors.line))),
      child: Row(children: [
        Container(width: 38, height: 38, decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppColors.primary, size: 18)),
        const SizedBox(width: 11),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 10.5, fontWeight: FontWeight.w600)),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
        ])),
      ]),
    );
  }
}
