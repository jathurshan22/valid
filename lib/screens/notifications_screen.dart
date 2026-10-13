import 'package:flutter/material.dart';
import '../data/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/app_motion.dart';
import 'reminder_details_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  String _timeLabel(DateTime time) {
    final d = DateTime.now().difference(time);
    if (d.inMinutes < 60) return '${d.inMinutes.clamp(1, 59)} min ago';
    if (d.inHours < 24) return '${d.inHours} hr ago';
    return '${d.inDays} day${d.inDays == 1 ? '' : 's'} ago';
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
        title: const Text('Notifications', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
        actions: [
          TextButton(
            onPressed: AppStore.instance.markAllAlertsRead,
            child: const Text('Mark all read', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedBuilder(
        animation: AppStore.instance,
        builder: (context, _) {
          final alerts = AppStore.instance.alerts;
          if (alerts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none_rounded, size: 50, color: AppColors.muted),
                  SizedBox(height: 12),
                  Text('You are all caught up', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
            itemCount: alerts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final alert = alerts[index];
              final doc = alert.documentId == null ? null : AppStore.instance.byId(alert.documentId!);
              return PageEntrance(
                delay: index * 45,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () async {
                      AppStore.instance.markAlertRead(alert.id);
                      if (doc != null) {
                        await openAppPage(context, ReminderDetailsScreen(documentId: doc.id));
                      }
                    },
                    child: Ink(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: alert.isRead ? AppColors.surface : AppColors.mintSoft,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: alert.isRead ? AppColors.line : AppColors.mint),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: alert.isRead ? AppColors.background : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.notifications_active_outlined, color: AppColors.primary, size: 21),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: Text(alert.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900))),
                                    if (!alert.isRead)
                                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(alert.subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 11, height: 1.4)),
                                const SizedBox(height: 8),
                                Text(_timeLabel(alert.createdAt), style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                          if (doc != null) const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
