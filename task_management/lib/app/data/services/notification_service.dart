import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _periodicChannelId = 'periodic_reminders';
  static const String _periodicChannelName = 'Periyodik Bakım Hatırlatıcıları';
  static const String _periodicChannelDescription =
      'Yaklaşan periyodik bakım, yağ değişimi, kira gibi rutinler için bildirimler.';

  static const String _routinesChannelId = 'daily_routines';
  static const String _routinesChannelName = 'Günlük Rutinler';
  static const String _routinesChannelDescription =
      'Uyku, uyanma ve günlük odağın için zamanlanmış hatırlatıcılar.';

  static const String _sleepReminderKey = 'sleep_reminder';
  static const int _sleepReminderWindowDays = 30;

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _periodicChannelId,
          _periodicChannelName,
          description: _periodicChannelDescription,
          importance: Importance.high,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _routinesChannelId,
          _routinesChannelName,
          description: _routinesChannelDescription,
          importance: Importance.high,
        ),
      );
    }
  }

  static Future<bool> ensurePermissions() async {
    if (kIsWeb) {
      return false;
    }

    if (Platform.isAndroid) {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidPlugin == null) {
        return false;
      }
      final granted = await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
      return granted ?? true;
    }

    if (Platform.isIOS) {
      final iosPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (iosPlugin == null) {
        return false;
      }
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return false;
  }

  static int notificationIdFor(dynamic key) {
    final str = key.toString();
    return str.hashCode & 0x7fffffff;
  }

  static Future<void> schedulePeriodicReminder({
    required dynamic key,
    required String title,
    required String body,
    required DateTime dueAt,
  }) async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      return;
    }

    await init();

    final id = notificationIdFor(key);
    await _plugin.cancel(id);

    final scheduled = _resolveScheduledTime(dueAt);
    if (scheduled == null) {
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      _periodicChannelId,
      _periodicChannelName,
      channelDescription: _periodicChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.reminder,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: null,
      );
    } on Exception {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: null,
      );
    }
  }

  static Future<void> cancelPeriodicReminder(dynamic key) async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      return;
    }
    await init();
    await _plugin.cancel(notificationIdFor(key));
  }

  static Future<void> scheduleSleepReminder({
    required int sleepHour,
    required int sleepMinute,
    required String title,
    required List<String> bodies,
    int minutesBefore = 15,
  }) async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      return;
    }
    if (bodies.isEmpty) {
      return;
    }

    await init();
    await cancelSleepReminder();

    const androidDetails = AndroidNotificationDetails(
      _routinesChannelId,
      _routinesChannelName,
      channelDescription: _routinesChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.reminder,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final location = tz.local;
    final now = tz.TZDateTime.now(location);

    for (var dayOffset = 0; dayOffset < _sleepReminderWindowDays; dayOffset++) {
      final base = tz.TZDateTime(
        location,
        now.year,
        now.month,
        now.day,
        sleepHour,
        sleepMinute,
      ).add(Duration(days: dayOffset));
      final fireAt = base.subtract(Duration(minutes: minutesBefore));
      if (!fireAt.isAfter(now)) {
        continue;
      }

      final id = notificationIdFor('${_sleepReminderKey}_day_$dayOffset');
      final body = bodies[dayOffset % bodies.length];

      try {
        await _plugin.zonedSchedule(
          id,
          title,
          body,
          fireAt,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } on Exception {
        await _plugin.zonedSchedule(
          id,
          title,
          body,
          fireAt,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }

  static Future<void> cancelSleepReminder() async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      return;
    }
    await init();
    await _plugin.cancel(notificationIdFor(_sleepReminderKey));
    for (var dayOffset = 0; dayOffset < _sleepReminderWindowDays; dayOffset++) {
      await _plugin.cancel(
        notificationIdFor('${_sleepReminderKey}_day_$dayOffset'),
      );
    }
  }

  static tz.TZDateTime? _resolveScheduledTime(DateTime dueAt) {
    final location = tz.local;
    final dueLocal = tz.TZDateTime.from(dueAt.toUtc(), location);
    final reminderAt = tz.TZDateTime(
      location,
      dueLocal.year,
      dueLocal.month,
      dueLocal.day,
      9,
    );

    if (reminderAt.isAfter(tz.TZDateTime.now(location))) {
      return reminderAt;
    }
    return null;
  }
}
