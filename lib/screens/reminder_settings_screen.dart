import 'package:flutter/material.dart';
import '../data/app_store.dart';
import '../theme/app_theme.dart';

class ReminderSettingsScreen extends StatefulWidget {
  final String documentId;
  const ReminderSettingsScreen({super.key, required this.documentId});

  @override
  State<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  late String _value;
  bool _saving = false;
  static const _options = ['7 days before', '14 days before', '30 days before', '60 days before', '90 days before'];

  @override
  void initState() {
    super.initState();
    _value = AppStore.instance.byId(widget.documentId)?.reminder ?? AppStore.instance.defaultReminder;
  }

  Future<void> _save() async {
    if (_saving) return;
    final doc = AppStore.instance.byId(widget.documentId);
    if (doc == null) return;
    setState(() => _saving = true);
    try {
      await AppStore.instance.updateDocument(doc.copyWith(reminder: _value));
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update the reminder. Please try again.')),
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
        title: const Text('Reminder settings', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: [
            const Text('When should Valid remind you?', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
            const SizedBox(height: 5),
            const Text('Choose enough time to complete the renewal comfortably.', style: TextStyle(color: AppColors.muted, fontSize: 11.5, height: 1.4)),
            const SizedBox(height: 18),
            Container(
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.line)),
              child: Column(
                children: _options.map((option) {
                  final selected = option == _value;
                  return RadioListTile<String>(
                    value: option,
                    groupValue: _value,
                    activeColor: AppColors.primary,
                    title: Text(option, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                    secondary: Icon(selected ? Icons.notifications_active_outlined : Icons.notifications_none_rounded, color: selected ? AppColors.primary : AppColors.muted),
                    onChanged: (value) => setState(() => _value = value ?? _value),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17))),
                icon: _saving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check_rounded),
                label: Text(_saving ? 'Saving...' : 'Save reminder', style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
