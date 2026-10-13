import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DocumentItem {
  final String id;
  final String title;
  final String type;
  final String number;
  final String issueDate;
  final String expiry;
  final String reminder;
  final int daysRemaining;
  final String status;
  final IconData icon;
  final Color accent;
  final DateTime? createdAt;
  final String? photoPath;

  const DocumentItem({
    required this.id,
    required this.title,
    required this.type,
    required this.number,
    required this.issueDate,
    required this.expiry,
    required this.reminder,
    required this.daysRemaining,
    required this.status,
    required this.icon,
    required this.accent,
    this.createdAt,
    this.photoPath,
  });

  static const months = <String>[
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static DateTime? parseDisplayDate(String? value) {
    if (value == null) return null;
    final parts = value.trim().split(RegExp(r'\s+'));
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = months.indexOf(parts[1]) + 1;
    final year = int.tryParse(parts[2]);
    if (day == null || month <= 0 || year == null) return null;
    return DateTime(year, month, day);
  }

  static String formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';

  static DateTime _dayOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  DateTime get expiryDate =>
      parseDisplayDate(expiry) ?? DateTime.now();

  DateTime get issueDateValue =>
      parseDisplayDate(issueDate) ?? DateTime.now();

  int get reminderDays {
    final match = RegExp(r'\d+').firstMatch(reminder);
    return int.tryParse(match?.group(0) ?? '') ?? 30;
  }

  String get daysText {
    if (daysRemaining < 0) return '${daysRemaining.abs()} days overdue';
    if (daysRemaining == 0) return 'Expires today';
    if (daysRemaining == 1) return '1 day left';
    if (daysRemaining > 365) return '${(daysRemaining / 365).floor()} years left';
    return '$daysRemaining days left';
  }

  static int calculateDays(DateTime expiry, {DateTime? now}) {
    return _dayOnly(expiry).difference(_dayOnly(now ?? DateTime.now())).inDays;
  }

  static String calculateStatus(int days) {
    if (days < 0) return 'Expired';
    if (days <= 90) return 'Expiring soon';
    return 'Valid';
  }

  static IconData iconForType(String type) {
    switch (type) {
      case 'Licence':
        return Icons.badge_outlined;
      case 'Passport':
        return Icons.travel_explore_outlined;
      case 'Insurance':
        return Icons.policy_outlined;
      case 'Identity':
        return Icons.contact_page_outlined;
      case 'Certificate':
        return Icons.workspace_premium_outlined;
      default:
        return Icons.description_outlined;
    }
  }

  static Color accentFor(String type, String status) {
    if (status == 'Expired') return AppColors.danger;
    if (status == 'Expiring soon') return AppColors.amber;
    if (type == 'Identity') return AppColors.blue;
    return AppColors.primary;
  }

  factory DocumentItem.create({
    required String id,
    required String title,
    required String type,
    required String number,
    required DateTime issueDate,
    required DateTime expiryDate,
    required String reminder,
    DateTime? createdAt,
    String? photoPath,
  }) {
    final days = calculateDays(expiryDate);
    final status = calculateStatus(days);
    return DocumentItem(
      id: id,
      title: title,
      type: type,
      number: number,
      issueDate: formatDate(issueDate),
      expiry: formatDate(expiryDate),
      reminder: reminder,
      daysRemaining: days,
      status: status,
      icon: iconForType(type),
      accent: accentFor(type, status),
      createdAt: createdAt ?? DateTime.now(),
      photoPath: photoPath,
    );
  }

  factory DocumentItem.fromFirestore(String id, Map<String, dynamic> data) {
    DateTime readDate(String timestampKey, String legacyKey) {
      final rawTimestamp = data[timestampKey];
      if (rawTimestamp is Timestamp) return rawTimestamp.toDate();
      if (rawTimestamp is DateTime) return rawTimestamp;
      final legacy = data[legacyKey]?.toString();
      return parseDisplayDate(legacy) ?? DateTime.now();
    }

    final type = data['type']?.toString() ?? 'Other';
    final issue = readDate('issueDateValue', 'issueDate');
    final expiry = readDate('expiryDate', 'expiry');
    final days = calculateDays(expiry);
    final status = calculateStatus(days);
    final createdRaw = data['createdAt'];
    final createdAt = createdRaw is Timestamp
        ? createdRaw.toDate()
        : (createdRaw is DateTime ? createdRaw : DateTime.now());

    return DocumentItem(
      id: id,
      title: data['title']?.toString() ?? 'Untitled document',
      type: type,
      number: data['number']?.toString() ?? '',
      issueDate: formatDate(issue),
      expiry: formatDate(expiry),
      reminder: data['reminder']?.toString() ?? '30 days before',
      daysRemaining: days,
      status: status,
      icon: iconForType(type),
      accent: accentFor(type, status),
      createdAt: createdAt,
      photoPath: null,
    );
  }

  Map<String, dynamic> toFirestore({required bool isNew}) {
    final data = <String, dynamic>{
      'title': title,
      'type': type,
      'number': number,
      'issueDate': issueDate,
      'issueDateValue': Timestamp.fromDate(issueDateValue),
      'expiry': expiry,
      'expiryDate': Timestamp.fromDate(expiryDate),
      'reminder': reminder,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (isNew) {
      data['createdAt'] = Timestamp.fromDate(createdAt ?? DateTime.now());
    }
    return data;
  }

  DocumentItem recompute() {
    final date = expiryDate;
    final days = calculateDays(date);
    final newStatus = calculateStatus(days);
    return copyWith(
      daysRemaining: days,
      status: newStatus,
      accent: accentFor(type, newStatus),
      icon: iconForType(type),
    );
  }

  DocumentItem copyWith({
    String? id,
    String? title,
    String? type,
    String? number,
    String? issueDate,
    String? expiry,
    String? reminder,
    int? daysRemaining,
    String? status,
    IconData? icon,
    Color? accent,
    DateTime? createdAt,
    String? photoPath,
  }) {
    return DocumentItem(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      number: number ?? this.number,
      issueDate: issueDate ?? this.issueDate,
      expiry: expiry ?? this.expiry,
      reminder: reminder ?? this.reminder,
      daysRemaining: daysRemaining ?? this.daysRemaining,
      status: status ?? this.status,
      icon: icon ?? this.icon,
      accent: accent ?? this.accent,
      createdAt: createdAt ?? this.createdAt,
      photoPath: photoPath ?? this.photoPath,
    );
  }
}
