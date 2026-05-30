import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const _androidChannelId = 'expense_tracker_channel';
  static const _androidChannelName = 'Expense Tracker';
  static const _androidChannelDesc = 'Notifications for budget alerts and reminders';

  static Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onTap,
    );

    await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(const AndroidNotificationChannel(
        _androidChannelId, _androidChannelName,
        description: _androidChannelDesc,
        importance: Importance.high,
      ));

    await _setupFirebaseMessaging();
    _initialized = true;
  }

  static Future<void> _setupFirebaseMessaging() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission(alert: true, badge: true, sound: true);
    FirebaseMessaging.onMessage.listen((msg) {
      final n = msg.notification;
      if (n != null) {
        show(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: n.title ?? 'Expense Tracker',
          body: n.body ?? '',
        );
      }
    });
  }

  static void _onTap(NotificationResponse response) {
    // Navigate based on payload
  }

  static AndroidNotificationDetails get _android => const AndroidNotificationDetails(
    _androidChannelId, _androidChannelName,
    channelDescription: _androidChannelDesc,
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
    color: Color(0xFF6C63FF),
  );

  static const DarwinNotificationDetails _ios = DarwinNotificationDetails(
    presentAlert: true, presentBadge: true, presentSound: true,
  );

  static Future<void> show({required int id, required String title, required String body, String? payload}) async {
    await _plugin.show(id, title, body, NotificationDetails(android: _android, iOS: _ios), payload: payload);
  }

  static Future<void> showBudgetWarning({required double percentage, required String currency, required double spent, required double budget}) async {
    final pct = (percentage * 100).toInt();
    await show(
      id: 1001,
      title: percentage >= 1 ? '🚨 Budget Exceeded!' : '⚠️ Budget Alert',
      body: percentage >= 1
        ? 'You\'ve spent $spent of your $budget budget ($pct%)'
        : 'You\'ve used $pct% of your monthly budget',
    );
  }

  static Future<void> scheduleDailyReminder({required int hour, required int minute}) async {
    await _plugin.zonedSchedule(
      2001,
      '💸 Daily Expense Reminder',
      'Don\'t forget to log your expenses today!',
      _nextInstanceOfTime(hour, minute),
      NotificationDetails(android: _android, iOS: _ios),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> scheduleWeeklySummary() async {
    await _plugin.zonedSchedule(
      3001,
      '📊 Weekly Summary Ready',
      'Your weekly spending report is available',
      _nextMonday(),
      NotificationDetails(android: _android, iOS: _ios),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) scheduled = scheduled.add(const Duration(days: 1));
    return scheduled;
  }

  static tz.TZDateTime _nextMonday() {
    final now = tz.TZDateTime.now(tz.local);
    var monday = now;
    while (monday.weekday != DateTime.monday) {
      monday = monday.add(const Duration(days: 1));
    }
    return tz.TZDateTime(tz.local, monday.year, monday.month, monday.day, 9, 0);
  }

  static Future<void> cancelAll() => _plugin.cancelAll();
  static Future<void> cancel(int id) => _plugin.cancel(id);
}
