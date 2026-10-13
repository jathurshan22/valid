import 'package:flutter/material.dart';
import '../data/app_store.dart';
import '../theme/app_theme.dart';

class DefaultReminderScreen extends StatefulWidget {
  const DefaultReminderScreen({super.key});

  @override
  State<DefaultReminderScreen> createState() => _DefaultReminderScreenState();
}

class _DefaultReminderScreenState extends State<DefaultReminderScreen> {
  late String _value;
  static const options = ['7 days before', '14 days before', '30 days before', '60 days before', '90 days before'];

  @override
  void initState() {
    super.initState();
    _value = AppStore.instance.defaultReminder;
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
        title: const Text('Default reminder', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: [
            const Text('Choose the default lead time for new documents.', style: TextStyle(color: AppColors.muted, fontSize: 11.5)),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.line)),
              child: Column(
                children: options.map((v) => RadioListTile<String>(
                  value: v,
                  groupValue: _value,
                  activeColor: AppColors.primary,
                  title: Text(v, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                  onChanged: (value) => setState(() => _value = value ?? _value),
                )).toList(),
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: () {
                  AppStore.instance.setDefaultReminder(_value);
                  Navigator.of(context).pop();
                },
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17))),
                icon: const Icon(Icons.check_rounded),
                label: const Text('Save default', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
