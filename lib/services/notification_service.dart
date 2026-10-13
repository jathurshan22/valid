import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/document_item.dart';

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  static Future<void> initialize() async {
    try {
      tz.initializeTimeZones();
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));

      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwin = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const settings = InitializationSettings(
        android: android,
        iOS: darwin,
        macOS: darwin,
      );
      await _plugin.initialize(settings: settings);
      _ready = true;
    } catch (e) {
      debugPrint('Notification initialization skipped: $e');
    }
  }

  static Future<bool> requestPermission() async {
    if (!_ready) return false;
    bool granted = true;
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final androidResult = await android?.requestNotificationsPermission();
    if (androidResult != null) granted = granted && androidResult;

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final iosResult = await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    if (iosResult != null) granted = granted && iosResult;
    return granted;
  }

  static int _idFor(String documentId) {
    var hash = 0;
    for (final unit in documentId.codeUnits) {
      hash = ((hash * 31) + unit) & 0x7fffffff;
    }
    return hash;
  }

  static Future<void> scheduleDocumentReminder(DocumentItem document) async {
    if (!_ready) return;
    await cancelDocumentReminder(document.id);

    final reminderDate = document.expiryDate.subtract(
      Duration(days: document.reminderDays),
    );
    final scheduled = tz.TZDateTime(
      tz.local,
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
      9,
    );
    if (!scheduled.isAfter(tz.TZDateTime.now(tz.local))) return;

    await _plugin.zonedSchedule(
      id: _idFor(document.id),
      title: '${document.title} expires soon',
      body:
          '${document.title} expires in ${document.reminderDays} days on ${document.expiry}.',
      scheduledDate: scheduled,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'document_expiry_reminders',
          'Document expiry reminders',
          channelDescription: 'Reminders for upcoming document expiry dates',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: document.id,
    );
  }

  static Future<void> scheduleAll(List<DocumentItem> documents) async {
    if (!_ready) return;
    for (final document in documents) {
      await scheduleDocumentReminder(document);
    }
  }

  static Future<void> cancelDocumentReminder(String documentId) async {
    if (!_ready) return;
    await _plugin.cancel(id: _idFor(documentId));
  }

  static Future<void> cancelAll() async {
    if (!_ready) return;
    await _plugin.cancelAll();
  }

  static Future<void> showTestNotification() async {
    if (!_ready) return;
    await _plugin.show(
      id: 999999,
      title: 'Valid reminder',
      body: 'Notifications are working correctly.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'document_expiry_reminders',
          'Document expiry reminders',
          channelDescription: 'Reminders for upcoming document expiry dates',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
    );
  }
}
