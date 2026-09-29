import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  int _notificationId(String medicineId, int type) {
    var hash = 0;
    for (final char in medicineId.codeUnits) {
      hash = (hash * 31 + char) & 0x7fffffff;
    }
    return hash + type;
  }

  Future<void> initialize() async {
    try {
      tz.initializeTimeZones();

      try {
        final timezone = await FlutterTimezone.getLocalTimezone();
        var locationName = timezone.identifier;
        if (locationName == 'Asia/Calcutta') {
          locationName = 'Asia/Kolkata';
        }
        tz.setLocalLocation(tz.getLocation(locationName));
      } catch (_) {
        try {
          tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
        } catch (_) {
          tz.setLocalLocation(tz.UTC);
        }
      }

      if (kIsWeb) {
        // Notifications initialization complete on web
        return;
      }

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
      );

      await _notifications.initialize(settings: settings);

      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      await androidPlugin?.requestNotificationsPermission();
      await androidPlugin?.requestExactAlarmsPermission();
    } catch (e) {
      debugPrint('NotificationService initialization note: $e');
    }
  }

  Future<void> scheduleExpiryReminder({
    required String medicineId,
    required String medicineName,
    required DateTime expiryDate,
  }) async {
    if (kIsWeb) return;

    try {
      await cancelExpiryReminder(medicineId);

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
      final daysUntilExpiry = expiry.difference(today).inDays;

      // 1. PRE-EXPIRY REMINDER
      DateTime? reminderDate;
      if (daysUntilExpiry > 7) {
        reminderDate = expiry.subtract(const Duration(days: 7));
      } else if (daysUntilExpiry >= 2) {
        reminderDate = expiry.subtract(const Duration(days: 1));
      } else if (daysUntilExpiry == 1) {
        reminderDate = today;
      }

      if (reminderDate != null) {
        final reminderAtNineAM = DateTime(
          reminderDate.year,
          reminderDate.month,
          reminderDate.day,
          9,
          0,
        );

        if (reminderAtNineAM.isAfter(now)) {
          final scheduledDate = tz.TZDateTime.from(
            reminderAtNineAM,
            tz.local,
          );

          await _notifications.zonedSchedule(
            id: _notificationId(medicineId, 0),
            title: 'Medicine Expiry Reminder',
            body: daysUntilExpiry == 1
                ? '$medicineName expires tomorrow.'
                : '$medicineName expires in $daysUntilExpiry days.',
            scheduledDate: scheduledDate,
            notificationDetails: const NotificationDetails(
              android: AndroidNotificationDetails(
                'medicine_expiry_channel',
                'Medicine Expiry Reminders',
                channelDescription: 'Notifications for upcoming medicine expiry dates.',
                importance: Importance.high,
                priority: Priority.high,
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          );
        }
      }

      // 2. EXPIRY DAY NOTIFICATION
      final expiryAtNineAM = DateTime(
        expiry.year,
        expiry.month,
        expiry.day,
        9,
        0,
      );

      if (expiryAtNineAM.isAfter(now)) {
        final scheduledDate = tz.TZDateTime.from(
          expiryAtNineAM,
          tz.local,
        );

        await _notifications.zonedSchedule(
          id: _notificationId(medicineId, 1),
          title: 'Medicine Expired',
          body: '$medicineName expires today.',
          scheduledDate: scheduledDate,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'medicine_expiry_channel',
              'Medicine Expiry Reminders',
              channelDescription: 'Notifications for upcoming medicine expiry dates.',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }

      // 3. DAILY REMINDER AFTER EXPIRY
      DateTime firstPostExpiryReminder = DateTime(
        expiry.year,
        expiry.month,
        expiry.day + 1,
        9,
        0,
      );

      if (!firstPostExpiryReminder.isAfter(now)) {
        firstPostExpiryReminder = DateTime(
          now.year,
          now.month,
          now.day + 1,
          9,
          0,
        );
      }

      final postExpiryDate = tz.TZDateTime.from(
        firstPostExpiryReminder,
        tz.local,
      );

      await _notifications.zonedSchedule(
        id: _notificationId(medicineId, 2),
        title: 'Medicine Needs Attention',
        body: '$medicineName has expired. Please discard it.',
        scheduledDate: postExpiryDate,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'medicine_expiry_channel',
            'Medicine Expiry Reminders',
            channelDescription: 'Notifications for upcoming medicine expiry dates.',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  Future<void> cancelExpiryReminder(String medicineId) async {
    if (kIsWeb) return;
    try {
      await _notifications.cancel(id: _notificationId(medicineId, 0));
      await _notifications.cancel(id: _notificationId(medicineId, 1));
      await _notifications.cancel(id: _notificationId(medicineId, 2));
    } catch (e) {
      debugPrint('Error canceling notification: $e');
    }
  }
}