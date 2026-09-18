import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class TimerNotificationService {
  TimerNotificationService._();

  static final instance = TimerNotificationService._();
  static const _notificationId = 1;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    try {
      await _plugin.initialize(settings);
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.requestNotificationsPermission();
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, sound: true);
      _initialized = true;
    } catch (_) {
      // Timer functionality must remain available if notifications are denied.
    }
  }

  Future<void> schedule(DateTime endTime, {required bool soundEnabled}) async {
    await initialize();
    if (!_initialized) return;

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'focus_timer',
        'Focus timer',
        channelDescription: 'Notifications when a focus timer finishes',
        importance: Importance.high,
        priority: Priority.high,
        playSound: soundEnabled,
        sound: soundEnabled
          ? const RawResourceAndroidNotificationSound('notification')
          : null,
      ),
      iOS: DarwinNotificationDetails(
        presentSound: soundEnabled,
        sound: soundEnabled ? 'default' : null,
      ),
    );

    final duration = endTime.difference(DateTime.now());
    if (duration.isNegative || duration == Duration.zero) return;

    await _plugin.zonedSchedule(
      _notificationId,
      'Focus timer complete',
      'Your session is finished.',
      tz.TZDateTime.now(tz.local).add(duration),
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancel() async {
    await initialize();
    if (_initialized) await _plugin.cancel(_notificationId);
  }
}