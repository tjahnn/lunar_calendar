import '../database/app_database.dart';

// TODO: flutter_local_notifications, timezone 패키지 추가 후 구현
class AlarmService {
  static Future<void> initialize() async {}

  static Future<void> schedule(Schedule s) async {
    throw UnimplementedError('flutter_local_notifications 패키지 추가 필요');
  }

  static Future<void> cancel(int id) async {}

  static Future<void> rescheduleAll(List<Schedule> schedules) async {}
}
