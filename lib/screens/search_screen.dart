import 'package:flutter/material.dart';
import '../data/app_store.dart';
import '../models/document_item.dart';
import '../theme/app_theme.dart';
import '../widgets/app_motion.dart';
import '../widgets/document_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<DocumentItem> _results() {
    final q = _controller.text.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return AppStore.instance.documents.where((item) {
      return item.title.toLowerCase().contains(q) ||
          item.type.toLowerCase().contains(q) ||
          item.number.toLowerCase().contains(q) ||
          item.status.toLowerCase().contains(q);
    }).toList();
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
        title: const Text('Search', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
      ),
      body: AnimatedBuilder(
        animation: AppStore.instance,
        builder: (context, _) {
          final results = _results();
          final emptyQuery = _controller.text.trim().isEmpty;
          return SafeArea(
            top: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                  child: PageEntrance(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search documents, numbers or status',
                        prefixIcon: const Icon(Icons.search_outlined),
                        suffixIcon: _controller.text.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  _controller.clear();
                                  setState(() {});
                                },
                                icon: const Icon(Icons.close_rounded),
                              ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: emptyQuery
                        ? _SearchSuggestions(
                            key: const ValueKey('suggestions'),
                            onPick: (value) {
                              _controller.text = value;
                              _controller.selection = TextSelection.collapsed(offset: value.length);
                              setState(() {});
                            },
                          )
                        : results.isEmpty
                            ? const _NoResults(key: ValueKey('empty'))
                            : ListView.separated(
                                key: ValueKey('results-${results.length}-${_controller.text}'),
                                padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
                                itemCount: results.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 10),
                                itemBuilder: (_, index) => DocumentCard(
                                  item: results[index],
                                  index: index,
                                ),
                              ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SearchSuggestions extends StatelessWidget {
  final ValueChanged<String> onPick;
  const _SearchSuggestions({super.key, required this.onPick});

  @override
  Widget build(BuildContext context) {
    const suggestions = ['Insurance', 'Licence', 'Passport', 'Expired'];
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
      children: [
        const Text('Quick search', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
        const SizedBox(height: 5),
        const Text('Start with a common document type or status.', style: TextStyle(color: AppColors.muted, fontSize: 11.5)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestions.map((s) {
            return ActionChip(
              avatar: const Icon(Icons.search_rounded, size: 16, color: AppColors.primary),
              label: Text(s),
              onPressed: () => onPick(s),
              backgroundColor: AppColors.surface,
              side: const BorderSide(color: AppColors.line),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            );
          }).toList(),
        ),
        const SizedBox(height: 26),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.mintSoft,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.mint),
          ),
          child: const Row(
            children: [
              Icon(Icons.manage_search_outlined, color: AppColors.primary, size: 26),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Search also matches document numbers and expiry status.',
                  style: TextStyle(color: AppColors.ink, fontSize: 11.5, height: 1.4, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 52, color: AppColors.muted),
            SizedBox(height: 14),
            Text('No matching documents', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
            SizedBox(height: 5),
            Text('Try a document name, number or status.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
