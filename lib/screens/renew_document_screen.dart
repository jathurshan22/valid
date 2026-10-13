import 'package:flutter/material.dart';
import '../data/app_store.dart';
import '../models/document_item.dart';
import '../theme/app_theme.dart';

class RenewDocumentScreen extends StatefulWidget {
  final String documentId;
  const RenewDocumentScreen({super.key, required this.documentId});

  @override
  State<RenewDocumentScreen> createState() => _RenewDocumentScreenState();
}

class _RenewDocumentScreenState extends State<RenewDocumentScreen> {
  late DateTime _newExpiry;
  late String _reminder;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final doc = AppStore.instance.byId(widget.documentId);
    _newExpiry = DateTime.now().add(const Duration(days: 365));
    _reminder = doc?.reminder ?? AppStore.instance.defaultReminder;
  }

  String _format(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
  }

  Future<void> _pick() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _newExpiry,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime(DateTime.now().year + 15),
    );
    if (picked != null) setState(() => _newExpiry = picked);
  }

  Future<void> _renew() async {
    if (_saving) return;
    final doc = AppStore.instance.byId(widget.documentId);
    if (doc == null) return;

    setState(() => _saving = true);
    try {
      final updated = DocumentItem.create(
        id: doc.id,
        title: doc.title,
        type: doc.type,
        number: doc.number,
        issueDate: doc.issueDateValue,
        expiryDate: _newExpiry,
        reminder: _reminder,
        createdAt: doc.createdAt,
        photoPath: doc.photoPath,
      );
      await AppStore.instance.updateDocument(updated);
      if (!mounted) return;
      Navigator.of(context).pop(updated);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not renew the document. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final document = AppStore.instance.byId(widget.documentId);
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
        title: const Text('Renew document', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.line)),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(color: AppColors.mintSoft, borderRadius: BorderRadius.circular(16)),
                    child: Icon(document.icon, color: AppColors.primary, size: 25),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(document.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text('Current expiry: ${document.expiry}', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                  ])),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text('New expiry date', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
            const SizedBox(height: 9),
            InkWell(
              onTap: _pick,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.line)),
                child: Row(children: [
                  const Icon(Icons.event_outlined, color: AppColors.primary),
                  const SizedBox(width: 11),
                  Expanded(child: Text(_format(_newExpiry), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800))),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
                ]),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _reminder,
              decoration: const InputDecoration(labelText: 'Reminder', prefixIcon: Icon(Icons.notifications_outlined)),
              items: const ['7 days before', '14 days before', '30 days before', '60 days before', '90 days before']
                  .map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (v) => setState(() => _reminder = v ?? _reminder),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: _saving ? null : _renew,
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17))),
                icon: _saving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.autorenew_rounded),
                label: Text(_saving ? 'Saving...' : 'Confirm renewal', style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
