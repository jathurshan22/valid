import 'package:flutter/material.dart';
import '../data/app_store.dart';
import '../models/document_item.dart';
import '../theme/app_theme.dart';
import '../widgets/app_motion.dart';
import 'document_details_screen.dart';
import 'document_photo_screen.dart';

class AddDocumentScreen extends StatefulWidget {
  final DocumentItem? existingDocument;
  const AddDocumentScreen({super.key, this.existingDocument});

  bool get isEditing => existingDocument != null;

  @override
  State<AddDocumentScreen> createState() => _AddDocumentScreenState();
}

class _AddDocumentScreenState extends State<AddDocumentScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _numberController;
  late String _type;
  late DateTime _issueDate;
  late DateTime _expiryDate;
  late String _reminder;
  String? _photoStatus;
  bool _saving = false;

  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  @override
  void initState() {
    super.initState();
    final existing = widget.existingDocument;
    _nameController = TextEditingController(text: existing?.title ?? 'Driving Licence');
    _numberController = TextEditingController(text: existing?.number ?? 'B1234567');
    _type = existing?.type ?? 'Licence';
    _issueDate = _parse(existing?.issueDate) ?? DateTime.now();
    _expiryDate = _parse(existing?.expiry) ?? DateTime.now().add(const Duration(days: 365));
    _reminder = existing?.reminder ?? AppStore.instance.defaultReminder;
    _photoStatus = existing?.photoPath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  DateTime? _parse(String? value) {
    if (value == null) return null;
    final parts = value.split(' ');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = _months.indexOf(parts[1]) + 1;
    final year = int.tryParse(parts[2]);
    if (day == null || month <= 0 || year == null) return null;
    return DateTime(year, month, day);
  }

  String _format(DateTime date) => '${date.day.toString().padLeft(2, '0')} ${_months[date.month - 1]} ${date.year}';

  Future<void> _pickDate(bool expiry) async {
    final initial = expiry ? _expiryDate : _issueDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2045),
    );
    if (picked == null) return;
    setState(() {
      if (expiry) {
        _expiryDate = picked;
      } else {
        _issueDate = picked;
      }
    });
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'Licence': return Icons.badge_outlined;
      case 'Passport': return Icons.travel_explore_outlined;
      case 'Insurance': return Icons.policy_outlined;
      case 'Identity': return Icons.contact_page_outlined;
      case 'Certificate': return Icons.workspace_premium_outlined;
      default: return Icons.description_outlined;
    }
  }

  Color _accentForStatus(String status) {
    if (status == 'Expired') return AppColors.danger;
    if (status == 'Expiring soon') return AppColors.amber;
    if (_type == 'Identity') return AppColors.blue;
    return AppColors.primary;
  }

  Future<void> _choosePhoto() async {
    final result = await openAppPage<String>(context, const DocumentPhotoScreen());
    if (result != null && mounted) setState(() => _photoStatus = result);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    if (_expiryDate.isBefore(_issueDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expiry date must be after the issue date.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final existing = widget.existingDocument;
      final item = DocumentItem.create(
        id: existing?.id ?? 'doc-${DateTime.now().microsecondsSinceEpoch}',
        title: _nameController.text.trim(),
        type: _type,
        number: _numberController.text.trim(),
        issueDate: _issueDate,
        expiryDate: _expiryDate,
        reminder: _reminder,
        createdAt: existing?.createdAt ?? DateTime.now(),
        photoPath: _photoStatus,
      );

      if (widget.isEditing) {
        await AppStore.instance.updateDocument(item);
      } else {
        await AppStore.instance.addDocument(item);
      }

      if (!mounted) return;
      if (widget.isEditing) {
        Navigator.of(context).pop(item);
      } else {
        Navigator.of(context).pushReplacement(
          appRoute(DocumentDetailsScreen(document: item)),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save this document. Check your internet connection and try again.'),
        ),
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
        title: Text(widget.isEditing ? 'Edit document' : 'Add document', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, letterSpacing: -.3)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageEntrance(
                  child: _UploadCard(photoStatus: _photoStatus, onTap: _choosePhoto),
                ),
                const SizedBox(height: 24),
                const _FormSectionTitle(title: 'Document details', subtitle: 'Use the same information shown on the document.'),
                const SizedBox(height: 13),
                DropdownButtonFormField<String>(
                  value: _type,
                  decoration: const InputDecoration(labelText: 'Document type', prefixIcon: Icon(Icons.article_outlined)),
                  items: const ['Licence', 'Passport', 'Insurance', 'Identity', 'Certificate', 'Other']
                      .map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                  onChanged: (value) => setState(() => _type = value ?? _type),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Document name', prefixIcon: Icon(Icons.description_outlined)),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Enter a document name' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _numberController,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(labelText: 'Document number', prefixIcon: Icon(Icons.tag_outlined)),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Enter a document number' : null,
                ),
                const SizedBox(height: 24),
                const _FormSectionTitle(title: 'Dates & reminder', subtitle: 'These dates control the expiry status and reminders.'),
                const SizedBox(height: 13),
                Row(children: [
                  Expanded(child: _DateField(label: 'Issue date', value: _format(_issueDate), onTap: () => _pickDate(false))),
                  const SizedBox(width: 10),
                  Expanded(child: _DateField(label: 'Expiry date', value: _format(_expiryDate), onTap: () => _pickDate(true), important: true)),
                ]),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _reminder,
                  decoration: const InputDecoration(labelText: 'Reminder', prefixIcon: Icon(Icons.notifications_outlined)),
                  items: const ['7 days before', '14 days before', '30 days before', '60 days before', '90 days before']
                      .map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                  onChanged: (value) => setState(() => _reminder = value ?? _reminder),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.mintSoft, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.mint)),
                  child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                    SizedBox(width: 10),
                    Expanded(child: Text('Set the reminder early enough to renew the document without a rush.', style: TextStyle(color: AppColors.ink, fontSize: 11.5, height: 1.45, fontWeight: FontWeight.w600))),
                  ]),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    style: FilledButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                    icon: _saving
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Icon(widget.isEditing ? Icons.check_rounded : Icons.save_outlined),
                    label: Text(_saving ? 'Saving...' : widget.isEditing ? 'Save changes' : 'Save document', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UploadCard extends StatelessWidget {
  final String? photoStatus;
  final VoidCallback onTap;
  const _UploadCard({required this.photoStatus, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ready = photoStatus != null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(28), border: Border.all(color: AppColors.line), boxShadow: AppShadows.soft),
      child: Row(children: [
        Container(
          width: 82,
          height: 96,
          decoration: BoxDecoration(color: ready ? AppColors.mintSoft : AppColors.background, borderRadius: BorderRadius.circular(21), border: Border.all(color: ready ? AppColors.mint : AppColors.line)),
          child: Icon(ready ? Icons.image_outlined : Icons.description_outlined, color: AppColors.primary, size: 34),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(ready ? 'Document photo ready' : 'Add a document photo', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          Text(ready ? 'Photo selected successfully' : 'Optional local preview. Document photos are not uploaded to Firebase in this build.', style: const TextStyle(color: AppColors.muted, fontSize: 11.5, height: 1.4)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.mint), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
            onPressed: onTap,
            icon: Icon(ready ? Icons.sync_outlined : Icons.add_photo_alternate_outlined, size: 17),
            label: Text(ready ? 'Change photo' : 'Choose photo', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
          ),
        ])),
      ]),
    );
  }
}

class _FormSectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  const _FormSectionTitle({required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
    const SizedBox(height: 3),
    Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 11.3)),
  ]);
}

class _DateField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool important;
  const _DateField({required this.label, required this.value, required this.onTap, this.important = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: important ? AppColors.mintSoft : AppColors.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: important ? AppColors.mint : AppColors.line)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 10.5, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(children: [
            Icon(Icons.calendar_today_outlined, size: 16, color: important ? AppColors.primary : AppColors.muted),
            const SizedBox(width: 6),
            Expanded(child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800))),
          ]),
        ]),
      ),
    );
  }
}
