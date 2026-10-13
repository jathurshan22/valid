import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

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
        title: const Text('Privacy', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: const [
            _PrivacyBlock(
              icon: Icons.lock_outline_rounded,
              title: 'Private by design',
              text: 'Your document records are stored in Cloud Firestore under your signed-in Firebase user ID. Firestore security rules restrict each user to their own data.',
            ),
            SizedBox(height: 12),
            _PrivacyBlock(
              icon: Icons.visibility_outlined,
              title: 'You control your data',
              text: 'You can edit or delete documents from the document details screen whenever you want.',
            ),
            SizedBox(height: 12),
            _PrivacyBlock(
              icon: Icons.cloud_off_outlined,
              title: 'Cloud sync',
              text: 'Document details, profile information and settings sync through Firebase. Expiry reminders and selected document photos stay local to the device.'
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyBlock extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  const _PrivacyBlock({required this.icon, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.line)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.mintSoft, borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: AppColors.primary)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          Text(text, style: const TextStyle(color: AppColors.muted, fontSize: 11, height: 1.45)),
        ])),
      ]),
    );
  }
}
