import 'package:flutter/material.dart';
import '../data/app_store.dart';
import '../models/document_item.dart';
import '../theme/app_theme.dart';
import '../widgets/app_motion.dart';
import '../widgets/document_card.dart';
import '../widgets/valid_nav_bar.dart';
import 'document_filter_screen.dart';

class DocumentsScreen extends StatefulWidget {
  final String initialFilter;
  const DocumentsScreen({super.key, this.initialFilter = 'All'});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final TextEditingController _search = TextEditingController();
  late String _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<DocumentItem> _visibleDocuments(List<DocumentItem> source) {
    final query = _search.text.trim().toLowerCase();
    return source.where((item) {
      final matchesSearch = query.isEmpty ||
          item.title.toLowerCase().contains(query) ||
          item.type.toLowerCase().contains(query) ||
          item.number.toLowerCase().contains(query) ||
          item.status.toLowerCase().contains(query);

      final matchesFilter = _filter == 'All' ||
          (_filter == 'Valid' && item.status == 'Valid') ||
          (_filter == 'Soon' && item.status == 'Expiring soon') ||
          (_filter == 'Expired' && item.status == 'Expired');

      return matchesSearch && matchesFilter;
    }).toList();
  }

  Future<void> _openFilter() async {
    final selected = await openAppPage<String>(
      context,
      DocumentFilterScreen(currentFilter: _filter),
    );
    if (selected != null && mounted) setState(() => _filter = selected);
  }

  String _filterTitle(String value) {
    switch (value) {
      case 'Valid':
        return 'Valid documents';
      case 'Soon':
        return 'Due soon';
      case 'Expired':
        return 'Expired documents';
      default:
        return 'All documents';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: AppStore.instance,
          builder: (context, _) {
            final all = AppStore.instance.documents;
            final visible = _visibleDocuments(all);
            final validCount = all.where((e) => e.status == 'Valid').length;
            final soonCount =
                all.where((e) => e.status == 'Expiring soon').length;
            final expiredCount = all.where((e) => e.status == 'Expired').length;
            final attentionCount = soonCount + expiredCount;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PageEntrance(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'My documents',
                                      style: TextStyle(
                                        fontSize: 28,
                                        height: 1.05,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -.7,
                                      ),
                                    ),
                                    const SizedBox(height: 7),
                                    Text(
                                      attentionCount == 0
                                          ? '${all.length} documents • Everything is up to date'
                                          : '${all.length} documents • $attentionCount need attention',
                                      style: const TextStyle(
                                        color: AppColors.muted,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              _SquareActionButton(
                                icon: Icons.tune_rounded,
                                tooltip: 'More filters',
                                onTap: _openFilter,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        PageEntrance(
                          delay: 40,
                          child: _SearchBox(
                            controller: _search,
                            onChanged: () => setState(() {}),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Quick filters',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: .15,
                          ),
                        ),
                        const SizedBox(height: 9),
                        PageEntrance(
                          delay: 80,
                          child: _FilterTabs(
                            activeFilter: _filter,
                            allCount: all.length,
                            validCount: validCount,
                            soonCount: soonCount,
                            expiredCount: expiredCount,
                            onChanged: (value) => setState(() => _filter = value),
                          ),
                        ),
                        const SizedBox(height: 18),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          child: Row(
                            key: ValueKey('${_filter}-${visible.length}'),
                            children: [
                              Expanded(
                                child: Text(
                                  _filterTitle(_filter),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              Text(
                                '${visible.length} ${visible.length == 1 ? 'item' : 'items'}',
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                if (visible.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 122),
                    sliver: SliverList.separated(
                      itemCount: visible.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => DocumentCard(
                        item: visible[index],
                        index: index,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: const ValidNavBar(currentIndex: 1),
    );
  }
}

class _SearchBox extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;

  const _SearchBox({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: (_) => onChanged(),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search documents',
        hintStyle: const TextStyle(
          color: Color(0xFF9BA7A3),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppColors.muted,
          size: 22,
        ),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                onPressed: () {
                  controller.clear();
                  onChanged();
                },
                icon: const Icon(Icons.close_rounded, size: 20),
              ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 17),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  final String activeFilter;
  final int allCount;
  final int validCount;
  final int soonCount;
  final int expiredCount;
  final ValueChanged<String> onChanged;

  const _FilterTabs({
    required this.activeFilter,
    required this.allCount,
    required this.validCount,
    required this.soonCount,
    required this.expiredCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      ('All', allCount, Icons.folder_outlined),
      ('Valid', validCount, Icons.check_circle_outline_rounded),
      ('Soon', soonCount, Icons.schedule_rounded),
      ('Expired', expiredCount, Icons.error_outline_rounded),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEEEA),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: items.map((item) {
          final active = activeFilter == item.$1;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: InkWell(
                borderRadius: BorderRadius.circular(13),
                onTap: () => onChanged(item.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 230),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: active ? AppColors.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: active
                        ? const [
                            BoxShadow(
                              color: Color(0x0C19352E),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.$3,
                        size: 17,
                        color: active ? AppColors.primary : AppColors.muted,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.$1 == 'Soon' ? 'Due soon' : item.$1,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: active ? AppColors.ink : AppColors.muted,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.$2}',
                        style: TextStyle(
                          color: active ? AppColors.primary : AppColors.muted,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SquareActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _SquareActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: PressableScale(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.line),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0919352E),
                blurRadius: 12,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Icon(icon, color: AppColors.ink, size: 22),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 24, 32, 120),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.mintSoft,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.folder_off_outlined,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No documents found',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 7),
            const Text(
              'Try a different search or choose another filter.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 12.5,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
