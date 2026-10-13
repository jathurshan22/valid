import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';

class DocumentPhotoScreen extends StatefulWidget {
  const DocumentPhotoScreen({super.key});

  @override
  State<DocumentPhotoScreen> createState() => _DocumentPhotoScreenState();
}

class _DocumentPhotoScreenState extends State<DocumentPhotoScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _busy = false;

  Future<void> _pick(ImageSource source) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final file = await _picker.pickImage(
        source: source,
        imageQuality: 88,
        maxWidth: 1800,
      );
      if (!mounted) return;
      if (file != null) {
        Navigator.of(context).pop(file.path);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the selected photo source.')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
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
        title: const Text('Document photo', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: [
            Container(
              height: 210,
              decoration: BoxDecoration(
                color: AppColors.mintSoft,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.mint),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: _busy
                        ? const SizedBox(
                            key: ValueKey('loading'),
                            width: 42,
                            height: 42,
                            child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.primary),
                          )
                        : const Icon(
                            Icons.document_scanner_outlined,
                            key: ValueKey('icon'),
                            color: AppColors.primary,
                            size: 48,
                          ),
                  ),
                  const SizedBox(height: 12),
                  Text(_busy ? 'Opening photo source...' : 'Add a clear document image', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 34),
                    child: Text('Keep all four corners visible and avoid glare.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted, fontSize: 11.5, height: 1.4)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _SourceButton(
              icon: Icons.photo_camera_outlined,
              title: 'Use camera',
              subtitle: 'Take a new document photo',
              enabled: !_busy,
              onTap: () => _pick(ImageSource.camera),
            ),
            const SizedBox(height: 10),
            _SourceButton(
              icon: Icons.photo_library_outlined,
              title: 'Choose from gallery',
              subtitle: 'Select a saved document image',
              enabled: !_busy,
              onTap: () => _pick(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback onTap;
  const _SourceButton({required this.icon, required this.title, required this.subtitle, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.line)),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(color: AppColors.mintSoft, borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 10.5)),
                ]),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}
