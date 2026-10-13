import 'package:flutter/material.dart';
import '../data/app_store.dart';
import '../models/document_item.dart';
import '../theme/app_theme.dart';
import '../widgets/app_motion.dart';
import '../widgets/document_card.dart';
import '../widgets/valid_nav_bar.dart';
import 'document_details_screen.dart';
import 'documents_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'reminder_details_screen.dart';
import 'search_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _openDocuments(BuildContext context, {String filter = 'All'}) {
    Navigator.of(context).pushReplacement(appRoute(DocumentsScreen(initialFilter: filter)));
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
            final store = AppStore.instance;
            final docs = store.documents;
            final expiring = docs.where((d) => d.status == 'Expiring soon').take(2).toList();
            final nextRenewal = docs.where((d) => d.daysRemaining >= 0).toList()
              ..sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));
            final hero = nextRenewal.isNotEmpty ? nextRenewal.first : (docs.isNotEmpty ? docs.first : null);

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 118),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PageEntrance(
                    child: _TopBar(
                      unreadCount: store.unreadAlertCount,
                      onSearch: () => openAppPage(context, const SearchScreen()),
                      onNotifications: () => openAppPage(context, const NotificationsScreen()),
                      onProfile: () => openAppPage(context, const ProfileScreen()),
                    ),
                  ),
                  const SizedBox(height: 22),
                  if (hero != null)
                    PageEntrance(
                      delay: 60,
                      child: _RenewalHero(
                        item: hero,
                        onTap: () => openAppPage(context, ReminderDetailsScreen(documentId: hero.id)),
                      ),
                    )
                  else
                    const _NoDocumentsHero(),
                  const SizedBox(height: 16),
                  PageEntrance(
                    delay: 110,
                    child: _QuickStats(
                      total: docs.length,
                      expiring: store.expiringCount,
                      expired: store.expiredCount,
                      valid: store.validCount,
                      onAll: () => _openDocuments(context),
                      onExpiring: () => _openDocuments(context, filter: 'Soon'),
                      onExpired: () => _openDocuments(context, filter: 'Expired'),
                      onValid: () => _openDocuments(context, filter: 'Valid'),
                    ),
                  ),
                  const SizedBox(height: 26),
                  PageEntrance(
                    delay: 150,
                    child: _SectionHeader(
                      title: 'Expiring soon',
                      subtitle: 'Worth checking this month',
                      action: 'View all',
                      onTap: () => _openDocuments(context, filter: 'Soon'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (expiring.isEmpty)
                    const _MiniEmpty(message: 'No documents need attention soon.')
                  else
                    ...expiring.asMap().entries.map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: PageEntrance(
                        delay: 180 + entry.key * 45,
                        child: DocumentCard(item: entry.value, index: entry.key, compact: true),
                      ),
                    )),
                  const SizedBox(height: 14),
                  PageEntrance(
                    delay: 260,
                    child: _SectionHeader(
                      title: 'Recently added',
                      subtitle: 'Your latest saved documents',
                      action: 'All documents',
                      onTap: () => _openDocuments(context),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (docs.isEmpty)
                    const _MiniEmpty(message: 'Add a document to see it here.')
                  else
                    PageEntrance(
                      delay: 300,
                      child: SizedBox(
                        height: 112,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: docs.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final item = docs[index];
                            return _RecentDocumentCard(
                              item: item,
                              onTap: () => openAppPage(context, DocumentDetailsScreen(document: item)),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const ValidNavBar(currentIndex: 0),
    );
  }
}

class _TopBar extends StatelessWidget {
  final int unreadCount;
  final VoidCallback onSearch;
  final VoidCallback onNotifications;
  final VoidCallback onProfile;
  const _TopBar({required this.unreadCount, required this.onSearch, required this.onNotifications, required this.onProfile});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Good evening', style: TextStyle(color: AppColors.muted, fontSize: 13, fontWeight: FontWeight.w600)),
        SizedBox(height: 3),
        Text('Your documents\nare on track', style: TextStyle(color: AppColors.ink, fontSize: 25, height: 1.05, fontWeight: FontWeight.w900, letterSpacing: -.7)),
      ])),
      _HeaderButton(icon: Icons.search_outlined, onTap: onSearch),
      const SizedBox(width: 8),
      Stack(clipBehavior: Clip.none, children: [
        _HeaderButton(icon: Icons.notifications_outlined, onTap: onNotifications),
        if (unreadCount > 0)
          Positioned(
            right: 6,
            top: 5,
            child: Container(
              constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(99), border: Border.all(color: AppColors.background, width: 2)),
              child: Text('$unreadCount', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900)),
            ),
          ),
      ]),
      const SizedBox(width: 8),
      _HeaderButton(icon: Icons.person_outline_rounded, onTap: onProfile),
    ]);
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderButton({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 43,
        height: 43,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFDCE3E0)),
          boxShadow: const [BoxShadow(color: Color(0x0815352E), blurRadius: 12, offset: Offset(0, 5))],
        ),
        child: Icon(icon, color: AppColors.ink, size: 21),
      ),
    );
  }
}

