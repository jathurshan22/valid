import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_motion.dart';
import 'support_contact_screen.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

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
        title: const Text('Help & support', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: AppColors.mintSoft, borderRadius: BorderRadius.circular(26), border: Border.all(color: AppColors.mint)),
              child: const Row(children: [
                Icon(Icons.help_outline_rounded, color: AppColors.primary, size: 32),
                SizedBox(width: 13),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('How can we help?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                  SizedBox(height: 4),
                  Text('Find quick answers or send a support message.', style: TextStyle(color: AppColors.muted, fontSize: 11)),
                ])),
              ]),
            ),
            const SizedBox(height: 18),
            const Text('Common questions', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
            const SizedBox(height: 9),
            const _Faq(title: 'How are expiry reminders calculated?', body: 'The app uses the expiry date and reminder lead time saved with each document.'),
            const _Faq(title: 'Can I edit a saved document?', body: 'Yes. Open the document, choose Edit, update the details, and save your changes.'),
            const _Faq(title: 'Can I remove an expired document?', body: 'Yes. Open the document options and choose Delete document.'),
            const SizedBox(height: 18),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: () => openAppPage(context, const SupportContactScreen()),
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17))),
                icon: const Icon(Icons.mail_outline_rounded),
                label: const Text('Contact support', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Faq extends StatelessWidget {
  final String title;
  final String body;
  const _Faq({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 9),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppColors.line)),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        iconColor: AppColors.primary,
        title: Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 15),
        children: [Text(body, style: const TextStyle(color: AppColors.muted, fontSize: 11, height: 1.45))],
      ),
    );
  }
}
