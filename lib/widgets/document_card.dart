import 'package:flutter/material.dart';
import '../models/document_item.dart';
import '../screens/document_details_screen.dart';
import '../theme/app_theme.dart';
import 'app_motion.dart';

class DocumentCard extends StatelessWidget {
  final DocumentItem item;
  final int index;
  final bool compact;

  const DocumentCard({
    super.key,
    required this.item,
    this.index = 0,
    this.compact = false,
  });

  Color get softColor {
    if (item.status == 'Expired') return AppColors.dangerSoft;
    if (item.status == 'Expiring soon') return AppColors.amberSoft;
    if (item.accent == AppColors.blue) return AppColors.blueSoft;
    return AppColors.mintSoft;
  }

  String get statusLabel {
    if (item.status == 'Expiring soon') return 'Due soon';
    return item.status;
  }

  Color get statusColor {
    if (item.status == 'Expired') return AppColors.danger;
    if (item.status == 'Expiring soon') return AppColors.amber;
    return item.accent;
  }

  IconData get statusIcon {
    if (item.status == 'Expired') return Icons.error_outline_rounded;
    if (item.status == 'Expiring soon') return Icons.schedule_rounded;
    return Icons.check_circle_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 55)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Transform.translate(
        offset: Offset(0, 10 * (1 - value)),
        child: Opacity(opacity: value, child: child),
      ),
      child: PressableScale(
        onTap: () => openAppPage(
          context,
          DocumentDetailsScreen(document: item),
        ),
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: Container(
          padding: EdgeInsets.all(compact ? 13 : 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(color: AppColors.line),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0B19352E),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'doc-${item.id}',
                    child: Container(
                      width: compact ? 46 : 52,
                      height: compact ? 46 : 52,
                      decoration: BoxDecoration(
                        color: softColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        item.icon,
                        color: statusColor,
                        size: compact ? 22 : 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15.5,
                            height: 1.15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${item.type} • No. ${item.number}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _StatusBadge(
                    label: statusLabel,
                    icon: statusIcon,
                    color: statusColor,
                    background: softColor,
                  ),
                ],
              ),
              if (!compact) ...[
                const SizedBox(height: 14),
                Container(height: 1, color: AppColors.line),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Expiry date',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.expiry,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: softColor,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                      child: Text(
                        item.daysText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 10.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF9AA7A2),
                      size: 21,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color background;

  const _StatusBadge({
    required this.label,
    required this.icon,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
