import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';

class SupportContactScreen extends StatefulWidget {
  const SupportContactScreen({super.key});

  @override
  State<SupportContactScreen> createState() => _SupportContactScreenState();
}

class _SupportContactScreenState extends State<SupportContactScreen> {
  final _subject = TextEditingController();
  final _message = TextEditingController();
  final _key = GlobalKey<FormState>();
  bool _sent = false;
  bool _sending = false;

  @override
  void dispose() {
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_key.currentState!.validate() || _sending) return;
    setState(() => _sending = true);
    try {
      await FirestoreService.submitSupportMessage(
        subject: _subject.text,
        message: _message.text,
      );
      if (!mounted) return;
      setState(() => _sent = true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not submit the message. Check your internet connection and try again.')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
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
        title: const Text('Contact support', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        top: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          child: _sent
              ? Center(
                  key: const ValueKey('sent'),
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Container(width: 78, height: 78, decoration: BoxDecoration(color: AppColors.mintSoft, borderRadius: BorderRadius.circular(24)), child: const Icon(Icons.mark_email_read_outlined, color: AppColors.primary, size: 38)),
                      const SizedBox(height: 16),
                      const Text('Message submitted', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 6),
                      const Text('Your support request was saved securely to your Firebase account.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted, fontSize: 11.5, height: 1.45)),
                      const SizedBox(height: 18),
                      FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Done')),
                    ]),
                  ),
                )
              : Form(
                  key: _key,
                  child: ListView(
                    key: const ValueKey('form'),
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
                    children: [
                      TextFormField(
                        controller: _subject,
                        decoration: const InputDecoration(labelText: 'Subject', prefixIcon: Icon(Icons.subject_outlined)),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Enter a subject' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _message,
                        minLines: 5,
                        maxLines: 8,
                        decoration: const InputDecoration(labelText: 'Message', alignLabelWithHint: true, prefixIcon: Icon(Icons.chat_bubble_outline_rounded)),
                        validator: (v) => v == null || v.trim().length < 10 ? 'Write at least 10 characters' : null,
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        height: 54,
                        child: FilledButton.icon(
                          onPressed: _sending ? null : _send,
                          style: FilledButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17))),
                          icon: _sending
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.send_outlined),
                          label: Text(_sending ? 'Sending...' : 'Send message', style: const TextStyle(fontWeight: FontWeight.w800)),
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