class _RenewalHero extends StatelessWidget {
  final DocumentItem item;
  final VoidCallback onTap;
  const _RenewalHero({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF07584B), Color(0xFF08705C), Color(0xFF18A679)]),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(.20), blurRadius: 30, offset: const Offset(0, 15))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(children: [
          Positioned(right: -40, top: -55, child: Container(width: 190, height: 190, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(.08)))),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 18, 18),
            child: Row(children: [
              Expanded(
                flex: 6,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(.12), borderRadius: BorderRadius.circular(999)),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.schedule_outlined, color: Color(0xFFFFE2A5), size: 16),
                      SizedBox(width: 6),
                      Text('Next renewal', style: TextStyle(color: Color(0xFFFFF1D0), fontSize: 11.5, fontWeight: FontWeight.w800)),
                    ]),
                  ),
                  const Spacer(),
                  Text(item.title, maxLines: 2, style: const TextStyle(color: Colors.white, fontSize: 22, height: 1.05, fontWeight: FontWeight.w900, letterSpacing: -.5)),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.calendar_month_outlined, size: 16, color: Color(0xFFD0E4DE)),
                    const SizedBox(width: 6),
                    Flexible(child: Text('${item.expiry}  •  ${item.daysText}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withOpacity(.78), fontSize: 12, fontWeight: FontWeight.w600))),
                  ]),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 42,
                    child: FilledButton.icon(
                      onPressed: onTap,
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFFF8F7F1), foregroundColor: AppColors.primaryDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                      iconAlignment: IconAlignment.end,
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: const Text('View reminder', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                    ),
                  ),
                ]),
              ),
              const SizedBox(width: 10),
              const Expanded(flex: 4, child: _InsuranceVisual()),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _InsuranceVisual extends StatelessWidget {
  const _InsuranceVisual();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [
        Container(width: 118, height: 118, decoration: BoxDecoration(color: Colors.white.withOpacity(.07), shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(.10)))),
        Transform.rotate(
          angle: -.035,
          child: Container(
            width: 100,
            height: 126,
            padding: const EdgeInsets.fromLTRB(13, 14, 13, 12),
            decoration: BoxDecoration(color: const Color(0xFFF8FCFA), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE0EBE7)), boxShadow: const [BoxShadow(color: Color(0x24142E27), blurRadius: 18, offset: Offset(0, 9))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 30, height: 30, decoration: BoxDecoration(color: AppColors.mintSoft, borderRadius: BorderRadius.circular(9)), child: const Icon(Icons.policy_outlined, size: 17, color: AppColors.primary)),
                const Spacer(),
                const Icon(Icons.verified_user_outlined, size: 19, color: AppColors.primary),
              ]),
              const Spacer(),
              const Text('DOCUMENT', style: TextStyle(color: AppColors.ink, fontSize: 8.5, letterSpacing: 1.1, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Container(width: 68, height: 4, decoration: BoxDecoration(color: const Color(0xFFBDD2CC), borderRadius: BorderRadius.circular(999))),
              const SizedBox(height: 6),
              Container(width: 49, height: 4, decoration: BoxDecoration(color: const Color(0xFFD8E5E1), borderRadius: BorderRadius.circular(999))),
            ]),
          ),
        ),
        Positioned(right: 2, bottom: 7, child: Container(width: 42, height: 42, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(13), border: Border.all(color: const Color(0xFFF8F7F1), width: 4)), child: const Icon(Icons.check_rounded, color: Colors.white, size: 22))),
      ]),
    );
  }
}

