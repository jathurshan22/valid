import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/document_item.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

class AppAlert {
  final String id;
  final String title;
  final String subtitle;
  final String? documentId;
  final DateTime createdAt;
  bool isRead;

  AppAlert({
    required this.id,
    required this.title,
    required this.subtitle,
    this.documentId,
    required this.createdAt,
    this.isRead = false,
  });
}

class AppStore extends ChangeNotifier {
  AppStore._();
  static final AppStore instance = AppStore._();

  final List<DocumentItem> _documents = [];
  final List<AppAlert> _alerts = [];

  String profileName = 'Valid user';
  String profileEmail = '';
  bool expiryNotifications = true;
  bool haptics = true;
  String defaultReminder = '30 days before';
  String appearance = 'Light';
  DateTime? lastBackupAt;
  bool documentsLoading = false;
  bool accountLoading = false;
  String? syncError;

  List<DocumentItem> get documents => List.unmodifiable(_documents);
  List<AppAlert> get alerts => List.unmodifiable(_alerts);

  int get unreadAlertCount => _alerts.where((a) => !a.isRead).length;
  int get expiringCount =>
      _documents.where((d) => d.status == 'Expiring soon').length;
  int get expiredCount =>
      _documents.where((d) => d.status == 'Expired').length;
  int get validCount => _documents.where((d) => d.status == 'Valid').length;

  DocumentItem? byId(String id) {
    for (final item in _documents) {
      if (item.id == id) return item;
    }
    return null;
  }

  Future<void> initializeForCurrentUser({String? registrationName}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      clearForLogout();
      return;
    }

    accountLoading = true;
    documentsLoading = true;
    syncError = null;
    notifyListeners();

    try {
      await FirestoreService.ensureUserProfile(name: registrationName);
      final userData = await FirestoreService.getUserData();
      final settings = userData['settings'];

      profileName = (userData['name']?.toString().trim().isNotEmpty == true)
          ? userData['name'].toString()
          : (user.displayName?.trim().isNotEmpty == true
              ? user.displayName!.trim()
              : 'Valid user');
      profileEmail = user.email ?? userData['email']?.toString() ?? '';

      if (settings is Map) {
        expiryNotifications = settings['expiryNotifications'] is bool
            ? settings['expiryNotifications'] as bool
            : true;
        haptics = settings['haptics'] is bool
            ? settings['haptics'] as bool
            : true;
        defaultReminder =
            settings['defaultReminder']?.toString() ?? '30 days before';
        appearance = settings['appearance']?.toString() ?? 'Light';
      }

      final cloudDocuments = await FirestoreService.getDocuments();
      _documents
        ..clear()
        ..addAll(cloudDocuments.map((d) => d.recompute()));
      _rebuildAlerts();
      lastBackupAt = DateTime.now();

      if (expiryNotifications) {
        await NotificationService.requestPermission();
        await NotificationService.scheduleAll(_documents);
      } else {
        await NotificationService.cancelAll();
      }
    } catch (e) {
      syncError = e.toString();
    } finally {
      accountLoading = false;
      documentsLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshFromCloud() => initializeForCurrentUser();

  Future<void> addDocument(DocumentItem item) async {
    final fresh = item.recompute();
    await FirestoreService.addDocument(fresh);
    _documents.insert(0, fresh);
    _rebuildAlerts();
    if (expiryNotifications) {
      await NotificationService.scheduleDocumentReminder(fresh);
    }
    lastBackupAt = DateTime.now();
    if (haptics) unawaited(HapticFeedback.mediumImpact());
    notifyListeners();
  }

  Future<void> updateDocument(DocumentItem item) async {
    final fresh = item.recompute();
    await FirestoreService.updateDocument(fresh);
    final index = _documents.indexWhere((d) => d.id == fresh.id);
    if (index >= 0) {
      _documents[index] = fresh;
    } else {
      _documents.insert(0, fresh);
    }
    _rebuildAlerts();
    if (expiryNotifications) {
      await NotificationService.scheduleDocumentReminder(fresh);
    } else {
      await NotificationService.cancelDocumentReminder(fresh.id);
    }
    lastBackupAt = DateTime.now();
    if (haptics) unawaited(HapticFeedback.selectionClick());
    notifyListeners();
  }

  Future<void> deleteDocument(String id) async {
    await FirestoreService.deleteDocument(id);
    await NotificationService.cancelDocumentReminder(id);
    _documents.removeWhere((d) => d.id == id);
    _rebuildAlerts();
    lastBackupAt = DateTime.now();
    if (haptics) unawaited(HapticFeedback.heavyImpact());
    notifyListeners();
  }

  void markAlertRead(String id) {
    final alert = _alerts.where((a) => a.id == id).firstOrNull;
    if (alert == null || alert.isRead) return;
    alert.isRead = true;
    notifyListeners();
  }

  void markAllAlertsRead() {
    for (final alert in _alerts) {
      alert.isRead = true;
    }
    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    required String email,
  }) async {
    await FirestoreService.updateProfile(name: name, email: email);
    profileName = name.trim();
    profileEmail = email.trim();
    notifyListeners();
  }

  void setNotifications(bool value) {
    expiryNotifications = value;
    notifyListeners();
    unawaited(_saveSettingsAndNotifications());
  }

  void setHaptics(bool value) {
    haptics = value;
    notifyListeners();
    unawaited(_persistSettingsQuietly());
  }

  void setDefaultReminder(String value) {
    defaultReminder = value;
    notifyListeners();
    unawaited(_persistSettingsQuietly());
  }

  void setAppearance(String value) {
    appearance = value;
    notifyListeners();
    unawaited(_persistSettingsQuietly());
  }

  Future<void> _saveSettingsAndNotifications() async {
    try {
      await _persistSettings();
      if (expiryNotifications) {
        await NotificationService.requestPermission();
        await NotificationService.scheduleAll(_documents);
      } else {
        await NotificationService.cancelAll();
      }
    } catch (_) {}
  }


  Future<void> _persistSettingsQuietly() async {
    try {
      await _persistSettings();
    } catch (e) {
      syncError = e.toString();
      notifyListeners();
    }
  }

  Future<void> _persistSettings() async {
    await FirestoreService.updateSettings(
      expiryNotifications: expiryNotifications,
      haptics: haptics,
      defaultReminder: defaultReminder,
      appearance: appearance,
    );
  }

  void clearForLogout() {
    _documents.clear();
    _alerts.clear();
    profileName = 'Valid user';
    profileEmail = '';
    expiryNotifications = true;
    haptics = true;
    defaultReminder = '30 days before';
    appearance = 'Light';
    lastBackupAt = null;
    syncError = null;
    accountLoading = false;
    documentsLoading = false;
    notifyListeners();
  }

  void _rebuildAlerts() {
    _alerts.clear();
    for (final document in _documents) {
      if (document.status == 'Expired') {
        _alerts.add(
          AppAlert(
            id: 'expired-${document.id}',
            title: '${document.title} has expired',
            subtitle: '${document.daysRemaining.abs()} days overdue. Renew it when possible.',
            documentId: document.id,
            createdAt: DateTime.now(),
          ),
        );
      } else if (document.status == 'Expiring soon') {
        _alerts.add(
          AppAlert(
            id: 'expiring-${document.id}',
            title: '${document.title} expires soon',
            subtitle: '${document.daysRemaining} days remaining. Reminder: ${document.reminder}.',
            documentId: document.id,
            createdAt: DateTime.now(),
          ),
        );
      }
    }
  }
}

extension FirstOrNullExtension<E> on Iterable<E> {
  E? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) return iterator.current;
    return null;
  }
}
