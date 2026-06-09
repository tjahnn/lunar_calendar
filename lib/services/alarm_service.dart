import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../database/app_database.dart';

class AlarmService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static const _channelId = 'lunar_calendar_alarms';
  static const _channelName = '일정 알람';

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    final tzName = await const MethodChannel('app/timezone')
            .invokeMethod<String>('getLocalTimezone') ?? 'UTC';
    tz.setLocalLocation(tz.getLocation(tzName));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    final android = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: '음력 달력 일정 알람',
        importance: Importance.high,
      ),
    );
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();
  }

  static Future<void> schedule(Schedule s) async {
    if (s.alarmTime == null) return;
    final parts = s.alarmTime!.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final targetDate = _nextOccurrence(s, hour, minute);
    if (targetDate == null) return;

    final scheduledTime = tz.TZDateTime(
      tz.local,
      targetDate.year, targetDate.month, targetDate.day,
      hour, minute,
    );
    if (scheduledTime.isBefore(tz.TZDateTime.now(tz.local))) return;

    try {
      await _plugin.zonedSchedule(
        s.id,
        s.title,
        s.description ?? '${targetDate.month}월 ${targetDate.day}일 일정',
        scheduledTime,
        NotificationDetails(
          android: const AndroidNotificationDetails(
            _channelId,
            _channelName,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('[AlarmService] schedule failed: $e');
    }
  }

  static Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  static Future<void> rescheduleAll(List<Schedule> schedules) async {
    await _plugin.cancelAll();
    for (final s in schedules) {
      await schedule(s);
    }
  }

  // 오늘 이후 최초 알람 날짜 반환
  static DateTime? _nextOccurrence(Schedule s, int hour, int minute) {
    final now = DateTime.now();
    final base = s.date;

    if (s.repeatType == 'none') {
      final alarmDt = DateTime(base.year, base.month, base.day, hour, minute);
      return alarmDt.isAfter(now) ? base : null;
    }

    // 반복 일정: 오늘 이후 최초 발생일 탐색 (최대 400일)
    for (int i = 0; i <= 400; i++) {
      final candidate = now.add(Duration(days: i));
      final alarmDt = DateTime(
        candidate.year, candidate.month, candidate.day, hour, minute,
      );
      if (alarmDt.isAfter(now) &&
          AppDatabase.scheduleAppliesTo(
            s, candidate, candidate.month, candidate.day,
          )) {
        return candidate;
      }
    }
    return null;
  }
}