class _QuickStats extends StatelessWidget {
  final int total;
  final int expiring;
  final int expired;
  final int valid;
  final VoidCallback onAll;
  final VoidCallback onExpiring;
  final VoidCallback onExpired;
  final VoidCallback onValid;
  const _QuickStats({required this.total, required this.expiring, required this.expired, required this.valid, required this.onAll, required this.onExpiring, required this.onExpired, required this.onValid});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: _StatTile(value: '$total', label: 'Documents', icon: Icons.folder_outlined, tone: AppColors.blue, soft: AppColors.blueSoft, onTap: onAll)),
      const SizedBox(width: 8),
      Expanded(child: _StatTile(value: '$expiring', label: 'Expiring', icon: Icons.schedule_outlined, tone: AppColors.amber, soft: AppColors.amberSoft, onTap: onExpiring)),
      const SizedBox(width: 8),
      Expanded(child: _StatTile(value: '$expired', label: 'Expired', icon: Icons.error_outline_rounded, tone: AppColors.danger, soft: AppColors.dangerSoft, onTap: onExpired)),
      const SizedBox(width: 8),
      Expanded(child: _StatTile(value: '$valid', label: 'Up to date', icon: Icons.verified_outlined, tone: AppColors.primary, soft: AppColors.mintSoft, onTap: onValid)),
    ]);
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color tone;
  final Color soft;
  final VoidCallback onTap;
  const _StatTile({required this.value, required this.label, required this.icon, required this.tone, required this.soft, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: 112,
        padding: const EdgeInsets.fromLTRB(11, 12, 8, 10),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.line), boxShadow: const [BoxShadow(color: Color(0x0B15352E), blurRadius: 18, offset: Offset(0, 8))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 34, height: 34, decoration: BoxDecoration(color: soft.withOpacity(.72), borderRadius: BorderRadius.circular(10), border: Border.all(color: tone.withOpacity(.12))), child: Icon(icon, size: 18, color: tone)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 20, height: 1, fontWeight: FontWeight.w900, color: AppColors.ink)),
          const SizedBox(height: 5),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.muted, fontSize: 9.8, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String action;
  final VoidCallback onTap;
  const _SectionHeader({required this.title, required this.subtitle, required this.action, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: AppColors.ink, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -.35)),
        const SizedBox(height: 3),
        Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 11.5, fontWeight: FontWeight.w500)),
      ])),
      TextButton.icon(
        onPressed: onTap,
        style: TextButton.styleFrom(foregroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5)),
        label: Text(action, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900)),
        icon: const Icon(Icons.arrow_forward_rounded, size: 16),
        iconAlignment: IconAlignment.end,
      ),
    ]);
  }
}

class _RecentDocumentCard extends StatelessWidget {
  final DocumentItem item;
  final VoidCallback onTap;
  const _RecentDocumentCard({required this.item, required this.onTap});
  Color get soft => item.status == 'Expired' ? AppColors.dangerSoft : item.status == 'Expiring soon' ? AppColors.amberSoft : item.accent == AppColors.blue ? AppColors.blueSoft : AppColors.mintSoft;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.line)),
        child: Row(children: [
          Container(width: 56, height: 64, decoration: BoxDecoration(color: soft.withOpacity(.72), borderRadius: BorderRadius.circular(14), border: Border.all(color: item.accent.withOpacity(.12))), child: Icon(item.icon, color: item.accent, size: 25)),
          const SizedBox(width: 11),
          Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.ink, fontSize: 13, height: 1.15, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text(item.type, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.muted, fontSize: 10.5, fontWeight: FontWeight.w600)),
            const SizedBox(height: 5),
            Text(item.daysText, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: item.accent, fontSize: 10, fontWeight: FontWeight.w800)),
          ])),
          const Icon(Icons.arrow_forward_ios_rounded, size: 15, color: AppColors.muted),
        ]),
      ),
    );
  }
}

class _MiniEmpty extends StatelessWidget {
  final String message;
  const _MiniEmpty({required this.message});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.line)),
    child: Row(children: [
      const Icon(Icons.check_circle_outline_rounded, color: AppColors.primary),
      const SizedBox(width: 10),
      Expanded(child: Text(message, style: const TextStyle(color: AppColors.muted, fontSize: 11.5, fontWeight: FontWeight.w600))),
    ]),
  );
}

class _NoDocumentsHero extends StatelessWidget {
  const _NoDocumentsHero();
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(color: AppColors.mintSoft, borderRadius: BorderRadius.circular(28), border: Border.all(color: AppColors.mint)),
    child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(Icons.folder_open_outlined, color: AppColors.primary, size: 34),
      SizedBox(height: 12),
      Text('No documents yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
      SizedBox(height: 5),
      Text('Use the Add button below to save your first document.', style: TextStyle(color: AppColors.muted, fontSize: 11.5)),
    ]),
  );
}
