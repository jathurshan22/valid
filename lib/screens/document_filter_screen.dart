import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DocumentFilterScreen extends StatefulWidget {
  final String currentFilter;
  const DocumentFilterScreen({super.key, required this.currentFilter});

  @override
  State<DocumentFilterScreen> createState() => _DocumentFilterScreenState();
}

class _DocumentFilterScreenState extends State<DocumentFilterScreen> {
  late String _status;

  @override
  void initState() {
    super.initState();
    _status = widget.currentFilter;
  }

  @override
  Widget build(BuildContext context) {
    const options = [
      ('All', 'Show every saved document', Icons.folder_outlined),
      ('Valid', 'Documents that are currently up to date', Icons.verified_outlined),
      ('Soon', 'Documents that need attention soon', Icons.schedule_outlined),
      ('Expired', 'Documents that have already expired', Icons.error_outline_rounded),
    ];

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
        title: const Text('Filter documents', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: [
            const Text('Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            const SizedBox(height: 5),
            const Text('Choose which documents you want to see.', style: TextStyle(color: AppColors.muted, fontSize: 11.5)),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.line)),
              child: Column(
                children: options.map((option) {
                  final selected = option.$1 == _status;
                  return InkWell(
                    onTap: () => setState(() => _status = option.$1),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: selected ? AppColors.mintSoft : AppColors.background,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Icon(option.$3, color: selected ? AppColors.primary : AppColors.muted, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(option.$1, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
                                const SizedBox(height: 3),
                                Text(option.$2, style: const TextStyle(color: AppColors.muted, fontSize: 10.5)),
                              ],
                            ),
                          ),
                          Icon(selected ? Icons.check_circle_rounded : Icons.circle_outlined, color: selected ? AppColors.primary : AppColors.line),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(_status),
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17))),
                icon: const Icon(Icons.filter_alt_outlined),
                label: const Text('Apply filter', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
